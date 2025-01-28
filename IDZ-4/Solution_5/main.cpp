#include <unistd.h>

#include <atomic>
#include <ctime>
#include <fstream>
#include <iostream>
#include <string>

// Я не знаю будет ли у вас это работать?
// Из-за того что у меня Macbook, пришлось как-то так это реализовывать.
#include "/opt/homebrew/Cellar/libomp/19.1.5/include/omp.h"

const int NUM_PHILOSOPHERS = 5;
std::atomic<bool> program_running(true);

std::ofstream output_file;
bool use_file_output = false;

struct Config {
  int minThink;
  int maxThink;
  int minEat;
  int maxEat;
  int simulationTime;
};

Config config;

void safe_print(const std::string &message) {
#pragma omp critical
  {
    std::cout << message << std::endl;
    if (use_file_output && output_file.is_open()) {
      output_file << message << std::endl;
    }
  }
}

int getRandomTime(int min_val, int max_val) {
  return min_val + (rand() % (max_val - min_val + 1));
}

bool validateConfig(const Config &c) {
  if (c.simulationTime < 10 || c.simulationTime > 100 || c.minThink < 1 ||
      c.minThink > 10 || c.maxThink < 1 || c.maxThink > 10 ||
      c.minThink > c.maxThink || c.minEat < 1 || c.minEat > 10 ||
      c.maxEat < 1 || c.maxEat > 10 || c.minEat > c.maxEat) {
    return false;
  }
  return true;
}

bool readConfigFromFile(const std::string &filename, Config &c) {
  std::ifstream config_file(filename);
  if (!config_file.is_open()) {
    std::cerr << "Ошибка открытия конфигурационного файла\n";
    return false;
  }

  std::string line;
  while (std::getline(config_file, line)) {
    size_t eq_pos = line.find('=');
    if (eq_pos != std::string::npos) {
      std::string key = line.substr(0, eq_pos);
      int value = std::atoi(line.substr(eq_pos + 1).c_str());
      if (key == "minThink")
        c.minThink = value;
      else if (key == "maxThink")
        c.maxThink = value;
      else if (key == "minEat")
        c.minEat = value;
      else if (key == "maxEat")
        c.maxEat = value;
      else if (key == "simulationTime")
        c.simulationTime = value;
    }
  }
  config_file.close();
  return true;
}

void printUsage(const char *programName) {
  std::cerr
      << "Использование:\n"
      << "1. С параметрами командной строки:\n"
      << programName
      << " -c minThink maxThink minEat maxEat simulationTime output_file\n"
      << "2. С конфигурационным файлом:\n"
      << programName << " -f config_file output_file\n";
}

int main(int argc, char *argv[]) {
  if (argc < 3) {
    printUsage(argv[0]);
    return 1;
  }

  std::string mode = argv[1];
  if (mode == "-c" && argc == 8) {
    config.minThink = std::atoi(argv[2]);
    config.maxThink = std::atoi(argv[3]);
    config.minEat = std::atoi(argv[4]);
    config.maxEat = std::atoi(argv[5]);
    config.simulationTime = std::atoi(argv[6]);
    output_file.open(argv[7]);
    use_file_output = true;
  } else if (mode == "-f" && argc == 4) {
    if (!readConfigFromFile(argv[2], config)) {
      return 1;
    }
    output_file.open(argv[3]);
    use_file_output = true;
  } else {
    printUsage(argv[0]);
    return 1;
  }

  if (use_file_output && !output_file.is_open()) {
    std::cerr << "Ошибка открытия выходного файла\n";
    return 1;
  }

  if (!validateConfig(config)) {
    std::cerr << "Неправильные значения параметров\n";
    if (use_file_output) output_file.close();
    return 1;
  }

  srand((unsigned int)time(nullptr));

  // Инициализация замков для вилок
  omp_lock_t forks[NUM_PHILOSOPHERS];
  for (int i = 0; i < NUM_PHILOSOPHERS; i++) {
    omp_init_lock(&forks[i]);
  }

  safe_print("\nНачальная конфигурация:");
  safe_print("Время размышления: " + std::to_string(config.minThink) + "-" +
             std::to_string(config.maxThink) + " секунд");
  safe_print("Время приема пищи: " + std::to_string(config.minEat) + "-" +
             std::to_string(config.maxEat) + " секунд");
  safe_print("Время симуляции: " + std::to_string(config.simulationTime) +
             " секунд\n");

  // Мы запускаем NUM_PHILOSOPHERS+1 поток: последний поток – таймер
#pragma omp parallel num_threads(NUM_PHILOSOPHERS + 1)
  {
    int id = omp_get_thread_num();
    if (id < NUM_PHILOSOPHERS) {
      // Код философа
      while (program_running) {
        // Размышление
        int thinkTime = getRandomTime(config.minThink, config.maxThink);
        safe_print("Философ " + std::to_string(id) + " думает " +
                   std::to_string(thinkTime) + " секунд.");
        for (int i = 0; i < thinkTime && program_running; ++i) {
          sleep(1);
        }
        if (!program_running) break;

        safe_print("Философ " + std::to_string(id) + " проголодался.");

        int leftFork = id;
        int rightFork = (id + 1) % NUM_PHILOSOPHERS;
        int firstFork = std::min(leftFork, rightFork);
        int secondFork = std::max(leftFork, rightFork);

        // Берем первую вилку
        safe_print("Философ " + std::to_string(id) + " пытается взять вилку " +
                   std::to_string(firstFork) + ".");
        omp_set_lock(&forks[firstFork]);
        if (!program_running) {
          omp_unset_lock(&forks[firstFork]);
          break;
        }

        // Берем вторую вилку
        safe_print("Философ " + std::to_string(id) + " пытается взять вилку " +
                   std::to_string(secondFork) + ".");
        omp_set_lock(&forks[secondFork]);
        if (!program_running) {
          omp_unset_lock(&forks[secondFork]);
          omp_unset_lock(&forks[firstFork]);
          break;
        }

        // Едим
        int eatTime = getRandomTime(config.minEat, config.maxEat);
        safe_print("Философ " + std::to_string(id) + " ест " +
                   std::to_string(eatTime) + " секунд.");
        for (int i = 0; i < eatTime && program_running; ++i) {
          sleep(1);
        }

        // Освобождаем вилки
        safe_print("Философ " + std::to_string(id) + " кладет вилки на стол.");
        omp_unset_lock(&forks[secondFork]);
        omp_unset_lock(&forks[firstFork]);
      }

    } else {
      // Таймерный поток
      sleep(config.simulationTime);
      // По истечении времени сигнал всем завершать
      program_running = false;
    }
  }

  safe_print("\nВремя работы программы истекло. Все потоки завершены.");
  safe_print("Программа завершена.");

  for (int i = 0; i < NUM_PHILOSOPHERS; i++) {
    omp_destroy_lock(&forks[i]);
  }

  if (use_file_output) {
    output_file.close();
  }

  return 0;
}
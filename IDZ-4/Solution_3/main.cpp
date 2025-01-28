#include <pthread.h>
#include <semaphore.h>
#include <unistd.h>

#include <atomic>
#include <cstdlib>
#include <ctime>
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>

// Количество философов
const int NUM_PHILOSOPHERS = 5;

// Флаг для завершения работы программы
std::atomic<bool> program_running(true);

// Глобальный мьютекс для вывода
pthread_mutex_t print_mutex = PTHREAD_MUTEX_INITIALIZER;
std::ofstream output_file;

// Структура для хранения конфигурации
struct Config {
  int minThink{};
  int maxThink{};
  int minEat{};
  int maxEat{};
  int simulationTime{};
};

// Функция для безопасного вывода
void safe_print(const std::string& message) {
  pthread_mutex_lock(&print_mutex);
  std::cout << message << std::endl;
  if (output_file.is_open()) {
    output_file << message << std::endl;
  }
  pthread_mutex_unlock(&print_mutex);
}

// Структура для передачи параметров в поток
struct PhilosopherArgs {
  int id_;
  sem_t* forks_;
  sem_t* stopper_;
  int minThink_;
  int maxThink_;
  int minEat_;
  int maxEat_;
};

// Функция для получения случайного времени в заданном диапазоне
int getRandomTime(int min_val, int max_val) {
  return min_val + (rand() % (max_val - min_val + 1));
}

// Функция для проверки корректности параметров
bool validateConfig(const Config& config) {
  return !(config.simulationTime < 10 || config.simulationTime > 100 ||
           config.minThink < 1 || config.minThink > 10 || config.maxThink < 1 ||
           config.maxThink > 10 || config.minThink > config.maxThink ||
           config.minEat < 1 || config.minEat > 10 || config.maxEat < 1 ||
           config.maxEat > 10 || config.minEat > config.maxEat);
}

// Функция для чтения конфигурации из файла
bool readConfigFromFile(const std::string& filename, Config& config) {
  std::ifstream config_file(filename);
  if (!config_file.is_open()) {
    std::cerr << "Ошибка открытия файла конфигурации\n";
    return false;
  }
  std::string line;
  while (std::getline(config_file, line)) {
    std::istringstream iss(line);
    std::string key;
    if (std::getline(iss, key, '=')) {
      int value;
      if (iss >> value) {
        if (key == "minThink")
          config.minThink = value;
        else if (key == "maxThink")
          config.maxThink = value;
        else if (key == "minEat")
          config.minEat = value;
        else if (key == "maxEat")
          config.maxEat = value;
        else if (key == "simulationTime")
          config.simulationTime = value;
      }
    }
  }
  return true;
}

void printUsage(const char* programName) {
  std::cerr
      << "Использование:\n"
      << "1. С параметрами командной строки:\n"
      << programName
      << " -c minThink maxThink minEat maxEat simulationTime output_file\n"
      << "2. С конфигурационным файлом:\n"
      << programName << " -f config_file output_file\n";
}

// Функция потока для каждого философа
void* philosopher(void* arg) {
  auto* p = (PhilosopherArgs*)arg;
  int leftFork = p->id_;
  int rightFork = (p->id_ + 1) % NUM_PHILOSOPHERS;
  while (program_running) {
    // Философ размышляет
    int thinkTime = getRandomTime(p->minThink_, p->maxThink_);
    safe_print("Философ " + std::to_string(p->id_) + " думает в течение " +
               std::to_string(thinkTime) + " секунд.");

    // Проверяем флаг во время сна
    for (int i = 0; i < thinkTime && program_running; ++i) {
      sleep(1);
    }
    if (!program_running) break;

    // Философ голоден и запрашивает у блокировщика разрешения
    safe_print("Философ " + std::to_string(p->id_) +
               " голоден и ждет разрешения брать вилки.");
    sem_wait(p->stopper_);  // Запрос разрешения

    if (!program_running) {
      sem_post(p->stopper_);
      break;
    }

    // Берёт левую вилку
    safe_print("Философ " + std::to_string(p->id_) +
               " пытается взять левую вилку " + std::to_string(leftFork) + ".");
    sem_wait(&(p->forks_[leftFork]));

    if (!program_running) {
      sem_post(&(p->forks_[leftFork]));
      sem_post(p->stopper_);
      break;
    }

    // Берёт правую вилку
    safe_print("Философ " + std::to_string(p->id_) +
               " пытается взять правую вилку " + std::to_string(rightFork) +
               ".");
    sem_wait(&(p->forks_[rightFork]));

    // Начинает есть
    int eat_time = getRandomTime(p->minEat_, p->maxEat_);
    safe_print("Философ " + std::to_string(p->id_) + " ест в течение " +
               std::to_string(eat_time) + " секунд.");

    // Проверяем флаг во время еды
    for (int i = 0; i < eat_time && program_running; ++i) {
      sleep(1);
    }

    // Закончил есть
    safe_print("Философ " + std::to_string(p->id_) +
               " закончил есть и кладет вилки назад на стол.");
    sem_post(&(p->forks_[rightFork]));
    sem_post(&(p->forks_[leftFork]));

    // Освобождает блокировщик
    sem_post(p->stopper_);
  }
  return nullptr;
}

int main(int argc, char* argv[]) {
  if (argc < 3) {
    printUsage(argv[0]);
    return 1;
  }

  std::string mode = argv[1];
  Config config;

  // Проверяем режим работы программы
  if (mode == "-c" && argc == 8) {
    // Режим командной строки
    config.minThink = std::atoi(argv[2]);
    config.maxThink = std::atoi(argv[3]);
    config.minEat = std::atoi(argv[4]);
    config.maxEat = std::atoi(argv[5]);
    config.simulationTime = std::atoi(argv[6]);
    output_file.open(argv[7]);
  } else if (mode == "-f" && argc == 4) {
    // Режим конфигурационного файла
    if (!readConfigFromFile(argv[2], config)) {
      return 1;
    }
    output_file.open(argv[3]);
  } else {
    printUsage(argv[0]);
    return 1;
  }

  if (!output_file.is_open()) {
    std::cerr << "Ошибка открытия выходного файла\n";
    return 1;
  }

  if (!validateConfig(config)) {
    std::cerr << "Неправильные значения параметров\n";
    output_file.close();
    return 1;
  }

  // Инициализация генератора случайных чисел
  srand((unsigned int)time(nullptr));

  // Создаём массив семафоров для вилок
  auto* forks = new sem_t[NUM_PHILOSOPHERS];
  for (int i = 0; i < NUM_PHILOSOPHERS; ++i) {
    sem_init(&forks[i], 0, 1);
  }

  // Создаём семафор блокировщиков
  sem_t stopper;
  sem_init(&stopper, 0, NUM_PHILOSOPHERS - 1);

  // Создаём потоки для философов
  pthread_t threads[NUM_PHILOSOPHERS];
  PhilosopherArgs args[NUM_PHILOSOPHERS];

  // Записываем начальную конфигурацию в файл
  safe_print("\nНачальная конфигурация:");
  safe_print("Время размышления: " + std::to_string(config.minThink) + "-" +
             std::to_string(config.maxThink) + " секунд");
  safe_print("Время приема пищи: " + std::to_string(config.minEat) + "-" +
             std::to_string(config.maxEat) + " секунд");
  safe_print("Время симуляции: " + std::to_string(config.simulationTime) +
             " секунд\n");

  for (int i = 0; i < NUM_PHILOSOPHERS; i++) {
    args[i].id_ = i;
    args[i].forks_ = forks;
    args[i].stopper_ = &stopper;
    args[i].minThink_ = config.minThink;
    args[i].maxThink_ = config.maxThink;
    args[i].minEat_ = config.minEat;
    args[i].maxEat_ = config.maxEat;
    pthread_create(&threads[i], nullptr, philosopher, &args[i]);
  }

  sleep(config.simulationTime);
  program_running = false;
  safe_print(
      "\nВремя работы программы истекло. Ожидание завершения потоков...");

  // Ожидание завершения всех потоков
  for (auto& thread : threads) {
    pthread_join(thread, nullptr);
  }

  // Очистка
  for (int i = 0; i < NUM_PHILOSOPHERS; ++i) {
    sem_destroy(&forks[i]);
  }
  delete[] forks;
  sem_destroy(&stopper);

  safe_print("Программа завершена.");
  output_file.close();
  return 0;
}
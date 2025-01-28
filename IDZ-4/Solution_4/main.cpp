#include <pthread.h>
#include <unistd.h>

#include <atomic>
#include <cstdlib>
#include <ctime>
#include <fstream>
#include <iostream>
#include <mutex>
#include <sstream>
#include <string>
#include <vector>

// Количество философов
const int NUM_PHILOSOPHERS = 5;

// Флаг для завершения работы программы
std::atomic<bool> program_running(true);

// Мьютекс для вывода
std::mutex print_mutex;
std::ofstream output_file;

// Структура для хранения конфигурации
struct Config {
  int minThink{};
  int maxThink{};
  int minEat{};
  int maxEat{};
  int simulationTime{};
};

// Класс наблюдателя для управления вилками
class ForkObserver {
 private:
  std::vector<bool> forks;  // true - вилка свободна
  std::vector<std::condition_variable> fork_cv;
  std::mutex observer_mutex;
  std::vector<bool> philosophers_eating;

 public:
  explicit ForkObserver(int num_philosophers)
      : forks(num_philosophers, true),
        fork_cv(num_philosophers),
        philosophers_eating(num_philosophers, false) {}

  bool tryTakeLeftFork(int philosopher_id) {
    std::unique_lock<std::mutex> lock(observer_mutex);

    if (!forks[philosopher_id]) {
      return false;
    }

    forks[philosopher_id] = false;
    return true;
  }

  bool tryTakeRightFork(int philosopher_id) {
    std::unique_lock<std::mutex> lock(observer_mutex);
    int right = (philosopher_id + 1) % NUM_PHILOSOPHERS;

    if (!forks[right]) {
      return false;
    }

    forks[right] = false;
    philosophers_eating[philosopher_id] = true;
    return true;
  }

  void putDownForks(int philosopher_id) {
    std::unique_lock<std::mutex> lock(observer_mutex);
    int right = (philosopher_id + 1) % NUM_PHILOSOPHERS;

    forks[philosopher_id] = true;  // левая вилка
    forks[right] = true;           // правая вилка
    philosophers_eating[philosopher_id] = false;

    // Уведомляем соседей
    fork_cv[(philosopher_id + NUM_PHILOSOPHERS - 1) % NUM_PHILOSOPHERS]
        .notify_one();
    fork_cv[(philosopher_id + 1) % NUM_PHILOSOPHERS].notify_one();
  }

  void waitForForks(int philosopher_id) {
    std::unique_lock<std::mutex> lock(observer_mutex);
    fork_cv[philosopher_id].wait(lock);
  }
};

// Функция для вывода
void safe_print(const std::string& message) {
  std::lock_guard<std::mutex> lock(print_mutex);
  std::cout << message << std::endl;
  if (output_file.is_open()) {
    output_file << message << std::endl;
  }
}

// Структура для передачи параметров в поток
struct PhilosopherArgs {
  int id_;
  ForkObserver* observer_;
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
           config.minThink < 1 || config.minThink > 30 || config.maxThink < 1 ||
           config.maxThink > 30 || config.minThink > config.maxThink ||
           config.minEat < 1 || config.minEat > 30 || config.maxEat < 1 ||
           config.maxEat > 30 || config.minEat > config.maxEat);
}

// Функция для чтения конфигурации из файла
bool readConfigFromFile(const std::string& filename, Config& config) {
  std::ifstream config_file(filename);
  if (!config_file.is_open()) {
    std::cerr << "Ошибка открытия конфигурационного файла\n";
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

// Функция потока философа
void* philosopher(void* arg) {
  auto* p = (PhilosopherArgs*)arg;

  while (program_running) {
    // Философ размышляет
    int thinkTime = getRandomTime(p->minThink_, p->maxThink_);
    safe_print("Философ " + std::to_string(p->id_) + " думает в течение " +
               std::to_string(thinkTime) + " секунд.");

    for (int i = 0; i < thinkTime && program_running; ++i) {
      sleep(1);
    }
    if (!program_running) break;

    safe_print("Философ " + std::to_string(p->id_) + " проголодался.");

    // Пытаемся взять левую вилку
    while (program_running) {
      safe_print("Философ " + std::to_string(p->id_) +
                 " пытается взять левую вилку " + std::to_string(p->id_) + ".");

      if (p->observer_->tryTakeLeftFork(p->id_)) {
        break;
      }
      p->observer_->waitForForks(p->id_);
      if (!program_running) break;
    }

    if (!program_running) break;

    // Пытаемся взять правую вилку
    while (program_running) {
      safe_print("Философ " + std::to_string(p->id_) +
                 " пытается взять правую вилку " +
                 std::to_string((p->id_ + 1) % NUM_PHILOSOPHERS) + ".");

      if (p->observer_->tryTakeRightFork(p->id_)) {
        break;
      }
      p->observer_->waitForForks(p->id_);
      if (!program_running) break;
    }

    if (!program_running) {
      p->observer_->putDownForks(p->id_);
      break;
    }

    // Начинает есть
    int eat_time = getRandomTime(p->minEat_, p->maxEat_);
    safe_print("Философ " + std::to_string(p->id_) + " ест в течение " +
               std::to_string(eat_time) + " секунд.");

    for (int i = 0; i < eat_time && program_running; ++i) {
      sleep(1);
    }

    // Заканчивает есть и освобождает вилки
    safe_print("Философ " + std::to_string(p->id_) +
               " закончил есть и кладет вилки на стол.");
    p->observer_->putDownForks(p->id_);
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

  // Создаем наблюдателя за вилками
  ForkObserver observer(NUM_PHILOSOPHERS);

  // Создаём потоки для философов
  pthread_t threads[NUM_PHILOSOPHERS];
  std::vector<PhilosopherArgs> args(NUM_PHILOSOPHERS);

  // Записываем начальную конфигурацию
  safe_print("\nНачальная конфигурация:");
  safe_print("Время размышления: " + std::to_string(config.minThink) + "-" +
             std::to_string(config.maxThink) + " секунд");
  safe_print("Время приема пищи: " + std::to_string(config.minEat) + "-" +
             std::to_string(config.maxEat) + " секунд");
  safe_print("Количество философов: " + std::to_string(NUM_PHILOSOPHERS));
  safe_print("Время симуляции: " + std::to_string(config.simulationTime) +
             " секунд\n");

  for (int i = 0; i < NUM_PHILOSOPHERS; i++) {
    args[i].id_ = i;
    args[i].observer_ = &observer;
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

  safe_print("Программа завершена.");
  output_file.close();
  return 0;
}
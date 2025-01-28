#include <pthread.h>
#include <semaphore.h>
#include <unistd.h>

#include <atomic>
#include <cstdlib>
#include <ctime>
#include <iostream>

// Количество философов
const int NUM_PHILOSOPHERS = 5;

// Флаг для завершения работы программы
std::atomic<bool> program_running(true);

// Глобальный мьютекс для вывода
pthread_mutex_t print_mutex = PTHREAD_MUTEX_INITIALIZER;

// Функция для безопасного вывода
void safe_print(const std::string& message) {
  pthread_mutex_lock(&print_mutex);
  std::cout << message << std::endl;
  pthread_mutex_unlock(&print_mutex);
}

// Структура для передачи параметров в поток
struct PhilosopherArgs {
  int id_;          // ID философа
  sem_t* forks_;    // Массив семафоров для вилок
  sem_t* stopper_;  // Семафор блокировщика
  int minThink_;    // Минимальное время размышления
  int maxThink_;  // Максимальное время размышления
  int minEat_;    // Минимальное время приема пищи
  int maxEat_;    // Максимальное время приема пищи
};

// Функция для получения случайного времени в заданном диапазоне
int getRandomTime(int min_val, int max_val) {
  return min_val + (rand() % (max_val - min_val + 1));
}

// Функция потока (для каждого философа)
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
  if (argc < 6) {
    std::cerr << "Использование: " << argv[0]
              << " minThink maxThink minEat maxEat simulationTime\n";
    return 1;
  }

  int minThink = std::atoi(argv[1]);
  int maxThink = std::atoi(argv[2]);
  int minEat = std::atoi(argv[3]);
  int maxEat = std::atoi(argv[4]);
  int simulationTime = std::atoi(argv[5]);

  //  Проверка корректности диапозонов
  if (simulationTime < 10 || simulationTime > 100 || minThink < 1 ||
      minThink > 30 || maxThink < 1 || maxThink > 30 || minThink > maxThink ||
      minEat < 1 || minEat > 30 || maxEat < 1 || maxEat > 30 ||
      minEat > maxEat) {
    std::cerr << "Неправильные значения\n";
    return 1;
  }

  // Инициализация генератора случайных чисел
  srand((long)time(nullptr));

  // Инициализация границ с помощью рандома
  //    int minThink = 1 + rand() % 10;
  //    int maxThink = minThink + rand() % (11 - minThink);
  //    int minEat = 1 + rand() % 10;
  //    int maxEat = minEat + rand() % (11 - minEat);
  //    int simulationTime = 10 + rand() % 91;

  // Создаём массив семафоров для вилок
  auto* forks = new sem_t[NUM_PHILOSOPHERS];
  for (int i = 0; i < NUM_PHILOSOPHERS; ++i) {
    sem_init(&forks[i], 0, 1);
  }

  // Создаём семафор блокировщиков
  // Разрешаем (NUM_PHILOSOPHERS - 1) философам одновременно пытаться брать
  // вилки
  sem_t stopper;
  sem_init(&stopper, 0, NUM_PHILOSOPHERS - 1);

  // Создаём потоки для философов
  pthread_t threads[NUM_PHILOSOPHERS];
  PhilosopherArgs args[NUM_PHILOSOPHERS];

  safe_print("Программа будет работать " + std::to_string(simulationTime) +
             " секунд");

  for (int i = 0; i < NUM_PHILOSOPHERS; i++) {
    args[i].id_ = i;
    args[i].forks_ = forks;
    args[i].stopper_ = &stopper;
    args[i].minThink_ = minThink;
    args[i].maxThink_ = maxThink;
    args[i].minEat_ = minEat;
    args[i].maxEat_ = maxEat;

    pthread_create(&threads[i], nullptr, philosopher, &args[i]);
  }

  sleep(simulationTime);
  // Сигнал для завершения потоков
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

  std::cout << "Программа завершена.\n";
  return 0;
}
# macrolib.asm

.data
  test_label:            .asciz "Тест "
  test_passed_msg:       .asciz "Тест пройден.\n"
  test_failed_msg:       .asciz "Тест не пройден.\n"
  expected_result_label: .asciz "Ожидаемый результат:  "
  real_result_label:     .asciz "Полученный результат: "
.text

.macro print_string %label
    la a0, %label
    li a7, 4          # Системный вызов для вывода строки
    ecall
.end_macro

.macro newline
    li a7, 11         # Системный вызов для вывода символа
    li a0, 10         # Код символа новой строки
    ecall
.end_macro

.macro read_double
    li a7, 7          # Системный вызов для ввода double
    ecall
.end_macro

.macro print_double
    li a7, 3          # Системный вызов для вывода double
    ecall
.end_macro

.macro print_int
    li a7, 1          # Системный вызов для вывода целого числа
    ecall
.end_macro

.macro exit_program
    li a7, 10         # Системный вызов для выхода
    ecall
.end_macro

# Макрос для тестирования
.macro test %test_number, %x_value_label, %expected_result_label

    # Вывод номера теста
    print_string test_label
    li a0, %test_number
    print_int
    newline

    # Загружает значение x
    la t0, %x_value_label
    fld fa0, 0(t0)                # fa0 = x_value

    # Вызывает compute_ln
    jal ra, compute_ln            # Результат в fa0

    # Сохраняет результат в ft0
    fmv.d ft0, fa0                # ft0 = real_result

    # Загружает ожидаемый результат
    la t0, %expected_result_label
    fld ft1, 0(t0)                # ft1 = expected_result

    # Вычисляет разницу между ожидаемым и полученным результатом
    fsub.d ft2, ft0, ft1          # ft2 = real_result - expected_result
    fabs.d ft2, ft2               # ft2 = |difference|

    # Устанавливает допустимую погрешность
    la t0, tolerance
    fld ft3, 0(t0)                # ft3 = 0.001

    # Выводим ожидаемый и полученный результаты
    print_string expected_result_label
    fmv.d fa0, ft1                # fa0 = expected_result
    print_double
    newline
    print_string real_result_label
    fmv.d fa0, ft0                # fa0 = real_result
    print_double
    newline

    # Сравнивает погрешность с допустимой
    flt.d t0, ft2, ft3            # t0 = (|difference| < 0.001) ? 1 : 0

    beqz t0, test_failed          # Если t0 == 0, тест не пройден

test_passed:
    # Выводит сообщение о прохождении теста
    print_string test_passed_msg
    j test_end

test_failed:
    # Выводит сообщение о не прохождении теста
    print_string test_failed_msg

test_end:
    # Пустую строку для разделения тестов
    newline

.end_macro
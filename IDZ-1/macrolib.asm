# macrolib.asm

# Макрос для ввода целого числа
.macro input_number %string
.data
	str_input_number: .asciz %string
.text
    la a0, str_input_number
    li a7, 4         # Системный вызов для вывода строки
    ecall
    li a7, 5         # Системный вызов для ввода числа
    ecall            # Результат в a0
.end_macro

# Макрос для вывода строки
.macro print_string %string
.data
	str_print_string: .asciz %string
.text
    la a0, str_print_string
    li a7, 4         # Системный вызов для вывода строки
    ecall
.end_macro

# Макрос для тестирования
.macro test %array_A, %correct_array_B, %real_array_B, %size, %correct_size
    # Подготовка для массива A
    la a3, %array_A             # a3 содержит адрес массива A
    li t0, %size                # t0 size (количество элементов в массиве A)
    slli a4, t0, 2              # a4 = t0 << 2 (размер массива A в байтах)
    la a5, %array_A             # a5 содержит адрес массива A
    print_string "\nArray A: "  # Выводим строку "Array A: "
    jal output_array

    # Подготовка для корректного массива B
    la a5, %correct_array_B     # a5 содержит адрес корректного массива B
    li t0, %correct_size        # t0 correct_size (количество элементов в корректном массиве B)
    slli a4, t0, 2              # a4 = t0 << 2 (размер корректного массива B в байтах)
    print_string "Correct array B: "
    jal output_array

    # Подготовка к формированию реального массива B
    la a3, %array_A             # a3 содержит адрес массива A
    li t0, %size                # t0 size
    slli a4, t0, 2              # a4 = t0 << 2 (размер массива A в байтах)
    la a5, %real_array_B        # a5 содержит адрес реального массива B
    jal filling_B               # Формируем массив B
    mv s5, a0                   # s5 количество элементов в массиве B

    # Обновляем a4 до размера реального массива B в байтах
    slli a4, s5, 2              # a4 = s5 << 2 (размер массива B в байтах)

    # Вывод реального массива B
    print_string "Real array B: "
    la a5, %real_array_B        # a5 содержит адрес реального массива B
    jal output_array

    # Подготовка для проверки
    la a5, %real_array_B        # a5 содержит адрес реального массива B
    la a6, %correct_array_B     # a6 содержит адрес корректного массива B
    mv a0, s5                   # a0 количество элементов в real_array_B
    li a1, %correct_size        # a1 количество элементов в correct_array_B
    jal compare                 # Проверяем корректность массива B
.end_macro


# test_main.asm

.include "macrolib.asm"
.data
.align 2
    # Тест 1
    array_A_1: .word 4
    correct_array_B_1: .space 0    # Пустой массив
    real_array_B_1: .space 4       # Максимум 1 элемент

    # Тест 2
    array_A_2: .word -5
    correct_array_B_2: .space 0    # Пустой массив
    real_array_B_2: .space 4       # Максимум 1 элемент

    # Тест 3
    array_A_3: .word -4, 6
    correct_array_B_3: .word 0	   # Пустой массив
    real_array_B_3: .space 8       # Максимум 2 элемента

    # Тест 4
    array_A_4: .word 8, -5
    correct_array_B_4: .space 0    # Пустой массив
    real_array_B_4: .space 8       # Максимум 2 элемента

    # Тест 5
    array_A_5: .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
    correct_array_B_5: .word 2, 3, 4, 5, 6, 7, 8, 9, 10
    real_array_B_5: .space 36      # Максимум 9 элементов

    # Тест 6
    array_A_6: .word -1, -2, -3, -4, -5
    correct_array_B_6: .word -1, -2, -3, -4
    real_array_B_6: .space 20      # Максимум 5 элементов

    # Тест 7
    array_A_7: .word 1, 2, 3, 4, 5
    correct_array_B_7: .word 2, 3, 4, 5
    real_array_B_7: .space 20      # Максимум 5 элементов

    # Тест 8
    array_A_8: .word -1, -4, 2, 5, -10
    correct_array_B_8: .word -1, -4, 5
    real_array_B_8: .space 20      # Максимум 5 элементов

    # Тест 9
    array_A_9: .word -39, 3, 4, 5
    correct_array_B_9: .word 4, 5
    real_array_B_9: .space 16      # Максимум 4 элемента

    # Тест 10
    array_A_10: .word 5, 6, -40, 3, 89
    correct_array_B_10: .word 6, 3, 89
    real_array_B_10: .space 20     # Максимум 5 элементов

    # Тест 11
    array_A_11: .word 0, 0, 0, 0, 0
    correct_array_B_11: .word 0, 0, 0, 0, 0
    real_array_B_11: .space 20     # Максимум 5 элементов

    # Тест 12
    array_A_12: .word -30, 2, 0, 20, 435, -345, 9, 0
    correct_array_B_12: .word -30, 0, 20, 435, 9, 0
    real_array_B_12: .space 32     # Максимум 8 элементов

    # Тест 13
    array_A_13: .word -2147483648, 3, 2147483647, 0, -234, 4, -2147483648, 4
    correct_array_B_13: .word -2147483648, 2147483647, 0, -234, 4, 4
    real_array_B_13: .space 32     # Максимум 8 элементов

.globl main
.text

main:
    # Тест 1
    test array_A_1, correct_array_B_1, real_array_B_1, 1, 0

    # Тест 2
    test array_A_2, correct_array_B_2, real_array_B_2, 1, 0

    # Тест 3
    test array_A_3, correct_array_B_3, real_array_B_3, 2, 0

    # Тест 4
    test array_A_4, correct_array_B_4, real_array_B_4, 2, 0

    # Тест 5
    test array_A_5, correct_array_B_5, real_array_B_5, 10, 9

    # Тест 6
    test array_A_6, correct_array_B_6, real_array_B_6, 5, 4

    # Тест 7
    test array_A_7, correct_array_B_7, real_array_B_7, 5, 4

    # Тест 8
    test array_A_8, correct_array_B_8, real_array_B_8, 5, 3

    # Тест 9
    test array_A_9, correct_array_B_9, real_array_B_9, 4, 2

    # Тест 10
    test array_A_10, correct_array_B_10, real_array_B_10, 5, 3

    # Тест 11
    test array_A_11, correct_array_B_11, real_array_B_11, 5, 5

    # Тест 12
    test array_A_12, correct_array_B_12, real_array_B_12, 8, 6

    # Тест 13
    test array_A_13, correct_array_B_13, real_array_B_13, 8, 6

    # Завершение программы
    li a7, 10
    ecall

# test_main.asm

.include "macrolib.asm"

.data
    # Константа для погрешности
    tolerance: .double 0.001

    # Тестовые данные
    x_value_1: .double 0.0
    expected_result_1: .double 0.0

    x_value_2: .double -0.5
    expected_result_2: .double 0.4054651081081644

    x_value_3: .double 0.5
    expected_result_3: .double -0.6931471805599453

    x_value_4: .double -0.9
    expected_result_4: .double 0.6418538861723947

    x_value_5: .double 0.9
    expected_result_5: .double -2.302585092994046

    x_value_6: .double 0.1
    expected_result_6: .double -0.10536051565782628

    x_value_7: .double -0.1
    expected_result_7: .double 0.09531017980432493

    x_value_8: .double 0.999
    expected_result_8: .double -6.907755278982136

    x_value_9: .double -0.999
    expected_result_9: .double 0.6926470555182631
    
    x_value_10: .double 0.001
    expected_result_10: .double -0.0010005003335835344
    
    x_value_11: .double -0.001
    expected_result_11: .double 0.0009995003330834232
    
    x_value_12: .double 1.0
    expected_result_12: .double 0.0
    
    x_value_13: .double -1.0
    expected_result_13: .double 0.0

.text
.globl test_main
test_main:
    # Тест 1
    test 1, x_value_1, expected_result_1

    # Тест 2
    test 2, x_value_2, expected_result_2

    # Тест 3
    test 3, x_value_3, expected_result_3

    # Тест 4
    test 4, x_value_4, expected_result_4

    # Тест 5
    test 5, x_value_5, expected_result_5

    # Тест 6
    test 6, x_value_6, expected_result_6

    # Тест 7
    test 7, x_value_7, expected_result_7

    # Тест 8
    test 8, x_value_8, expected_result_8

    # Тест 9
    test 9, x_value_9, expected_result_9
    
    # Тест 10
    test 10, x_value_10, expected_result_10
    
    # Тест 11
    test 11, x_value_11, expected_result_11
    
    # Тест 12
    test 12, x_value_12, expected_result_12
    
    # Тест 13
    test 13, x_value_13, expected_result_13

    # Завершение программы
    exit_program

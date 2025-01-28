# output_array.asm

.include "macrolib.asm"
.text
.globl output_array

output_array:
    addi sp, sp, -4          	# Выделяем место на стеке
    sw ra, 0(sp)             	# Сохраняем адрес возврата

    add t1 zero a5           	# t1 содержит адрес первого элемента массива
    add t2, a5, a4           	# t2 содержит адрес конца массива (a5 + размер в байтах)

    # Проверяем, есть ли элементы в массиве
    beq t1, t2, output_newline  # Если массив пустой, переходим к выводу новой строки

output_loop:
    blt t1, t2, output_element   # Если t1 < t2, продолжаем вывод элементов
    j end_output                 # Иначе завершаем вывод

output_element:
    lw a0, 0(t1)                # Загружаем элемент массива в a0
    li a7, 1                    # Системный вызов для вывода целого числа
    ecall

    addi t1, t1, 4              # Переходим к следующему элементу

    # Проверяем, есть ли еще элементы для вывода
    blt t1, t2, output_space     # Если есть, выводим пробел и продолжаем
    j end_output                 # Иначе завершаем вывод

output_space:
    print_string " "            # Выводим пробел
    j output_loop               # Переходим к следующему элементу

end_output:
    output_newline:
    print_string "\n"           # Выводим новую строку

    lw ra, 0(sp)                # Восстанавливаем адрес возврата
    addi sp, sp, 4              # Освобождаем место на стеке
    ret

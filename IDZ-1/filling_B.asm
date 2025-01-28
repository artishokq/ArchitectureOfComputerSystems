# filling_B.asm

.text
.globl filling_B

filling_B:
    addi sp, sp, -16        	# Выделяем место на стеке
    sw ra, 12(sp)           	# Сохраняем адрес возврата
    sw s0, 8(sp)            	# Сохраняем s0 (индекс первого положительного)
    sw s1, 4(sp)            	# Сохраняем s1 (индекс последнего отрицательного)
    sw s2, 0(sp)            	# Сохраняем s2 (счетчик элементов в B)

    add t1, zero, a3        	# t1 адрес первого элемента массива A
    add t2, a3, a4          	# t2 адрес конца массива A
    add t3, zero, a5        	# t3 адрес первого элемента массива B
    addi t4, zero, 0        	# t4 индекс текущего элемента массива A
    li s0, -1               	# s0 = -1 (индекс первого положительного элемента)
    li s1, -1               	# s1 = -1 (индекс последнего отрицательного элемента)
    li s2, 0                	# s2 = 0 (счетчик элементов в массиве B)

find_indices:
    blt t1, t2, check_element   # Пока t1 < t2, продолжаем
    j copy_elements             # После поиска переходим к копированию

check_element:
    lw t6, 0(t1)                # t6 = array_A[t4]
    blt s0, zero, check_positive  # Если s0 < 0, ищем первый положительный
    j check_negative            # Иначе переходим к проверке отрицательного

check_positive:
    bgt t6, zero, set_first_positive  # Если t6 > 0, устанавливаем первый положительный
    j check_negative

set_first_positive:
    mv s0, t4                   # s0 = t4 (индекс первого положительного)
    j check_negative

check_negative:
    blt t6, zero, set_last_negative  # Если t6 < 0, обновляем последний отрицательный
    j next_element

set_last_negative:
    mv s1, t4                   # s1 = t4 (индекс последнего отрицательного)
    j next_element

next_element:
    addi t1, t1, 4              # Переходим к следующему элементу массива A
    addi t4, t4, 1              # Увеличиваем индекс t4
    j find_indices

copy_elements:
    # Сбрасываем указатели для копирования
    add t1, zero, a3            # t1 адрес первого элемента массива A
    addi t4, zero, 0            # t4 индекс текущего элемента массива A

copy_loop:
    blt t1, t2, copy_check      # Пока t1 < t2, продолжаем копирование
    j end_copy

copy_check:
    beq t4, s0, skip_copy       # Пропускаем первый положительный элемент
    beq t4, s1, skip_copy       # Пропускаем последний отрицательный элемент

    lw t6, 0(t1)                # t6 = array_A[t4]
    sw t6, 0(t3)                # array_B[...] = t6
    addi t3, t3, 4              # Переходим к следующему элементу массива B
    addi s2, s2, 1              # Увеличиваем счетчик для B

skip_copy:
    addi t1, t1, 4              # Переходим к следующему элементу массива A
    addi t4, t4, 1              # Увеличиваем индекс t4
    j copy_loop

end_copy:
    mv a0, s2                   # Возвращаем количество элементов в массиве B через a0

    # Восстанавливаем регистры и возвращаемся
    lw s2, 0(sp)                # Восстанавливаем s2
    lw s1, 4(sp)                # Восстанавливаем s1
    lw s0, 8(sp)                # Восстанавливаем s0
    lw ra, 12(sp)               # Восстанавливаем ra
    addi sp, sp, 16             # Освобождаем место на стеке
    ret

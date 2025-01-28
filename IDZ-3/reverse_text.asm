# reverse_text.asm

.text
.global reverse_text    
reverse_text:
    mv t0, a0                  # t0 = адрес текущего символа
    mv t1, a0                  # t1 = адрес начала слова
    li t2, 0                   # t2 = флаг внутри слова 0 - нет, 1 - да

reverse_loop:
    lb t3, 0(t0)               # Загрузка текущего символа
    beq t3, x0, reverse_end    # Если конец строки, выйти из цикла

    # Проверка, является ли символ буквой (A-Z или a-z)
    li t4, 'A'
    li t5, 'Z'
    blt t3, t4, check_lower
    ble t3, t5, is_letter
check_lower:
    li t4, 'a'
    li t5, 'z'
    blt t3, t4, not_letter
    ble t3, t5, is_letter

not_letter:
    # Если был внутри слова, reverse его
    beq t2, x0, continue_not_word
    # Начало реверса слова
    mv t4, t1                  # t4 = начало слова
    addi t5, t0, -1            # t5 = конец слова текущий адрес - 1
reverse_inner_loop:
    bge t4, t5, reverse_done   # Если t4 >= t5, конец реверса
    lb t6, 0(t4)               # Сохраняем символ с начала
    lb a3, 0(t5)               # Сохраняем символ с конца
    sb a3, 0(t4)               # Записываем символ с конца в начало
    sb t6, 0(t5)               # Записываем символ с начала в конец
    addi t4, t4, 1             # Сдвигаем указатели
    addi t5, t5, -1
    j reverse_inner_loop
reverse_done:
    li t2, 0                   # Сбрасываем флаг внутри слова

continue_not_word:
    j next_char

is_letter:
    beq t2, x0, set_word_start  # Если только начинаем слово
    j continue_word

set_word_start:
    mv t1, t0                  # Установка начала слова
    li t2, 1                   # Установка флага внутри слова
    j continue_word

continue_word:
    j next_char

next_char:
    addi t0, t0, 1             # Переход к следующему символу
    j reverse_loop

reverse_end:
    # Если строка заканчивается на слово, реверсируем его
    beq t2, x0, end_proc
    # Начало реверса слова
    mv t4, t1                  # t4 = начало слова
    addi t5, t0, -1            # t5 = конец слова текущий адрес - 1
reverse_inner_loop_end:
    bge t4, t5, end_proc       # Если t4 >= t5, конец реверса
    lb t6, 0(t4)               # Сохраняем символ с начала
    lb a3, 0(t5)               # Сохраняем символ с конца
    sb a3, 0(t4)               # Записываем символ с конца в начало
    sb t6, 0(t5)               # Записываем символ с начала в конец
    addi t4, t4, 1             # Сдвигаем указатели
    addi t5, t5, -1
    j reverse_inner_loop_end

end_proc:
    jr ra                       # Возврат из подпрограммы

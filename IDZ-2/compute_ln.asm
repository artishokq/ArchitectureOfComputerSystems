# compute_ln.asm

.data
    small_value:    .double 0.0000000000001       # Точность
    one:            .double 1.0         		  # Константа 1.0
    minus_one:      .double -1.0        		  # Константа -1.0
    positive_zero:  .double 0.0         		  # Положительный 0
    error_msg:		.asciz "Ошибка! Недопустимое значение x. Введите x из интервала (-1, 1).\n"
.text
.globl compute_ln

    # Входные параметры:
    #   fa0 - значение x
    
    # Выходные параметры:
    #   fa0 - значение ln(1 - x)
    #   a0  - статус выполнения (0 - успех, 1 - ошибка)
compute_ln:
    # Сохранение регистров
    addi sp, sp, -16		   # Выделяет место на стеке
    sw ra, 8(sp)               # Сохраняет ra
    sw s0, 0(sp)               # Сохраняет s0

    # Копирует входной параметр из fa0 в ft0
    fmv.d ft0, fa0             # ft0 = x

    # Загрузка констант
    la t0, one
    fld ft1, 0(t0)             # ft1 = 1.0
    la t0, minus_one
    fld ft2, 0(t0)             # ft2 = -1.0

    # Проверка x > -1
    flt.d t1, ft2, ft0         # t1 = (-1.0 < x) ? 1 : 0
    beqz t1, invalid_x         # Если x <= -1, ошибка

    # Проверка x < 1
    flt.d t1, ft0, ft1         # t1 = (x < 1.0) ? 1 : 0
    beqz t1, invalid_x         # Если x >= 1, ошибк

    # Инициализация переменных для ряда
    fneg.d ft3, ft0            # ft3 = -x
    fmv.d ft4, ft3             # ft4 = term (текущий член ряда)
    fmv.d ft5, ft4             # ft5 = sum
    li t2, 1                   # n = 1

compute_series:
    # Увеличивает n для следующего члена ряда
    addi t2, t2, 1             # n = n + 1

    # Обновляем степень x^n
    fmul.d ft3, ft3, ft0       # ft3 = (-x^n) * x = -x^(n+1)

    # Вычисляет текущий член, term = ft3 / n
    fcvt.d.w ft6, t2           # ft6 = (double) n
    fdiv.d ft4, ft3, ft6       # ft4 = ft3 / n

    # Обновляет сумму
    fadd.d ft5, ft5, ft4       # ft5 = ft5 + ft4

    # Проверка условия окончания цикла
    # Загрузка small_value
    la t0, small_value
    fld ft7, 0(t0)             # ft7 = small_value (0.001)

    # Вычисляет |term|
    fabs.d ft8, ft4            # ft8 = |term|

    # Вычисляет |sum|
    fabs.d ft9, ft5            # ft9 = |sum|

    # Проверка является ли сумма равной нулю
    feq.d t3, ft9, ft0         # t3 = (|sum| == 0.0) ? 1 : 0
    bnez t3, sum_zero          # Если сумма равна нулю переходим к sum_zero

    # Если сумма не равна нулю, вычисляем threshold = |sum| * small_value
    fmul.d ft10, ft9, ft7      # ft10 = threshold
    j compare_terms

sum_zero:
    # Если сумма равна нулю, устанавливаем threshold = small_value
    fmv.d ft10, ft7            # ft10 = small_value

compare_terms:
    # Сравниваем |term| и threshold
    flt.d t1, ft8, ft10        # t1 = (|term| < threshold) ? 1 : 0
    bnez t1, end_series        # Если условие выполнено, выходим из цикла

    j compute_series           # Иначе продолжаем цикл

end_series:
    # Проверка, является ли результат нулем
    feq.d t1, ft5, ft0         # t1 = (ft5 == 0.0) ? 1 : 0
    beqz t1, return_result     # Если результат не ноль, пропускает фиксацию знака

    # Загрузка положительного нуля
    la t0, positive_zero
    fld ft11, 0(t0)            # ft11 = 0.0 (положительный нуль)

    # Устанавливает знак результата в положительный
    fmv.d ft5, ft11            # ft5 = 0.0 (положительный нуль)

return_result:
    # Возвращает результат в fa0
    fmv.d fa0, ft5             # fa0 = sum
    li a0, 0                   # Статус выполнения: 0 - успех

    # Восстановление регистров
    lw s0, 0(sp)               # Восстанавливаем s0
    lw ra, 8(sp)               # Восстанавливаем ra
    addi sp, sp, 16
    ret                        # Возвращаемся

invalid_x:
    # Вывод сообщения об ошибке
    la a0, error_msg
    li a7, 4                   # Системный вызов для вывода строки
    ecall

    # Возвращает 0.0 в fa0
    la t0, positive_zero
    fld ft0, 0(t0)
    fmv.d fa0, ft0             # fa0 = 0.0 (ft0 предполагается 0.0)
    li a0, 1                   # Статус выполнения: 1 - ошибка

    # Восстановление регистров
    lw s0, 0(sp)               # Восстанавливаем s0
    lw ra, 8(sp)               # Восстанавливаем ra
    addi sp, sp, 16
    ret                        # Возврат

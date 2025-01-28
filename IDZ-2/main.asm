# main.asm

.include "macrolib.asm"
.data
	input_msg:	.asciz "Функция ln(1 - x). Введите значение x (|x| < 1): "
	result:		.asciz "ln(1 - x) = "
.text
.globl main
main:
	input_x:
    	# Вывод сообщения ввода
    	print_string input_msg
    	read_double                # Ввод x в fa0

    	# Вызов compute_ln
    	# Передача параметра x в fa0
    	# Вызов подпрограммы compute_ln для вычисления ln(1 - x)
    	jal ra, compute_ln         # Результат будет в fa0, статус в a0

    	# Проверка статуса выполнения
    	beq a0, zero, print_result # Если a0 = 0, переходим к выводу результата
    	# Иначе (a0 != 0) повторяем ввод
    	j input_x

	print_result:
    	# Вывод результата
    	print_string result
    	print_double               # Вывод fa0
    	newline

    	# Завершение программы
    	exit_program
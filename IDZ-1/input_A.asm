# input_A.asm

.include "macrolib.asm"
.text
.globl input_A

input_A:
	addi sp sp -4	# Стек
	sw ra (sp)		# Сохранить адрес возврата

input_number("Enter the number of array elements (1-10): ")
	# Ввод количества элементов массива; результат в a0
	mv t0 a0 		# Сохранение результата в t0
	
	# Если введено число больше 10 или меньше 1 - завершить программу
	addi t5 zero 1
	blt t0 t5 input_error
	addi t5 zero 10
	bgt t0 t5 input_error
	add t1 zero a3
	
	# t1 содержит адрес первого элемента массива A; подсчет правой границы массива A
	add t0 t0 t0
	add t0 t0 t0
	add t2 t1 t0
	# t2 содержит адрес правой границы массива A
	add a4 zero t0 	# a4 содержит количество байт для массива A
	
fill:
	input_number("Enter the element: ") # Результат в a0
	mv t3 a0 		# Сохранение результата в t3
	sw t3 (t1)
	# Запись числа из t3 по адресу t1 (в массив A)
	addi t1 t1 4 	# Переход к следующему элементу массива A
	bltu t1 t2 fill
	# Выполнять, пока не выйдем за пределы массива A
	lw ra (sp) 		# Запомнить ra
	addi sp sp 4	# Восстановление адреса возврата
	ret

input_error:
	print_string("Error, the number of elements should be between 1 and 10!")
	j the_end

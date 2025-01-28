# macrolib.asm

.macro print_str %label
	la a0, %label
	li a7, 4
	ecall
.end_macro


.macro str_get %buffer, %length
	la a0, %buffer         # Адрес буфера для чтения
	li a1, %length         # Максимальная длина ввода
	li a7, 8               # Системный вызов для чтения строки
	ecall
.end_macro


.macro print_int %reg
	mv a0, %reg
	li a7, 1
	ecall
.end_macro


.data
nl: .asciz "\n"
.macro newline
	la a0, nl
	li a7, 4
	ecall
.end_macro


.macro exit
    li a7, 10
    ecall
.end_macro


.macro allocate(%size)
    li a7, 9
    li a0, %size			# Размер блока памяти
    ecall
.end_macro


.eqv READ_ONLY	0			# Открыть для чтения
.eqv WRITE_ONLY	1			# Открыть для записи
.eqv APPEND	    9			# Открыть для добавления
.macro open(%opt)
    li   	a7 1024     	# Системный вызов открытия файла
    li   	a1 %opt        	# Открыть для чтения (флаг = 0)
    ecall             		# Дескриптор файла в a0 или -1)
.end_macro


# Закрытие файла
.macro close(%file_descriptor)
    li   a7, 57       				# Системный вызов закрытия файла
    mv   a0, %file_descriptor  		# Дескриптор файла
    ecall             				# Закрытие файла
.end_macro


.macro read_addr_reg(%file_descriptor, %reg, %size)
    li   a7, 63       				# Системный вызов для чтения из файла
    mv   a0, %file_descriptor       # Дескриптор файла
    mv   a1, %reg   				# Адрес буфера для читаемого текста из регистра
    li   a2, %size 					# Размер читаемой порции
    ecall             				# Чтение
.end_macro


# Чтение информации из открытого файла
.macro read(%file_descriptor, %strbuf, %size)
    li   a7, 63       				# Системный вызов для чтения из файла
    mv   a0, %file_descriptor       # Дескриптор файла
    la   a1, %strbuf   				# Адрес буфера для читаемого текста
    li   a2, %size 					# Размер читаемой порции
    ecall             				# Чтение
.end_macro


# удаление \n
.macro remove_newline %buffer
	la t0, %buffer          		# Загрузка адреса буфера в t0
remove_newline_loop:
	lb t1, 0(t0)             		# Загрузка текущего символа
	beq t1, x0, remove_newline_end  # Если конец строки, выйти
	li t2, '\n'              		# Сравниваем с символом новой строки
	beq t1, t2, replace_newline
	addi t0, t0, 1           		# Переход к следующему символу
	j remove_newline_loop   		# Повтор цикла
replace_newline:
	sb x0, 0(t0)            		# Замена символа новой строки на нулевой байт
	j remove_newline_end    		# Переход к завершению
remove_newline_end:
.end_macro


#Макрос для тестирования
.data
err_read:         	.asciz "\nОшибка при чтении входного файла.\n"
err_write:        	.asciz "\nОшибка при записи в выходной файл.\n"
err_msg:   			.asciz "\nОшибка при обработке файла.\n"
.text
.macro test %input_file_name, %output_file_name, %test_number
    # Начало обработки тестовых файлов
    la a0, %input_file_name
    jal load_text                # Вызов подпрограммы load_text
    mv s0, a0                    # s0 = адрес загруженного текста (буфера)
    mv s1, a1                    # s1 = размер загруженного текста
    
    li t3, -1
    beq s0, t3, read_fail	      # Если a0 == -1, перейти к обработке ошибки

    # Операция с текстом (reverse слов)
    mv a0, s0                    # Адрес загруженного текста
    jal reverse_text
    
    # Запись обработанного текста в выходной файл
    la a0, %output_file_name       # Адрес имени выходного файла
    mv a1, s0                    # Адрес обработанного текста
    mv a2, s1                    # Размер данных для записи
    jal output_text              # Вызов подпрограммы output_text

    # Проверка на ошибку записи
    li t4, -1
    beq a0, t4, write_fail	     # Если a0 == -1, перейти к обработке ошибки
    
    # Вывод номера теста, если ошибок не было
    print_str %test_number

    # Переход в основной блок после успешного выполнения
    j end_test

# Вывод сообщения об ошибке чтения и завершение программы
read_fail:
    print_str err_read
    j end_test   # Возвращаемся в конец теста, чтобы продолжить выполнение

# Вывод сообщения об ошибке записи и завершение программы
write_fail:
    print_str err_write
    j end_test   # Возвращаемся в конец теста, чтобы продолжить выполнение
# Метка завершения теста
end_test:
.end_macro
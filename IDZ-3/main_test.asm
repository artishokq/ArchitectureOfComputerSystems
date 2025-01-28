# main_test.asm
.include "macrolib.asm"

.data
test_1:				.asciz "TEST 1 успешно пройден\n"
test_2:				.asciz "TEST 2 успешно пройден\n"
test_3:				.asciz "TEST 3 успешно пройден\n"
test_4:				.asciz "TEST 4 успешно пройден\n"
end_msg: 			.asciz "Все тесты успешно пройдены, обновлённые текста сохранены в новые файлы.\n"

test_input1:		.asciz "input1.txt"
test_input2:    	.asciz "input2.txt"
test_input3:    	.asciz "input3.txt"
test_input4:    	.asciz "input4.txt"

test_output1:	 	.asciz "output1.txt"
test_output2:    	.asciz "output2.txt"
test_output3:    	.asciz "output3.txt"
test_output4:    	.asciz "output4.txt"

error_read:         .asciz "\nОшибка при чтении входного файла.\n"
error_write:        .asciz "\nОшибка при записи в выходной файл.\n"
error_msg:   		.asciz "\nОшибка при обработке файла.\n"
.text

.globl main_test
main_test:
# ТЕСТ №1
    # Начало обработки тестовых файлов
    la a0, test_input1
    jal load_text                # Вызов подпрограммы load_text
    mv s0, a0                    # s0 = адрес загруженного текста (буфера)
    mv s1, a1                    # s1 = размер загруженного текста
	
	li t3, -1
    beq s0, t3, read_failed      # Если a0 == -1, перейти к обработке ошибки

    # Операция с текстом (reverse слов)
    mv a0, s0                    # Адрес загруженного текста
    jal reverse_text
    
    # Запись обработанного текста в выходной файл
    la a0, test_output1       # Адрес имени выходного файла
    mv a1, s0                    # Адрес обработанного текста
    mv a2, s1                    # Размер данных для записи
    jal output_text              # Вызов подпрограммы output_text

    # Проверка на ошибку записи
    li t4, -1
    beq a0, t4, write_failed     # Если a0 == -1, перейти к обработке ошибки
    print_str test_1

# ТЕСТ №2
	# Начало обработки тестовых файлов
    la a0, test_input2
    jal load_text                # Вызов подпрограммы load_text
    mv s0, a0                    # s0 = адрес загруженного текста (буфера)
    mv s1, a1                    # s1 = размер загруженного текста
	
	li t3, -1
    beq s0, t3, read_failed      # Если a0 == -1, перейти к обработке ошибки

    # Операция с текстом (reverse слов)
    mv a0, s0                    # Адрес загруженного текста
    jal reverse_text
    
    # Запись обработанного текста в выходной файл
    la a0, test_output2       # Адрес имени выходного файла
    mv a1, s0                    # Адрес обработанного текста
    mv a2, s1                    # Размер данных для записи
    jal output_text              # Вызов подпрограммы output_text

    # Проверка на ошибку записи
    li t4, -1
    beq a0, t4, write_failed     # Если a0 == -1, перейти к обработке ошибки
	print_str test_2
	
# ТЕСТ №3
	# Начало обработки тестовых файлов
    la a0, test_input3
    jal load_text                # Вызов подпрограммы load_text
    mv s0, a0                    # s0 = адрес загруженного текста (буфера)
    mv s1, a1                    # s1 = размер загруженного текста
	
	li t3, -1
    beq s0, t3, read_failed      # Если a0 == -1, перейти к обработке ошибки

    # Операция с текстом (reverse слов)
    mv a0, s0                    # Адрес загруженного текста
    jal reverse_text
    
    # Запись обработанного текста в выходной файл
    la a0, test_output3       # Адрес имени выходного файла
    mv a1, s0                    # Адрес обработанного текста
    mv a2, s1                    # Размер данных для записи
    jal output_text              # Вызов подпрограммы output_text

    # Проверка на ошибку записи
    li t4, -1
    beq a0, t4, write_failed     # Если a0 == -1, перейти к обработке ошибки
	print_str test_3
	
# ТЕСТ №4
	# Начало обработки тестовых файлов
    la a0, test_input4
    jal load_text                # Вызов подпрограммы load_text
    mv s0, a0                    # s0 = адрес загруженного текста (буфера)
    mv s1, a1                    # s1 = размер загруженного текста
	
	li t3, -1
    beq s0, t3, read_failed      # Если a0 == -1, перейти к обработке ошибки

    # Операция с текстом (reverse слов)
    mv a0, s0                    # Адрес загруженного текста
    jal reverse_text
    
    # Запись обработанного текста в выходной файл
    la a0, test_output4       # Адрес имени выходного файла
    mv a1, s0                    # Адрес обработанного текста
    mv a2, s1                    # Размер данных для записи
    jal output_text              # Вызов подпрограммы output_text

    # Проверка на ошибку записи
    li t4, -1
    beq a0, t4, write_failed     # Если a0 == -1, перейти к обработке ошибки
    print_str test_4
    print_str end_msg
    exit
    
# Вывод сообщения об ошибке чтения и завершение программы
read_failed:
    print_str error_read
    exit

# Вывод сообщения об ошибке записи и завершение программы
write_failed:
    print_str error_write
    exit
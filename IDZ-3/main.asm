.include "macrolib.asm"

.eqv INPUT_FILE_NAME_SIZE 256
.eqv OUTPUT_FILE_NAME_SIZE 256
.eqv CONSOLE_CHOICE_SIZE 4

.data
input_filename:     .space INPUT_FILE_NAME_SIZE                # Имя входного файла
output_filename:    .space OUTPUT_FILE_NAME_SIZE               # Имя выходного файла
console_choice:     .space CONSOLE_CHOICE_SIZE                 # Выбор пользователя (Y/N)

input_msg:        	.asciz "Введите имя входного файла: "
output_msg:       	.asciz "Введите имя выходного файла: "
error_read:         .asciz "\nОшибка при чтении входного файла.\n"
error_write:        .asciz "\nОшибка при записи в выходной файл.\n"
console_msg:		.asciz "\nВывести результат на экран? (Y/N): "
message_ok:         .asciz "Операция завершена успешно!\n"
message_error:		.asciz "Операция прервана из-за ошибки. Попробуйте еще раз!\n"
message_bye:		.asciz "До скорых встреч!\n"

.text
.globl main
main:
    # Используем InputDialogString для ввода имени входного файла
    la a0, input_msg           # Адрес строки запроса
    la a1, input_filename      # Адрес буфера для имени входного файла
    li a2, INPUT_FILE_NAME_SIZE  # Максимальная длина ввода
    li a7, 54                  # Системный вызов InputDialogString
    ecall                      # Вызов системного вызова
	remove_newline input_filename
	
    # Вызов подпрограммы load_text для загрузки текста
    la a0, input_filename        # Адрес имени входного файла
    jal load_text                # Вызов подпрограммы load_text
    mv s0, a0                    # s0 = адрес загруженного текста (буфера)
    mv s1, a1                    # s1 = размер загруженного текста

    # Проверка на ошибку загрузки текста
    li t3, -1
    beq s0, t3, read_failed      # Если a0 == -1, перейти к обработке ошибки

    # Операция с текстом (reverse слов)
    mv a0, s0                    # Адрес загруженного текста
    jal reverse_text             # Вызов подпрограммы reverse_text

    # Используем InputDialogString для ввода имени выходного файла
    la a0, output_msg           # Адрес строки запроса
    la a1, output_filename      # Адрес буфера для имени выходного файла
    li a2, OUTPUT_FILE_NAME_SIZE  # Максимальная длина ввода
    li a7, 54                  # Системный вызов InputDialogString
    ecall                      # Вызов системного вызова
    remove_newline output_filename

    # Запись обработанного текста в выходной файл
    la a0, output_filename       # Адрес имени выходного файла
    mv a1, s0                    # Адрес обработанного текста
    mv a2, s1                    # Размер данных для записи
    jal output_text              # Вызов подпрограммы output_text

    # Проверка на ошибку записи
    li t4, -1
    beq a0, t4, write_failed     # Если a0 == -1, перейти к обработке ошибки

    # Запрос пользователю о выводе результата на консоль
    la a0, console_msg           # Адрес строки запроса
    la a1, console_choice        # Адрес буфера для выбора
    li a2, CONSOLE_CHOICE_SIZE   # Максимальная длина ввода
    li a7, 54                    # Системный вызов InputDialogString
    ecall                        # Вызов системного вызова
    remove_newline console_choice
    
    # Загрузка первого символа выбора в t0
    la t1, console_choice        # Загрузка адреса console_choice в t1
    lb t0, 0(t1)                 # Загрузка первого байта из console_choice в t0

    # Проверка первого символа выбора
    li t1, 'Y'                   # Значение Y
    li t2, 'y'                   # Значение y
    beq t0, t1, print_result      # Если символ Y, перейти к выводу результата
    beq t0, t2, print_result      # Если символ y, перейти к выводу результата
    # Иначе завершаем программу
    
    # Используем MessageDialogString для вывода обработанного текста в окно
    la a0, message_ok            # Адрес сообщения "Операция завершена успешно!"
    la a1, message_bye
    li a7, 59                    # Системный вызов MessageDialogString
    ecall                        # Вызов системного вызова
    exit

print_result:
    # Используем MessageDialogString для вывода обработанного текста в окно
    la a0, message_ok            # Адрес сообщения "Операция завершена успешно!"
    mv a1, s0                    # Адрес обработанного текста
    li a7, 59                    # Системный вызов MessageDialogString
    ecall                        # Вызов системного вызова
    exit

# Вывод сообщения об ошибке чтения и завершение программы
read_failed:
    la a0, error_read            # Адрес строки ошибки
    la a1, message_error            # Сообщение об успешной операции
    li a7, 59                    # Системный вызов MessageDialogString
    ecall                        # Вызов системного вызова
    exit

# Вывод сообщения об ошибке записи и завершение программы
write_failed:
    la a0, error_write           # Адрес строки ошибки
    la a1, message_error            # Сообщение об успешной операции
    li a7, 59                    # Системный вызов MessageDialogString
    ecall                        # Вызов системного вызова
    exit

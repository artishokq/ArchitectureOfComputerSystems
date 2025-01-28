# main_test_macrolib.asm
.include "macrolib.asm"

.data
test_1:				.asciz "TEST 1 успешно пройден\n"
test_2:				.asciz "TEST 2 успешно пройден\n"
test_3:				.asciz "TEST 3 успешно пройден\n"
test_4:				.asciz "TEST 4 успешно пройден\n"
end_msg: 			.asciz "Все тесты завршились, обновлённые текста сохранены в новые файлы.\n"

test_input1:		.asciz "input1.txt"
test_input2:    	.asciz "input2.txt"
test_input3:    	.asciz "input3.txt"
test_input4:    	.asciz "input4.txt"

test_output1:	 	.asciz "output1.txt"
test_output2:    	.asciz "output2.txt"
test_output3:    	.asciz "output3.txt"
test_output4:    	.asciz "output4.txt"
.text

.globl main_test_macrolib
main_test_macrolib:
	# ТЕСТ №1
	test test_input1, test_output1, test_1
	
	# ТЕСТ №2
	test test_input2, test_output2, test_2
	
	# ТЕСТ №3
	test test_input3, test_output3, test_3
	
	# ТЕСТ №4
	test test_input4, test_output4, test_4
	
	#Завершение
	print_str end_msg
    exit
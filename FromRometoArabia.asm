# From Rome to Arabia - Assignment 7
#
# Written by Neo Chung-kit YIU, 12 Jul 2016

.data
# Lookup tables to match the input roman with corresponding decimals
roman: .asciiz "IVXLCDM"
decimals: .byte 1, 5, 10, 50, 100, 500, 1000

# Input
input1: .word 4
input2: .asciiz "\n "   
input3: .asciiz "\n "   
input4: .asciiz "\n "

# Conversion
left: .word 0
sum: .word 0

# I/O session
convertAgain: .word 2
prompt1: .asciiz "\nPlease enter the Roman Number (in UPPERCASE): "
printResult: .asciiz "\nThe corresponding decimal is: "
loopAgain: .asciiz "\nTry another round? Press 1 to continue or 2 to terminate: "

end: .asciiz "\n\nThat's the end of the program.\n"

# Error handling
errorMsg: .asciiz "\nInvalid character(s). Please try again.\n"

#--------------------------------------------------------------------
.text

.globl main

main:

#Ask user to key in the Roman Numerals
li $v0, 4 # Print prompt1
la $a0, prompt1 # Load adr
syscall

# Load input1
la $a0, input1 
la $a1, input1      # Load the length
li $v0, 8 # Read string from user
syscall

sw $ra, 0($sp)      # return adr onto the stack
addi $sp, $sp, -4   # Move stack pointer  

# Go to sub-routines for lookup and conversion
jal lookup

lw $ra, 0($sp)      # return adr off the stack
addi $sp, $sp, 4    # Move stack pointer


# Display results

display:

# Display the decimal value
la $a0, printResult 
li $v0, 4           # print str
syscall

# Display the sum
lw $a0, sum 
li $v0, 1           # print int
syscall

# ask if the users would like to loop the process again
la $a0, loopAgain 
li $v0, 4           # print str
syscall

li $v0, 5 # Read int input
syscall

sw $v0, convertAgain #store the input of the decision
lw $t0, convertAgain

bne $t0, 1, Exit # !=1, jump to exit

move $s0, $zero     # reset $s0
sw $zero, sum       # reset sum
sw $zero, left      # reset left

j main # Go back to start if the user enters 1

#--------------------------------------------------------------------

# to convert roman numerals into decimal integers  

lookup:
sw $a1, 4($sp)
addi $sp, $sp, -4 	# move stack pointer

la $t2, input1 		# Load the adr of the str
la $t3, roman 		# Load the adr of the roman lookup table into $t3
la $t4, decimals 	# Load the adr of the decimal lookup table into $t4

# Loop through each char of the input str
loopChar:
lb $a0, ($t2) 		# get the next byte
beq $a0, 10, return # jump to return if it has reached the end
beq $a0, 1, return 	

#li $v0, 11 		# print byte to console
#syscall


sw $ra, 8($sp) 		# Return adr onto the stack
addi $sp, $sp, -4 	# move stack pointer

# While str[i] != null:
jal index

lw $ra, 8($sp) 		# return adr off stack
addi $sp, $sp, 4 	# move stack pointer

addi $t2, $t2, 1 	# move to next character in input str

sw $ra, 8($sp) 		# return adr onto the stack
addi $sp, $sp, -4 	# move stack pointer

jal loopChar 		# loop again

lw $ra, 8($sp) 		# return adr off the stack
addi $sp, $sp, 4 	# Move stack pointer

# look for the index of the roman table

index:
lb $t5, ($t3) 		# Load the first byte
beqz $t5, invalid 	# invalid character if couldnt find the table

beq $a0, $t5, lookValue # jump to lookValue to look for value of the character if it meets in the roman table

sw $ra, 12($sp) 		# return adr onto the stack
addi $sp, $sp, -4 		# Move stack pointer

jal reloop 				# jump toincrement $t3 and loop again

lw $ra, 12($sp) 		# return adr off the stack
addi $sp, $sp, 4 		# Move stack pointer

lookValue:
la $t6, roman 		# adr of the array containing Roman number characters
la $t7, decimals

sub $t8, $t3, $t6 	# the index value of the element that matches the byte
add $t7, $t7, $t8
lbu $t9, ($t7) 		# $t9 is the decimal value that corresponds to the letter
bgeu $t9, 232, adjust1

j gotValue

adjust1:

seq $a2, $t5, 68 		# set $a2 to 1; else, 0
mul $t9, $t9, $zero
beq $a2, 1, adjustD
addi $t9, $t9, 1000 	# M=1000

j gotValue

adjustD: 
addi $t9, $t9, 500

j gotValue

gotValue: 
sw $ra, 16($sp)
addi $sp, $sp, -4 		# move stack pointer

jal initSetup

addi $sp, $sp, 4 		# reset the stack pointer
lw $ra, 16($sp) 		# return adr off stack
# lw $t9, 12($sp) 		# fetch $t9

jr $ra 					# return   

# increment $t3 by 1 and loop

reloop:   
addi $t3, $t3, 1 
jal index

initSetup:
lw $s0, sum 			# Load sum into $s0
beqz $s0, base 			# add the first decimal value to sum and return to get the next char

sw $ra, 20($sp) 		# return adr onto stack
addi $sp, $sp, -4 		# Move stack pointer

jal calcSum 			# calculates the sum

addi $sp, $sp, 4 		# Reset the stack pointer
lw $ra, 20($sp) 		# return adr off stack
jr $ra 					# return adr

base: add $s0, $s0, $t9 # Add value of first char + 0 and store in $s0
sw $s0, sum 			# Store contents of $s0 in sum
sw $t9, left 			# Store contents of $t9 

la $t3, roman 		# Load adr of roman array into $t3 (reset pointer)
addi $t2, $t2, 1 	# select next char in input str

jal loopChar 		# Jump back to start of the loop

calcSum: addi $sp, $sp, 8 	# Reset the stack pointer
lw $t1, left 				# Pop the decimal value of the Roman number to the left  
sw $t9, left 				# Reset left pointer

la $t3, roman 			# Load adr of roman array into $t3 (reset pointer)
bge $t1, $t9, plus 		# add the current char value to the sum
blt $t1, $t9, minus 	# jump to minus if the previous is smaller than the cpurrent

plus: 
lw $s0, sum 		# Load sum into $s0
add $s0, $s0, $t9 	# Add current char's decimal value to sum
sw $s0, sum 		# Store the result in sum

la $t3, roman 		# Load adr of roman to reset the pointer
addi $t2, $t2, 1 	# Add 1 to $t2, so that we can select next char in input str

jal loopChar 		# Jump back to beginning of loop

minus: 
lw $s0, sum 		# Load sum into $s0
mul $t1, $t1, 2 	# Multiply $1 by 2
sub $t9, $t9, $t1 	# prev char - (2 * current char)
add $s0, $s0, $t9 	# Add to existing sum
sw $s0, sum 		# Store to sum   

la $t3, roman 		# Load adr of roman array to reset pointer
addi $t2, $t2, 1 	# select next char in input str

jal loopChar 		# jump back to the start of loop

# return to main   

return:
sw $s0, sum 		# Store sum
j display 			# Jump to display outpuT

# invalid users' inputs happen

invalid:
li $v0, 4 			# Print str
la $a0, errorMsg 	# Load adr for errorMsg
syscall

j main
 
# System Exit

Exit:
li $v0, 4 		# Print str
la $a0, end 	# Load adr of the message of end
syscall

li $v0, 10      # system call 10; exit
syscall

# Lottery Odds Program
#
# Written by Neo Chung-kit YIU, 8 Jul 2016

.data
prompt1: .asciiz "Key in the size of large pool: "
prompt2: .asciiz "Key in the count of numbers to be selected from the large pool: "
prompt3: .asciiz "Key in the size of second pool: "
prompt4: .asciiz "Key in the count of numbers to be selected from the second pool: "
str1: .asciiz "The odds are 1 in "
strEnd: .asciiz "This is the end of the program!"
newline:        .asciiz "\n"

.text
.globl main

main: 
                
                #       Initalize the size of the large pool
                li      $v0, 4                          # prompt for input of size of the large pool
                la      $a0, prompt1
                syscall
                li      $v0, 5                          # read in the prompt1
                syscall
                move $s3, $v0           

                #       Initalize the count of numbers for large pool
                li      $v0, 4                          # prompt for the count numbers for large pool
                la      $a0, prompt2
                syscall
                li      $v0, 5                          # read in the prompt2
                syscall
                move $s4, $v0     

                #       Initalize the size of the second pool
                li      $v0, 4                          # prompt for input of size of the second pool
                la      $a0, prompt3
                syscall
                li      $v0, 5                          # read in the prompt3
                syscall
                move $t1, $v0           

                #       Initalize the count of numbers for second pool
                li      $v0, 4                          # prompt for the count numbers for second pool
                la      $a0, prompt4
                syscall
                li      $v0, 5                          # read in the prompt4
                syscall
                move $t2, $v0    

                li  $v0, 4
                la  $a0, newline
                syscall             

                #		Subtraction process of large pool (n-r)
                sub $s5, $s3, $s4
                addi $s5, $s5, 1

                #		Subtraction process of second pool (n-r)
                sub $t3, $t1, $t2
                addi $t3, $t3, 1

                #       Calculate Factorial for count numbers of large pool (r!)
                move $a0, $s4
                jal factrl
                move $s1, $v0 

                #       Calculate Factorial for count numbers of second pool (r!)
                move $a0, $t2
                jal factrl
                move $t4, $v0

                # 	Call function while for large pool
				move $a0, $s3
				move $a1, $s5
				move $a2, $s4
				jal While
				move $s2, $v0

               	# 	Call function while for second pool
				move $a0, $t1
				move $a1, $t3
				move $a2, $t2
				jal While
				move $t5, $v0

                # 	Call function operation for large pool
                move $a0, $s2
                move $a1, $s1
                jal operation
                move $s6, $v0

				# 	Call function operation for second pool
                move $a0, $t5
                move $a1, $t4
                jal operation
                move $t6, $v0
  
                  # Multiply combinations of both pools
                mul $s7, $s6, $t6

                li      $v0, 4            # print result
                la      $a0, str1
                syscall  

                li $v0, 1
				move $a0, $s7
				syscall        

				li  $v0, 4
                la  $a0, newline
                syscall 

                li      $v0, 4            # print end message
                la      $a0, strEnd
                syscall  

                #       Exit
                li  $v0,10          # system call 10; exit
                syscall

#----------------------------------------------------------------
#
# Given n, in register $a0;
# calculates n! and stores the result in register $v0

factrl: 

sw $ra, 4($sp) # save the return address
sw $a0, 0($sp) # save the current value of n
addi $sp, $sp, -8 # move stack pointer
slti $t0, $a0, 2 # save 1 iteration, n=0 or n=1; n!=1

beq $t0, $zero, L1 # not, calculate n(n-1)!
addi $v0, $zero, 1 # n=1; n!=1
jr $ra # now multiply

L1: addi $a0, $a0, -1 # n = n-1
jal factrl # now (n-1)!
addi $sp, $sp, 8 # reset the stack pointer
lw $a0, 0($sp) # fetch saved (n-1)
lw $ra, 4($sp) # fetch return address
mul $v0, $a0, $v0 # multiply (n)*(n-1)
jr $ra # return value n!


While:
sw $ra, 4($sp) # save the return address
sw $a0, 0($sp) # save the current value of n
addi $sp, $sp, -8 # move stack pointer
slti $t0, $a2, 2

bgt $a0, $a1, L2 # not, calculate n(n-1)!
beq $t0, $0, print # if equals to zero, jump to add 1 to $v0
add $v0, $zero, $a1 # if r<2, assign the value of (n-r)+1 to $v0
jr $ra

print:
addi $v0, $zero, 1 # n=1; n!=1
jr $ra # now multiply

L2: addi $a0, $a0, -1 # n = n-1
jal While # now (n-1)!
addi $sp, $sp, 8 # reset the stack pointer
lw $a0, 0($sp) # fetch saved (n-1)
lw $ra, 4($sp) # fetch return address
mul $v0, $a0, $v0 # multiply (n)*(n-1)
jr $ra # return value


operation:

div $v0, $a0, $a1
jr $ra

######### End of the subroutine






























##############################################################

#Dynamic array

##############################################################

#   4 Bytes - Capacity

#   4 Bytes - Size

#   4 Bytes - Address of the Elements

##############################################################



##############################################################

#Song

##############################################################

#   4 Bytes - Address of the Name (name itself is 64 bytes)

#   4 Bytes - Duration

##############################################################





.data

space: .asciiz " "

newLine: .asciiz "\n"

tab: .asciiz "\t"

menu: .asciiz "\n● To add a song to the list-> \t\t enter 1\n● To delete a song from the list-> \t enter 2\n● To list all the songs-> \t\t enter 3\n● To exit-> \t\t\t enter 4\n"

menuWarn: .asciiz "Please enter a valid input!\n"

name: .asciiz "Enter the name of the song: "

duration: .asciiz "Enter the duration: "

name2: .asciiz "Song name: "

duration2: .asciiz "Song duration: "

emptyList: .asciiz "List is empty!\n"

noSong: .asciiz "\nSong not found!\n"

songAdded: .asciiz "\nSong added.\n"

songDeleted: .asciiz "\nSong deleted.\n"



copmStr: .space 64


sReg: .word 3, 7, 1, 2, 9, 4, 6, 5

songListAddress: .word 0 #the address of the song list stored here!

capacity: .asciiz "Capacity: "
size: .asciiz "size: "

.text 

main:



	jal initDynamicArray

	sw $v0, songListAddress

	

	la $t0, sReg

	lw $s0, 0($t0)

	lw $s1, 4($t0)

	lw $s2, 8($t0)

	lw $s3, 12($t0)

	lw $s4, 16($t0)

	lw $s5, 20($t0)

	lw $s6, 24($t0)

	lw $s7, 28($t0)



menuStart:

	la $a0, menu    

    li $v0, 4

    syscall



	li $v0,  5

    syscall

	li $t0, 1

	beq $v0, $t0, addSong

	li $t0, 2

	beq $v0, $t0, deleteSong

	li $t0, 3

	beq $v0, $t0, listSongs

	li $t0, 4

	beq $v0, $t0, terminate

	

	la $a0, menuWarn    

    li $v0, 4

    syscall

	b menuStart

	

addSong:

	jal createSong

	lw $a0, songListAddress

	move $a1, $v0

	jal putElement

	b menuStart

	

deleteSong:

	lw $a0, songListAddress

	jal findSong

	lw $a0, songListAddress

	move $a1, $v0

	jal removeElement

	b menuStart

	

listSongs:

	lw $a0, songListAddress

	jal listElements

	b menuStart

	

terminate:

	la $a0, newLine		

	li $v0, 4

	syscall

	syscall

	

	li $v0, 1

	move $a0, $s0

	syscall

	move $a0, $s1

	syscall

	move $a0, $s2

	syscall

	move $a0, $s3

	syscall

	move $a0, $s4

	syscall

	move $a0, $s5

	syscall

	move $a0, $s6

	syscall

	move $a0, $s7

	syscall

	

	li $v0, 10

	syscall




initDynamicArray:

	li $a0, 8
	li $v0, 9
	syscall
	
	
	move $t2, $v0 # 2 kapasiteli song arrayinin adresi t2 içinde
	
	
	li $a0, 12
	li $v0, 9
	syscall
	
	li $t0, 0 #size
	li $t1, 2 #capacity
	
	sw $t1, 0($v0) # store the content of t1 into the v0[0]
	sw $t0, 4($v0) # store the content of t0 into the v0[4]
	sw $t2, 8($v0) # store the content of t2 into the v0[8]

	jr $ra


putElement:

	move $t8, $a0
	 
	lw $t0, 0($a0) #  $t0 = capacity
	lw $t1, 4($a0) #  $t1 = size
	lw $t2, 8($a0) #  $t2 = dynamic array song elements adress 
	
	
 	mulo $t4 $t1, 4 
 	move $t5, $t2 # t5 = list adress 
 	
 	add $t4, $t5, $t4 # t4= index, t5 = base
  	
 	sw $a1, 0($t4) # put
 		
 	addi $t1, $t1, 1
 	sw $t1, 4($a0) # increment size and store it 
 	
 	beq $t0, $t1, doubleCapacity
 	bne $t0, $t1 ,exit

	doubleCapacity:

		mul $t0, $t0, 2 # double capacity in temporary register
		mul $t9, $t0, 4
	
		move $a0, $t9
		li $v0, 9
		syscall  # v0 = new adress of doubled size array
		
		sw $v0, 8($t8) #update address
		
		move $t3, $v0 # load base adress into the t3 (t3 = new ,t5 = old one)
		
		addi $t4, $zero, 0 # t4 is counter for copy process
			
		copy:   
			beq $t4, $t1, exit
			lw $t6, ($t5)
			
			sw $t6, ($t3)
			
			addi $t3, $t3, 4
			addi $t5, $t5, 4
			addi $t4, $t4, 1
			
			j copy
			


	exit:
	
	sw $t0, 0($t8) #update capacity
	
	li $v0, 4
	la $a0, songAdded
	syscall
	
	
	li $v0, 4
	la $a0, capacity
	syscall
	
	li $v0, 1
	lw $a0, 0($t8)
	syscall
	
	li $v0, 4
	la $a0, size
	syscall
	
	li $v0, 1
	lw $a0, 4($t8)
	syscall

	move $a0, $t8
	
	jr $ra



removeElement:
	
	lw $t0, 8($a0) #t0 = address
	move $t1, $a1 # t1 = index
	lw $t3, 4($a0) # t3 = size
	
	beq $t3, $zero, quit3

	addi $t2, $zero, 0 
	subu $t2, $t2, 1
	beq $t1, $t2, songIsNotFound
	
	
	mul $t5, $t1, 4
	add $t0, $t0, $t5 # t0 = silinecek şarkının adresi
	subu $t3, $t3, 1
	
	sw $t3, 4($a0) #store size
	dongu:
	beq $t1, $t3, quit
	lw  $t4, 4($t0)
	sw $t4, 0($t0)
	addi $t0, $t0, 4
	
	addi $t1, $t1, 1
	
	j dongu
	
	songIsNotFound:
	
	la $a0, noSong
	li $v0, 4
	syscall
	
	quit:
	move $t8, $a0
	lw $t0, 8($a0) #t0 = address
	lw $t1, 4($a0) # t1 = size
	lw $t2, ($a0) #capacity
	
	mul $t1, $t1, 2
	slt $t4, $t1, $t2 
	beq $t4, 0, quit2
	# eğerki 1 ise yani size yarısından az ise , decrease capasity
	div $t2, $t2, 2 #divide the capacity
	mul $t9, $t2, 4 # byte that needs to be allocated
	
	
	move $a0, $t9
	li $v0, 9
	syscall  # v0 = new adress of doubled size array
	
	sw $v0, 8($t8) #update address
	
	move $t5, $v0 # load base adress into the t5 (t5 = new ,t0 = old one)
		
	addi $t4, $zero, 0 # t2 is counter for copy process
	
	copyy:   
		beq $t4, $t1, exitt
		lw $t6, ($t0)
			
		sw $t6, ($t5)
			
		addi $t0, $t0, 4
		addi $t5, $t5, 4
			
			
		addi $t4, $t4, 1
			
		
		j copyy
			


	exitt:
	
	sw $t2, 0($t8) #update capacity
	
	li $v0, 4
	la $a0, songDeleted
	syscall
	
		
	li $v0, 4
	la $a0, capacity
	syscall
	
	li $v0, 1
	lw $a0, 0($t8)
	syscall
	
	li $v0, 4
	la $a0, size
	syscall
	
	li $v0, 1
	lw $a0, 4($t8)
	syscall
	
	quit2:
	
	jr $ra

	quit3:
	la $a0, emptyList
	li $v0, 4
	syscall
	jr $ra

listElements:
	
	#a0 songlistaddress
	lw   $t0, 0($a0)    
	lw   $t1, 4($a0)    
	lw  $t2, 8($a0)  
		
	beq $t1, $zero, exit3
	addi $t4, $zero, 0
	
	while:
		beq $t4, $t1, exit2
	
		move $a0, $t2  #song adress
		
		subu $sp, $sp, 4
		sw $ra, 0($sp)

		jal printElement

		lw $ra, 0($sp)
		addu $sp, $sp, 4
		
		
		add, $t2, $t2, 4
		addi $t4, $t4, 1
		j while
	
	
	exit2:
		jr $ra
	exit3:
		la $a0, emptyList
		li $v0, 4
		syscall
		jr $ra
compareString:
	
	la $t0, ($a0)
	la $t1, ($a1)
	move $t2, $a2 # comparison size 
	
	
	lw $t0, 0($t0) #listedeki şarkı
	la $t1, 0($t1) # silinmek istenen şarkı 
	
	
	
	li $t3, 0 # t3 = counter
	
	compare:
		lb $t4, ($t0)
		lb $t5, ($t1)
		
		beqz $t4,checkt1 #str1 end
		beqz $t5,missmatch
		
		bne $t4, $t5, missmatch
		addi $t0, $t0, 1
		addi $t1, $t1, 1
		j compare
	
	
	missmatch: 
	addi $v0,$zero, 0
	j endfunction
	checkt1:
	bnez $t5,missmatch
	addi $v0,$zero, 1

	endfunction:
	jr $ra


printElement:

	move $v0, $a0
	
	subu $sp, $sp, 4
	sw $ra, 0($sp)

	jal printSong

	lw $ra, 0($sp)
	addu $sp, $sp, 4
	#Write your instructions here!

	

	jr $ra



createSong:
	
	
	li $v0, 4
	la $a0, name
	syscall
	
	
	
     	li $a0, 8
     	li $v0, 9
     	syscall
     	
     	
     	move $t0, $v0  # $t0 = addres of 8 byte
     	
     	
     	li $a0, 61
     	li $v0, 9
     	syscall
     	
     	move $t8, $v0
     	
 	li $a1, 61
     	move $a0, $t8
     	li $v0, 8
     	syscall
     	
     	move $t1, $a0  # $t1 = adress of the song 
     	
     	li $v0, 4
	la $a0, duration
	syscall
	
	
	li $v0, 5
	syscall
	
	move $t2, $v0 # $t2 = song duration 
	
	sw $t1, ($t0)
	sw $t2, 4($t0)
	
	move $v0, $t0

	jr $ra



findSong:

	move $t8, $a0
	lw $t7, 8($a0)
	lw $t6, 4($a0)  #t6 = size
	
	
 	li $v0, 8       # take in input
    	la $a0, copmStr  # load byte space into address
    	li $a1, 61 
    	syscall
    	
    	la $a1, copmStr # song for delete
    	li $a2, 61 # a2 = comparison size 
    	
	addi $t9, $zero, 0 # t9 = index
		
	find:	
	beq $t9, $t6, no
		
	lw $a0, ($t7)	
		
  	subu $sp, $sp, 4
	sw $ra, 0($sp)

	jal compareString


	lw $ra, 0($sp)
	addu $sp, $sp, 4
    	
    	beq $v0, 1, yes
    	
    	
    	
    	addi $t7, $t7, 4
    	addi $t9, $t9, 1

    	j find
    
	yes:
    	move $v0, $t9
    	jr $ra
   
	no:
	addi $v0, $zero, 0
	subu $v0, $v0, 1
	
						
	jr $ra

	#Write your instructions here!

printSong:
	lw $t5, ($v0)

	li $v0, 4
	la $a0, name2
	syscall 
		
	li $v0,4
	lw $a0, 0($t5)	
	syscall
	
	li $v0, 4
	la $a0, duration2
	syscall 
		
	li $v0,1
	lw $a0, 4($t5)	
	syscall
		
	li $v0, 4
	la $a0, newLine
	syscall 
		
	jr $ra

additionalSubroutines:








.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#   If any file operation fails or doesn't read the proper number of bytes,
#   exit the program with exit code 1.
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
#
# If you receive an fopen error or eof, 
# this function exits with error code 50.
# If you receive an fread error or eof,
# this function exits with error code 51.
# If you receive an fclose error or eof,
# this function exits with error code 52.
# ==============================================================================
read_matrix:

    # Prologue
	addi sp, sp, -28
    sw ra, 0(sp)
    sw s0, 4(sp) #will hold int pointer
    sw s1, 8(sp) 
    sw s2, 12(sp)
    sw s3, 16(sp)

    #Set Variables
    mv s1, a0 #s1 holds the file name
    mv s2, a1 #holds num rows
    mv s3, a2 #holds num cols

    #Open the file
    mv a1, s1 #a1 holds file name
    li a2, 0 #permission = r

    jal fopen 
    
    li t0, 0
    blt a0, t0, error_return_fopen #if a0 = -1, fopen failed
    
    mv s1, a0 #s1 now holds file descripter

    #Fread in rows and cols into pointers
    mv a1, s1 #move in file descripter
    mv a2, s2 #want to write to row pointer
    li a3, 4 #load in four bytes

    jal fread
	
    li t0, 4
    blt a0, t0, error_return_fread #if read less than 4 bytes

    mv s2, a2 #move in address of row pointer

    mv a1, s1 #move in file descripter
    mv a2, s3 #want to write to col pointer
    li a3, 4 #load in four bytes

    jal fread
	
    li t0, 4
    blt a0, t0, error_return_fread #if read less than 4 bytes

    mv s3, a2 #move in address of col pointer

    #Malloc the correct space
    lw t5, 0(s2) #num of rows 
    lw t6, 0(s3) #num of col 
    mul t5, t5, t6 #total elements is row * cols
    slli t5, t5, 2 #total elements in bytes needed to malloc

    mv a0, t5 #prep num bytes to malloc 

    sw t5, 20(sp) #store total elements in bytes
    sw t6, 24(sp)

    jal malloc 
    
    beq a0, x0, error_return_malloc #if a0 = 0, malloc failed (null)

    lw t5, 20(sp)
    lw t6, 24(sp)

    mv s0, a0 #s0 holds malloced matrix

    #fread rest of elements in malloced matrix
    mv a1, s1 #move in file descripter
    mv a2, s0 #move in pointer to buffer
    mv a3,  t5 #move in number of bytes to read

    jal fread 

    blt a0, t5, error_return_fread #if read less than the total number of elements in bytes

    mv s0, a2 #store the read in matrix back into s0 

    #Fclose the file
    mv a1, s1 #move in file descripter

    jal fclose

    li t3, 0
    blt a0, t3, error_return_fclose #if fopen fails (a0 = -1)

    # Epilogue
    mv a0, s0 #move pointer to matrix in memory for return
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp) 
    lw s2, 12(sp)
    lw s3, 16(sp)
    addi sp, sp 28

    ret

error_return_malloc:
    li a1, 48
    j exit2

error_return_fopen:
    li a1, 50
    j exit2

error_return_fread:
    li a1, 51
    j exit2

error_return_fclose:
    li a1, 52
    j exit2

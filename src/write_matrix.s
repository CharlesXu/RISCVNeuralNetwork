.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
#   If any file operation fails or doesn't write the proper number of bytes,
#   exit the program with exit code 1.
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
#
# If you receive an fopen error or eof, 
# this function exits with error code 53.
# If you receive an fwrite error or eof,
# this function exits with error code 54.
# If you receive an fclose error or eof,
# this function exits with error code 55.
# If malloc error, code 56
# ==============================================================================
write_matrix:
    # USES t0 and t1
    # Prologue

    addi sp, sp, -28
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)

    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3

# open file
    li t0, 53 # fopen error code

    mv a1, s0
    li a2, 1 # 1 for write
    jal ra fopen
    # fopen returns a0 file descriptor
    li t1, -1 # check if a0 is -1
    beq a0, t1, error

    mv s4, a0 # move file descriptor into s3

# write to file
    # first print row and column
    # need to malloc space for ints
    li a0, 8
    jal ra malloc
    li t0, 56
    beq a0, x0, error # malloc failed
    mv t1, a0 # t1 points to memory for 2 ints
    
    # store row and column into array
    sw s2, 0(t1)
    sw s3, 4(t1)

    # write row and col
    mv a1, s4 # move file descriptor
    mv a2, t1
    li a3, 2 # 2 elements
    li a4, 4 # 4 bytes per elements
    jal ra fwrite
    li t0, 54 # fwrite error code
    li a4, 2

    # addi sp, sp, -4
    # sw a0, 0(sp)

    # mv a1, a0
    # jal ra print_int

    # li a1 '\n'
    # jal ra print_char

    # lw a0, 0(sp)
    # addi sp, sp, 4

    bne a0, a4, error # a0 number of elements written into file

    # write rest of matrix
    mv a1, s4 # move file descriptor
    mv a2, s1 # move pointer to memory into a2
    mul s5, s2, s3 # total number of elements
    mv a3, s5 # number of elements for fwrite
    li a4, 4 # each element is 4 bytes
    jal ra fwrite
    li t0, 54 # fwrite error code
    bne a0, s5, error # a0 number of elements written into file

# close the file
    mv a1, s4 # move file descriptor
    jal ra fclose
    # a0 is 0 on success, -1 otherwise
    li t0, 55 # fclose error code
    bne a0, x0, error

    # no errors
    j no_error

error:
    mv a1, t0 # move error code into a1
    j exit2

no_error:
    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    addi sp, sp, 28

    ret

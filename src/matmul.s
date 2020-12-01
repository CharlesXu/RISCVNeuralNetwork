.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
#   The order of error codes (checked from top to bottom):
#   If the dimensions of m0 do not make sense, 
#   this function exits with exit code 2.
#   If the dimensions of m1 do not make sense, 
#   this function exits with exit code 3.
#   If the dimensions don't match, 
#   this function exits with exit code 4.
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# =======================================================
matmul:

    # Error checks
    blt a1, x0, error_return2 #rows of m0 < 0
    blt a2, x0, error_return2 #cols of m0 < 0
    blt a4, x0, error_return3 #rows of m1 < 0
    blt a5, x0, error_return3 #cols of m1 < 0
    bne a1, a5, error_return4 #if m0 rows not equal to m1 cols
    bne a2, a4, error_return4 #if m0 cols not equal to m1 rows

    # Prologue
    addi sp, sp, -56
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)

    mv s0, a0 #pointer to m0
    mv s2, a1 #rows m0
    mv s3 , a2 #cols m0
    mv s1, a3 #pointer to m1
    mv s4, a4 #rows m1
    mv s5 , a5 #cols m1
    mv s6, a6 #s6 will hold the address of d

    mv t6, a3 #t6 will be used to hold the starting address of m1 after every inner loop
    
    li t2, 4 #prepping row offset for m0 address
    mul t2, t2, s3 #t2 = row offset in bytes for each row of m0

    li t0, 0 #i = 0

outer_loop_start:
    beq t0, s2, outer_loop_end #if i = m0 rows
    li t1, 0 #j = 0
    mv a0, s0 #pointer to row start
    mv a2, s3 #length of vector is cols of m0
    li a3, 1 #stride of v0 is 1 always
    mv s1, t6 #start at first index of m1 again
    j inner_loop_start

inner_loop_start:
	mv a0, s0 #pointer to row start
    beq t1, s5, inner_loop_end #if j = m1 cols
    mv a4, s4 #stride for v1 = row length of m1
    mv a1, s1 #move in curr col of m1
	
    sw t0, 28(sp)
    sw t1, 32(sp)
    sw t3, 36(sp)
    sw t2, 40(sp)
    sw t6, 44(sp)
    sw a6, 48(sp)

    jal dot
     
    lw t0, 28(sp)
    lw t1, 32(sp)
    lw t3, 36(sp)
    lw t2, 40(sp)
    lw t6, 44(sp)
    lw a6, 48(sp)


    sw a0, 0(s6) #store dot product at d[i]
    addi s6, s6, 4 #increment to d[i + 1]

    addi s1, s1, 4 #go one col over increment address by one byte
    addi t1, t1, 1 #j++
    j inner_loop_start

inner_loop_end:
    add s0, s0, t2 #shifts memory address of m0 to next row
    addi t0, t0, 1 #i++
    j outer_loop_start



outer_loop_end:

    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)

    addi sp, sp, 56
    ret


error_return2:
    li a0, 2
    j exit2

error_return3:
    li a0, 3
    j exit2

error_return4:
    li a0, 4
    j exit2
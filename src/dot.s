.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
#
# If the length of the vector is less than 1, 
# this function exits with error code 5.
# If the stride of either vector is less than 1,
# this function exits with error code 6.
# =======================================================
dot:
    # Prologue
	addi sp, sp, -4
    sw ra, 0(sp)
	li t0, 1 
    blt a2, t0, error_return_length #check if length < 1
    blt a3, t0, error_return_stride #check if stride < 1
    blt a4, t0, error_return_stride #check if stride < 1
    mv t0, a0 #v0 address pointer
    mv t1, a1 #v1 address pointer
	li t2, 0 #i = 0
    li t6, 0 #total sum = 0
    li t5, 4 #num of bytes offset
    mul a5, a3, t5 #a5 = stride * 4 to get address v0
    mul a6, a4, t5 #a6 = stride * 4 to get addres v1

loop_start:
    beq a2,t2,loop_end #if (i == length of vector) loop is done
    lw t3, 0(t0) #t3 = element of v0
    lw t4, 0(t1) #t4 = element of v1
    add t0, t0, a5 #v0 next element with stride
    add t1, t1, a6 #v1 next element with stride
    mul t3, t3, t4 #t3 = multiply elements together
    add t6, t6, t3 #sum += current dot product
    addi t2, t2, 1 #i++
    j loop_start

loop_end:
    # Epilogue
    mv a0, t6 #prep return the total sum
	lw ra, 0(sp)
    addi sp, sp, 4
	ret

error_return_length:
    li a1, 5
    j exit2

error_return_stride:
    li a1, 6
    j exit2
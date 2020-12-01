.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
#
# If the length of the vector is less than 1, 
# this function exits with error code 7.
# =================================================================
argmax:
    # Prologue
	addi sp, sp, -4
    sw ra, 0(sp)
	li t0, 1 
    blt a1, t0, error_return #check if length < 1
    mv t0, a0 #arr pointer
    mv t1, a1 #length of arr
	li t2, 0 #i = 0
    li t3, 0 #max element = 0
    li t5, 0 #max index = 0

loop_start:
    beq t2, t1, loop_end
    lw t4, 0(t0) # t4 = arr[i]
    bge t4, t3, loop_continue #if (t4 > t3)
    addi t2, t2, 1 #i++
    addi t0, t0, 4 #arr[i + 1]
    j loop_start

loop_continue:
    mv t3, t4 #new max element moved in
    mv t5, t2 #new max ele index stored
    addi t2, t2, 1 #i++
    addi t0, t0, 4 #arr[i + 1]
    j loop_start

loop_end:
    # Epilogue
    mv a0, t5 #prep return index
	lw ra, 0(sp)
    addi sp, sp, 4
	ret

error_return:
    li a1, 7
    j exit2
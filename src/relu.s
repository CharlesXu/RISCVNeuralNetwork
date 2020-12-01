.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
#
# If the length of the vector is less than 1, 
# this function exits with error code 8.
# ==============================================================================
relu:
    # Prologue
	addi sp, sp, -4
    sw ra, 0(sp)
	li t0, 1 
    blt a1, t0, error_return #check if length < 1
    mv t0, a0 #arr pointer
    mv t1, a1 #length of arr
	li t2, 0 #i = 0

loop_start:
    beq t2,t1,loop_end #if (i = length of arr) loop done
    lw t3, 0(t0) #load in element of arr
    bge t3, x0, loop_continue #if arr[i] > 0
    li t3, 0
    sw t3, 0(t0) #if negative store as 0
    j loop_continue

loop_continue:
	addi t0, t0, 4 #increment address to next element in arr
    addi t2, t2, 1 #increment i variable
	j loop_start

loop_end:
    # Epilogue
	lw ra, 0(sp)
    addi sp, sp, 4
	ret

error_return:
    li a1, 8
    j exit2
    


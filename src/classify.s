.globl classify

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # 
    # If there are an incorrect number of command line args,
    # this function returns with exit code 49.
    #
    # exit code 60 if malloc fails
    #
    # Usage:
    #   main.s -m -1 <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>

    addi sp, sp, -36
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)

    mv s1, a2 # store print classification

    # =====================================
    # REGISTERS
    # t0 - error code
    # t1 - number of args, then pointer to m0 path
    # t2 - pointer to m1 path
    # t3 - pointer to input path
    # t4 - pointer to output path
    #
    # 0(s0) - rows of m0
    # 4(s0) - cols of m0
    # 8(s0) - rows of m1
    # 12(s0) - cols of m1
    # 16(s0) - rows of input
    # 20(s0) - cols of input
    # s1 - print classification
    # s2 - pointer to matrix m0 in memory
    # s3 - pointer to matrix m1 in memory
    # s4 - pointer to matrix input in memory
    # s5 - pointer to m0 * input matrix
    # s6 - pointer to scores = m1 * relu(m0 * input)
    # s7 - index value of largest element from argmax in scores
    #
    # =====================================

    li t1, 5 # number of args
    li t0, 49 # load error code into a1
    beq a0, t1, no_error # if argc equals 5, no issues

error:
    mv a1, t0
    j exit2 # exit with error

save_t:
    # save t registers before function call
    addi sp, sp, -20
    sw t0, 0(sp)
    sw t1, 4(sp)
    sw t2, 8(sp)
    sw t3, 12(sp)
    sw t4, 16(sp)

    # ra should've been saved before
    jr ra


retrieve_t:
    # retrieve t regsiters after function call
    lw t0, 0(sp)
    lw t1, 4(sp)
    lw t2, 8(sp)
    lw t3, 12(sp)
    lw t4, 16(sp)
    addi sp, sp, 20

    # ra should've been saved before
    jr ra

no_error:

    # get file paths
    # ASSUMING a pointer is 4 bytes
    # loads a word (4 bytes) from argv
    # a1 has not been changed up to this point, and now we won't need it
    # 0(a1) is the filename (main.S)
    lw t1, 4(a1)
    lw t2, 8(a1)
    lw t3, 12(a1)
    lw t4, 16(a1)

	# =====================================
    # LOAD MATRICES
    # =====================================


    # malloc for int pointers to rows and column
    li a0, 24 # need 24 bytes for 6 ints
    jal ra malloc
    li t0, 60 # error code for malloc fail
    beq a0, x0, error # malloc failed
    mv s0, a0 # move a0 malloc location to s0
    
#   read_matrix
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns

load_m0:
    # Load pretrained m0
    mv a0, t1 # filepath
    mv a1, s0 # pointer to int for row
    addi a2, s0, 4 # read 4 bytes after s0 for columns
    # save t registers
    jal ra save_t
    jal ra read_matrix
    # read_matrix would exit with error code if something failed, we don't have to handle
    jal ra retrieve_t
    mv s2, a0 # s2 holds pointer to matrix m0 in memory

load_m1:
    # Load pretrained m1
    mv a0, t2 # filepath for m1
    addi a1, s0, 8 # pointer to rows of m1
    addi a2, s0, 12 # pointer to cols of m1
    # save t registers
    jal ra save_t
    jal ra read_matrix
    jal ra retrieve_t
    mv s3, a0 # s3 holds pointer to matrix m1 in memory

load_input:
    # Load input matrix
    mv a0, t3 # filepath for input
    addi a1, s0, 16 # pointer to rows for input
    addi a2, s0, 20 # pointer to cols for input
    jal ra save_t
    jal ra read_matrix
    jal ra retrieve_t
    mv s4, a0 # s4 holds pointer to matrix input in memory




    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)


linear_layer1:
    # first malloc for linear layer output matrix
    # m0 * input
    
    # load row and column values of output array for malloc
    lw a1, 0(s0)
    lw a2, 20(s0)
    mul a0, a1, a2
    slli a0, a0, 2 # a0 is number of bytes we want for malloc
    # malloc uses a0 and a1
    jal ra malloc
    li t0, 60 # error code for malloc fail
    beq a0, x0, error # malloc failed
    mv s5, a0 # s5 is pointer to malloc'd space for output matrix

    # call matmul on m0 * input
    mv a0, s2 # start of m0
    lw a1, 0(s0)
    lw a2, 4(s0)
    mv a3, s4 # start of input
    lw a4, 16(s0)
    lw a5, 20(s0)
    mv a6, s5


    # addi sp, sp, -12
    # sw a0, 0(sp)
    # sw a1, 4(sp)
    # sw a2, 8(sp)
    # lw a1, 20(s0)
    # jal ra print_int
    # lw a0, 0(sp)
    # lw a1, 4(sp)
    # lw a2, 8(sp)
    # addi sp, sp, 12

    jal ra save_t
    jal ra matmul
    jal ra retrieve_t
    # s5 should be pointing to the filled matrix now

nonlinear_layer:
    # relu in place

    mv a0, s5 # pointer to array to be ReLu'd
    lw a1, 0(s0) # rows of m0
    lw a2, 20(s0) # cols of input
    mul a1, a1, a2 # number of elements in array
    jal ra save_t
    jal ra relu
    jal ra retrieve_t
    # s5 now points to relu'd matrix


# matmul
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

linear_layer2:
    # get scores = m1 * (matrix pointed to by s5)

    # first malloc space for scores matrix
    lw a0, 8(s0) # rows of m1
    lw a1, 20(s0) # column of s5 matrix
    mul a0, a0, a1 # number of elements in scores
    slli a0, a0, 2 # number of bytes for malloc
    # malloc uses a0 and a1
    jal ra malloc
    li t0, 60 # error code for malloc fail
    beq a0, x0, error # malloc failed
    mv s6, a0 # s6 points to malloc'd space for scores matrix

    # call matmul
    mv a0, s3 # pointer to matrix m1 in memory
    lw a1, 8(s0) # rows of m1
    lw a2, 12(s0) # cols of m1
    mv a3, s5 # pointer to start of relu'd hidden layer
    lw a4, 0(s0) # rows of s5 matrix
    lw a5, 20(s0) # column of s5 matrix
    mv a6, s6 # pointer to malloc'd scores matrix
    jal ra save_t
    jal ra matmul
    jal ra retrieve_t
    # s6 should be pointing to filled matrix now

    # for debugging, prints matrix
    # addi sp, sp, -12
    # sw a0, 0(sp)
    # sw a1, 4(sp)
    # sw a2, 8(sp)
    # lw a1, 16(s0)
    # mv a0, s6
    # li a1, 3
    # li a2, 1
    # jal ra print_int_array
    # lw a0, 0(sp)
    # lw a1, 4(sp)
    # lw a2, 8(sp)
    # addi sp, sp, 12


    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix

# write matrix
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix

write_output_matrix:
    mv a0, t4 # filepath for write matrix
    mv a1, s6 # pointer to start of matrix
    lw a2, 8(s0) # rows of m1 and scores
    lw a3, 20(s0) # cols of input and scores
    jal ra save_t
    jal ra write_matrix
    jal ra retrieve_t


    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax

call_argmax:
    # 0(s0) - rows of m0
    # 4(s0) - cols of m0
    # 8(s0) - rows of m1
    # 12(s0) - cols of m1
    # 16(s0) - rows of input
    # 20(s0) - cols of input
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector

    mv a0, s6 # start of scores
    lw a1, 8(s0) # rows of m1 and scores
    lw a2, 20(s0) # cols of input and scores
    mul a1, a1, a2 # number elements in the array
    jal ra save_t
    jal ra argmax
    jal ra retrieve_t
    # a0 is the first index of the largest element
    # apparently that is what needs to be returned, not the value
    # slli a0, a0, 2 # multiply by 4 to get number of bytes from s6
    # add a0, a0, s0 # memory address of the largest address
    # lw s7, 0(a0) # s7 stores largest value from argmax
    mv s7, a0


    bne s1, x0, no_print # if s1 is not 0, don't print

    # Print classification
    mv a1, s7 # int to be printed
    jal ra print_int # uses a0 and a1

    # Print newline afterwards for clarity
    li a1 '\n'
    jal ra print_char

no_print:

    mv a0, s7 # return classification

    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    addi sp, sp, 36

    ret
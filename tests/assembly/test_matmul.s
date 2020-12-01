.import ../../src/matmul.s
.import ../../src/utils.s
.import ../../src/dot.s

# static values for testing
.data
m0: .word 1 2 3 4 5 6 7 8 9
m1: .word 1 2 3 4 5 6 7 8 9
d: .word 0 0 0 0 0 0 0 0 0 # allocate static space for output

.text
main:
    # Load addresses of input matrices (which are in static memory), and set their dimensions
    
    la s0 m0
    la s1 m1
    la s2 d

    # Call matrix multiply, m0 * m1

    #   a0 (int*)  is the pointer to the start of m0 
    #	a1 (int)   is the # of rows (height) of m0
    #	a2 (int)   is the # of columns (width) of m0
    #	a3 (int*)  is the pointer to the start of m1
    # 	a4 (int)   is the # of rows (height) of m1
    #	a5 (int)   is the # of columns (width) of m1
    #	a6 (int*)  is the pointer to the the start of d

    mv a0, s0
    mv a3, s1
    mv a6, s2
    li a1, 3
    li a2, 3
    li a4, 3
    li a5, 3
    jal ra matmul


    # Print the output (use print_int_array in utils.s)

    mv a0, s2
    li a1, 3
    li a2, 3
    jal ra print_int_array

    # Exit the program
    jal exit
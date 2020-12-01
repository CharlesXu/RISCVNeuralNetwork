.import ../../src/read_matrix.s
.import ../../src/utils.s

.data
file_path: .asciiz "inputs/test_read_matrix/test_input.bin"
row: .word 0
col: .word 0

.text
main:
    # Read matrix into memory
    la s0, row
    la s1, col
    la s2, file_path
    
    mv a0, s2
    mv a1, s0
    mv a2, s1

    jal ra read_matrix

    # Print out elements of matrix

    mv a0, a0 # start of array is at a0
    lw s0, 0(s0)
    lw s1, 0(s1)
    mv a1, s0
    mv a2, s1
    jal ra print_int_array

    # Terminate the program
    jal exit
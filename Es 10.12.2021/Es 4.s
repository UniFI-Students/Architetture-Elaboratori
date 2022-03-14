.data

a:    .word 1
b:    .word 2
c:    .word 3
d:    .word 4
e:    .word 5

.text
    
    # a0 contains result of 
    # 1. (a + b + c) * 2 + d - e
    # 2. 3 * a + e * 2 - (d + e)
    # 3. 7 * b + (a + c) - d - 6 * b 
    
    lw s0, a
    lw s1, b
    lw s2, c
    lw s3, d
    lw s4, e
    
    
    # (a + b + c) * 2 + d - e
    li t0, 0
    add t0, s0, s1
    add t0, t0, s2
    slli t0, t0, 1
    add t0, t0, s3
    sub t0, t0, s4
    
    li a0, 0
    add a0, a0, t0
    li a7, 1
    ecall
    
    # 3 * a + e * 2 - (d + e)
    li t0, 0
    addi t0, s0, 0
    li t1, 0
    add t1, t1, s4
    li t2, 0
    add t2, t2, s3
    
    slli t0, t0, 2
    sub t0, t0, s0
    
    slli t1, t1, 1
    
    add t2, t2, s4
    
    add t0, t0, t1
    sub t0, t0, t2
    
    li a0, 0
    add a0, a0, t0
    li a7, 1
    ecall
    
    
    # 7 * b + (a + c) - d - 6 * b 
    li t0, 0
    li t1, 0
    li t2, 0
    
    add t0, t0, s1
    slli t0, t0, 3
    sub t0, t0, s1
    
    add t0, t0, s0
    add t0, t0, s2
    sub t0, t0, s3
    
    add t1, t1, s1
    add t2, t2, s1
    
    slli t1, t1, 3
    slli t2, t2, 1
    sub t1, t1, t2
    
    sub t0, t0, t1
    
    li a0, 0
    add a0, a0, t0
    li a7, 1
    ecall
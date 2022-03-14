.data
a:    .word 12
b:    .word -2
c:    .word 4
newline: .string "\n"

.text

    # (a+b)*16
    lw t0, a
    lw t1, b
    add t0, t0, t1
    slli a0, t0, 4
    
    
    li a7, 1
    ecall
    
    la a0, newline
    li a7, 4
    ecall
    
    
    #c+(a-b)/2
    lw t0, c
    lw t1, a
    lw t2, b
    sub t1, t1, t2
    
    srli t1, t1, 1
    add a0, t0, t1
    
    li a7, 1
    ecall
    
    la a0, newline
    li a7, 4
    ecall
    
    
    
    #a*20
    lw t0, a
    lw t1, a
    slli t0, t0, 4
    slli t1, t1, 2
    
    add a0, t0, t1
    
    li a7, 1
    ecall
    
    la a0, newline
    li a7, 4
    ecall
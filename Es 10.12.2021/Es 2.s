.data

b:    .word 7
c:    .word 3
d:    .word 5


.text
    # a0 = a
    
    lw t0, b
    lw t1, c
    lw t2, d
    
    add a0, t0, t1
    add a0, a0, t2
    addi a0, a0, 10
.data

g:    .word 7
h:    .word 2
i:    .word 5
j:    .word 3

.text

    # a0 = f
    lw t0, g
    lw t1, h
    lw t2, i
    lw t3, j
    
    add s0, t0, t1
    add s1, t2, t3
    
    sub a0, s0, s1
.data

b:    .word 7
c:    .word 2
d:    .word 3
f:    .word -3

# a = b + c + d
# e = f - a

.text

    # a = b + c 
    lw t0 b
    lw t1 c 
    add s0, t0, t1
    
    # a = a + d
    lw t0 d
    add s0, s0, t0
    
    # e = f - a 
    lw t0 f
    sub s1, t0, s0
    
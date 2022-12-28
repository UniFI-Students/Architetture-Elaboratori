.data

mycypher: .string "Security"
myplaintext: .string "test"

#Should be declared last, 
#because it will grow after applying cryptography by occurrences
cryptedtext: .string ""  

.text

j main


#length(a0)
#Takes:
#    a0 - adress of the string
#Returns:
#    a0 - length
length:
    addi t0, a0, 0

    length_loop:    
        lb t1, 0(t0)
        beq t1, zero, length_end_loop
        addi t0, t0, 1
        j length_loop

    length_end_loop:
        sub a0, t0, a0
        jr ra

#findNextLetterOccurenceInTheString(a0, a1, a2)
#Takes:
#    a0 - adress of the string
#    a1 - offset
#    a2 - letter
#Returns:
#    a0 - index of the next letter occurence
findNextLetterOccurenceInTheString:
    add t0, a0, a1

    while_notFoundLetter_Or_EndOfString:    
        lb t1, 0(t0)
        beq t1, zero, failedSearch_loop_end
        beq t1, a2, successfulSearch_loop_end
        addi t0, t0, 1
        j while_notFoundLetter_Or_EndOfString

    successfulSearch_loop_end:    
        sub a0, t0, a0
        jr ra
        
    failedSearch_loop_end:
        li a0, -1
        jr ra
    

#isBetween(a0, a1, a2)
#Takes:
#    a0 - value 
#    a1 - left boundary
#    a2 - right boundary
#Returns:
#    a0 - true if a0 was in range between a1 and a2 inclusive
isBetween:
    li t0, 0
    li t1, 0
    
    
    #if a0 >= a1 then t0 = 1
    slt t0, a0, a1
    xori t0, t0, 1
    
    #if a0 <= a2 then t1 = 1
    slt t1, a2, a0
    xori t1, t1, 1
    
    and a0, t0, t1
    jr ra

#isLetter(a0)
#Takes:
#    a0 - symbol
#Returns:
#    a0 - true if a0 is letter
isLetter:    
    addi sp, sp, -8
    sw ra, 4(sp)
    sw a0, 0(sp)
 
    #if a0 is capital letter then return true
    #else check if a0 is small letter
    jal isCapitalLetter
    li t1, 1
    beq a0, t1, return_isLetter
 
    lw a0, 0(sp)
    
    jal isSmallLetter
    
return_isLetter:   
    lw ra, 4(sp)
    addi sp, sp, 8
    
    jr ra
    

#isCapitalLetter(a0)
#Takes:
#    a0 - symbol
#Returns:
#    a0 - true if a0 was capital letter
isCapitalLetter:
    addi sp, sp, -4
    sw ra, 0(sp)
    
    #if a0 >= 65 && a0 <= 90 then a0 = 1
    li a1, 65
    li a2, 90
    jal isBetween
    
    lw ra, 0(sp)
    addi sp, sp, 4
    
    jr ra

#isSmallLetter(a0)
#Takes:
#    a0 - symbol
#Returns:
#    a0 - true is a0 was small letter
isSmallLetter:
    addi sp, sp, -4
    sw ra, 0(sp)
    
    #if a0 >= 97 && a0 <= 122 then a0 = 1
    li a1, 97
    li a2, 122
    jal isBetween
    
    lw ra, 0(sp)
    addi sp, sp, 4
    
    jr ra

#isNumber(a0)
#Takes:
#    a0 - symbol
#Returns:
#    a0 - true if a0 was number
isNumber:
    addi sp, sp, -4
    sw ra, 0(sp)
    
    #if a0 >= 48 && a0 <= 57 then a0 = 1
    li a1, 48
    li a2, 57
    jal isBetween
    
    lw ra, 0(sp)
    addi sp, sp, 4
    
    jr ra

#mod(a0, a1)
#Takes:
#    a0 - dividend
#    a1 - divisor

#Returns:
#    a0 - reminder 

mod:
    addi t0, a0, 0
    addi t1, a1, 0
    
    bge t0, t1, sub_loop_mod  
    bgt t0, zero, end_loop_mod

#add untill original value is less than zero
#(in case of negative original value)
add_loop_mod:
    add t0, t0, t1
    blt t0, zero, add_loop_mod
    j end_loop_mod

#subtract untill original value is bigger than modulo value
sub_loop_mod:
    sub t0, t0, t1
    bge t0, t1, sub_loop_mod
    
end_loop_mod:
    addi a0, t0, 0
    jr ra


#printNumber(a0)
#Takes:
# a0 - number
printNumber:
    li a7, 1
    ecall
    jr ra

main:
    la a0, myplaintext
    li a1, 0
    li a2, 116
    jal findNextLetterOccurenceInTheString
    jal printNumber



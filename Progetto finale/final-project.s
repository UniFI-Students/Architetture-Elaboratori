.data
A: .byte 65
B: .byte 66
C: .byte 67
D: .byte 68
E: .byte 69
Newline: .byte 10


mycypher: .string "ABCDE"
myplaintext: .string "test"
sostK: .word -2
blockKey: .string "OLE"

#Should be declared last, 
#because it will grow after applying encryption by occurrences
encryptedtext: .string ""  

.text

j main

#copyString(a0, a1)
#Takes:
#    a0 - adress of the string to copy to
#    a1 - adress of the string to copy from
copyString:
    addi t0, a0, 0
    addi t1, a1, 0
    
    
    copyString_loop:
        lb t2, 0(t1)
        sb t2, 0(t0)
        beq t2, zero, copyString_endLoop 
        addi t0, t0, 1
        addi t1, t1, 1
        j copyString_loop
    
    copyString_endLoop:
        jr ra
    

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
#    a0 - number
printNumber:
    li a7, 1
    ecall
    jr ra

#printString(a0)
#Takes:
#    a0 - adress of the string
printString:
    li a7, 4
    ecall  
    jr ra
    
#printNewLine()
printNewLine:
    #save a0 to t0 so it wont affect later on a0
    #(used for chaining methods execution)
    addi t0, a0, 0
    
    lb a0, Newline
    li a7, 11
    ecall    
    
    addi a0, t0, 0
    jr ra


main:
    la s0, mycypher
    la s1, encryptedtext
    la s2, myplaintext
    
    lb s3, A
    lb s4, B
    lb s5, C
    lb s6, D
    lb s7, E
    
    
    addi a0, s0, 0
    jal length
    addi s8, a0, 0
    
    addi a0, s1, 0
    addi a1, s2, 0
    jal copyString
    jal printString
    jal printNewLine
    
    main_encryption_loop:
        lb t0, 0(s0)
        addi s0, s0, 1
        beq t0, zero, main_encryption_endLoop
        beq t0, s3, main_AEncryption
        beq t0, s4, main_BEncryption
        beq t0, s5, main_CEncryption
        beq t0, s6, main_DEncryption
        beq t0, s7, main_EEncryption
        j main_encryption_loop
        
    main_AEncryption:
        j main_encryption_loop
    main_BEncryption:
        j main_encryption_loop
    main_CEncryption:
        j main_encryption_loop
    main_DEncryption:
        j main_encryption_loop
    main_EEncryption:
        j main_encryption_loop



    main_encryption_endLoop:
        addi s0, s0, -2 #add -2 so in loop we`ll be able to load char without any offset
        addi s8, s8, 1 #add 1 so in loop we`ll be able to check equality for 0
        
    main_decryption_loop:
        lb t0, 0(s0)
        addi s0, s0, -1
        addi s8, s8, -1
        beq s8, zero, main_decryption_endLoop
        beq t0, s3, main_ADecryption
        beq t0, s4, main_BDecryption
        beq t0, s5, main_CDecryption
        beq t0, s6, main_DDecryption
        beq t0, s7, main_EDecryption
        j main_decryption_loop
        
    main_ADecryption:
        j main_decryption_loop
    main_BDecryption:
        j main_decryption_loop
    main_CDecryption:
        j main_decryption_loop
    main_DDecryption:
        j main_decryption_loop
    main_EDecryption:
        j main_decryption_loop


    main_decryption_endLoop:    
        jal printString
        jal printNewLine


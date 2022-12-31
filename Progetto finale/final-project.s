.data
A: .byte 65
B: .byte 66
C: .byte 67
D: .byte 68
E: .byte 69
Newline: .byte 10


mycypher: .string "C"
myplaintext: .string "sempio di messaggio criptato -1"
sostK: .word -2
blockKey: .string "OLE"

#Should be declared last, 
#because it will grow after applying encryption by occurrences
encryptedtext: .string ""  

.text

j main


#blocksEncryption(a0)
#Takes:
#    a0 - adress of the string
#Returns:
#    a0 - adress of the resulting string(same adress)
blocksEncryption:
    la t0, blockKey
    addi t1, a0, 0
    addi t2, t0, 0
    
    blocksEncryption_Loop:
        lb t3, 0(t1)
        lb t4, 0(t2)
        
        beq t3, zero, blocksEncryption_EndLoop
        beq t4, zero, blockEncryption_SetInitialPositionOfBlockKey
        blockEncryption_ContinueLoop:
        
        add t3, t3, t4
        li t4, 96
        rem t3, t3, t4
        addi t3, t3, 32
        
        sb t3, 0(t1)
        
        addi t1, t1, 1
        addi t2, t2, 1
        j blocksEncryption_Loop
        
    
    blockEncryption_SetInitialPositionOfBlockKey:
        addi t2, t0, 0
        lb t4, 0(t2)
        j blockEncryption_ContinueLoop
    
    blocksEncryption_EndLoop:    
        jr ra
    
#blocksDecryption(a0)
#Takes:
#    a0 - adress of the string
#Returns:
#    a0 - adress of the resulting string(same adress)
blocksDecryption:
    la t0, blockKey
    addi t1, a0, 0
    addi t2, t0, 0
    
    blocksDecryption_Loop:
        lb t3, 0(t1)
        lb t4, 0(t2)
        
        beq t3, zero, blocksDecryption_EndLoop
        beq t4, zero, blockDecryption_SetInitialPositionOfBlockKey
        blockDecryption_ContinueLoop:
        
        # t3 = ((t3 - 32) - t4 + 96) % 96
        addi t3, t3, 64
        sub t3, t3, t4
        li t4, 96
        rem t3, t3, t4
        
        sb t3, 0(t1)
        
        addi t1, t1, 1
        addi t2, t2, 1
        j blocksDecryption_Loop
        
    
    blockDecryption_SetInitialPositionOfBlockKey:
        addi t2, t0, 0
        lb t4, 0(t2)
        j blockDecryption_ContinueLoop
    
    blocksDecryption_EndLoop:    
        jr ra


#dictionaryEncryption(a0)
#Takes:
#    a0 - adress of the string
#Returns:
#    a0 - adress of the resulting string(same adress)
dictionaryEncryption:
    addi t0, a0, -1
    
    dictionaryEncryption_Loop:
        addi t0, t0, 1
        
        lb t1, 0(t0)
        beq t1, zero, dictionaryEncryption_EndLoop
        
        
        addi sp, sp, -12
        sw t0, 8(sp)
        sw ra 4(sp)
        sw a0, 0(sp)
        
        addi a0, t1, 0
        
        jal isSmallLetter
        
        #save result of isSmallLetter
        addi sp, sp, -4
        sw a0, 0(sp)
        
        #load current character adress
        lw a0, 12(sp)
        #load current character
        lb a0, 0(a0)
        
        jal isCapitalLetter
        
        #save result of isCapitalLetter
        addi sp, sp, -4
        sw a0, 0(sp)
        
        #load current character adress
        lw a0, 16(sp)
        #load current character
        lb a0, 0(a0)
        
        jal isNumber
        
        #store result of isNumber to t4
        addi t4, a0, 0
        
        lw t0, 16(sp)
        lw ra, 12(sp)
        lw a0, 8(sp)
        
        #load result of isSmallLetter
        lw t2, 4(sp)
        #load result of isCapitalLetter
        lw t3, 0(sp)
        addi sp, sp, 20
        
        
        li t5, 1
        beq t2, t5, dictionaryEncryption_SmallLetter
        beq t3, t5, dictionaryEncryption_CapitalLetter
        beq t4, t5, dictionaryEncryption_Number
        
        
        j dictionaryEncryption_Loop
    
    dictionaryEncryption_SmallLetter:
        lb t1, 0(t0)
        
        #t1 = 90 - (t1 - 97) = 187 - t1 
        li t2, 187
        sub t1, t2, t1
        
        sb t1, 0(t0)
        j dictionaryEncryption_Loop
        
    dictionaryEncryption_CapitalLetter:
        lb t1, 0(t0)
        
        #t1 = 122 - (t1 - 65) = 187 - t1
        li t2, 187
        sub t1, t2, t1
        
        sb t1, 0(t0)
        j dictionaryEncryption_Loop
        
    dictionaryEncryption_Number:
        lb t1, 0(t0)
        
        #t1 = 57 - t1 + 48 = 105 - t1
        li t2, 105
        sub t1, t2, t1
        
        sb t1, 0(t0)
        j dictionaryEncryption_Loop
    
    
    dictionaryEncryption_EndLoop:
        jr ra

#dictionaryDecryption(a0)
#Takes:
#    a0 - adress of the string
#Returns:
#    a0 - adress of the resulting string(same adress)
dictionaryDecryption:    

    addi sp, sp, -4
    sw ra, 0(sp)
    
    jal dictionaryEncryption
    
    lw ra, 0(sp)
    addi sp, sp, 4
    
    jr ra
     
     

#cesareEncryption(a0)
#Takes:
#    a0 - adress of the string
#Returns:
#    a0 - adress of the resulting string(same adress)
cesareEncryption:
    addi t0, a0, -1
    
    cesareEncryption_Loop:
        
        addi t0, t0, 1
        lb t1, 0(t0)
        beq t1, zero, cesareEncryption_EndLoop
        
        addi sp, sp, -16
        sw ra, 12(sp)
        sw t0, 8(sp)
        sw t1, 4(sp) 
        sw a0, 0(sp)
        
        addi a0, t1, 0
        
        jal isSmallLetter
         
        #store result of isSmallLetter        
        addi sp, sp, -4
        sw a0, 0(sp)
        
        #load current character
        lw a0, 8(sp)
        
        
        jal isCapitalLetter
        addi t3, a0, 0
        
        
        
        lw ra, 16(sp)
        #load adress of charent character
        lw t0, 12(sp)
        #load current character
        lw t1, 8(sp) 
        #load adress of the string
        lw a0, 4(sp)
        #load result of isSmallLetter
        lw t2, 0(sp)
        addi sp, sp, 20
        
        li t4, 1
        beq t2, t4, cesareEncryption_SmallLetter
        beq t3, t4, cesareEncryption_CapitalLetter
     
        
        j cesareEncryption_Loop
        
    cesareEncryption_SmallLetter:
        #calculate 97 + ((t1 - 97 + sostK) % 26)
        lw t2, sostK
        addi t1, t1, -97
        add t1, t1, t2
        
        addi sp, sp, -12
        sw ra, 8(sp)
        sw t0, 4(sp)
        sw a0, 0(sp)
        
        addi a0, t1, 0
        li a1, 26
        
        jal mod
        addi t1, a0, 97
        
        lw ra, 8(sp)
        lw t0, 4(sp)
        lw a0, 0(sp)
        addi sp, sp, 12
     
        sb t1, 0(t0)
        j cesareEncryption_Loop
       
    cesareEncryption_CapitalLetter: 
        #calculate 65 + ((t1 - 65 + sostK) % 26)
        lw t2, sostK
        addi t1, t1, -65
        add t1, t1, t2
        
        addi sp, sp, -12
        sw ra, 8(sp)
        sw t0, 4(sp)
        sw a0, 0(sp)
        
        addi a0, t1, 0
        li a1, 26
        
        jal mod
        addi t1, a0, 65
        
        lw ra, 8(sp)
        lw t0, 4(sp)
        lw a0, 0(sp)
        addi sp, sp, 12
     
        sb t1, 0(t0)
        j cesareEncryption_Loop
            
    cesareEncryption_EndLoop:
        jr ra
 
 
#cesareDecryption(a0)
#Takes:
#    a0 - adress of the string
#Returns:
#    a0 - adress of the resulting string(same adress)
cesareDecryption:
    addi t0, a0, -1
    
    cesareDecryption_Loop:
        
        addi t0, t0, 1
        lb t1, 0(t0)
        beq t1, zero, cesareDecryption_EndLoop
        
        addi sp, sp, -16
        sw ra, 12(sp)
        sw t0, 8(sp)
        sw t1, 4(sp) 
        sw a0, 0(sp)
        
        addi a0, t1, 0
        
        jal isSmallLetter
         
        #store result of isSmallLetter        
        addi sp, sp, -4
        sw a0, 0(sp)
        
        #load current character
        lw a0, 8(sp)
        
        
        jal isCapitalLetter
        addi t3, a0, 0
        
        
        
        lw ra, 16(sp)
        #load adress of charent character
        lw t0, 12(sp)
        #load current character
        lw t1, 8(sp) 
        #load adress of the string
        lw a0, 4(sp)
        #load result of isSmallLetter
        lw t2, 0(sp)
        addi sp, sp, 20
        
        li t4, 1
        beq t2, t4, cesareDecryption_SmallLetter
        beq t3, t4, cesareDecryption_CapitalLetter
     
        
        j cesareDecryption_Loop
        
    cesareDecryption_SmallLetter:
        #calculate 97 + ((t1 - 97 - sostK) % 26)
        lw t2, sostK  
              
        addi t1, t1, -97
        sub t1, t1, t2
        
        addi sp, sp, -12
        sw ra, 8(sp)
        sw t0, 4(sp)
        sw a0, 0(sp)
        
        addi a0, t1, 0
        li a1, 26
        
        jal mod
        addi t1, a0, 97
        
        lw ra, 8(sp)
        lw t0, 4(sp)
        lw a0, 0(sp)
        addi sp, sp, 12
     
        sb t1, 0(t0)
        j cesareDecryption_Loop
       
    cesareDecryption_CapitalLetter: 
        #calculate 65 + ((t1 - 65 - sostK) % 26)
        lw t2, sostK
        addi t1, t1, -65
        sub t1, t1, t2
        
        addi sp, sp, -12
        sw ra, 8(sp)
        sw t0, 4(sp)
        sw a0, 0(sp)
        
        addi a0, t1, 0
        li a1, 26
        
        jal mod
        addi t1, a0, 65
        
        lw ra, 8(sp)
        lw t0, 4(sp)
        lw a0, 0(sp)
        addi sp, sp, 12
     
        sb t1, 0(t0)
        j cesareDecryption_Loop
            
    cesareDecryption_EndLoop:
        jr ra   


#inverseString(a0)
#Takes:
#    a0 - adress of the string
#Returns:
#    a0 - adress of the resulting string(same adress)
inverseString:
    #calculate length of the string
    addi sp, sp, -8
    sw ra, 4(sp)
    sw a0, 0(sp)
    
    jal length
    
    lw t0, 0(sp)
    lw ra, 4(sp)
    addi sp, sp, 8
    
    #t1 will have adress of last character in the string
    add t1, t0, a0
    addi t1, t1, -1
    
    addi t2, a0, 0
    srli t2, t2, 1
    
    #save adress of the string to a0
    addi a0, t0, 0
    inverseString_Loop:
        
        beq t2, zero, inverseString_endLoop
        
        #swap characters in t0 and t1
        lb t3, 0(t0)
        lb t4, 0(t1)
        sb t3, 0(t1)
        sb t4, 0(t0)
        
        addi t0, t0, 1
        addi t1, t1, -1
        addi t2, t2, -1
        j inverseString_Loop
        
    inverseString_endLoop:
        jr ra
        

#stringToInteger(a0)
#Takes:
#    a0 - adress of the string
#Returns:
#    a0 - integer
stringToInteger:
    addi t0, a0, 0
    li a0, 0
    
    stringToInteger_Loop:
        #t1 will have an integer for correspoding character
        #t2 will have final result
        lb t1, 0(t0)
        beq t1, zero, stringToInteger_EndLoop
        addi t1, t1, -48
        
        # a0 * 10 = a0 * 2 + a0 * 8
        addi t2, a0, 0
        addi t3, a0, 0
        slli t2, t2, 1
        slli t3, t3, 3  
        add a0, t2, t3
        
        
        add a0, a0, t1
        
        addi t0, t0, 1
        j stringToInteger_Loop
        
    stringToInteger_EndLoop:
        jr ra
            
    


#integerToString(a0, a1)
#Takes:
#    a0 - integer
#    a1 - adress to write the resulting string
#Returns:
#    a0 - adress of the resulting string(same adress)
integerToString:
    li t0, 10
    addi t1, a0, 0
    addi t2, a1, 0
    
    integerToString_Loop:
        
        #function mod can be used here
        rem t3, t1, t0
        
        #add 48 so the number would be number in ASCII code
        addi t3, t3, 48
        sb t3, 0(t2)
        
        #function div can be used here
        div t1, t1, t0
        addi t2, t2, 1
        
        beq t1, zero, integerToString_EndLoop
        j integerToString_Loop
    
    integerToString_EndLoop:
        #insert "end of the string" after writing all numbers
        sb zero, 0(t2)
        
        
        #inverse string
        
        
        
        addi sp, sp, -4
        sw ra, 0(sp)
        
        addi a0, a1, 0
        jal inverseString
     
        lw ra, 0(sp)
        addi sp, sp, 4
        
        jr ra
        

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


#printInteger(a0)
#Takes:
#    a0 - Integer
printInteger:
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
    
    #TESTING
    
    #END_TESTING
    
    
    la s0, mycypher
    la s1, encryptedtext
    la s2, myplaintext
    
    lb s3, A
    lb s4, B
    lb s5, C
    lb s6, D
    lb s7, E
    
    #s8 will have length of the string so it would be used inside main loops
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
        jal cesareEncryption
        jal printString
        jal printNewLine
        
        j main_encryption_loop
    main_BEncryption:
        jal blocksEncryption
        jal printString
        jal printNewLine
        
        j main_encryption_loop
    main_CEncryption:
        j main_encryption_loop
    main_DEncryption:
        jal dictionaryEncryption
        jal printString
        jal printNewLine
                
        j main_encryption_loop
    main_EEncryption:
        jal inverseString
        jal printString
        jal printNewLine
        
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
        jal cesareDecryption
        jal printString
        jal printNewLine
        
        j main_decryption_loop
    main_BDecryption:
        jal blocksDecryption
        jal printString
        jal printNewLine
        
        j main_decryption_loop
    main_CDecryption:
        j main_decryption_loop
    main_DDecryption:
        jal dictionaryDecryption
        jal printString
        jal printNewLine 
        
        j main_decryption_loop
    main_EDecryption:
        
        jal inverseString
        jal printString
        jal printNewLine
        
        j main_decryption_loop


    main_decryption_endLoop:
        jal printNewLine


.data
A: .byte 65
B: .byte 66
C: .byte 67
D: .byte 68
E: .byte 69
Newline: .byte 10


mycypher: .string "EDCBA"
myplaintext: .string "simple test -1"
sostK: .word 5
blockKey: .string "104A-"

#Should be declared last, 
#because it will grow after applying encryption by occurrences
encryptedtext: .string ""  

.text

j main


#occurencesEncryption(a0)
#Takes:
#    a0 - adress of the string
#Returns:
#    a0 - adress of the resulting string(same adress)
occurencesEncryption:
    #t0 is the adress of the string
    #t1 is the adress of the resulting string
    #(the string will be copied in t0 after encryption)
    addi sp, sp, -8
    sw ra, 4(sp)
    sw a0, 0(sp)
    
    jal length
    addi t1, a0, 1
    
    lw ra, 4(sp)
    lw t0, 0(sp)
    addi sp, sp, 8
    
    add t1, t1, t0
    
    #t2 - adress of the current character in original string
    #t3 - adress of the current character in encrypted string
    addi t2, t0, -1
    addi t3, t1, 0
    
    occurencesEncryption_Loop:
        addi t2, t2, 1
        beq t2, t1, occurencesEncryption_EndLoop
        
        #t4 - current character in original string
        lb t4, 0(t2)
        
        #if t4 was already controlled than it will be marked with zero
        #so we should skip it for encryption
        beq t4, zero, occurencesEncryption_Loop
        
        #write current symbol in the resulting string
        sb t4, 0(t3)
        addi t3, t3, 1
        
        #t4 - "-" symbol  
        li t4, 45
        
        #t5 - index from of the original string 
        #of next occurence of current symbol incremented by one
        #(used for findNextOccurence function)
        sub t5, t2, t0
        
        addi t5, t5, 1
            	
        
        occurencesEncyption_InternalLoop:     
            #write "-" in the resulting string
            sb t4 0(t3)
            addi t3, t3, 1
            
            #write next occurence index in the encrypted string
            addi sp, sp, -28
            sw ra, 24(sp)
            sw t0, 20(sp)
            sw t1, 16(sp)
            sw t2, 12(sp)
            sw t3, 8(sp)
            sw t4, 4(sp)
            sw t5, 0(sp)
            
            addi a0, t5, 0
            addi a1, t3, 0
            
            jal integerToString
            
            lw ra, 24(sp)
            lw t0, 20(sp)
            lw t1, 16(sp)
            lw t2, 12(sp)
            lw t3, 8(sp)
            lw t4, 4(sp)
            lw t5, 0(sp)
            addi sp, sp, 28
            
            
            add t3, t3, a1
            
            
            addi sp, sp, -28
            sw ra, 24(sp)
            sw t0, 20(sp)
            sw t1, 16(sp)
            sw t2, 12(sp)
            sw t3, 8(sp)
            sw t4, 4(sp)
            sw t5, 0(sp)
            
            addi a0, t0, 0
            
            sub a1, t1, t0
            addi a1, a1, -1
            
            addi a2, t5, 0
            lb a3, 0(t2)
            
            jal findNextLetterOccurenceInTheString
            
            lw ra, 24(sp)
            lw t0, 20(sp)
            lw t1, 16(sp)
            lw t2, 12(sp)
            lw t3, 8(sp)
            lw t4, 4(sp)
            lw t5, 0(sp)
            addi sp, sp, 28
            
            #t6 = -1
            li t6, -1
            beq a0, t6, occurencesEncryption_EndInternalLoop
            
            #t6 - adress of the next occurence of the character 
            add t6, t0, a0
            #mark character in index a0 as already encrypted
            sb zero, 0(t6) 
            
            addi t5, a0, 1
            
            j occurencesEncyption_InternalLoop
        
        occurencesEncryption_EndInternalLoop:
            #t4 - " " symbol
            li t4, 32
            sb t4, 0(t3)
            addi t3, t3, 1
            
            
        j occurencesEncryption_Loop
        
        
    
    occurencesEncryption_EndLoop:
        #insert end of the string in the encrypted string
        sb zero, -1(t3)
        
        addi sp, sp, -8
        sw ra, 4(sp)
        sw t0, 0(sp)
        
        addi a0, t0, 0
        addi a1, t1, 0
        
        jal copyString
        
        lw ra, 4(sp)
        lw a0, 0(sp)
        addi sp, sp, 8
        
        jr ra
    


#occurencesDecryption(a0)
#Takes:
#    a0 - adress of the string
#Returns:
#    a0 - adress of the resutling string(same adress)
occurencesDecryption:
    #t0 is the adress of the string
    #t1 is the adress of the resulting string
    #(the string will be copied in t0 after decryption)
    addi sp, sp, -8
    sw ra, 4(sp)
    sw a0, 0(sp)
    
    jal length
    addi t1, a0, 1
    
    lw ra, 4(sp)
    lw t0, 0(sp)
    addi sp, sp, 8
    
    add t1, t1, t0
    
    #t2 - adress of the current character in the original string
    addi t2, t0, 0
    
    #t3 - decrypted string length
    li t3, 0
    
    occurencesDecryption_Loop:
        beq t2, t1, occurencesDecryption_EndLoop
        
        #t4 - character to store in decrypted string
        lb t4, 0(t2)
        addi t2, t2, 1
        
        occurencesDecryption_InternalLoop:
              
            #t5 - current character  in the original string
            lb t5, 0(t2)
            beq t5, zero, occurencesDecryption_EndInternalLoop
            
            #t6 - " "
            li t6, 32
            beq t5, t6, occurencesDecryption_EndInternalLoop
            
            addi t2, t2, 1      
                        
            #t6 - adress of the next character
            #used for finding integer
            addi t6, t2, 0
            addi t3, t3, 1
            
            
            occurencesDecryption_Loop_FindInteger:
                addi t6, t6, 1
                
                #t5 - character in the adress of t6
                lb t5, 0(t6)
                #a0 - " "
                li a0, 32
                beq t5, a0, occurencesDecryption_EndLoop_FindInteger
                #a0 - "-"
                li a0, 45
                beq t5, a0, occurencesDecryption_EndLoop_FindInteger
                beq t5, zero, occurencesDecryption_EndLoop_FindInteger
                j occurencesDecryption_Loop_FindInteger

            occurencesDecryption_EndLoop_FindInteger:
                #t6 here is an adress of the end of the integer
                #store character in adress t6 to t5 and set that to 0
                lb t5, 0(t6)
                sb zero, 0(t6)
                
                #use stringToInteger method for finding storing position
                addi sp, sp, -32
                sw ra, 28(sp)
                sw t0, 24(sp)
                sw t1, 20(sp)
                sw t2, 16(sp)
                sw t3, 12(sp)
                sw t4, 8(sp)
                sw t5, 4(sp)
                sw t6, 0(sp)
            
                addi a0, t2, 0
                jal stringToInteger
            
                lw ra, 28(sp)
                lw t0, 24(sp)
                lw t1, 20(sp)
                lw t2, 16(sp)
                lw t3, 12(sp)
                lw t4, 8(sp)
                lw t5, 4(sp)
                lw t6, 0(sp)
                addi sp, sp, 32
                
                #a0 - index of the character in the resulting decrypted string
                addi a0, a0, -1
    
                #a0 - adress of the decrypted character in index a0
                add a0, t1, a0
                #save storing character in adress a0
                sb t4, 0(a0) 
                sb t5, 0(t6)
                
                addi t2, t6, 0
            
            j occurencesDecryption_InternalLoop
            
        occurencesDecryption_EndInternalLoop:
            addi t2, t2, 1
        
        j occurencesDecryption_Loop
        
    occurencesDecryption_EndLoop:
        #set end of the string for decrypted string
        add t3, t1, t3
        sb zero, 0(t3)
        
        addi sp, sp, -8
        sw ra, 4(sp)
        sw t0, 0(sp)
        
        addi a0, t0, 0
        addi a1, t1, 0
        
        jal copyString
        
        lw ra, 4(sp)
        lw a0, 0(sp)
        addi sp, sp, 8
        
        jr ra

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
        
        addi t3, t3, -32
        sub t3, t3, t4
        
        
        addi sp, sp, -20
        sw ra, 16(sp)
        sw t0, 12(sp)
        sw t1, 8(sp)
        sw t2, 4(sp)       
        sw a0, 0(sp)
        
        addi a0, t3, 0
        li a1, 96
        
        jal mod
        
        addi t3, a0, 0
        
        lw ra, 16(sp)
        lw t0, 12(sp)
        lw t1, 8(sp)
        lw t2, 4(sp)       
        lw a0, 0(sp)
        addi sp, sp, 20
        
        
               
        li t5, 32
        bge t3, t5, skip_add_ciphercode
        
        addi t3, t3, 96
        
        skip_add_ciphercode:
            
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
#    a1 - length of the resulting number
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
        
        
        
        addi sp, sp, -8
        sw ra, 4(sp)
        sw a0, 0(sp)
        
        addi a0, a1, 0
        jal inverseString
        jal length
        addi a1, a0, 0
     
        lw a0, 0(sp) 
        lw ra, 4(sp)
        addi sp, sp, 8
        
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

#findNextLetterOccurenceInTheString(a0, a1, a2, a3)
#Takes:
#    a0 - adress of the string
#    a1 - length of the string
#    a2 - offset
#    a3 - letter
#Returns:
#    a0 - index of the next letter occurence
findNextLetterOccurenceInTheString:
    add t0, a0, a2
    add a1, a0, a1

    while_notFoundLetter_Or_EndOfString:   
        beq t0, a1, failedSearch_loop_end 
        lb t1, 0(t0)
        beq t1, a3, successfulSearch_loop_end
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
    bge t0, zero, end_loop_mod

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
        jal occurencesEncryption
        jal printString
        jal printNewLine
        
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
        jal occurencesDecryption
        jal printString
        jal printNewLine
        
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


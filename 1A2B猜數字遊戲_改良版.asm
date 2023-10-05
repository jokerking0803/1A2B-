Include Irvine32.inc
Include Macros.inc

.data
    
    s1 BYTE 'Enter:',0
    s2 BYTE 'A',0
    s3 BYTE 'B',0
    s4 BYTE 'Enter again:',0
    s5 BYTE 'Win! You finish in ',0
    s60 Byte 'Please enter ',0
    s61 Byte ' digits number:',0
    s7 Byte 'Do not enter symbol and letter:',0
    s8 BYTE ' times.',0

    ss0 byte 'Enter numbers 1 to 9 to determine password length.',0
    ss01 byte 'Notice:Password will not have repeated digits.',0
    ss1 byte 'How long you want to play?',0
    ss2 byte 'Please enter a single digit:',0
    ss3 byte 'Please do not enter ',0
    ss4 byte ',enter again:',0
   
    B Dword 0
    A Dword 0
    L Dword 0
   
    n Dword 0
    count Dword 0

    Keyls Byte 4 dup(?)
    keyl Dword 0

    Key Dword 12 dup(?)
    aa Dword 0

    Inputt Byte 12 dup(0)
    InputtN Dword 12 dup(?)

.code
main PROC
    mov   eax , green + ( black*16 )   
    call    SetTextColor
;-----------------HOW long----------------------
    mov edx,offset ss0
    call writestring
    call crlf
    call crlf
    mov edx,offset ss01
    call writestring
    call crlf
    call crlf
    mov edx,offset ss1
    call writestring

Hlong0:
    mov edx,offset Keyls
    mov ecx,10
    call ReadString
    mov L,eax
;-------------How long debugger--------------------
    cmp L,1
    je Hlong2
Hlong1:                 ;Input too long
    mov edx,offset ss2
    call writestring
    jmp Hlong0
Hlong2:                 ;Check if the number is 1 to 9
    mov al,Keyls
    cmp al,30h
    je Hlong
    jne Hlong3
Hlong:                  ;The single digit out of range
    mov edx,offset ss3
    call writestring
    sub al,30h
    call writedec
    mov edx,offset ss4
    call writestring
    jmp Hlong0

Hlong3:                 ;Check if numbers are symbols or letters
    mov bl,30h
    cmp bl,al
    ja Hlong1

    cmp al,39h
    ja Hlong1    

    sub al,30h
    mov keyl,eax
;-----------------產生亂數-----------------
L9:
    mov aa,0            
    mov ecx,keyl
    mov esi,offset Key
    call randomize
L0:                     ;Generate a password of the length entered by the user
    mov eax,10
    call randomRange
    mov [esi],eax
    
    ;call writedec
    add esi,4
Loop L0
    ;call crlf
    mov eax,keyl
    cmp eax,1
    je LK1
;--------------------使亂數不重複---------------------
;If there are duplicate digits, regenerate a set of passwords
    mov ecx,keyl
    dec ecx
    mov esi,offset Key
P1:
    mov eax,aa
    inc eax
    mov aa,eax
    
    push ecx
    
    mov ebx,keyl
    sub ebx,eax
    mov ecx,ebx

    mov eax,[esi]
    mov edi,offset Key
    push eax
    mov eax,aa
    mov ebx,4
    mul ebx
    add edi,eax
    pop eax
    P2: 
        mov ebx,[edi]
        cmp eax,ebx
        jne LLL
        pop ecx
        jmp L9          ;Repeated digits are found, so regenerate the password
        LLL:      
            add edi,4
    Loop P2
    pop ecx
    add esi,4
Loop P1
LK1:
;------------------------顯示key---------------
;--------------------偷看答案用----------------
    ;mov esi,offset Key
    ;mov ecx,keyl
;LL:
    ;mov eax,[esi]
    ;call writedec
    ;add esi,4
;Loop LL
    ;call crlf
;----------------------------------------------------
    mov	  EDX,OFFSET s1	
    call  WriteString
L1:
    mov A,0                     ;number of A
    mov B,0                     ;number of B
    mov n,10

    mov edx,offset Inputt       ;User enters guess
    mov ecx,n
    call ReadString
    mov L,eax

;------------input debugger-------------------------
    mov ebx,keyl                ;Confirm whether the length of the guess entered by the user 
    cmp eax,ebx                 ;is equal to the length of the password
    je H1                       ;if not equal,enter again

    call crlf
    mov edx,offset s60
    call writestring
    mov eax,keyl
    call writedec
    mov edx,offset s61
    call writestring
    jmp L1                      

H1:                             ;Check if numbers contain symbols or letters
                                ;if contain,then enter again
    mov ecx,keyl
    mov esi,offset Inputt

    HN1:
        mov al,[esi]
        mov bl,30h
        cmp bl,al
        ja HN2

        mov bl,39h
        cmp bl,al
        jb HN2
        jmp HN3
    HN2:
        call crlf
        mov edx,offset s7
        call writestring
        jmp L1
    HN3:
        inc esi
Loop HN1

;--------------------------------------------------------
    mov esi,offset Inputt             ;convert byte to dword
    mov edi,offset InputtN            ;will easy to work to us
    mov ecx,keyl
L2:
    mov al,[esi]
    sub al,30h
    movzx eax,al
    mov [edi],eax
    inc esi
    add edi,4
Loop L2
;------------------------------判斷B------------------------------------------
;Determine whether each bit of the guessed value exists in the password,if it exists then B is incremented by one
    mov ecx,keyl
    mov esi,offset InputtN

M1: 
    mov edi,offset Key
    push ecx
    mov ecx,keyl
    N0:
        mov eax,[esi]
        mov ebx,[edi]
        ;call dumpregs
        cmp eax,ebx  
        jnz N1
        
        mov edx,B
        inc edx
        mov B,edx
    N1:
        add edi,4
    Loop N0
    add esi,4
    pop ecx
Loop M1

;--------------------------------判斷A--------------------------------
;Check whether each digit of the guessed value is the same as the password in the corresponding position, 
;if it is the same, add one to A, and subtract one to B
    mov ecx,keyl
    mov esi,offset InputtN
    mov edi,offset Key
M2:
    mov eax,[esi]
    mov ebx,[edi]
    cmp eax,ebx
    jne N2
        mov edx,B
        dec edx
        mov B,edx
        mov edx,A
        inc edx
        mov A,edx
    N2:
    add esi,4
    add edi,4
Loop M2

;------------------------看幾個A----------------------------
;if A equal to password length,then end the game,if not,then guess again

    mov eax,A
    mov ebx,keyl
    cmp eax,keyl
    je ENDD             ;equal to password length,end the game
        call writedec
        mov EDX,OFFSET s2	
        call WriteString	
        mov eax,B
        call writedec
        mov EDX,OFFSET s3
        call WriteString
        call crlf
        call crlf
        mov EDX,OFFSET s4	
        call WriteString

        mov eax,count
        inc eax
        mov count,eax
        jmp L1           ;guess again
;-----------------------E N D--------------------------------------

ENDD:                    ;Show game wins, and show guess counts
    mov EDX,OFFSET s5	
    call WriteString

    mov eax,count
    inc eax
    call writedec
    mov edx,offset s8
    call writestring

    call crlf
  ret
 
  main ENDP
  END main
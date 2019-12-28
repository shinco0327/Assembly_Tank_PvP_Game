;uProcessor Final Project
;File name: GamePrint.h
;Date: 2019/12/28
;Author: Yu Shan Huang
;StudentID: B10707049
;National Taiwan University of Science Technology
;Department of Electrical Engineering

SetCursor macro row, column
    pusha
    mov 		ah, 02h
    mov         bh, 00h
    mov         dh, column
    mov         dl, row
    int         10h 
    popa
endm

PrintString macro Para
    pusha
    mov         ah, 09h
    lea         dx, Para
    int         21h
    popa
endm

PrintColorString macro Para, color
    Local       L1, Test, L2, L3
    pusha
    mov         cx, 00h
    Test:
    push        cx
    lea         si, Para
    L1:
    mov         al, byte ptr[si]
    .if         al != 10
        mov         ah, 09h
        pop         cx
        push        cx
        mov         bl, cl
        mov         bh, 0
        mov         cx, 1
        int         10h
        mov         ah, 03h
        int         10h
        inc         dl
    .endif
    .if         dl >= 100 || al == 10
        mov         dl, 0
        inc         dh 
    .endif
    mov         ah, 02h
    int         10h
    inc         si
    cmp         byte ptr[si], '$'
    jne         L1
    
    pop     cx
    inc     cx
    push    cx 
    mov     cx, 010h
    L2:
    push    cx
    mov     cx, 0ffffh
    L3:
    loop    L3
    pop     cx
    loop L2
    pop     cx
    SetCursor 0, 28
    cmp     cx, 0ffh
    jle Test
    popa
endm
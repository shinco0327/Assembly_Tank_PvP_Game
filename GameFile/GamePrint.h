;uProcessor Final Project
;File name: GamePrint.h
;Date: 2020/1/1
;By B10707009 and B10707049
;National Taiwan University of Science And Technology
;Department of Electrical Engineering

SetCursor macro row, column         ;Save the cursor
    pusha
    mov 		ah, 02h
    mov         bh, 00h
    mov         dh, column
    mov         dl, row
    int         10h 
    popa
endm

PrintString macro Para              ;Print a string
    pusha
    mov         ah, 09h
    lea         dx, Para
    int         21h
    popa
endm

Delete_Line macro           
    Local       L1
    pusha
    mov         ah, 03h
    mov         bh, 0
    int         10h
    push        dx                  ;save current row and column
    mov         cx, 20              ;Will delete 20 words
    L1:
        mov         dl, ' '
        mov         ah, 02h
        int         21h
    loop        L1
    pop         dx
    SetCursor   dl, dh              ;restore row and column
    popa
endm



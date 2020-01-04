;uProcessor Final Project
;File name: GameDraw.h
;Date: 2020/1/1
;By B10707009 and B10707049
;National Taiwan University of Science And Technology
;Department of Electrical Engineering

draw_circle macro xPara, yPara, radius, color       ;This macro will print a circle
    Local circleLoop, L1, exitL1, L2, exitL2
    pusha                                           ;push all general register
    push        sp
    push        xPara
    push        yPara
    mov         cx, xPara
    add         cx, radius                          ;The left-most border of circle
    push        cx                                  ;will be place in SS:[BP+4]
    mov         ax, radius
    mul         ax                                  ;radius^2
    push        dx
    push        ax
    mov         bp, sp                              ;push radius^2
    ;The data in stack:
    ;bp ax, bp+2 dx, bp+4 xPara + radius, bp+6 yPara, bp+8 xPara, bp+10 old sp
    circleLoop:                                     ;Start drawing a circle
    dec         word ptr SS:[BP+4]                  ;dec x
    mov         di, word ptr SS:[BP+6]              ;mov yPara to di                         
    L1:                                             ;Start drawing to below
    mov         ax, di                              ;The distance from current y position to yPara
    sub         ax, word ptr SS:[BP+6]              ;current y - yPara                              
    mul         ax                                  ;square
    push        dx
    push        ax
    mov         ax, word ptr SS:[BP+4]              ;The distance from current x position to xPara
    sub         ax, word ptr SS:[BP+8]                              
    imul        ax                                  ;square
    pop         bx
    add         ax, bx      
    pop         bx
    add         dx, bx
    ;if
    ; x^2+y^2 < radius^2
    ;draw a pixel
    cmp         dx, SS:[BP+2]
    jg          exitL1
    cmp         ax, SS:[BP]
    jg          exitL1
    draw_pixel  SS:[BP+4], di, color                ;draw pixel
    inc         di                                  ;inc y position
    mov         ax, word ptr SS:[BP+6]              ;if exceed yPara + radius
    add         ax, radius                          ;leave loop
    cmp         di, ax
    jle         L1
    exitL1:
    mov         di, word ptr SS:[BP+6]              ;mov yPara to di
    L2:                                             ;Start drawing upward
    mov         ax, word ptr SS:[BP+6]              ;The distance from current y position to yPara
    sub         ax, di                              ;yPara - current y                              
    mul         ax                                  ;square
    push        dx
    push        ax
    mov         ax, word ptr SS:[BP+4]              ;The distance from current x to xPara
    sub         ax, word ptr SS:[BP+8]                              
    imul        ax                                  ;square
    pop         bx
    add         ax, bx      
    pop         bx
    add         dx, bx
    ; x^2+y^2 < radius^2
    cmp         dx, SS:[BP+2]
    jg          exitL2
    cmp         ax, SS:[BP]
    jg          exitL2
    draw_pixel  SS:[BP+4], di, color
    dec         di
    mov         ax, word ptr SS:[BP+6] 
    sub         ax, radius
    cmp         di, ax
    jge         L2
    exitL2:
    mov         ax, word ptr SS:[BP+8] 
    sub         ax, radius
    cmp         word ptr SS:[BP+4], ax
    jge         circleLoop
    mov         sp, word ptr[BP+10]
    popa
endm

draw_pixel macro xPara, yPara, color                ;This macro will write a pixel    
    Local store_pixel, Xmax, Xmin, checkY, Ymax, Ymin, printPixel
    pusha
    push sp
    push word ptr color
    push xPara
    push yPara
    mov  bp, sp
    mov ax, SS:[BP+2]                               ;compare to x
    cmp ax, word ptr Screen_Size[0]                 ;exceed x max
    jl checkY
    jge Xmax
    cmp ax, 0                                       ;lower than 0
    jge checkY
    jl Xmin
    Xmax:                                           ;reach x max
    mov ax, word ptr Screen_Size[0]
    dec ax
    jmp checkY
    Xmin:                                           ;reach x min
    mov ax, 0
    jmp checkY
    checkY:                                         
    mov ax, SS:[bp]
    cmp ax, word ptr Screen_Size[2]
    jl printPixel
    jge Ymax
    cmp ax, 0
    jge printPixel
    jl Ymin
    Ymax:                                           ;reach y max
    mov ax, word ptr Screen_Size[2]
    dec ax
    jmp printPixel
    Ymin:                                           ;reach y min
    mov ax, 0
    printPixel:
    mov ax, SS:[BP]                                 ;row*800
    mov bx, 800
    mul bx
    add ax, word ptr SS:[BP+2]                      ;add column
    mov bx, 0
    adc dx, bx                                      ;exceed 0ffffh or not
    push ax
    
    call dword ptr [vesa_info+0ch]                  ;call far address of window-handling function
    store_pixel:
    pop di
    mov ax, word ptr SS:[BP+4]
    mov byte ptr es:[di], al
    mov sp, SS:[BP+6]
    popa
endm

set_Background macro color                          ;Set background color
    Local       store_process
    pusha
    cld                                             ;clear direction flag
    mov         ax, 0A000h
    mov         es, ax
    mov         dx, 0
    store_process:
    mov         cx, 0ffffh                          ;window-handling function
    mov         ax, 4f05h
    mov         bx, 0
    int         10h
    mov         al, color
    mov         di, 0
    rep         stosb                               ;stos color
    inc         dx
    cmp         dx, 7
    jle         store_process

    mov         ax, 4f05h
    mov         bx, 0
    int         10h
    popa
endm




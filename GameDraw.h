;uProcessor Final Project
;File name: GameDraw.h
;Date: 2019/11/29
;Author: Yu Shan Huang
;StudentID: B10707049
;National Taiwan University of Science Technology
;Department of Electrical Engineering
draw_circle macro xPara, yPara, radius, color       ;This macro will print a circle
    Local circleLoop, L1, exitL1, L2, exitL2
    pusha                                           ;push all general register
    mov         cx, xPara
    add         cx, radius                          ;The left-most border of circle
    push        cx                                  ;will be place in SS:[BP+4]
    mov         ax, radius
    mul         ax                                  ;radius^2
    push        dx
    push        ax
    mov         bp, sp                              ;push radius^2
    ;The data in stack:
    ;bp ax, bp+2 dx, bp+4 xPara + radius
    circleLoop:                                     ;Start drawing a circle
    dec         word ptr SS:[BP+4]                  ;dec x
    mov         di, yPara                           ;mov yPara to di                         
    L1:                                             ;Start drawing to below
    mov         ax, di                              ;The distance from current y position to yPara
    sub         ax, yPara                           ;current y - yPara                              
    mul         ax                                  ;square
    push        dx
    push        ax
    mov         ax, word ptr SS:[BP+4]              ;The distance from current x position to xPara
    sub         ax, xPara                              
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
    mov         ax, yPara                           ;if exceed yPara + radius
    add         ax, radius                          ;leave loop
    cmp         di, ax
    jle         L1
    exitL1:
    mov         di, yPara                           ;mov yPara to di
    L2:                                             ;Start drawing upward
    mov         ax, yPara                           ;The distance from current y position to yPara
    sub         ax, di                              ;yPara - current y                              
    mul         ax                                  ;square
    push        dx
    push        ax
    mov         ax, word ptr SS:[BP+4]              ;The distance from current x to xPara
    sub         ax, xPara                              
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
    mov         ax, yPara
    sub         ax, radius
    cmp         di, ax
    jge         L2
    exitL2:
    mov         ax, xPara
    sub         ax, radius
    cmp         word ptr SS:[BP+4], ax
    jge         circleLoop
    pop         ax                                  ;pop out SS:[BP+4]
    popa
endm

draw_pixel macro xPara, yPara, color                ;This macro will write a pixel    
    pusha
    mov         cx, xPara
    mov         dx, yPara
    mov         al, color
    mov         bx, 0
    mov         ah, 0Ch
    int         10h
    popa
endm
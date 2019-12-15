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
    Local       write_Xmax, write_Xmin, check_y, write_Ymax, write_Ymin, pixel_out
    pusha
    mov         cx, xPara
    cmp         cx, word ptr Screen_Size[0]
    jg          write_Xmax
    cmp         cx, 0
    jl          write_Xmin
    jmp         check_y
    write_Xmax:
    mov         cx, word ptr Screen_Size[0]
    jmp         check_y
    write_Xmin:
    mov         cx, 0
    check_y: 
    mov         dx, yPara
    cmp         dx, word ptr Screen_Size[2]
    jg          write_Ymax
    cmp         dx, 0
    jle         write_Ymin
    jmp         pixel_out
    write_Ymax:
    mov         dx, word ptr Screen_Size[2]
    jmp         pixel_out
    write_Ymin:
    mov         dx, 0
    jmp         pixel_out
    pixel_out:
    mov         al, color
    mov         bx, 0
    mov         ah, 0Ch
    int         10h
    popa
endm

car_surround macro xPara, yPara, radius, color
Local circleLoop, L1, exitL1, L2, exitL2, not_write1, not_write2
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
	draw_pixel  SS:[BP+4], yPara, color
	
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
    inc         di                                  ;inc y position
    mov         ax, yPara                           ;if exceed yPara + radius
    add         ax, radius                          ;leave loop
    cmp         di, ax
    jle         L1
    exitL1:
	mov 		dx, 0
	mov 		ax, SS:[BP+4]
	mov			bx, 4
	mul			bx
	mov			bx, radius
	div			bx
	cmp 		dx, 0
	jne not_write1
	draw_pixel  SS:[BP+4], di, color                ;draw pixel
	inc circle_count 
	not_write1:
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
    dec         di
    mov         ax, yPara
    sub         ax, radius
    cmp         di, ax
    jge         L2
    exitL2:
	mov 		dx, 0
	mov 		ax, SS:[BP+4]
	mov			bx, 4
	mul			bx
	mov			bx, radius
	div			bx
	cmp 		dx, 0
	jne not_write2
	draw_pixel  SS:[BP+4], di, color                ;draw pixel
	inc circle_count 
	not_write2: 
    mov         ax, xPara
    sub         ax, radius
    cmp         word ptr SS:[BP+4], ax
    jge         circleLoop
    draw_pixel  SS:[BP+4], yPara, color                ;draw pixel
	inc circle_count
	pop         ax                                  ;pop out SS:[BP+4]
    popa
endm


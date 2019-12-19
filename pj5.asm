.model small

.stack

.data

xcount dw 0
ycount dw 0
height   dw 29
count  dw 0
x dw 240 ;center
y dw 320

h1 dw 15
h2 dw 21
h3 dw 15
hcount dw 0
rwidth dw 0
body_color db 6 ;color change
gun_color  db 4	
tire_color db 2
last_body_color db 0
last_gun_color  db 0
last_tire_color db 0
Tankvesa_info dd ?
Tankgraph_reg dw 0
TankScreen_Size dw 800, 600
extstr1 db "I learn Assembly.", 10, 13, "And, it is a external file$"

.code

;SetMode macro mode    
;        mov ah,00h
;        mov al,mode
;        int 10h
;        endm
;SetColor macro color  
;         mov ah,0bh 
;         mov bh,00h
;         mov bl,color  
;         int 10h
;         endm
WrPixel macro xPara, yPara, color                ;This macro will write a pixel    
    Local store_pixel, Xmax, Xmin, checkY, Ymax, Ymin, printPixel
    pusha
    push sp
	push ax
    push xPara
    push yPara
    mov  bp, sp
    mov ax, SS:[BP+2]                               ;compare to x
    cmp ax, word ptr TankScreen_Size[0]                 ;exceed x max
    jl checkY
    jge Xmax
    cmp ax, 0                                       ;lower than 0
    jge checkY
    jl Xmin
    Xmax:
    mov ax, word ptr TankScreen_Size[0]
    dec ax
    jmp checkY
    Xmin:
    mov ax, 0
    jmp checkY
    checkY:
    mov ax, SS:[bp]
    cmp ax, word ptr TankScreen_Size[2]
    jl printPixel
    jge Ymax
    cmp ax, 0
    jge printPixel
    jl Ymin
    Ymax:
    mov ax, word ptr TankScreen_Size[2]
    dec ax
    jmp printPixel
    Ymin:
    mov ax, 0
    printPixel:
    mov ax, SS:[BP]
    mov bx, 800
    mul bx
    add ax, word ptr SS:[BP+2]
    mov bx, 0
    adc dx, bx
    push ax
    cmp dx, Tankgraph_reg
    je  store_pixel
    mov Tankgraph_reg, dx
    call dword ptr [Tankvesa_info] ;call far address of window-handling function
    store_pixel:
    pop di
	mov ax, SS:[BP+4]
    mov byte ptr es:[di], color 
    mov sp, SS:[BP+6]
    popa
    endm

print_up_right proc 
up_right_up_square_intit_set:
	push x
	push y
	sub y,14
	mov cx,x
	mov dx,y
	mov count,0	
	mov di,1
	mov al,body_color	
up_right_up_square_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb up_right_up_square_Print
up_right_up_square_next_row:
	add di,2	
	cmp di,height 
	ja up_right_up_square_over
	sub x,1
	mov cx,x
	mov count,0
	inc dx
	jmp up_right_up_square_Print
up_right_up_square_over:
	mov cx,x
	mov dx,y
	pop y
	pop x
up_right_down_square_intit_set:
	push x
	push y
	sub x,14
	mov cx,x
	mov dx,y
	mov count,0	
	mov di,height
	mov al,body_color	
up_right_down_square_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb up_right_down_square_Print
up_right_down_square_next_row:
	sub di,2	
	cmp di,height 
	ja up_right_down_square_over
	add x,1
	mov cx,x
	mov count,0
	inc dx
	jmp up_right_down_square_Print
up_right_down_square_over:
	mov cx,x
	mov dx,y
	pop y
	pop x
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~		
	mov h1,15
	mov h2,21
	mov h3,15
	push x
	push y
	add x,22
	sub y,7
	mov rwidth,15
up_right_right1_tire_intit_set:
	mov cx,x
	mov dx,y
	mov count,0	
	mov di,1
	mov al,tire_color	
up_right_right1_tire_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb up_right_right1_tire_Print
up_right_right1_tire_next_row:
	add di,2	
	cmp di,h1
	ja  up_right_right_tire2_intit_set
	sub x,1
	mov cx,x
	mov count,0
	inc dx
	inc y
	jmp up_right_right1_tire_Print
up_right_right_tire2_intit_set:
	mov hcount,0
	sub x,1
	add y,1
	mov cx,x
	mov dx,y
	mov count,0
	mov di,rwidth
	mov al,tire_color
up_right_right_tire2_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb up_right_right_tire2_Print
up_right_right_tire2_next_row:
	add hcount,1
	mov bx,hcount
	cmp bx,h2
	je  up_right_right_tire3_intit_set
	sub x,1
	add y,1
	add dx,1
	mov cx,x
	mov count,0
	jmp up_right_right_tire2_Print
up_right_right_tire3_intit_set:
	add y,1
	mov cx,x
	mov dx,y
	mov count,0
	mov di,14
	mov al,tire_color
up_right_right_tire3_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb up_right_right_tire3_Print
up_right_right_tire3_next_row:
	sub di,2	
	cmp di,h3
	ja up_right_right_tire3_over
	add x,1
	mov cx,x
	mov count,0
	inc dx
	jmp up_right_right_tire3_Print
up_right_right_tire3_over:
	mov cx,x
	mov dx,y
	pop y
	pop x

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	mov h1,15
	mov h2,21
	mov h3,15
	push x
	push y
	sub y,28
	mov rwidth,15
up_right_left_tire1_intit_set:
	mov cx,x
	mov dx,y
	mov count,0	
	mov di,1	
	mov al,tire_color
up_right_left_tire1_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb up_right_left_tire1_Print
up_right_left_tire1_next_row:
	add di,2	
	cmp di,h1
	ja  up_right_left_tire2_intit_set
	sub x,1
	mov cx,x
	mov count,0
	inc dx
	inc y
	jmp up_right_left_tire1_Print
up_right_left_tire2_intit_set:
	mov hcount,0
	sub x,1
	add y,1
	mov cx,x
	mov dx,y
	mov count,0
	mov di,rwidth
	mov al,tire_color
up_right_left_tire2_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb up_right_left_tire2_Print
up_right_left_tire2_next_row:
	add hcount,1
	mov bx,hcount
	cmp bx,h2
	je  up_right_left_tire3_intit_set
	sub x,1
	add y,1
	add dx,1
	mov cx,x
	mov count,0
	jmp up_right_left_tire2_Print
up_right_left_tire3_intit_set:
	add y,1
	mov cx,x
	mov dx,y
	mov count,0
	mov di,14
	mov al,tire_color
up_right_left_tire3_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb up_right_left_tire3_Print
up_right_left_tire3_next_row:
	sub di,2	
	cmp di,h3
	ja up_right_left_tire3_over
	add x,1
	mov cx,x
	mov count,0
	inc dx
	jmp up_right_left_tire3_Print
up_right_left_tire3_over:
	mov cx,x
	mov dx,y
	pop y
	pop x

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	mov h1,10
	mov h2,10
	mov h3,10
	push x
	push y
	add x,20
	sub y,24
	mov rwidth,10
up_right_gun1_intit_set:
	mov cx,x
	mov dx,y
	mov count,0	
	mov di,1	
	mov bl,gun_color
up_right_gun1_Print:
	WrPixel cx,dx,bl
	inc count
	inc cx
	cmp count,di
	jb up_right_gun1_Print
up_right_gun1_next_row:
	add di,2	
	cmp di,h1
	ja  up_right_gun2_intit_set
	sub x,1
	mov cx,x
	mov count,0
	inc dx
	inc y
	jmp up_right_gun1_Print
up_right_gun2_intit_set:
	mov hcount,0
	sub x,1
	add y,1
	mov cx,x
	mov dx,y
	mov count,0
	mov di,rwidth
	mov al,gun_color
up_right_gun2_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb up_right_gun2_Print
up_right_gun2_next_row:
	add hcount,1
	mov bx,hcount
	cmp bx,h2
	je  up_right_gun3_intit_set
	sub x,1
	add y,1
	add dx,1
	mov cx,x
	mov count,0
	jmp up_right_gun2_Print
up_right_gun3_intit_set:
	add y,1
	mov cx,x
	mov dx,y
	mov count,0
	mov di,9
	mov bl,gun_color
up_right_gun3_Print:
	WrPixel cx,dx,bl
	inc count
	inc cx
	cmp count,di
	jb up_right_gun3_Print
up_right_gun3_next_row:
	sub di,2	
	cmp di,h3
	ja up_right_gun3_over
	add x,1
	mov cx,x
	mov count,0
	inc dx
	jmp up_right_gun3_Print
up_right_gun3_over:
	mov cx,x
	mov dx,y
	pop y
	pop x
	ret
	print_up_right endp

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

print_down_left proc
down_left_up_square_intit_set:
	push x
	push y
	sub y,14
	mov cx,x
	mov dx,y
	mov count,0	
	mov di,1
	mov al,body_color	
down_left_up_square_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb down_left_up_square_Print
down_left_up_square_next_row:
	add di,2	
	cmp di,height 
	ja down_left_up_square_over
	sub x,1
	mov cx,x
	mov count,0
	inc dx
	jmp down_left_up_square_Print
down_left_up_square_over:
	mov cx,x
	mov dx,y
	pop y
	pop x
down_left_down_square_intit_set:
	push x
	push y
	sub x,14
	mov cx,x
	mov dx,y
	mov count,0	
	mov di,height	
	mov al,body_color	
down_left_down_square_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb down_left_down_square_Print
down_left_down_square_next_row:
	sub di,2	
	cmp di,height 
	ja down_left_down_square_over
	add x,1
	mov cx,x
	mov count,0
	inc dx
	jmp down_left_down_square_Print
down_left_down_square_over:
	mov cx,x
	mov dx,y
	pop y
	pop x

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~		
	mov h1,15
	mov h2,21
	mov h3,15
	push x
	push y
	add x,22
	sub y,7
	mov rwidth,15
down_left_right1_tire_intit_set:
	mov cx,x
	mov dx,y
	mov count,0	
	mov di,1	
	mov al,tire_color
down_left_right1_tire_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb down_left_right1_tire_Print
down_left_right1_tire_next_row:
	add di,2	
	cmp di,h1
	ja  down_left_right_tire2_intit_set
	sub x,1
	mov cx,x
	mov count,0
	inc dx
	inc y
	jmp down_left_right1_tire_Print
down_left_right_tire2_intit_set:
	mov hcount,0
	sub x,1
	add y,1
	mov cx,x
	mov dx,y
	mov count,0
	mov di,rwidth
	mov al,tire_color
down_left_right_tire2_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb down_left_right_tire2_Print
down_left_right_tire2_next_row:
	add hcount,1
	mov bx,hcount
	cmp bx,h2
	je  down_left_right_tire3_intit_set
	sub x,1
	add y,1
	add dx,1
	mov cx,x
	mov count,0
	jmp down_left_right_tire2_Print
down_left_right_tire3_intit_set:
	add y,1
	mov cx,x
	mov dx,y
	mov count,0
	mov di,14
	mov al,tire_color
down_left_right_tire3_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb down_left_right_tire3_Print
down_left_right_tire3_next_row:
	sub di,2	
	cmp di,h3
	ja down_left_right_tire3_over
	add x,1
	mov cx,x
	mov count,0
	inc dx
	jmp down_left_right_tire3_Print
down_left_right_tire3_over:
	mov cx,x
	mov dx,y
	pop y
	pop x

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	mov h1,15
	mov h2,21
	mov h3,15
	push x
	push y
	sub y,28
	mov rwidth,15
down_left_left_tire1_intit_set:
	mov cx,x
	mov dx,y
	mov count,0	
	mov di,1	
	mov al,tire_color
down_left_left_tire1_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb down_left_left_tire1_Print
down_left_left_tire1_next_row:
	add di,2	
	cmp di,h1
	ja  down_left_left_tire2_intit_set
	sub x,1
	mov cx,x
	mov count,0
	inc dx
	inc y
	jmp down_left_left_tire1_Print
down_left_left_tire2_intit_set:
	mov hcount,0
	sub x,1
	add y,1
	mov cx,x
	mov dx,y
	mov count,0
	mov di,rwidth
	mov al,tire_color
down_left_left_tire2_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb down_left_left_tire2_Print
down_left_left_tire2_next_row:
	add hcount,1
	mov bx,hcount
	cmp bx,h2
	je  down_left_left_tire3_intit_set
	sub x,1
	add y,1
	add dx,1
	mov cx,x
	mov count,0
	jmp down_left_left_tire2_Print
down_left_left_tire3_intit_set:
	add y,1
	mov cx,x
	mov dx,y
	mov count,0
	mov di,14
	mov al,tire_color
down_left_left_tire3_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb down_left_left_tire3_Print
down_left_left_tire3_next_row:
	sub di,2	
	cmp di,h3
	ja down_left_left_tire3_over
	add x,1
	mov cx,x
	mov count,0
	inc dx
	jmp down_left_left_tire3_Print
down_left_left_tire3_over:
	mov cx,x
	mov dx,y
	pop y
	pop x

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	mov h1,10
	mov h2,10
	mov h3,10
	push x
	push y
	sub x,10
	add y,5
	mov rwidth,10
down_left_gun1_intit_set:
	mov cx,x
	mov dx,y
	mov count,0	
	mov di,1	
	mov al,gun_color
down_left_gun1_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb down_left_gun1_Print
down_left_gun1_next_row:
	add di,2	
	cmp di,h1
	ja  down_left_gun2_intit_set
	sub x,1
	mov cx,x
	mov count,0
	inc dx
	inc y
	jmp down_left_gun1_Print
down_left_gun2_intit_set:
	mov hcount,0
	sub x,1
	add y,1
	mov cx,x
	mov dx,y
	mov count,0
	mov di,rwidth
	mov al,gun_color
down_left_gun2_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb down_left_gun2_Print
down_left_gun2_next_row:
	add hcount,1
	mov bx,hcount
	cmp bx,h2
	je  down_left_gun3_intit_set
	sub x,1
	add y,1
	add dx,1
	mov cx,x
	mov count,0
	jmp down_left_gun2_Print
down_left_gun3_intit_set:
	add y,1
	mov cx,x
	mov dx,y
	mov count,0
	mov di,9
	mov al,gun_color
down_left_gun3_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb down_left_gun3_Print
down_left_gun3_next_row:
	sub di,2	
	cmp di,h3
	ja down_left_gun3_over
	add x,1
	mov cx,x
	mov count,0
	inc dx
	jmp down_left_gun3_Print
down_left_gun3_over:
	mov cx,x
	mov dx,y
	pop y
	pop x
	ret
print_down_left endp
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

print_up_left proc
up_left_up_square_intit_set:
	push x
	push y
	sub y,14
	mov cx,x
	mov dx,y
	mov count,0	
	mov di,1	
	mov al,body_color
up_left_up_square_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb up_left_up_square_Print
up_left_up_square_next_row:
	add di,2	
	cmp di,height 
	ja up_left_up_square_over
	sub x,1
	mov cx,x
	mov count,0
	inc dx
	jmp up_left_up_square_Print
up_left_up_square_over:
	mov cx,x
	mov dx,y
	pop y
	pop x
up_left_down_square_intit_set:
	push x
	push y
	sub x,14
	mov cx,x
	mov dx,y
	mov count,0	
	mov di,height	
	mov al,body_color
up_left_down_square_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb up_left_down_square_Print
up_left_down_square_next_row:
	sub di,2	
	cmp di,height 
	ja up_left_down_square_over
	add x,1
	mov cx,x
	mov count,0
	inc dx
	jmp up_left_down_square_Print
up_left_down_square_over:
	mov cx,x
	mov dx,y
	pop y
	pop x

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~		
	mov h1,15
	mov h2,21
	mov h3,15
	push x
	push y
	sub y,28
	mov rwidth,15
up_left_right1_tire_intit_set:
	mov cx,x
	mov dx,y
	mov count,0	
	mov di,1	
	mov al,tire_color
up_left_right1_tire_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb up_left_right1_tire_Print
up_left_right1_tire_next_row:
	add di,2	
	cmp di,h1
	ja  up_left_right_tire2_intit_set
	sub x,1
	mov cx,x
	mov count,0
	inc dx
	inc y
	jmp up_left_right1_tire_Print
up_left_right_tire2_intit_set:
	mov hcount,0
	add x,1
	add y,1
	mov cx,x
	mov dx,y
	mov count,0
	mov di,rwidth
	mov al,tire_color
up_left_right_tire2_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb up_left_right_tire2_Print
up_left_right_tire2_next_row:
	add hcount,1
	mov bx,hcount
	cmp bx,h2
	je  up_left_right_tire3_intit_set
	add x,1
	add y,1
	add dx,1
	mov cx,x
	mov count,0
	jmp up_left_right_tire2_Print
up_left_right_tire3_intit_set:
	add y,1
	mov cx,x
	mov dx,y
	mov count,0
	mov di,14
	mov al,tire_color
up_left_right_tire3_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb up_left_right_tire3_Print
up_left_right_tire3_next_row:
	sub di,2	
	cmp di,h3
	ja up_left_right_tire3_over
	add x,1
	mov cx,x
	mov count,0
	inc dx
	jmp up_left_right_tire3_Print
up_left_right_tire3_over:
	mov cx,x
	mov dx,y
	pop y
	pop x

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	mov h1,15
	mov h2,21
	mov h3,15
	push x
	push y
	sub x,22
	sub y,7
	mov rwidth,15
up_left_left_tire1_intit_set:
	mov cx,x
	mov dx,y
	mov count,0	
	mov di,1	
	mov al,tire_color
up_left_left_tire1_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb up_left_left_tire1_Print
up_left_left_tire1_next_row:
	add di,2	
	cmp di,h1
	ja  up_left_left_tire2_intit_set
	sub x,1
	mov cx,x
	mov count,0
	inc dx
	inc y
	jmp up_left_left_tire1_Print
up_left_left_tire2_intit_set:
	mov hcount,0
	add x,1
	add y,1
	mov cx,x
	mov dx,y
	mov count,0
	mov di,rwidth
	mov al,tire_color
up_left_left_tire2_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb up_left_left_tire2_Print
up_left_left_tire2_next_row:
	add hcount,1
	mov bx,hcount
	cmp bx,h2
	je  up_left_left_tire3_intit_set
	add x,1
	add y,1
	add dx,1
	mov cx,x
	mov count,0
	jmp up_left_left_tire2_Print
up_left_left_tire3_intit_set:
	add x,1
	add y,1
	mov cx,x
	mov dx,y
	mov count,0
	mov di,14
	mov al,tire_color
up_left_left_tire3_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb up_left_left_tire3_Print
up_left_left_tire3_next_row:
	sub di,2	
	cmp di,h3
	ja up_left_left_tire3_over
	add x,1
	mov cx,x
	mov count,0
	inc dx
	jmp up_left_left_tire3_Print
up_left_left_tire3_over:
	mov cx,x
	mov dx,y
	pop y
	pop x

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	mov h1,10
	mov h2,10
	mov h3,10
	push x
	push y
	sub x,19
	sub y,23
	mov rwidth,11
up_left_gun1_intit_set:
	mov cx,x
	mov dx,y
	mov count,0	
	mov di,1	
	mov al,gun_color
up_left_gun1_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb up_left_gun1_Print
up_left_gun1_next_row:
	add di,2	
	cmp di,h1
	ja  up_left_gun2_intit_set
	sub x,1
	mov cx,x
	mov count,0
	inc dx
	inc y
	jmp up_left_gun1_Print
up_left_gun2_intit_set:
	mov hcount,0
	sub x,1
	add y,1
	mov cx,x
	mov dx,y
	mov count,0
	mov di,rwidth
	mov al,gun_color
up_left_gun2_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb up_left_gun2_Print
up_left_gun2_next_row:
	add hcount,1
	mov bx,hcount
	cmp bx,h2
	je  up_left_gun3_intit_set
	add x,1
	add y,1
	add dx,1
	mov cx,x
	mov count,0
	jmp up_left_gun2_Print
up_left_gun3_intit_set:
	add x,1
	add y,1
	mov cx,x
	mov dx,y
	mov count,0
	mov di,9
	mov al,gun_color
up_left_gun3_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb up_left_gun3_Print
up_left_gun3_next_row:
	sub di,2	
	cmp di,h3
	ja up_left_gun3_over
	add x,1
	mov cx,x
	mov count,0
	inc dx
	jmp up_left_gun3_Print
up_left_gun3_over:
	mov cx,x
	mov dx,y
	pop y
	pop x
	ret
print_up_left endp

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

print_down_right proc 
down_right_up_square_intit_set:
	push x
	push y
	sub y,14
	mov cx,x
	mov dx,y
	mov count,0	
	mov di,1	
	mov al,body_color
down_right_up_square_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb down_right_up_square_Print
down_right_up_square_next_row:
	add di,2	
	cmp di,height 
	ja down_right_up_square_over
	sub x,1
	mov cx,x
	mov count,0
	inc dx
	jmp down_right_up_square_Print
down_right_up_square_over:
	mov cx,x
	mov dx,y
	pop y
	pop x
down_right_down_square_intit_set:
	push x
	push y
	sub x,14
	mov cx,x
	mov dx,y
	mov count,0	
	mov di,height	
	mov al,body_color
down_right_down_square_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb down_right_down_square_Print
down_right_down_square_next_row:
	sub di,2	
	cmp di,height 
	ja down_right_down_square_over
	add x,1
	mov cx,x
	mov count,0
	inc dx
	jmp down_right_down_square_Print
down_right_down_square_over:
	mov cx,x
	mov dx,y
	pop y
	pop x

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~		
	mov h1,15
	mov h2,21
	mov h3,15
	push x
	push y
	sub y,28
	mov rwidth,15
down_right_right1_tire_intit_set:
	mov cx,x
	mov dx,y
	mov count,0	
	mov di,1	
	mov al,tire_color
down_right_right1_tire_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb down_right_right1_tire_Print
down_right_right1_tire_next_row:
	add di,2	
	cmp di,h1
	ja  down_right_right_tire2_intit_set
	sub x,1
	mov cx,x
	mov count,0
	inc dx
	inc y
	jmp down_right_right1_tire_Print
down_right_right_tire2_intit_set:
	mov hcount,0
	add x,1
	add y,1
	mov cx,x
	mov dx,y
	mov count,0
	mov di,rwidth
	mov al,tire_color
down_right_right_tire2_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb down_right_right_tire2_Print
down_right_right_tire2_next_row:
	add hcount,1
	mov bx,hcount
	cmp bx,h2
	je  down_right_right_tire3_intit_set
	add x,1
	add y,1
	add dx,1
	mov cx,x
	mov count,0
	jmp down_right_right_tire2_Print
down_right_right_tire3_intit_set:
	add y,1
	mov cx,x
	mov dx,y
	mov count,0
	mov di,14
	mov al,tire_color
down_right_right_tire3_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb down_right_right_tire3_Print
down_right_right_tire3_next_row:
	sub di,2	
	cmp di,h3
	ja down_right_right_tire3_over
	add x,1
	mov cx,x
	mov count,0
	inc dx
	jmp down_right_right_tire3_Print
down_right_right_tire3_over:
	mov cx,x
	mov dx,y
	pop y
	pop x

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	mov h1,15
	mov h2,21
	mov h3,15
	push x
	push y
	sub x,22
	sub y,7
	mov rwidth,15
down_right_left_tire1_intit_set:
	mov cx,x
	mov dx,y
	mov count,0	
	mov di,1	
	mov al,tire_color
down_right_left_tire1_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb down_right_left_tire1_Print
down_right_left_tire1_next_row:
	add di,2	
	cmp di,h1
	ja  down_right_left_tire2_intit_set
	sub x,1
	mov cx,x
	mov count,0
	inc dx
	inc y
	jmp down_right_left_tire1_Print
down_right_left_tire2_intit_set:
	mov hcount,0
	add x,1
	add y,1
	mov cx,x
	mov dx,y
	mov count,0
	mov di,rwidth
	mov al,tire_color
down_right_left_tire2_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb down_right_left_tire2_Print
down_right_left_tire2_next_row:
	add hcount,1
	mov bx,hcount
	cmp bx,h2
	je  down_right_left_tire3_intit_set
	add x,1
	add y,1
	add dx,1
	mov cx,x
	mov count,0
	jmp down_right_left_tire2_Print
down_right_left_tire3_intit_set:
	add x,1
	add y,1
	mov cx,x
	mov dx,y
	mov count,0
	mov di,14
	mov al,tire_color
down_right_left_tire3_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb down_right_left_tire3_Print
down_right_left_tire3_next_row:
	sub di,2	
	cmp di,h3
	ja down_right_left_tire3_over
	add x,1
	mov cx,x
	mov count,0
	inc dx
	jmp down_right_left_tire3_Print
down_right_left_tire3_over:
	mov cx,x
	mov dx,y
	pop y
	pop x

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	mov h1,10
	mov h2,10
	mov h3,10
	push x
	push y
	add x,10
	add y,5
	mov rwidth,11
down_right_gun1_intit_set:
	mov cx,x
	mov dx,y
	mov count,0	
	mov di,1	
	mov al,gun_color
down_right_gun1_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb down_right_gun1_Print
down_right_gun1_next_row:
	add di,2	
	cmp di,h1
	ja  down_right_gun2_intit_set
	sub x,1
	mov cx,x
	mov count,0
	inc dx
	inc y
	jmp down_right_gun1_Print
down_right_gun2_intit_set:
	mov hcount,0
	sub x,1
	add y,1
	mov cx,x
	mov dx,y
	mov count,0
	mov di,rwidth
	mov al,gun_color
down_right_gun2_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb down_right_gun2_Print
down_right_gun2_next_row:
	add hcount,1
	mov bx,hcount
	cmp bx,h2
	je  down_right_gun3_intit_set
	add x,1
	add y,1
	add dx,1
	mov cx,x
	mov count,0
	jmp down_right_gun2_Print
down_right_gun3_intit_set:
	add x,1
	add y,1
	mov cx,x
	mov dx,y
	mov count,0
	mov di,9
	mov al,gun_color
down_right_gun3_Print:
	WrPixel cx,dx,al
	inc count
	inc cx
	cmp count,di
	jb down_right_gun3_Print
down_right_gun3_next_row:
	sub di,2	
	cmp di,h3
	ja down_right_gun3_over
	add x,1
	mov cx,x
	mov count,0
	inc dx
	jmp down_right_gun3_Print
down_right_gun3_over:
	mov cx,x
	mov dx,y
	pop y
	pop x
	ret
print_down_right endp

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
print_up proc
	push x
	push y
	sub y,10
	sub x,10
	mov xcount,0
	mov ycount,0
	mov al,body_color
urec:
	add x,1
	add xcount,1
	mov cx,x
	mov dx,y
	WrPixel cx,dx,al
	cmp xcount,20
	jne urec
	sub x,20
	sub xcount,20
	add y,1
	add ycount,1
	cmp ycount,20
	jne urec	
	pop y
	pop x
	push x
	push y
	mov xcount,0
	mov ycount,0
	add x,10
	sub y,20
	mov al,tire_color
urtire:
	add x,1
	add xcount,1
	mov cx,x
	mov dx,y
	WrPixel cx,dx,al
	cmp xcount,10
	jne urtire
	sub x,10
	sub xcount,10
	add y,1
	add ycount,1
	cmp ycount,40
	jne urtire
	pop y
	pop x
	push x
	push y
	mov xcount,0
	mov ycount,0
	sub x,20
	sub y,20
	mov al,tire_color
ultire:
	add x,1
	add xcount,1
	mov cx,x
	mov dx,y
	WrPixel cx,dx,al
	cmp xcount,10
	jne ultire
	sub x,10
	sub xcount,10
	add y,1
	add ycount,1
	cmp ycount,40
	jne ultire
	pop y
	pop x
	push x
	push y
	mov xcount,0
	mov ycount,0
	sub x,3
	sub y,30
	mov al,gun_color
ugun:
	add x,1
	add xcount,1
	mov cx,x
	mov dx,y
	WrPixel cx,dx,al
	cmp xcount,6
	jne ugun
	sub x,6
	sub xcount,6
	add y,1
	add ycount,1
	cmp ycount,20
	jne ugun
	pop y
	pop x
	ret
print_up endp

print_down proc
	push x
	push y
	sub y,10
	sub x,10
	mov xcount,0
	mov ycount,0
	mov al,body_color
drec:
	add x,1
	add xcount,1
	mov cx,x
	mov dx,y
	WrPixel cx,dx,al
	cmp xcount,20
	jne drec
	sub x,20
	sub xcount,20
	add y,1
	add ycount,1
	cmp ycount,20
	jne drec	
	pop y
	pop x
	push x
	push y
	mov xcount,0
	mov ycount,0
	add x,10
	sub y,20
	mov al,tire_color
drtire:
	add x,1
	add xcount,1
	mov cx,x
	mov dx,y
	WrPixel cx,dx,al
	cmp xcount,10
	jne drtire
	sub x,10
	sub xcount,10
	add y,1
	add ycount,1
	cmp ycount,40
	jne drtire
	pop y
	pop x
	push x
	push y
	mov xcount,0
	mov ycount,0
	sub x,20
	sub y,20
	mov al,tire_color
dltire:
	add x,1
	add xcount,1
	mov cx,x
	mov dx,y
	WrPixel cx,dx,al
	cmp xcount,10
	jne dltire
	sub x,10
	sub xcount,10
	add y,1
	add ycount,1
	cmp ycount,40
	jne dltire
	pop y
	pop x
	push x
	push y
	mov xcount,0
	mov ycount,0
	sub x,3
	add y,10
	mov al,gun_color
dgun:
	add x,1
	add xcount,1
	mov cx,x
	mov dx,y
	WrPixel cx,dx,al
	cmp xcount,6
	jne dgun
	sub x,6
	sub xcount,6
	add y,1
	add ycount,1
	cmp ycount,20
	jne dgun
	pop y
	pop x
	ret

print_down endp 






print_right  proc

	push x
	push y
	sub y,10
	sub x,10
	mov xcount,0
	mov ycount,0
	mov al,body_color
rrec:
	add x,1
	add xcount,1
	mov cx,x
	mov dx,y
	WrPixel cx,dx,al
	cmp xcount,20
	jne rrec
	sub x,20
	sub xcount,20
	add y,1
	add ycount,1
	cmp ycount,20
	jne rrec	
	pop y
	pop x
	push x
	push y
	mov xcount,0
	mov ycount,0
	sub x,20
	sub y,20
	mov al,tire_color
rltire:
	add x,1
	add xcount,1
	mov cx,x
	mov dx,y
	WrPixel cx,dx,al
	cmp xcount,40
	jne rltire
	sub x,40
	sub xcount,40
	add y,1
	add ycount,1
	cmp ycount,10
	jne rltire
	pop y
	pop x
	push x
	push y
	mov xcount,0
	mov ycount,0
	sub x,20
	add y,10
	mov al,tire_color
rrtire:
	add x,1
	add xcount,1
	mov cx,x
	mov dx,y
	WrPixel cx,dx,al
	cmp xcount,40
	jne rrtire
	sub x,40
	sub xcount,40
	add y,1
	add ycount,1
	cmp ycount,10
	jne rrtire
	pop y
	pop x
	push x
	push y
	mov xcount,0
	mov ycount,0
	add x,10
	sub y,2
	mov al,gun_color
rgun:
	add x,1
	add xcount,1
	mov cx,x
	mov dx,y
	WrPixel cx,dx,al
	cmp xcount,20
	jne rgun
	sub x,20
	sub xcount,20
	add y,1
	add ycount,1
	cmp ycount,6
	jne rgun
	pop y
	pop x
	ret
print_right endp

print_left proc
	push x
	push y
	sub y,10
	sub x,10
	mov xcount,0
	mov ycount,0
	mov al,body_color
lrec:
	add x,1
	add xcount,1
	mov cx,x
	mov dx,y
	WrPixel cx,dx,al
	cmp xcount,20
	jne lrec
	sub x,20
	sub xcount,20
	add y,1
	add ycount,1
	cmp ycount,20
	jne lrec	
	pop y
	pop x
	push x
	push y
	mov xcount,0
	mov ycount,0
	sub x,20
	sub y,20
	mov al,tire_color
lltire:
	add x,1
	add xcount,1
	mov cx,x
	mov dx,y
	WrPixel cx,dx,al
	cmp xcount,40
	jne lltire
	sub x,40
	sub xcount,40
	add y,1
	add ycount,1
	cmp ycount,10
	jne lltire
	pop y
	pop x
	push x
	push y
	mov xcount,0
	mov ycount,0
	sub x,20
	add y,10
	mov al,tire_color
lrtire:
	add x,1
	add xcount,1
	mov cx,x
	mov dx,y
	WrPixel cx,dx,al
	cmp xcount,40
	jne lrtire
	sub x,40
	sub xcount,40
	add y,1
	add ycount,1
	cmp ycount,10
	jne lrtire
	pop y
	pop x
	push x
	push y
	mov xcount,0
	mov ycount,0
	sub x,30
	sub y,2
	mov al,gun_color
lgun:
	add x,1
	add xcount,1
	mov cx,x
	mov dx,y
	WrPixel cx,dx,al
	cmp xcount,20
	jne lgun
	sub x,20
	sub xcount,20
	add y,1
	add ycount,1
	cmp ycount,6
	jne lgun
	pop y
	pop x
	ret
print_left endp

pj5_Init proc 
	push		bp
	mov			bp, sp
	push 		sp
	push ax
	mov ax, word ptr SS:[BP+4]
	mov word ptr Tankvesa_info[0], ax
	mov ax, word ptr SS:[BP+6]
	mov word ptr Tankvesa_info[2], ax
	pop ax
	pop			sp
	pop			bp
	ret	4
pj5_Init endp

TankProcess proc 
;TABLE 	dw ONE
;		dw TWO
;		dw THREE
;		dw FOUR
;		dw FIVE
;		DW SIX
;		DW SEVEN
;		dw EIGHT
	push		bp
	mov			bp, sp
	push 		sp
	push ax
	push si
	mov al, byte ptr SS:[BP+4]
	mov			body_color, al
	mov al, byte ptr SS:[BP+5]
	mov			gun_color, al
	mov al, byte ptr SS:[BP+6]
	mov			tire_color, al
	mov ax, word ptr SS:[BP+9]
	mov			y, 300
	mov ax, word ptr SS:[BP+11]
	mov			x, 400
	mov si, word ptr SS:[BP+7]
	dec si
	add si, si
	jmp ONE
	ONE:
	call print_up
	jmp exit_Tank
	TWO:
	call print_up_right
	jmp exit_Tank
	THREE:
	call print_right
	jmp exit_Tank
	FOUR:
	call print_down_right
	jmp exit_Tank
	FIVE:
	call print_down
	jmp exit_Tank
	SIX:
	call print_down_left
	jmp exit_Tank
	SEVEN:
	call print_left
	jmp exit_Tank
	EIGHT:
	call print_up_left
	jmp exit_Tank
	exit_Tank:
	pop si
	pop ax
	pop	sp
	pop bp
	ret 9
TankProcess endp

END

	

	 



















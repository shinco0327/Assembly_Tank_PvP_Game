.model small

.stack 500h

.data

xcount dw 0
ycount dw 0
height   dw 29
count  dw 0
x dw 240 ;center
y dw 320
strcount db 0
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

TankScreen_Size dw 800, 600
extstr1 db "I learn Assembly.", 10, 13, "And, it is a external file$"

melody dw 0000, 9121, 8126, 7239, 6833, 6087, 5423, 4831, 4560, 4063, 3619, 3416, 3043, 2711, 2415, 2280, 2031, 1809, 1715, 1521, 1355, 1207
musicOffset dw ?
M_GotShoot 	dw 0ff87h
			dw 0100h, 0008h
			dw 0070h, 0008h
			dw 0060h, 0008h
			dw 0001h, 0020h
			dw 0003h, 0010h
			dw 0000h, 0001h
			dw 0003h, 0010h
			dw 0002h, 0010h
			dw 0000h, 0001h
			dw 0002h, 0010h
			dw 0001h, 0020h, 0ffffh
M_Welcome	dw 0ff87h, 0050h, 0010h
			dw 0000h, 0002h
			dw 0050h, 0010h
			dw 0000h, 0002h
			dw 0030h, 0010h
			dw 0000h, 0002h
			dw 0030h, 0010h
			dw 0000h, 0002h
			dw 0020h, 0010h
			dw 0000h, 0002h
			dw 0020h, 0010h
			dw 0000h, 0002h
			dw 0010h, 0080h, 0ffffh
M_twoTiger dw 0ff87h, 0010h, 0040h 
	dw	0020h, 0040h 
	dw	0030h, 0040h 
	dw	0010h, 0040h
	dw	0000h, 0010h
	dw	0010h, 0040h
	dw	0020h, 0040h 
	dw	0030h, 0040h
	dw	0010h, 0040h
	dw	0000h, 0010h
	dw	0030h, 0040h 
	dw	0040h, 0040h 
	dw	0050h, 0040h
	dw	0000h, 0010h
	dw	0030h, 0040h 
	dw	0040h, 0040h 
	dw	0050h, 0040h
	dw	0000h, 0010h
	dw	0050h, 0030h
	dw	0060h, 0030h
	dw	0050h, 0030h
	dw	0040h, 0030h
	dw	0030h, 0030h
	dw	0010h, 0040h
	dw 	0000h, 0010h
	dw	0050h, 0040h
	dw	0060h, 0030h
	dw	0050h, 0040h
	dw	0040h, 0040h
	dw	0030h, 0040h
	dw	0010h, 0040h
	dw	0000h, 0010h
	dw	0010h, 0040h
	dw	0005h, 0060h
	dw	0010h, 0040h
	dw	0000h, 0010h
	dw	0010h, 0040h
	dw	0005h, 0060h
	dw	0010h, 0040h, 0FFFFh

M_Win 	dw 0ff87h
		dw 0000h, 0200h
	  	dw 0010h, 0010h
		dw 0030h, 0010h
		dw 0000h, 0001h
		dw 0030h, 0010h
		dw 0020h, 0001h
		dw 0040h, 0010h
		dw 0000h, 0001h
		dw 0040h, 0010h
		dw 0070h, 0010h
		dw 0000h, 0001h
		dw 0070h, 0010h
		dw 0060h, 0010h
		dw 0070h, 0010h
		dw 0100h, 0010h, 0ffffh
M_Stop	dw 0FF87h, 0FFFFh

TitleColor dw 1 ,6h, 2fh, 28h, 09h, 2Ch, 0FFFFh


o_time dw ?


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
	push bp
    push sp
	push ax
	mov bl, color
	push bx
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
    call dword ptr [Tankvesa_info] ;call far address of window-handling function
    store_pixel:
    pop di
	mov ax, SS:[BP+6]
	mov	bx, SS:[BP+4]
    mov byte ptr es:[di], bl 
    mov sp, SS:[BP+8]
	pop bp
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
	WrPixel cx,dx, gun_color
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
	WrPixel cx,dx,gun_color
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




print_word macro x,y, color
	push bp
	mov bp, sp
	mov cx, color
	push cx
	mov cx,x
	mov dx,y
	mov strcount,0

print_t1:
	WrPixel cx,dx, SS:[BP-2]
	inc strcount
	inc cx
	cmp strcount,140   ;寬
	jb 	print_t1
print_t1_next_row:
	add dx,1	
	cmp dx,100       ;高
	ja  print_t2_initial
    mov cx,x
	mov strcount,0
	jmp print_t1
print_t2_initial:
    mov cx,x
    add cx,56
    
    mov strcount,0

print_t2:  
    WrPixel cx,dx, SS:[BP-2]
	inc strcount
	inc cx
	cmp strcount,28   ;寬
	jb 	print_t2
print_t2_next_row:
	add dx,1	
	cmp dx,210       ;高
	ja  print_a1_initial
    mov cx,x
    add cx,56
	mov strcount,0
	jmp print_t2
print_a1_initial:
    mov cx,x
    mov dx,y
    mov strcount,0
    add cx,150
print_a1:
    WrPixel cx,dx, SS:[BP-2]
	inc strcount
	inc cx
	cmp strcount,40   ;寬
	jb 	print_a1
print_a1_next_row:
	add dx,1	
	cmp dx,210       ;高
	ja  print_a2_initial
    mov cx,x
    add cx,150
	mov strcount,0
	jmp print_a1   
print_a2_initial:
    mov cx,x
    mov dx,y
    mov strcount,0
    add cx,190
print_a2:
    WrPixel cx,dx, SS:[BP-2]
	inc strcount
	inc cx
	cmp strcount,70   ;寬
	jb 	print_a2
print_a2_next_row:
	add dx,1	
	cmp dx,100       ;高
	ja  print_a3_initial
    mov cx,x
    add cx,190
	mov strcount,0
	jmp print_a2
print_a3_initial:   
    mov cx,x
    mov dx,y
    mov strcount,0
    add cx,260
print_a3:
    WrPixel cx,dx,SS:[BP-2]
	inc strcount
	inc cx
	cmp strcount,40   ;寬
	jb 	print_a3
print_a3_next_row:
	add dx,1	
	cmp dx,210       ;高
	ja  print_n1_initial
    mov cx,x
    add cx,260
	mov strcount,0
	jmp print_a3  
print_n1_initial:
    mov cx,x
    mov dx,y
    mov strcount,0
    add cx,310
print_n1:
    WrPixel cx,dx,SS:[BP-2]
	inc strcount
	inc cx
	cmp strcount,40   ;寬
	jb 	print_n1
print_n1_next_row:
	add dx,1	
	cmp dx,210       ;高
	ja  print_n2_initial
    mov cx,x
    add cx,310
	mov strcount,0
	jmp print_n1       
print_n2_initial:
    mov cx,x
    mov dx,y
    mov strcount,0
    add cx,350
    add dx,30
print_n2:
    WrPixel cx,dx,SS:[BP-2]    
    inc strcount
    inc dx
    cmp strcount,40
    jb print_n2
print_n2_next_row:
    add cx,1
    cmp cx,540
    ja print_n3_initial
    sub dx,39
    mov strcount,0
    jmp print_n2
print_n3_initial:
    mov cx,x
    mov dx,y
    mov strcount,0
    add cx,410

print_n3:
    WrPixel cx,dx,SS:[BP-2]
	inc strcount
	inc cx
	cmp strcount,40   ;寬
	jb 	print_n3
print_n3_next_row:
	add dx,1	
	cmp dx,210       ;高
	ja  print_k1_initial
    mov cx,x
    add cx,410
	mov strcount,0
	jmp print_n3 
print_k1_initial:
    mov cx,x
    mov dx,y
    mov strcount,0
    add cx,460
print_k1:
    WrPixel cx,dx,SS:[BP-2]
	inc strcount
	inc cx
	cmp strcount,40   ;寬
	jb 	print_k1
print_k1_next_row:
	add dx,1	
	cmp dx,210       ;高
	ja  print_k2_initial
    mov cx,x
    add cx,460
	mov strcount,0
	jmp print_k1 
print_k2_initial:
    mov cx,x
    mov dx,y
    mov strcount,0
    add cx,560
print_k2:
    
    WrPixel cx,dx,SS:[BP-2]
    inc strcount
    inc cx
    cmp strcount,40
    jb print_k2
print_k2_next_row:
    add dx,1
    cmp dx,145
    ja  print_k3_initial
    sub cx,41
    mov strcount,0
    jmp print_k2
print_k3_initial:
    mov cx,x
    mov dx,y
    mov strcount,0
    add cx,565
    add dx,160
print_k3:
    WrPixel cx,dx,SS:[BP-2]
    inc strcount
    inc cx
    cmp strcount,40
    jb print_k3
print_3_next_row:
    sub dx,1
    cmp dx,130
    jb  print_k4_initial
    sub cx,41
    mov strcount,0
    jmp print_k3 
print_k4_initial:
	mov sp, bp
	pop bp
endm

pj5_Init proc 
	push		bp
	mov			bp, sp
	push 		sp
	push ax
	push ds
	mov ax, word ptr SS:[BP+4]
	mov word ptr Tankvesa_info[0], ax
	mov ax, word ptr SS:[BP+6]
	mov word ptr Tankvesa_info[2], ax
	pop ds
	pop ax
	pop			sp
	pop			bp
	ret	4
pj5_Init endp



TankProcess proc 
	push		bp
	mov			bp, sp
	push 		sp
	push		ax
	push 		si
	mov xcount, 0
	mov ycount,0
	mov height, 29
	mov count, 0
	mov h1, 15
	mov h2, 21
  	mov h3, 15
	mov hcount, 0
	mov rwidth, 0
	mov al, byte ptr SS:[BP+4]
	mov			tire_color, al
	mov al, byte ptr SS:[BP+6]
	mov			gun_color, al
	mov al, byte ptr SS:[BP+8]
	mov			body_color, al
	mov ax, word ptr SS:[BP+12]
	mov			y, ax
	mov ax, word ptr SS:[BP+14]
	mov			x, ax
	mov si, word ptr SS:[BP+10]
	dec si
	add si, si
	jmp TABLE[si]
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
	pop	si
	pop ax
	mov sp, SS:[BP-2]
	pop bp
	ret 12
	TABLE	dw ONE
			dw TWO
			dw THREE
			dw FOUR
			dw FIVE
			dw SIX
			dw SEVEN
			dw EIGHT
TankProcess endp

musicInit proc 
    push	bp
	mov		bp, sp
	push 	sp
    push    di
	push	si
	mov		si, SS:[BP+4]
	shl		si, 1
	jmp		M_table[si]
	GotShoot_Music:
    lea     di, M_GotShoot
    mov     musicOffset, di
	jmp		Exit_process
	Welcome_Music:
    lea     di, M_Welcome
    mov     musicOffset, di
	jmp		Exit_process
	TT_Music:
    lea     di, M_Win
    mov     musicOffset, di
	jmp		Exit_process
	Stop_Playing:
	lea		di, M_Stop
	mov		musicOffset, di
	jmp		Exit_process
	Exit_process:
	mov		o_time, 0
	pop		si
    pop     di   
	mov     sp, SS:[BP-2]
    pop     bp
	ret     2
	M_table	dw GotShoot_Music
			dw Welcome_Music
			dw TT_Music
			dw Stop_Playing
musicInit endp

Playmusic proc
    push	bp
	mov		bp, sp
	push 	sp
    push    di
    mov     di, musicOffset
    .if		word ptr [di] != 0ff87h
	mov     ah, 2ch
	int     21h
	cmp     dx, o_time
	jg      continue
	add     o_time, 0E890h
	xchg    dx, o_time
	continue:
	sub     dx, o_time
	cmp     dx, word ptr[di-2]
	jl      Exit_process
	.else
	add		di, 2
	.endif
    START:
	.if     word ptr [di] == 0ffffh
        in      al, 61h ; Turn off note (get value from; port 61h).
 	    and     al, 11111100b ; Reset bits 1 and 0.
 	    out     61h, al ; Send new value.
        jmp     Exit_process
    .endif
	mov		bx, word ptr[di]
	cmp		bx, 0000h
	jne     Not_mute
	in      al, 61h ; Turn off note (get value from; port 61h).
 	and     al, 11111100b ; Reset bits 1 and 0.
 	out     61h, al ; Send new value.
	mov     ah, 2ch
	int     21h
	mov     o_time, dx
	jmp     Next_Melody
	Not_mute:
	cmp 	bx, 0010h
	jge		middleF
	jmp		output_melody
	middleF: 
	cmp		bx, 0100h
	jge		highF
	mov     cl, 4
	shr		bx, cl
	add		bx, 7
	jmp		output_melody
	highF:	
	mov     cl, 8
	shr		bx, cl
	add		bx, 14
	output_melody:
	shl		bx, 1
	add		bx, offset melody
	mov		ax, word ptr[bx]
	out		42h, al
	mov		al, ah
	out		42h, al
	in 		al, 61h

	or 		al, 00000011b
	out     61h, al ; Send new value.

	mov     ah, 2ch
	int     21h
	mov     o_time, dx

 	

 	Next_Melody:
	add     di, 4
    mov     musicOffset, di


	

    Exit_process:
    pop     di   
	mov     sp, SS:[BP-2]
    pop     bp
	ret     
Playmusic endp

PlayLoopMusic proc
	push	bp
	mov		bp, sp
	push 	sp
    push    di
	mov		di, musicOffset
	.if		word ptr[di] == 0ff87h
			add di, 2
	.endif
	.if		word ptr[di] == 0ffffh
		jmp		Exit_process
	.endif
	START:
	mov		bx, [di]
	cmp		bx, 0000h
	jne     Not_mute
	in al, 61h ; Turn off note (get value from; port 61h).
 	and al, 11111100b ; Reset bits 1 and 0.
 	out 61h, al ; Send new value.
	mov ah, 2ch
	int 21h
	mov o_time, dx
	jmp dummy
	Not_mute:
	cmp 	bx, 0010h
	jge		middleF
	jmp		output_melody
	middleF: 
	cmp		bx, 0100h
	jge		highF
	mov cl, 4
	shr		bx, cl
	add		bx, 7
	jmp		output_melody
	highF:	
	mov cl, 8
	shr		bx, cl
	add		bx, 14
	output_melody:
	shl		bx, 1
	add		bx, offset melody
	mov		ax, [bx]
	out		42h, al
	mov		al, ah
	out		42h, al
	in 		al, 61h

	or 		al, 00000011b
	out 61h, al ; Send new value.

	mov ah, 2ch
	int 21h
	mov o_time, dx

 	dummy:
	mov ah, 2ch
	int 21h
	cmp dx, o_time
	jg continue
	add o_time, 0E890h
	xchg dx, o_time
	continue:
	sub dx, o_time
	cmp dx, word ptr[di+2]
	jl dummy

 	
	add di, 4
	cmp word ptr[di], 0FFFFh
	jne START
	
	in al, 61h ; Turn off note (get value from; port 61h).
 	and al, 11111100b ; Reset bits 1 and 0.
 	out 61h, al ; Send new value.
	mov		musicOffset, di
	Exit_process:
	pop     di   
	mov     sp, SS:[BP-2]
    pop     bp
	ret     
PlayLoopMusic endp

ShowTitle proc
	mov di, word ptr TitleColor[0]
	add di, di
	print_word 100, 50, word ptr TitleColor[di]
	inc word ptr TitleColor
	.if word ptr TitleColor[di+2] == 0ffffh
	mov word ptr TitleColor[0], 1
	.endif
	ret
ShowTitle endp

END

	

	 



















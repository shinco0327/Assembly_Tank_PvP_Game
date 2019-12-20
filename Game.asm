;uProcessor Final Project
;File name: Game.asm
;Date: 2019/11/29
;Author: Yu Shan Huang
;StudentID: B10707049
;National Taiwan University of Science Technology
;Department of Electrical Engineering
include .\INCLUDE\Irvine16.inc
include GameDraw.h
include	GameObject.h
include pj5.inc

.model small

.data
str1 db "This is a text", 10, 13, "$"
twoTiger dw 0010h, 0040h 
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
circle_count dw 100 dup(?)
location dw 50 dup(?)
Screen_Size dw 800, 600
object dw 100 dup(?)
object_tank dw 14 dup(0)
game_timer dw 0, 0, 0, 0
speed_of_Bullet dw 6
speed_of_Tank dw 10 	
mapType dw ?
map01 dw 0, 0, 50, 50
	dw 100, 300, 150, 480
	dw 300, 150, 350, 350
	dw 550, 0, 580, 250
	dw 250, 0, 300, 150
	dw 580, 400, 639, 480, 0ffffh


graph_reg dw 0
bg_color db 72h
;   8   1   2
;    \  |  /
;     \ | /
;      \|/
;7---------------3
;      /|\
;     / | \
;    /  |  \ 4
;    6  5
bound_handler db 5, 4, 7, 2, 1, 8, 3, 6		;meet x asix
			  db 5, 8, 7, 6, 1, 4, 3, 2		;meet y asix
vesa_info db 256 dup(?)

.stack 0FFFh

.code
main proc
    mov         ax, @data
    mov         ds, ax
	mov 		es, ax
    mov 		ax, 4f01h
    mov 		cx, 103h
    lea 		di, vesa_info
    int 		10h
	mov 		ax, 0A000h
	mov 		es, ax
    mov     	ax, 4f02h
	mov 		bx, 103h					;800*600 256 colors
    int     	10h
	push 		dword ptr vesa_info[0Ch]
	invoke 		pj5_Init
	
	
	
    call    init_Page
	call    GameMode_A
	

    exit_game:
    mov		ah, 10h
	int    	16h
    mov     ax, 0003h                       ;Back to text mode
    int     10h
    mov     ax, 4c00h                       ;Exit to DOS
    int     21h
main endp


Erase_Tank macro 
	pusha
	xor			ax, ax
	mov 		al, bg_color
	push		word ptr [si+2]				;xPara
	push		word ptr [si+4]				;yPara
	push		word ptr [si+6]				;Direction
	push		word ptr ax					;body
	push		word ptr ax					;gun
	push		word ptr ax					;tire
	invoke		TankProcess
	popa
endm

Update_Tank macro UserID, Para
	Local FindLoop, ObjectNotFound, ObjectFound, exit_macro, Forward_Process, Reverse_Process, Left_Process, Right_Process
	Local Forward1, Forward2, Forward3, Forward4, Forward5, Forward6, Forward7, Forward8
	Local Reverse1, Reverse2, Reverse3, Reverse4, Reverse5, Reverse6, Reverse7, Reverse8
	pusha
	lea			si, object_tank
	mov			cx, LENGTHOF object_tank
	FindLoop:							
		cmp			word ptr [si], UserID
		je			ObjectFound
		ObjectNotFound:
		add			si, 14
		sub			cx, 7
		cmp			cx, 0
		jle			exit_macro
		jmp			FindLoop
	ObjectFound:
	Erase_Tank 	
	mov			ax, word ptr[si+2]
	mov			bx, word ptr[si+4]
	mov			cx, Para
	cmp			cx, 1
	je			Forward_Process
	cmp			cx, 3
	je			Reverse_Process
	cmp			cx, 2
	je			Right_Process
	cmp			cx, 4
	je			Left_Process
	jmp			exit_macro
	Right_Process:
	add			word ptr[si+6], 1
	cmp			word ptr[si+6], 9
	jl			exit_macro
	mov			word ptr[si+6], 1
	jmp 		exit_macro
	Left_Process:
	sub			word ptr[si+6], 1
	cmp			word ptr[si+6], 0
	jg			exit_macro
	mov			word ptr[si+6], 8
	jmp 		exit_macro
	Forward_Process:
	cmp			word ptr[si+6], 1
	je			Forward1
	cmp			word ptr[si+6], 2
	je			Forward2
	cmp			word ptr[si+6], 3
	je			Forward3
	cmp			word ptr[si+6], 4
	je			Forward4
	cmp			word ptr[si+6], 5
	je			Forward5
	cmp			word ptr[si+6], 6
	je			Forward6
	cmp			word ptr[si+6], 7
	je			Forward7
	cmp			word ptr[si+6], 8
	je			Forward8
	Forward1:
	sub			bx, speed_of_Tank
	jmp			exit_macro
	Forward2:
	add			ax, speed_of_Tank
	sub			bx, speed_of_Tank
	jmp			exit_macro
	Forward3:
	add			ax, speed_of_Tank
	jmp			exit_macro
	Forward4:
	add			ax, speed_of_Tank
	add 		bx, speed_of_Tank 
	jmp			exit_macro
	Forward5:
	add			bx, speed_of_Tank
	jmp 		exit_macro
	Forward6:
	add			bx, speed_of_Tank
	sub			ax, speed_of_Tank
	jmp			exit_macro
	Forward7:
	sub			ax, speed_of_Tank
	jmp			exit_macro
	Forward8:
	sub			ax, speed_of_Tank
	sub			bx, speed_of_Tank
	jmp			exit_macro
	Reverse_Process:
	cmp			word ptr[si+6], 1
	je			Reverse1
	cmp			word ptr[si+6], 2
	je			Reverse2
	cmp			word ptr[si+6], 3
	je			Reverse3
	cmp			word ptr[si+6], 4
	je			Reverse4
	cmp			word ptr[si+6], 5
	je			Reverse5
	cmp			word ptr[si+6], 6
	je			Reverse6
	cmp			word ptr[si+6], 7
	je			Reverse7
	cmp			word ptr[si+6], 8
	je			Reverse8
	Reverse1:
	add			bx, speed_of_Tank
	jmp			exit_macro
	Reverse2:
	sub			ax, speed_of_Tank
	add			bx, speed_of_Tank
	jmp			exit_macro
	Reverse3:
	sub			ax, speed_of_Tank
	jmp			exit_macro
	Reverse4:
	sub			ax, speed_of_Tank
	sub 		bx, speed_of_Tank 
	jmp			exit_macro
	Reverse5:
	sub			bx, speed_of_Tank
	jmp 		exit_macro
	Reverse6:
	sub			bx, speed_of_Tank
	add			ax, speed_of_Tank
	jmp			exit_macro
	Reverse7:
	add			ax, speed_of_Tank
	jmp			exit_macro
	Reverse8:
	add			ax, speed_of_Tank
	add			bx, speed_of_Tank
	jmp			exit_macro
	exit_macro:
	mov			word ptr[si+2], ax
	mov			word ptr[si+4], bx
	Print_Tank
	popa
endm
GameA_Keyboard macro
	Local		exit_macro, Allocate, P1_UP, P1_RIGHT, P1_LEFT, P1_DOWN, P2
	Local		P1_UP_Write, P1_DOWN_Write
	Local		P2_UP, P2_RIGHT, P2_DOWN, P2_LEFT, P2_UP_Write, P2_DOWN_Write
	mov 		ah, 11h
	int 		16h
	jz			exit_macro
	mov			ah, 10h
	int			16h
	cmp			al, 1bh
	je			exit_game
	cmp			ah, 48h
	je			P2_UP
	cmp 		ah, 4Dh
	je			P2_RIGHT
	cmp			ah, 50h
	je			P2_DOWN
	cmp			ah, 4Bh
	je			P2_RIGHT
	cmp			al, 61h
	jge			Allocate
	add			al, 31
	Allocate:
	cmp			al, 73h
	je			P1_DOWN
	cmp			al, 77h
	je			P1_UP
	cmp			al, 61h
	je			P1_LEFT
	cmp			al, 64h
	je			P1_RIGHT
	jmp			exit_macro
	P1_UP:
	mov 		ah, 2ch
	int 		21h
	sub			dx, word ptr game_timer[6]
	cmp 		dx, 15
	jge			P1_UP_Write
	sub			cx, word ptr game_timer[4]
	jg			P1_UP_Write
	jmp			exit_macro
	P1_UP_Write:
	mov 		ah, 2ch
	int 		21h
	mov 		word ptr game_timer[4], cx
	mov			word ptr game_timer[6], dx
	
	Update_Tank	1, 1
	jmp			exit_macro
	P1_RIGHT:
	Update_Tank	1, 2
	jmp			exit_macro
	P1_DOWN:
	mov 		ah, 2ch
	int 		21h
	sub			dx, word ptr game_timer[6]
	cmp 		dx, 15
	jge			P1_DOWN_Write
	sub			cx, word ptr game_timer[4]
	jg			P1_DOWN_Write
	jmp			exit_macro
	P1_DOWN_Write:
	mov 		ah, 2ch
	int 		21h
	mov 		word ptr game_timer[4], cx
	mov			word ptr game_timer[6], dx
	Update_Tank	1, 3
	jmp			exit_macro
	P1_LEFT:
	Update_Tank	1, 4
	jmp			exit_macro
	P2_UP:
	mov 		ah, 2ch
	int 		21h
	sub			dx, word ptr game_timer[6]
	cmp 		dx, 15
	jge			P2_UP_Write
	sub			cx, word ptr game_timer[4]
	jg			P2_UP_Write
	jmp			exit_macro
	P2_UP_Write:
	mov 		ah, 2ch
	int 		21h
	mov 		word ptr game_timer[4], cx
	mov			word ptr game_timer[6], dx
	
	Update_Tank	2, 1
	jmp			exit_macro
	P2_RIGHT:
	Update_Tank	2, 2
	jmp			exit_macro
	P2_DOWN:
	mov 		ah, 2ch
	int 		21h
	sub			dx, word ptr game_timer[6]
	cmp 		dx, 15
	jge			P2_DOWN_Write
	sub			cx, word ptr game_timer[4]
	jg			P2_DOWN_Write
	jmp			exit_macro
	P2_DOWN_Write:
	mov 		ah, 2ch
	int 		21h
	mov 		word ptr game_timer[4], cx
	mov			word ptr game_timer[6], dx
	Update_Tank	2, 3
	jmp			exit_macro
	P2_LEFT:
	Update_Tank	2, 4
	jmp			exit_macro
	exit_macro:
endm




GameMode_A proc
	push		bp
	mov			bp, sp
	push 		sp
	lea			ax, map01
	mov			mapType, ax
	setMap 		mapType
	Create_Tank 1, 500, 500, 5, 2bh, 2fh, 0f7h
	Create_Tank 2, 100, 100, 2, 2bh, 2fh, 0f7h
	Create_Bullet 200, 240, 6				;Test Purpose
	Create_Bullet 550, 400, 6					;Test Purpose
	Create_Bullet 400, 20, 6				;Test Purpose
	Create_Bullet 630, 80, 6					;Test Purpose
	Print_Tank
	mov 		ah, 2ch
	int 		21h
	mov 		word ptr game_timer[0], cx
	mov			word ptr game_timer[2], dx
	mov 		word ptr game_timer[4], cx
	mov			word ptr game_timer[6], dx
	Update_Bullet
	GameA:
	GameA_Keyboard
	

	mov 		ah, 2ch
	int 		21h
	sub			dx, word ptr game_timer[2]
	cmp 		dx, 5
	jge			Timeup
	sub			cx, word ptr game_timer[0]
	jg			Timeup
	
	
	jmp			GameA
	Timeup:
	
	Update_Bullet
	
	
	;Print_Tank
	mov 		ah, 2ch
	int 		21h
	mov 		word ptr game_timer[0], cx
	mov			word ptr game_timer[2], dx
	
	jmp			GameA
	

	exit_game:
	mov			sp, SS:[bp-2]
	pop			bp
	ret
GameMode_A endp



draw_Object proc
	lea			di, object
	mov			cx, LENGTHOF object
	checkLoop:								;object Number, xPara, yPara
		cmp			word ptr[di], 0
		je			ObjectNotFound
		draw_circle word ptr[di+2], word ptr[di+4], 5, 0Ah
		ObjectNotFound:
		add			di, 8
		sub			cx, 4
		cmp			cx, 0
		jg			checkLoop
	proc_end:
	ret
draw_Object endp

init_Page proc
    set_Background bg_color
    ret
init_Page endp


font_set proc 
    ret
font_set endp
include pj5.asm
end main
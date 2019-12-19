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
object dw 50 dup(?)
game_timer dd ?
speed_of_Bullet dw 2
mapType dw ?
map01 dw 0, 0, 50, 50
	dw 100, 300, 150, 480
	dw 300, 150, 350, 350
	dw 550, 0, 580, 250
	dw 580, 400, 639, 480, 0ffffh
graph_reg dw 0
bg_color db 72h
bound_handler db 5, 8, 7, 6, 1, 4, 3, 2
vesa_info db 256 dup(?)

.stack 100h

.code


test_shoot macro
    Create_Bullet 320, 240
	call draw_Object
endm



draw_a_line macro
endm


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
	mov 		bx, 103h
    int     	10h

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

GameMode_A proc
	push		bp
	mov			bp, sp
	push 		sp
	lea			ax, map01
	mov			mapType, ax
	setMap 		mapType
	
	Create_Bullet 200, 240, 1				;Test Purpose
	Create_Bullet 550, 400, 2					;Test Purpose
	Create_Bullet 400, 20, 6				;Test Purpose
	Create_Bullet 630, 80, 6					;Test Purpose
	Update_Bullet
	mov 		ah, 2ch
	int 		21h
	mov 		word ptr game_timer[0], cx
	mov			word ptr game_timer[2], dx
	GameA:

	mov 		ah, 11h
	int 		16h
	jnz			Keyboard_In
	mov 		ah, 2ch
	int 		21h
	sub			dx, word ptr game_timer[2]
	cmp 		dx, 10
	jge			Timeup
	sub			cx, word ptr game_timer[0]
	jge			Timeup
	jmp			GameA
	Timeup:
	Update_Bullet
	mov 		ah, 2ch
	int 		21h
	mov 		word ptr game_timer[0], cx
	mov			word ptr game_timer[2], dx
	jmp			GameA
	Keyboard_In:
	mov			ah, 10h
	int			16h
	cmp			al, 1Bh
	je			exit_game
	Create_Bullet 200, 240,1		;Test Purpose
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
end main
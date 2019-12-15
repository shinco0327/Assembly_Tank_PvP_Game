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
Screen_Size dw 640, 480
object dw 50 dup(?)
game_timer dd ?
speed_of_Bullet dw 2
mapType dw ?
map01 dw 0, 0, 50, 50
	dw 100, 300, 150, 480
	dw 300, 150, 350, 350
	dw 550, 0, 580, 250
	dw 580, 400, 639, 480, 0ffffh
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

    mov     ax, 0012h
    int     10h

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
	Create_Bullet 200, 240, 2				;Test Purpose
	Create_Bullet 550, 400, 8					;Test Purpose
	Create_Bullet 400, 20, 4				;Test Purpose
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
    mov     	ah, 0Bh
	mov     	bh, 00h
	mov     	bl, 06h
	int     	10h
    
    ret
init_Page endp


font_set proc 
    ret
font_set endp
end main
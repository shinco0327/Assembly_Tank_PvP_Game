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
game_timer dw 0, 0, 0, 0, 0, 0
speed_of_Bullet dw 8
speed_of_Tank dw 25	
mapType dw ?
map01 dw 0, 0, 50, 50
	dw 100, 300, 150, 480
	dw 300, 150, 350, 350
	dw 550, 0, 580, 250
	dw 250, 0, 300, 150
	dw 580, 400, 639, 480, 0ffffh
;esc w s a d q up down left right  enter
char_table db 01h, 11h, 1fh, 1eh, 20h, 10h, 48h, 50h, 4bh, 4dh, 1ch
char_status db 11 dup(0) 

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
	;Handle Keyboard interrupt 9h
	mov 		ah, 35h						;Get int 9h vector
    mov 		al, 09h
    int 		21h
    push 		es							;push to stack
    push 		bx
	mov			ax, @code
	mov			ds, ax
	mov			ah, 25h
	mov			al, 09h
	lea			dx, MyInterrupt
	int			21h
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
	L1:
	cmp		char_status[10], 1

	jne		L1
	L2:
	cmp		char_status[10], 0
	jne		L2

	call    GameMode_A
	

    exit_game:
    cmp		byte ptr char_status[0], 1
	jne		exit_game
    mov     ax, 0003h                       ;Back to text mode
    int     10h
	pop 	dx								;Restore int 9h
    pop 	ax								
    mov 	ds, ax
    mov 	ah, 25h
    mov 	al, 09h
    int 	21h
    mov     ax, 4c00h                       ;Exit to DOS
    int     21h
main endp






Update_Tank macro UserID, Para
	Local FindLoop, ObjectNotFound, ObjectFound, exit_macro, Forward_Process, Reverse_Process, Left_Process, Right_Process
	Local Forward1, Forward2, Forward3, Forward4, Forward5, Forward6, Forward7, Forward8
	Local Reverse1, Reverse2, Reverse3, Reverse4, Reverse5, Reverse6, Reverse7, Reverse8
	Local CheckComplete, Under_Xmax, Above_Xmin, Under_Ymax, DischargeProcess
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
	cmp			cx, 5
	je			DischargeProcess
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
	DischargeProcess:
	;Create_Bullet
	Discharge_Bullet
	jmp			CheckComplete
	exit_macro:
	mov			word ptr[si+2], ax
	mov			word ptr[si+4], bx
	mov			ax, Screen_Size[0]
	sub			ax, 30
	cmp			word ptr[si+2], ax
	jl			Under_Xmax
	mov			word ptr[si+2], ax
	Under_Xmax:
	mov			ax, 30
	cmp 		word ptr[si+2], ax
	jge			Above_Xmin
	mov			word ptr[si+2], ax
	Above_Xmin:
	mov			ax, Screen_Size[2]
	sub			ax, 30
	cmp			word ptr[si+4], ax
	jl			Under_Ymax
	mov			word ptr[si+4], ax
	Under_Ymax:
	mov			ax, 30
	cmp 		word ptr[si+4], ax
	jg			CheckComplete
	mov			word ptr[si+4], ax
	
	
	CheckComplete:
	Print_Tank
	popa
endm
GameA_Keyboard macro
	Local		exit_macro, checkP1_Down, checkP1_Down, checkP1_Left, checkP1_Right
	Local		checkP2_Up, checkP2_Down, checkP2_Left, checkP2_Right, checkP2_Discharge
	Local		P1_Left_Write, P1_Right_Write, P2_Left_Write, P2_Right_Write, P1_Discharge_Write, P2_Discharge_Write
	;mov 		ah, 11h
	;int 		16h
	;jz			exit_macro
	;mov			ah, 10h
	;int			16h
	cmp			byte ptr char_status[0], 1
	je			exit_game
	cmp			byte ptr char_status[1], 1
	jne			checkP1_Down
	;P1 up 
	Update_Tank 1, 1
	checkP1_Down:
	cmp			byte ptr char_status[2], 1
	jne			checkP1_Left
	;P2 Down
	Update_Tank 1,3
	checkP1_Left:
	cmp			byte ptr char_status[3], 1
	jne			checkP1_Right
	;p1 Left
	;mov 		ah, 2ch
	;int 		21h
	;sub			dx, word ptr game_timer[6]
	;cmp 		dx, 5
	;jge			P1_Left_Write
	;sub			cx, word ptr game_timer[4]
	;jg			P1_Left_Write
	;jmp			checkP1_Right
	;P1_Left_Write:
	;mov 		ah, 2ch
	;int 		21h
	;mov 		word ptr game_timer[4], cx
	;mov			word ptr game_timer[6], dx
	Update_Tank 1, 4
	checkP1_Right:
	cmp			byte ptr char_status[4], 1
	jne			checkP1_Discharge
	;P1 Right
	;mov 		ah, 2ch
	;int 		21h
	;sub			dx, word ptr game_timer[6]
	;cmp 		dx, 5
	;jge			P1_Right_Write
	;sub			cx, word ptr game_timer[4]
	;jg			P1_Right_Write
	;jmp			checkP1_Discharge
	;P1_Right_Write:
	;mov 		ah, 2ch
	;int 		21h
	;mov 		word ptr game_timer[4], cx
	;mov			word ptr game_timer[6], dx
	Update_Tank 1, 2
	checkP1_Discharge:
	cmp			byte ptr char_status[5], 1
	jne			checkP2_Up
	;P1 Discharge
	mov 		ah, 2ch
	int 		21h
	sub			dx, word ptr game_timer[6]
	cmp 		dx, 5
	jge			P1_Discharge_Write
	sub			cx, word ptr game_timer[4]
	jg			P1_Discharge_Write
	jmp			checkP2_Up
	P1_Discharge_Write:
	mov 		ah, 2ch
	int 		21h
	mov 		word ptr game_timer[4], cx
	mov			word ptr game_timer[6], dx
	Update_Tank 1, 5
	checkP2_Up:
	cmp			byte ptr char_status[6], 1
	jne			checkP2_Down
	;P2 Up
	Update_Tank 2,1
	checkP2_Down:
	cmp			byte ptr char_status[7], 1
	jne			checkP2_Left
	;P2 Down
	Update_Tank 2, 3
	checkP2_Left:
	cmp			byte ptr char_status[8], 1
	jne			checkP2_Right
	;P2 Left
	;mov 		ah, 2ch
	;int 		21h
	;sub			dx, word ptr game_timer[6]
	;cmp 		dx, 5
	;jge			P2_Left_Write
	;sub			cx, word ptr game_timer[4]
	;jg			P2_Left_Write
	;jmp			checkP2_Right
	;P2_Left_Write:
	;mov 		ah, 2ch
	;int 		21h
	;mov 		word ptr game_timer[4], cx
	;mov			word ptr game_timer[6], dx
	Update_Tank 2, 4
	checkP2_Right:
	cmp			byte ptr char_status[9], 1
	jne			checkP2_Discharge
	;P2 Right
	;mov 		ah, 2ch
	;int 		21h
	;sub			dx, word ptr game_timer[6]
	;cmp 		dx, 5
	;jge			P2_Right_Write
	;sub			cx, word ptr game_timer[4]
	;jg			P2_Right_Write
	;jmp			checkP2_Discharge
	;P2_Right_Write:
	;mov 		ah, 2ch
	;int 		21h
	;mov 		word ptr game_timer[4], cx
	;mov			word ptr game_timer[6], dx
	Update_Tank 2, 2
	checkP2_Discharge:
	cmp			byte ptr char_status[10], 1
	jne			exit_macro
	;P2 Discharge
	mov 		ah, 2ch
	int 		21h
	sub			dx, word ptr game_timer[6]
	cmp 		dx, 5
	jge			P2_Discharge_Write
	sub			cx, word ptr game_timer[4]
	jg			P2_Discharge_Write
	jmp			exit_macro
	P2_Discharge_Write:
	mov 		ah, 2ch
	int 		21h
	mov 		word ptr game_timer[4], cx
	mov			word ptr game_timer[6], dx
	Update_Tank 2, 5
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
	Create_Tank 2, 100, 100, 2, 24h, 22h, 0DFh
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
	mov			word ptr game_timer[8], cx
	mov			word ptr game_timer[10], dx
	Update_Bullet
	GameA:
	
	

	mov 		ah, 2ch
	int 		21h
	sub			dx, word ptr game_timer[2]
	cmp 		dx, 3
	jge			TimeupA
	sub			cx, word ptr game_timer[0]
	jg			TimeupA
	
	CheckTimeB:
	mov 		ah, 2ch
	int 		21h
	sub			dx, word ptr game_timer[10]
	cmp 		dx, 20
	jge			TimeupB
	sub			cx, word ptr game_timer[8]
	jg			TimeupB

	jmp			GameA

	TimeupA:
	Update_Bullet
	mov 		ah, 2ch
	int 		21h
	mov 		word ptr game_timer[0], cx
	mov			word ptr game_timer[2], dx
	jmp			CheckTimeB
	
	TimeupB:
	GameA_Keyboard
	mov 		ah, 2ch
	int 		21h
	mov 		word ptr game_timer[8], cx
	mov			word ptr game_timer[10], dx
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

MyInterrupt proc
	cli							;Disable Interrupt
	pushf
    push        ax
    push        cx
    push        di
    push        es
    mov         ax, @data
    mov         es, ax
    in 			al, 60h
	push		ax
	cld
	and			al, 01111111b
	lea 		di, char_table
	mov 		cx, LENGTHOF char_table
	repne  		scasb
	pop			ax
	je          FindChar
    jmp			exit_Handler
    FindChar:
    sub			di, offset char_table
	dec         di
	bt			ax, 7
	jnc			Press
	jc			Release
	Press:
	mov			byte ptr char_status[di], 1
	jmp 		exit_Handler
    Release:
	mov			byte ptr char_status[di], 0
	jmp			exit_Handler
    exit_Handler:
	mov 		al, 20h
    out 		20h, al
	pop         es
    pop         di
    pop         cx
    pop         ax
	popf
	sti							;Enable the interrupt
    iret
MyInterrupt endp

font_set proc 
	pusha
	popa
    ret
font_set endp
include pj5.asm
end main
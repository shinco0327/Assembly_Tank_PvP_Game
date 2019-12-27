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
;include	GMusic.inc

.model small

.data
WelcomeStr 	db "uProcessor Lab Fall, 2019", 10, 13
			db "By B10707009 and B10707049", 10, 16
			db "https://github.com/shinco0327/uProcessor_Game", 10, 13, '$'
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
map dw 350, 250, 450, 350, 150, 0, 200, 350, 600, 400, 650, 600, 0ffffh
	dw 0, 0, 50, 50, 100, 300, 150, 480, 300, 150, 350, 350, 550, 0, 580, 250, 250, 0, 300, 150, 580, 400, 639, 480, 0ffffh
	dw 375, 200, 425, 400, 250, 200, 375, 250, 250, 350, 375, 400, 425, 200, 550, 250, 425, 350, 550, 400, 175, 75, 225, 125, 375, 0, 425, 50, 575, 75, 625, 125, 175, 475, 225, 525, 375, 550, 425, 600, 575, 475, 625, 525, 0ffffh
	dw 100, 175, 125, 425, 500, 175, 525, 425, 125, 175, 300, 200, 125, 290, 300, 310, 125, 400, 300, 425, 525, 175, 700, 200, 525, 290, 700, 310, 525, 400, 700, 425, 0ffffh, 0FF87h 
TankInit_set dw 50, 40, 5, 750, 560, 1, 150, 40, 5, 700, 40, 5, 300, 300, 7, 500, 300, 3, 250, 250, 3, 650, 350, 3
;esc w s a d q up down left right  enter
char_table db 01h, 11h, 1fh, 1eh, 20h, 39h, 48h, 50h, 4bh, 4dh, 1ch
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

TankStr1 	db "Please customize your tank.", 10, 13, '$'
.stack 0FFFh

.code
main proc
	push		ax
	push		ax
	call		Start_Process
	MainIndex:
	call    init_Page
	L1:
	cmp		char_status[0], 1
	je		exit_game

	cmp		char_status[10], 1

	jne		L1
	L2:
	cmp		char_status[10], 0
	jne		L2
	call	Tank_Customize
	bt		ax, 0
	jc		MainIndex
	call	Choose_Map
	bt		ax, 0
	jc		MainIndex
	call	SetTank_Position
	call    GameMode_A
	
	jmp		MainIndex
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

Start_Process proc
	push		bp
	mov			bp, sp
	push 		sp
	mov			ax, 0003h
	int			10h
	mov			ax, @data
	mov			ds, ax
	lea			dx, WelcomeStr
	mov 		ah, 09h
	int 		21h
	;Handle Keyboard interrupt 9h
	mov 		ah, 35h						;Get int 9h vector
    mov 		al, 09h
    int 		21h
	mov			word ptr SS:[BP+6], es
	mov			word ptr SS:[BP+4], bx
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
	mov			sp, SS:[BP-2]
	pop			bp
	ret
Start_Process endp

Choose_Map proc
	lea		di, map
	push	es
	mov		ax, @data
	mov		es, ax
	cld
	mov		cx, 0FFFFh
	mov		ax, 0FF87h
	repne	scasw
	sub		di, 2
	mov		dx, di
	sub		dx,	offset map
	pop		es
	lea		di, map
	mov		mapType, di
	setMap 	mapType
	L1:
		.if		char_status[0] == 1
			set_Background bg_color
			mov		ax, 1
			ret	
		.endif
		.if		char_status[3] == 1
			set_Background bg_color
			mov		cx, di
			sub		cx, offset map
			.if		cx <= 0
				lea		di, map
				add		di, dx
			.endif
			sub		di, 4
			mov		cx, di
			sub		cx, offset map
			shr		cx, 1
			.if		cx > 0
				std
				push	es
				mov		ax, @data
				mov		es, ax
				mov		ax, 0ffffh
				repne	scasw
				pop		es
				cmp		cx, 0
				jz		exit_Left
				add		di, 4
			.endif
			exit_Left:
			cld
			mov		mapType, di
			setMap 	mapType
		.endif

		.if		char_status[4] == 1
			set_Background bg_color
			lea		cx, map
			add		cx, dx
			sub		cx, di
			shr		cx, 1
			cld
			push	es
			mov		ax, @data
			mov		es, ax
			mov		ax, 0ffffh
			repne	scasw
			pop		es
			
			lea		cx, map
			add		cx, dx
			.if		di >= cx
				lea		di, map
			.endif
		mov		mapType, di
		setMap 	mapType
		.endif
		
		cmp		char_status[5], 1
		jne		L1
	set_Background bg_color
	mov		mapType, di
	xor		ax, ax
	ret
Choose_Map endp

SetTank_Position proc
	push	di
	mov		cx, di
	sub		cx, offset map
	.if		cx > 0
		mov		cx, di
		sub		cx, offset map
		mov		bx, 0
		L1:
			.if		word ptr[di] == 0ffffh
				inc		bx
			.endif
			sub		di, 2
		loop 	L1
	.else
		mov		bx, 0
	.endif
	push	bx
	mov		cx, 3
	shl		bx, cl
	pop		ax
	mov		cx, 2
	shl		ax, cl
	add		bx, ax
	lea		di, object_tank
	lea		si, TankInit_set
	add		si, bx
	push	es
	mov		ax, @data
	mov		es, ax
	cld
	mov		cx, 3
	add		di, 2
	rep		movsw
	add		di, 8 
	mov		cx, 3
	rep		movsw
	pop		es
	pop		di
	ret
SetTank_Position endp

Tank_Customize proc
	lea 	dx, TankStr1
	mov 	ah, 09h
	int 	21h
	Clear_All_Object
	Create_Tank 1, 200, 300, 1, 24h, 22h, 0DFh
	Create_Tank 2, 600, 300, 1, 2bh, 2fh, 0f7h
	Print_Tank
	lea		di, offset object_tank
	add		di, 8
	lea		si, offset object_tank
	add		si, 22
	xor		ax, ax
	Start:
	.if		char_status[0] == 1
		set_Background bg_color
		mov		ax, 1
		ret	
	.endif
	.if		char_status[5] == 1
		btc		ax, 0	
	.endif
	.if		char_status[10] == 1
		btc		ax, 1
	.endif
	.if		al == 00000011b
		jmp		set_Complete
	.endif

	bt		ax, 0
	jc		Determine2
	.if		char_status[1] == 1
		inc		byte ptr[di]
		Print_Tank
		jmp		Determine2
	.endif
	.if		char_status[2] == 1
		dec		byte ptr[di]
		Print_Tank
		jmp		Determine2
	.endif
	.if		char_status[3] == 1
		sub		di, 2
		mov		bx, di
		sub		bx, offset object_tank
		.if		bx <= 7
		add		di, 6
		.endif				
		jmp		Determine2
	.endif
	.if		char_status[4] == 1
		add		di, 2
		mov		bx, di
		sub		bx, offset object_tank
		.if		bx >= 14
		sub		di, 6
		.endif
		jmp		Determine2
	.endif


	
	Determine2:
	bt		ax, 1
	jc		Start

	.if		char_status[6] == 1
		inc		byte ptr[si]
		Print_Tank
		jmp		Start
	.endif
	.if		char_status[7] == 1
		dec		byte ptr[si]
		Print_Tank
		jmp		Start
	.endif
	.if		char_status[8] == 1
		sub		si, 2
		mov		bx, si
		sub		bx, offset object_tank
		sub		bx, 14
		.if		bx <= 7
		add		si, 6
		.endif				
		jmp		Start
	.endif
	.if		char_status[9] == 1
		add		si, 2
		mov		bx, si
		sub		bx, offset object_tank
		sub		bx, 14
		.if		bx >= 14
		sub		si, 6
		.endif
		jmp		Start
	.endif
	jmp			Start
	
	set_Complete:
	set_Background bg_color
	xor		ax, ax
	ret
Tank_Customize endp


Update_Tank macro UserID, Para
	Local FindLoop, ObjectNotFound, ObjectFound, Act_Control, exit_macro, Forward_Process, Reverse_Process, Left_Process, Right_Process
	Local Forward1, Forward2, Forward3, Forward4, Forward5, Forward6, Forward7, Forward8
	Local Reverse1, Reverse2, Reverse3, Reverse4, Reverse5, Reverse6, Reverse7, Reverse8
	Local CheckComplete, Under_Xmax, Above_Xmin, Under_Ymax, DischargeProcess
	Local checkObstacle, L1, Recheck, InYRange, MeetObstacle
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
	Act_Control:
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
	push		word ptr[si+2]
	push		word ptr[si+4]		
	mov			word ptr[si+2], ax
	mov			word ptr[si+4], bx
	mov			cx, Screen_Size[0]
	sub			cx, 30
	cmp			word ptr[si+2], cx
	jl			Under_Xmax
	mov			word ptr[si+2], cx
	Under_Xmax:
	mov			cx, 30
	cmp 		word ptr[si+2], cx
	jge			Above_Xmin
	mov			word ptr[si+2], cx
	Above_Xmin:
	mov			cx, Screen_Size[2]
	sub			cx, 30
	cmp			word ptr[si+4], cx
	jl			Under_Ymax
	mov			word ptr[si+4], cx
	Under_Ymax:
	mov			cx, 30
	cmp 		word ptr[si+4], cx
	jg			checkObstacle
	mov			word ptr[si+4], cx
	
	checkObstacle:
	pop			bx
	pop			ax
	mov 		di, mapType
		L1:
		mov			cx, word ptr[di+4]		;xMax of obstacle
		add			cx, 20
		cmp			word ptr[si+2], cx		;if xPosition is bigger than xMax
		jg			Recheck					;check next obstacle
		mov			cx, word ptr[di]		;xMin of obstacle
		sub			cx, 20
		cmp			word ptr[si+2], cx		;if xPosition is bigger than xMin
		jge			InYRange				;Mean it is in the range of obstacle in x asix 
		Recheck:
		add			di, 8			
		cmp			word ptr[di], 0FFFFh
		jne			L1
		jmp			CheckComplete
		InYRange:
		mov			cx, word ptr[di+6]		;YMax of obstacle
		add			cx, 20
		cmp			word ptr[si+4], cx		;if yPosition is bigger than yMax
		jg			Recheck					;check next obstacle
		mov			cx, word ptr[di+2]		;yMin of obstacle
		sub 		cx, 20
		cmp			word ptr[si+4], cx		;if yPosition is bigger than yMin
		jge			MeetObstacle			;bullet meet obstacle
		jmp 		Recheck
	MeetObstacle:
	mov			word ptr[si+2], ax
	mov			word ptr[si+4], bx		
	CheckComplete:
	Print_Tank
	popa
endm
GameA_Keyboard macro
	Local		exit_macro, checkP1_Down, checkP1_Down, checkP1_Left, checkP1_Right
	Local		checkP2_Up, checkP2_Down, checkP2_Left, checkP2_Right, checkP2_Discharge
	Local		P1_Left_Write, P1_Right_Write, P2_Left_Write, P2_Right_Write, P1_Discharge_Write, P2_Discharge_Write

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
	setMap 		mapType
	Print_Tank
	mov 		ah, 2ch
	int 		21h
	mov 		word ptr game_timer[0], cx
	mov			word ptr game_timer[2], dx
	mov 		word ptr game_timer[4], cx
	mov			word ptr game_timer[6], dx
	mov			word ptr game_timer[8], cx
	mov			word ptr game_timer[10], dx
	
	GameA:
	
	

	mov 		ah, 2ch
	int 		21h
	sub			dx, word ptr game_timer[2]
	cmp 		dx, 2
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

	GameSet:
	push		si
	set_Background bg_color
	pop			si
	sub			si, offset object_tank
	.if			si == 0
		mov			word ptr object_tank[16], 400
		mov			word ptr object_tank[18], 300
		mov			word ptr object_tank[20], 1
		mov			word ptr object_tank[si], 0
		Print_Tank
		wait_player2:
		cmp			char_status[10], 1
		jne			wait_player2
	.endif
	.if			si == 14
		mov			word ptr object_tank[2], 400
		mov			word ptr object_tank[4], 300
		mov			word ptr object_tank[6], 1
		mov			word ptr object_tank[si], 0
		Print_Tank
		wait_player1:
		cmp			char_status[5], 1
		jne			wait_player1
	.endif
	

	exit_game:
	mov			sp, SS:[bp-2]
	pop			bp
	ret
GameMode_A endp

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


include pj5.asm
end main
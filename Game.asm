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
include	GamePrint.h
include pj5.inc
;include	GMusic.inc

.model small

.data
WelcomeStr 	db "TANK", 10, 10, 13
			db "National Taiwan University of Science Technology", 10, 13
			db "Department of Electrical Engineering", 10, 10, 13
			db "uProcessor Lab Fall, 2019", 10, 13
			db "By", 10, 13
			db "B10707009 HISU MIN YANG said, I got a big dick!", 10, 13
			db "B10707049 YU SHAN HUANG said, I learn Assembly!", 10, 10, 13
			db "Recommend running the program on DOSBOX.", 10, 13
			db "Download DOSBOX at https://www.dosbox.com/",10, 10, 13
			db "Explore this program on https://github.com/shinco0327/uProcessor_Game", 10, 13, '$'
WelcomeStr2 db "Press esc to exit", '$'
NotSupportStr db "Your computer does not support VESA SuperVGA. Press any key to exit.", 10, 13, '$'
IntroStr	db "Hi, since you are new here", 10, 13
			db "Let's get familiar with the game", '$'
TutorStr	db "Here's the tutorials", 10, 10 ,13
			db "How to play?", 10, 13
			db "1. Customize your tank", 10, 13
			db "2. Select map", 10, 13
			db "3. Enjoy your game!", 10, 10, 10, 13 
			db "Control your tank by the following keys", 10, 13
			db "	       Player1					            Player2", 10, 13
			db "  		  W  					            Arrow Up", 10, 13
			db "		A   D					Arrow Left            Arrow Right", 10, 13
			db "		  S  					           Arrow Down", 10, 13
			db "	     Spece to fire					 Enter to fire", 10, 10, 10, 13
			db "Press ESC to exit", '$'

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
file_in dw 10 dup(?)
file_handle dw ?
file_name db "GameData.txt", 0
file_default dw 0ff87h, 24h, 22h, 0DFh, 2bh, 2fh, 0f7h

MenuStr1	db "Press SPACE and ENTER simultaneously to start a new game", 10, 13, '$'
MenuStr2	db "Press S for tutorials", 10, 13, '$'
MenuStr3	db "Press ESC to exit the game", 10, 13, '$'
MenuStr4	db "Press A for more information", 10, 13, '$'
TankStr1 	db "Please customize your tank.", 10, 13, '$'
TankStr2	db "		     Player 1					       Player 2", 10, 10, 10, 13
			db "	  Use Key A & D to change part			     Use Left & Right to change part", 10, 13
			db "	 Use Key W & S to change color			      Use Up & Down to change color", 10, 13
			db "     Once you completed, please press SPACE		Once you completed, please press ENTER", 10, 13, '$'
TankStr3	db "Status: Ready", 10, 13, '$'
TankStr4	db "Status: Body", 10, 13, '$'
TankStr5	db "Status: Tire", 10, 13, '$'
TankStr6	db "Status: Gun", 10, 13, '$'
mapStr1 	db "Please select map. Use key A & D  or Arrow Left & Right to switch", 10, 13, '$'
mapStr2		db 'Once you have determined the map, player 1 please press SPACE, player 2 please press ENTER', 10, 13 , '$'
winStr1 	db "Player 1 won. Congratulation!!! Press ESC to exit", 10, 13, '$'
winStr2 	db "Player 2 won. Congratulation!!! Press ESC to exit", 10, 13, '$'
BtnStr1		db "Please release keys", '$'

.stack 0FFFh

.code
main proc
	push		ax
	push		ax
	call		Start_Process
	MainIndex:
	call	GetFile
	call    init_Page
	MainIndexLoop:
	cmp		char_status[0], 1
	je		exit_game
	.if		char_status[2] == 1
	call	Tutorial
	jmp		MainIndex
	.endif
	.if		char_status[3] == 1
	call	About
	jmp		MainIndex
	.endif
	.if		char_status[5] == 1 && char_status[10] == 1
		call	Tank_Customize
		bt		ax, 0
		jc		MainIndex
		call	Choose_Map
		bt		ax, 0
		jc		MainIndex
		call	SetTank_Position
		call    GameMode_A
		jmp		MainIndex
	.endif
	jmp		MainIndexLoop
    
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
	push 		dword ptr vesa_info[0Ch]
	invoke 		pj5_Init
	push		1
	invoke 		musicInit
	invoke		PlayLoopMusic
	mov 		ax, 0A000h
	mov 		es, ax
    mov     	ax, 4f02h
	mov 		bx, 103h					;800*600 256 colors
    int     	10h
	.if			al != 4fh || ah == 01h
		mov     ax, 0003h                       ;Back to text mode
    	int     10h
		mov		ah, 09h
		lea		dx, NotSupportStr
		int		21h
		mov 	dx,	word ptr SS:[BP+4]			;Restore int 9h
    	mov 	ax, word ptr SS:[BP+6]								
    	mov 	ds, ax
    	mov 	ah, 25h
    	mov 	al, 09h
    	int 	21h
		mov		ah, 10h
		int 	16h
    	mov     ax, 4c00h                       ;Exit to DOS
    	int     21h
	.endif
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
		SetCursor 0, 0
		PrintString mapStr1
		SetCursor 5, 36
		PrintString mapStr2
		.if		char_status[0] == 1
			set_Background bg_color
			mov		ax, 1
			ret	
		.endif
		.if		char_status[3] == 1 || char_status[8] == 1
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

		.if		char_status[4] == 1 || char_status[9] == 1
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
		
		.if		char_status[5] == 1 && char_status[10] == 1
		.else
		jmp			L1
		.endif
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

About proc
	set_Background 00h
	SetCursor 0, 0
	PrintString WelcomeStr
	SetCursor 0, 36
	PrintString WelcomeStr2
	L1:
	cmp		char_status[0], 1
	jne		L1
	ret
About endp

Tutorial proc
	set_Background 00h
	SetCursor 0, 0
	PrintString TutorStr
	L1:
	cmp		char_status[0], 1
	jne		L1
	ret
Tutorial endp

Tank_Customize proc
	set_Background 00h
	SetCursor 0, 0
	PrintString BtnStr1
	check_loop:
	.if		char_status[5] == 1 || char_status[10] == 1
		jmp		check_loop
	.endif
	
	set_Background 00h
	SetCursor 0, 0
	PrintString TankStr1
	SetCursor 0, 21
	PrintString TankStr2
	mov 	word ptr object_tank[2], 200
	mov 	word ptr object_tank[4], 300
	mov 	word ptr object_tank[6], 1
	mov 	word ptr object_tank[16], 600
	mov 	word ptr object_tank[18], 300
	mov 	word ptr object_tank[20], 1
	Print_Tank
	xor		ax, ax
	xor		cx, cx
	lea		di, offset object_tank
	add		di, 8
	lea		si, offset object_tank
	add		si, 22

	PrintP2:
	mov		bx, si
	sub		bx, offset object_tank
	.if		bx == 22
	SetCursor 69, 15
	Delete_Line
	PrintString TankStr4
	.endif
	.if		bx == 24
	SetCursor 69, 15
	Delete_Line
	PrintString TankStr6
	.endif	
	.if		bx == 26
	SetCursor 69, 15
	Delete_Line
	PrintString TankStr5
	.endif

	PrintP1:
	bt		ax, 0
	jc		Determine2
	mov		bx, di
	sub		bx, offset object_tank
	.if		bx == 8
	SetCursor 19, 15
	Delete_Line
	PrintString TankStr4
	.endif
	.if		bx == 10
	SetCursor 19, 15
	Delete_Line
	PrintString TankStr6
	.endif
	.if		bx == 12
	SetCursor 19, 15
	Delete_Line
	PrintString TankStr5
	.endif
	jmp		Determine2
	Start:
	.if		char_status[0] == 1
		set_Background bg_color
		mov		ax, 1
		ret	
	.endif
	.if		char_status[5] == 1
		bt		cx, 2
		jc		Determine2
		bts		cx, 2	
		btc		ax, 0
		jc		Player1_space
		SetCursor 19, 15
		Delete_Line
		PrintString TankStr3
		jmp		exit_P1
		Player1_space:
		jmp		PrintP1
		exit_P1:
	.endif
	.if		char_status[5] == 0
		btr		cx, 2
	.endif
	.if		char_status[10] == 1
		bt		cx, 5
		jc		Start
		bts		cx, 5
		btc		ax, 1
		jc		Player2_enter
		SetCursor 69, 15
		Delete_Line
		PrintString TankStr3
		jmp		exit_P2
		Player2_enter:
		jmp		PrintP2
		exit_P2:
	.endif
	.if		char_status[10] == 0
		btr		cx, 5
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
		bt		cx, 0
		jc		Determine2
		bts		cx, 0		
		sub		di, 2
		mov		bx, di
		sub		bx, offset object_tank
		.if		bx <= 7
		add		di, 6
		.endif
		jmp		PrintP1				
	.endif
	.if		char_status[3] == 0
		btr		cx, 0
	.endif
	.if		char_status[4] == 1
		bt		cx, 1
		jc		Determine2
		bts		cx, 1	
		add		di, 2
		mov		bx, di
		sub		bx, offset object_tank
		.if		bx >= 14
		sub		di, 6
		.endif
		jmp		PrintP1
	.endif
	.if		char_status[4] == 0
		btr		cx, 1
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
		bt		cx, 3
		jc		Start
		bts		cx, 3	
		sub		si, 2
		mov		bx, si
		sub		bx, offset object_tank
		sub		bx, 14
		.if		bx <= 7
		add		si, 6
		.endif				
		jmp		PrintP2
	.endif
	.if		char_status[8] == 0
		btr		cx, 3
	.endif
	.if		char_status[9] == 1
		bt		cx, 4
		jc		Start
		bts		cx, 4	
		add		si, 2
		mov		bx, si
		sub		bx, offset object_tank
		sub		bx, 14
		.if		bx >= 14
		sub		si, 6
		.endif
		jmp		PrintP2
	.endif
	.if		char_status[9] == 0
		btr		cx, 4
	.endif
	jmp			Start
	
	set_Complete:
	push 	es
	mov		ax, @data
	mov		es, ax
	lea		di, file_in[2]
	lea		si, object_tank[8]
	mov		cx, 3
	cld
	rep		movsw
	lea		di, file_in[8]
	lea		si, object_tank[22] 
	mov		cx, 3
	rep		movsw
	pop		es
	mov 	ah, 3Dh
    mov 	al, 2
    lea 	dx, file_name
    int 	21h
    mov 	bx, file_handle
    mov 	cx, 14
    lea 	dx, file_in
    mov 	ah, 40h
    int 	21h
    mov 	ah, 3Eh
    mov 	bx, file_handle
    int 	21h
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


GetFile proc
	Open_FIle:
    mov ah, 3Dh
    mov al, 2
    lea dx, file_name
    int 21h
    mov file_handle, ax
    jc NO_File
    jnc FindFIle
    NO_File:
    mov ah, 3ch
    mov cx, 7
    lea dx, file_name
    int 21h
    mov ah, 3Dh
    mov al, 2
    lea dx, file_name
    int 21h
    mov file_handle, ax
    mov ah, 40h
    mov bx, file_handle
    mov cx, 14
    lea dx, file_default
    int 21h
    mov ah, 3Eh
    mov bx, file_handle
    int 21h
	Introdution IntroStr, TutorStr
    jmp Open_FIle
    FindFIle:
    mov ah, 3fh
    mov bx, file_handle
    mov cx, 14
    lea dx, file_in
    int 21h
    .if word ptr file_in[0]!= 0ff87h
        mov ah, 3Eh
        mov bx, file_handle
        int 21h
        jmp NO_File
    .endif
    mov ah, 3Eh
    mov bx, file_handle
    int 21h
	ret
GetFile endp



GameMode_A proc
	push		bp
	mov			bp, sp
	push 		sp
	set_Background bg_color
	SetCursor   0, 0
	PrintString BtnStr1
	exitLoop:
		.if	char_status[5] != 0 || char_status[10] != 0
			jmp			exitLoop
		.endif
	SetCursor 0, 0
	Delete_Line
	set_Background bg_color
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
	push		2
	invoke 		musicInit
	.if			si == 0
		mov			word ptr object_tank[16], 400
		mov			word ptr object_tank[18], 300
		mov			word ptr object_tank[20], 1
		mov			word ptr object_tank[si], 0
		Print_Tank
		SetCursor	25, 36
		PrintString winStr2
		wait_player2:
		invoke		Playmusic
		cmp			char_status[0], 1
		jne			wait_player2
	.endif
	.if			si == 14
		mov			word ptr object_tank[2], 400
		mov			word ptr object_tank[4], 300
		mov			word ptr object_tank[6], 1
		mov			word ptr object_tank[si], 0
		Print_Tank
		SetCursor	25, 36
		PrintString winStr1
		wait_player1:
		invoke		Playmusic
		cmp			char_status[0], 1
		jne			wait_player1
	.endif
	push		3
	invoke		musicInit
	invoke		Playmusic
	exit_game:
	mov			sp, SS:[bp-2]
	pop			bp
	ret
GameMode_A endp

init_Page proc
    set_Background 00h
	Clear_All_Object
	invoke	ShowTitle
	Create_Tank 1, 50, 550, 2, word ptr file_in[2], word ptr file_in[4], word ptr file_in[6]
	Create_Tank 2, 750, 550, 8, word ptr file_in[8], word ptr file_in[10], word ptr file_in[12]
	Print_Tank
	SetCursor 22, 27
	PrintString MenuStr1
	SetCursor 40, 30
	PrintString MenuStr2
	SetCursor 37, 33
	PrintString MenuStr3
	SetCursor 36, 36
	PrintString MenuStr4
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
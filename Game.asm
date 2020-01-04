;uProcessor Final Project
;File name: Game.asm
;Date: 2020/1/1
;By B10707009 and B10707049
;National Taiwan University of Science And Technology
;Department of Electrical Engineering
include .\GameFile\GameDraw.h
include	.\GameFile\GameObject.h
include	.\GameFile\GamePrint.h
include .\GameFile\pj5.inc

.model small
.386

.data
WelcomeStr 	db "TANK", 10, 10, 13
			db "National Taiwan University of Science And Technology", 10, 13
			db "Department of Electrical Engineering", 10, 10, 13
			db "uProcessor Lab Fall, 2019", 10, 13
			db "By", 10, 13
			db "B10707009 HISU MIN YANG said, I got a big dick!", 10, 13
			db "B10707049 YU SHAN HUANG said, Knock Knock...", 10, 10, 13
			db "Recommend running the program on DOSBOX.", 10, 13
			db "Download DOSBOX at https://www.dosbox.com/",10, 10, 13
			db "Explore this program on https://github.com/shinco0327/uProcessor_Game", 10, 13
			db "Enjoy your game.						   Jan 1st, 2020", '$'
WelcomeStr2 db "Press esc to exit", '$'
NotSupportStr db "Your computer does not support VESA SuperVGA. Press any key to exit.", 10, 13, '$'
IntroStr	db "Hi, since you are new here", 10, 13
			db "Let's get familiar with the game", '$'
TutorStr	db "Here's the tutorials", 10, 10 ,13
			db "How to play?", 10, 13
			db "1. Customize your tank", 10, 13
			db "2. Select difficulty level", 10, 13
			db "3. Select map", 10, 13
			db "4. Enjoy your game!", 10, 10, 10, 13 
			db "Control your tank by the following keys", 10, 13
			db "	       Player1					            Player2", 10, 13
			db "  		  W  					            Arrow Up", 10, 13
			db "		A   D					Arrow Left            Arrow Right", 10, 13
			db "		  S  					           Arrow Down", 10, 13
			db "	     Spece to fire					 Enter to fire", 10, 10, 10, 13
			db "Press ESC to exit", '$'

circle_count dw 100 dup(?)
Screen_Size dw 800, 600
object dw 100 dup(?)			;Used to store bullet
object_tank dw 14 dup(0)		;Used to store tank
game_timer dw 8 dup(?)
speed_of_Bullet dw 8
speed_of_Tank dw 25	
mapType dw ?
map dw 350, 250, 450, 350, 150, 0, 200, 350, 600, 400, 650, 600, 0ffffh
	dw 250, 475, 475, 500, 100, 300, 150, 480, 300, 150, 350, 350, 550, 0, 580, 250, 250, 0, 300, 150, 580, 400, 639, 480, 0ffffh
	dw 375, 250, 425, 350, 250, 200, 550, 250, 250, 350, 550, 400, 175, 75, 225, 125, 375, 0, 425, 50, 575, 75, 625, 125, 175, 475, 225, 525, 375, 550, 425, 600, 575, 475, 625, 525, 0ffffh
	dw 100, 175, 125, 425, 500, 175, 525, 425, 125, 175, 300, 200, 125, 290, 300, 310, 125, 400, 300, 425, 525, 175, 700, 200, 525, 290, 700, 310, 525, 400, 700, 425, 0ffffh, 0FF87h 
;Tanks' initial position in every map x, y, direction
TankInit_set dw 50, 40, 5, 750, 560, 1, 150, 40, 5, 700, 40, 5, 300, 300, 7, 500, 300, 3, 250, 250, 3, 650, 350, 3
;Char_table represents to following keys
;esc w s a d q up down left right  enter
char_table db 01h, 11h, 1fh, 1eh, 20h, 39h, 48h, 50h, 4bh, 4dh, 1ch
char_status db 11 dup(0) 

strcount db 0												;Used to store title current color
TitleColor dw 2 ,2Ah, 2fh, 28h, 09h, 2Ch, 5Eh, 0FFFFh		;Title color

bg_color db 72h
;Bound Handle
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
bound_time	  dw 1
vesa_info db 256 dup(?)						;Used to store VESA SVGA info
file_in dw 10 dup(?)					
file_handle dw ?							;For file io
file_name db "GameData.txt", 0
;If the GameData.txt is not found, crate the file with following parameters"
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
Diff_Str1 	db "Please select difficulty level. Use key A & D  or Arrow Left & Right to switch", '$'
Diff_Str2 	db "Level: ", '$'
Diff_Str3	db "Easy", '$'
Diff_Str4	db "Normal", '$'
Diff_Str5	db "Hard", '$'
Diff_Str6	db "Expert", '$'
Diff_Str7 	db  'Once you have determined, player 1 please press SPACE, player 2 please press ENTER', 10, 13 , '$'
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
	.if		char_status[0] == 1				;Check if ESC got pressed
		set_Background 00h
		SetCursor 	0, 0
		PrintString	BtnStr1
		ESC_Pressed:						
		cmp			char_status[0], 1
		je			ESC_Pressed
	.endif						
	call    init_Page
	MainIndexLoop:	
	call    ShowTitle
	cmp		char_status[0], 1				;Esc to exit
	je		exit_game
	.if		char_status[2] == 1				;S to show tutorials
		call	Tutorial
		jmp		MainIndex
	.endif
	.if		char_status[3] == 1				;A to show about
		call	About
		jmp		MainIndex
	.endif
	.if		char_status[5] == 1 && char_status[10] == 1			;Press both space and enter to start a new game
		call	Tank_Customize
		bt		ax, 0											;if the rightmost bit is 0, go back to home page
		jc		MainIndex
		call	Set_Difficulty
		bt		ax, 0											;if the rightmost bit is 0, go back to home page
		jc		MainIndex
		call	Choose_Map
		bt		ax, 0											;if the rightmost bit is 0, go back to home page
		jc		MainIndex
		call	SetTank_Position								
		call    GameMode_A
		jmp		MainIndex
	.endif
	jmp		MainIndexLoop
    
	exit_game:
    mov     ax, 0003h                       ;Back to text mode
    int     10h
	pop 	dx								;Restore int 9h
    pop 	ax								
    mov 	ds, ax
    mov 	ah, 25h
    mov 	al, 09h							;Interrupt vector 9h
    int 	21h
    mov     ax, 4c00h                       ;Exit to DOS
    int     21h
main endp

;Following procedure will be done in Start_Process
;Replace int 9h
;Get info of SVGA 800*600 256 colors mode 
;Set graph mode
Start_Process proc					
	push		bp
	mov			bp, sp
	push 		sp
	mov			ax, 0003h					;Text mode
	int			10h
	mov			ax, @data					
	mov			ds, ax
	SetCursor 	0, 0
	PrintString WelcomeStr
	;Handle Keyboard interrupt 9h
	mov 		ah, 35h						;Get int 9h vector
    mov 		al, 09h
    int 		21h
	mov			word ptr SS:[BP+6], es		;ES:BX current 9h handler
	mov			word ptr SS:[BP+4], bx
	mov			ax, @code					
	mov			ds, ax						;CS to DS
	mov			ah, 25h						;Set int 9h handler
	mov			al, 09h						
	lea			dx, MyInterrupt				;DS:DX
	int			21h
    mov         ax, @data					;Restore DS 
    mov         ds, ax
	mov 		es, ax						;mov ds to es
    mov 		ax, 4f01h					;Get VESA SVGA mode 103h informations
    mov 		cx, 103h
    lea 		di, vesa_info				
    int 		10h
	push 		dword ptr vesa_info[0Ch]	;+0CH far address of window-handling function
	invoke 		pj5_Init
	push		1
	invoke 		musicInit
	invoke		PlayLoopMusic
	mov 		ax, 0A000h			
	mov 		es, ax
    mov     	ax, 4f02h
	mov 		bx, 103h					;800*600 256 colors
    int     	10h
	.if			al != 4fh || ah == 01h		;if set failed
		mov     ax, 0003h                  	;Back to text mode
    	int     10h
		PrintString NotSupportStr			
		mov 	dx,	word ptr SS:[BP+4]		;Restore int 9h
    	mov 	ax, word ptr SS:[BP+6]								
    	mov 	ds, ax
    	mov 	ah, 25h
    	mov 	al, 09h
    	int 	21h	
		mov		ah, 10h						;Wait Keystroke
		int 	16h
    	mov     ax, 4c00h                  	;Exit to DOS
    	int     21h
	.endif
	mov			sp, SS:[BP-2]
	pop			bp
	ret
Start_Process endp

Tank_Customize proc
	set_Background 00h
	SetCursor 0, 0
	PrintString BtnStr1
	check_loop:							;Both space and enter need to be released
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
	lea		di, offset object_tank		;di will be in charge of player 1
	add		di, 8
	lea		si, offset object_tank		;si will be in charge of player 2
	add		si, 22

	PrintP2:							;print player 2's status
	mov		bx, si
	sub		bx, offset object_tank
	.if		bx == 22					;Body
	SetCursor 69, 15
	Delete_Line
	PrintString TankStr4
	.endif
	.if		bx == 24					;Gun
	SetCursor 69, 15
	Delete_Line
	PrintString TankStr6
	.endif	
	.if		bx == 26					;Tire
	SetCursor 69, 15
	Delete_Line
	PrintString TankStr5
	.endif

	PrintP1:							;print player 2's status
	bt		ax, 0						;0 bit of ax is 1 represents player 1 is ready
	jc		Determine2
	mov		bx, di
	sub		bx, offset object_tank
	.if		bx == 8						;Body
	SetCursor 19, 15
	Delete_Line
	PrintString TankStr4
	.endif
	.if		bx == 10					;Gun
	SetCursor 19, 15
	Delete_Line
	PrintString TankStr6
	.endif
	.if		bx == 12					;Tire
	SetCursor 19, 15
	Delete_Line
	PrintString TankStr5
	.endif
	jmp		Determine2
	Start:
	.if		char_status[0] == 1			;Exit to home page
		set_Background bg_color
		mov		ax, 1
		ret	
	.endif
	.if		al == 00000011b				;Both players are ready
		jmp		set_Complete
	.endif
	.if		char_status[5] == 1			;space got pressed
		bt		cx, 2					;prevent program running to fast, that cause the status change multiple times in one keystroke
		jc		Determine2
		bts		cx, 2				
		btc		ax, 0					;complement 0 bit of ax
		jc		Player1_space
		SetCursor 19, 15
		Delete_Line
		PrintString TankStr3			;String ready
		jmp		exit_P1
		Player1_space:
		jmp		PrintP1
		exit_P1:
	.endif
	.if		char_status[5] == 0			;space release 
		btr		cx, 2
	.endif
	bt		ax, 0						;player 1 ready
	jc		Determine2
	.if		char_status[1] == 1			;w
		inc		byte ptr[di]
		Print_Tank
		jmp		Determine2
	.endif
	.if		char_status[2] == 1			;s
		dec		byte ptr[di]
		Print_Tank
		jmp		Determine2
	.endif
	.if		char_status[3] == 1			;a
		bt		cx, 0					;press and release detection 
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
	.if		char_status[3] == 0			;a released
		btr		cx, 0
	.endif
	.if		char_status[4] == 1			;d
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
	.if		char_status[4] == 0			;d released
		btr		cx, 1
	.endif


	
	Determine2:
	.if		char_status[10] == 1		;enter
		bt		cx, 5
		jc		Start
		bts		cx, 5
		btc		ax, 1
		jc		Player2_enter
		SetCursor 69, 15
		Delete_Line
		PrintString TankStr3			;ready str
		jmp		exit_P2
		Player2_enter:
		jmp		PrintP2
		exit_P2:
	.endif
	.if		char_status[10] == 0		;enter released
		btr		cx, 5
	.endif
	bt		ax, 1
	jc		Start

	.if		char_status[6] == 1			;up
		inc		byte ptr[si]
		Print_Tank
		jmp		Start
	.endif
	.if		char_status[7] == 1			;down
		dec		byte ptr[si]
		Print_Tank
		jmp		Start
	.endif
	.if		char_status[8] == 1			;left
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
	.if		char_status[8] == 0			;left released
		btr		cx, 3
	.endif
	.if		char_status[9] == 1			;right
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
	.if		char_status[9] == 0			;right released
		btr		cx, 4
	.endif
	jmp			Start
	
	set_Complete:						
	push 	es							;store color into file 
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
	mov 	ah, 3Dh					;Open file
    mov 	al, 2					;W/R
    lea 	dx, file_name
    int 	21h
    mov 	bx, file_handle
    mov 	cx, 14					;14 Bytes to write
    lea 	dx, file_in
    mov 	ah, 40h
    int 	21h
    mov 	ah, 3Eh					;close file
    mov 	bx, file_handle
    int 	21h
	set_Background bg_color
	xor		ax, ax
	ret
Tank_Customize endp

Set_Difficulty proc
	set_Background 00h
	SetCursor 0,0 
	PrintString	BtnStr1
	checkRelease:
	.if char_status[5] == 1 || char_status[10] == 1
		jmp	checkRelease
	.endif
	set_Background 00h
	SetCursor 0, 0
	PrintString Diff_Str1
	SetCursor 45, 18
	PrintString Diff_Str2
	SetCursor 9, 36
	PrintString Diff_Str7
	Select_Loop:
	SetCursor 52, 18
	Delete_Line
	.if		bound_time == 0
		PrintString Diff_Str3
	.endif
	.if		bound_time == 1
		PrintString Diff_Str4
	.endif
	.if		bound_time == 3
		PrintString Diff_Str5
	.endif
	.if		bound_time == 5
		PrintString Diff_Str6
	.endif
	check_input:
	.if		char_status[4] == 0 && char_status[9] == 0		;press and release detection
		btr		cx, 0										;released
	.endif
	.if		char_status[3] == 0 && char_status[8] == 0
		btr		cx, 1
	.endif
	bt		cx, 0
	jc		check_input
	.if		char_status[4] == 1 || char_status[9] == 1		;D or right
		.if		bound_time == 0								
			mov bound_time, 1
		.elseif bound_time == 5
			mov bound_time, 0
		.else
			add bound_time, 2
		.endif
		bts		cx, 0										;0 bit of cx is 1 after pressed
		jmp		Select_Loop
	.endif
	bt		cx, 1
	jc		check_input
	.if		char_status[3] == 1 || char_status[8] == 1		;A or left
		.if		bound_time == 0
			mov bound_time, 5
		.elseif bound_time == 1
			mov bound_time, 0
		.else
			sub bound_time, 2
		.endif
		bts		cx, 1
		jmp		Select_Loop
	.endif
	.if		char_status[0] == 1								;Back to home page
		mov		ax, 1
		ret
	.endif
	.if		char_status[5] == 1 && char_status[10] == 1		;selected
		jmp 	Exit_process
	.endif
	jmp		check_input

	Exit_process:
	.if		char_status[5] == 1 || char_status[10] == 1		
		set_Background 00h
		SetCursor 0, 0
		PrintString BtnStr1
		wait_release:										;Wait for release
		.if	char_status[5] == 1 || char_status[10]==1
			jmp		wait_release
		.endif
	.endif
	set_Background bg_color
	xor		ax, ax
	ret
Set_Difficulty endp

Choose_Map proc							
	lea		di, map
	push	es
	mov		ax, @data
	mov		es, ax
	cld
	mov		cx, 0FFFFh
	mov		ax, 0FF87h
	repne	scasw											;Find the end of map array 
	sub		di, 2							
	mov		dx, di											;get offset
	sub		dx,	offset map									;dx = how many bytes in map
	pop		es
	lea		di, map
	mov		mapType, di
	setMap 	mapType
	L1:
		SetCursor 0, 0
		PrintString mapStr1
		SetCursor 5, 36
		PrintString mapStr2
		.if		char_status[0] == 1							;back to home page
			set_Background bg_color
			mov		ax, 1
			ret	
		.endif
		.if		char_status[3] == 1 || char_status[8] == 1	;A or left
			set_Background bg_color
			mov		cx, di									;find current offset in map array
			sub		cx, offset map
			.if		cx <= 0									;Reach 0, Back to max
				lea		di, map
				add		di, dx
			.endif
			sub		di, 4
			mov		cx, di
			sub		cx, offset map							;byte to word
			shr		cx, 1
			.if		cx > 0
				std											;Direction flag = 1, find from high to low
				push	es
				mov		ax, @data
				mov		es, ax
				mov		ax, 0ffffh							;Find the end of each map
				repne	scasw
				pop		es
				cmp		cx, 0
				jz		exit_Left
				add		di, 4								;Will equal to start of each map
			.endif
			exit_Left:
			cld												;clear direction flag
			mov		mapType, di								;draw map
			setMap 	mapType
		.endif

		.if		char_status[4] == 1 || char_status[9] == 1	;D and right
			set_Background bg_color
			lea		cx, map
			add		cx, dx
			sub		cx, di
			shr		cx, 1
			cld												;Clear direction flag, low to high
			push	es
			mov		ax, @data
			mov		es, ax
			mov		ax, 0ffffh
			repne	scasw
			pop		es
			
			lea		cx, map
			add		cx, dx
			.if		di >= cx								;exceed the max, set di to the 0 byte in map array
				lea		di, map
			.endif
		mov		mapType, di
		setMap 	mapType
		.endif
		
		.if		char_status[5] == 1 && char_status[10] == 1	;Done
		.else
		jmp			L1										
		.endif
	set_Background bg_color
	mov		mapType, di
	xor		ax, ax
	ret
Choose_Map endp



SetTank_Position proc										;Place the tanks based on th map selected
	push	di												;the result of Choose_map
	mov		cx, di
	sub		cx, offset map									;sub start address of map
	.if		cx > 0
		mov		bx, 0
		L1:
			.if		word ptr[di] == 0ffffh
				inc		bx
			.endif
			sub		di, 2
		loop 	L1
	.else
		mov		bx, 0
	.endif													;bx equals to what map selected
	push	bx
	mov		cx, 3
	shl		bx, cl											;bx*8
	pop		ax												
	mov		cx, 2
	shl		ax, cl											;what map selected * 4
	add		bx, ax											;what map selected * 12
	lea		di, object_tank
	lea		si, TankInit_set
	add		si, bx
	push	es
	mov		ax, @data
	mov		es, ax
	cld														;clear direction flag
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
	cmp		char_status[0], 1								;esc to home page
	jne		L1
	ret
About endp

Tutorial proc
	set_Background 00h
	SetCursor 0, 0
	PrintString TutorStr
	L1:
	cmp		char_status[0], 1								;esc to home page
	jne		L1
	ret
Tutorial endp



GetFile proc
	Open_FIle:
    mov ah, 3Dh
    mov al, 2
    lea dx, file_name
    int 21h
    mov file_handle, ax
    jc NO_File											;Failed = File not found
    jnc FindFIle										;Successed = found
    NO_File:
    mov ah, 3ch											;Create file
    mov cx, 7
    lea dx, file_name
    int 21h
    mov ah, 3Dh											;open file mode W/R
    mov al, 2
    lea dx, file_name
    int 21h
    mov file_handle, ax									;Store default value into GameData
    mov ah, 40h
    mov bx, file_handle
    mov cx, 14
    lea dx, file_default
    int 21h
    mov ah, 3Eh											;close file
    mov bx, file_handle
    int 21h
	Introdution IntroStr, TutorStr						;Introdution of the game
    jmp Open_FIle
    FindFIle:
    mov ah, 3fh											;Read what in file
    mov bx, file_handle
    mov cx, 14
    lea dx, file_in
    int 21h
    .if word ptr file_in[0]!= 0ff87h					;File format not correct
        mov ah, 3Eh
        mov bx, file_handle
        int 21h
        jmp NO_File
    .endif
    mov ah, 3Eh											;close file
    mov bx, file_handle
    int 21h
	ret
GetFile endp

ShowTitle proc
	mov di, word ptr TitleColor[0]						;Get previous color
	add di, di
	print_title 100, 50, word ptr TitleColor[di]
	inc word ptr TitleColor
	.if word ptr TitleColor[di+2] == 0ffffh				;exceed the max
	mov word ptr TitleColor[0], 1						;reset to first color
	.endif
	ret
ShowTitle endp

GameMode_A proc
	push		bp
	mov			bp, sp
	push 		sp
	set_Background bg_color
	SetCursor   0, 0
	PrintString BtnStr1
	exitLoop:
		.if	char_status[5] != 0 || char_status[10] != 0	;wait space and enter release
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
	sub			dx, word ptr game_timer[6]
	cmp 		dx, 20
	jge			TimeupB
	sub			cx, word ptr game_timer[4]
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
	mov 		word ptr game_timer[4], cx
	mov			word ptr game_timer[6], dx
	jmp			GameA

	GameSet:											;Game set
	push		si
	set_Background bg_color
	pop			si
	sub			si, offset object_tank					;Find the winner
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
	.endif
	.if			si == 14
		mov			word ptr object_tank[2], 400
		mov			word ptr object_tank[4], 300
		mov			word ptr object_tank[6], 1
		mov			word ptr object_tank[si], 0
		Print_Tank
		SetCursor	25, 36
		PrintString winStr1
	.endif
	wait_player:
		invoke		Playmusic						;Play music
		cmp			char_status[0], 1
		jne			wait_player
	push		3									;Stop the music
	invoke		musicInit
	invoke		PlayLoopMusic
	exit_game:
	mov			sp, SS:[bp-2]
	pop			bp
	ret
GameMode_A endp

init_Page proc		
	call	GetFile								
    set_Background 00h
	Clear_All_Object								;Clear bullets and tanks
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
    print_title 100, 50, 6
	ret
init_Page endp

MyInterrupt proc
	cli								;Disable Interrupt
	pushf
    push        ax
    push        cx
    push        di
    push        es
    mov         ax, @data
    mov         es, ax
    in 			al, 60h				;Get Scan code
	push		ax
	cld
	and			al, 01111111b	
	lea 		di, char_table		;which key?
	mov 		cx, LENGTHOF char_table
	repne  		scasb
	pop			ax
	je          FindChar			;Find in char_table
    jmp			exit_Handler
    FindChar:
    sub			di, offset char_table
	dec         di
	bt			ax, 7				;Press or release
	jnc			Press
	jc			Release
	Press:
	mov			byte ptr char_status[di], 1
	jmp 		exit_Handler
    Release:
	mov			byte ptr char_status[di], 0
	jmp			exit_Handler
    exit_Handler:
	mov 		al, 20h				;acknowledge the interrupt
    out 		20h, al
	pop         es
    pop         di
    pop         cx
    pop         ax
	popf
	sti								;Enable the interrupt
    iret
MyInterrupt endp

end main
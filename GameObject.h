;uProcessor Final Project
;File name: GameObject.h
;Date: 2019/12/15
;Author: Yu Shan Huang
;StudentID: B10707049
;National Taiwan University of Science Technology
;Department of Electrical Engineering

;Bullet Direction
;   8   1   2
;    \  |  /
;     \ | /
;      \|/
;7---------------3
;      /|\
;     / | \
;    /  |  \ 4
;    6  5
;Bullet 
;object info
;Object ID, x Position, y Position, Direction, Count of rebound
Create_Bullet macro xPara, yPara, Direction                             ;Will draw a bullet
	Local		checkLoop, FindAvailable, NoStorage
	pusha
	push		bp
	push		sp
	push		xPara
	push		yPara
	push		Direction
	mov			bp, sp

	lea			di, object                                              ;load object storage
	mov			cx, LENGTHOF object
	checkLoop:								                            ;object Number, xPara, yPara
		cmp			word ptr[di], 0                                     ;0 means the storage is unuse
		je			FindAvailable
		add			di, 10                                              ;check the next element
		sub			cx, 5                       
		cmp			cx, 0
		jle			NoStorage                                           ;Ran out of storage
		jmp 		checkLoop                   
	FindAvailable:
	mov			word ptr[di], 2 
	mov			ax, word ptr SS:[BP+4]                                    
	mov			word ptr[di+2], ax
	mov			ax, word ptr SS:[BP+2]    
	mov			word ptr[di+4], ax
	mov			ax, word ptr SS:[BP]    
	mov			word ptr[di+6], ax
	mov			word ptr[di+8], 0000h			
	NoStorage:
	mov			sp, word ptr SS:[BP+6]
	pop			bp
	popa
endm

Create_Tank macro userID, xPara, yPara, Direction, body_color, gun_color, tire_color
Local		checkLoop, FindAvailable, NoStorage
	pusha
	lea			di, object_tank                                             ;load object storage
	mov			cx, LENGTHOF object_tank
	checkLoop:								                            ;object Number, xPara, yPara
		cmp			word ptr[di], 0                                     ;0 means the storage is unuse
		je			FindAvailable
		add			di, 14                                              ;check the next element
		sub			cx, 7                       
		cmp			cx, 0
		jle			NoStorage                                           ;Ran out of storage
		jmp 		checkLoop                   
	FindAvailable:
	mov			word ptr[di], userID                                    
	mov			word ptr[di+2], xPara
	mov			word ptr[di+4], yPara
	mov			word ptr[di+6], Direction
	mov			word ptr[di+8], body_color
	mov			word ptr[di+10], gun_color
	mov			word ptr[di+12], tire_color			
	NoStorage:
	popa
endm

Clear_All_Object macro
	pusha
	push		es
	mov			ax, ds
	mov			es, ax
	cld
	lea			di, object
	mov			cx, sizeof object
	mov			al, 0
	rep			stosb
	lea			di, object_tank
	mov			cx, sizeof object_tank
	mov			al, 0
	rep			stosb
	pop			es
	popa
endm

Print_Tank macro
	Local PrintLoop, ObjectNotFound
	pusha
	lea			si, object_tank
	mov			cx, LENGTHOF object_tank
	PrintLoop:							
		cmp			word ptr [si], 0
		je			ObjectNotFound
		push 		si
		push		cx
		push		word ptr [si+2]				;xPara
		push		word ptr [si+4]				;yPara
		push		word ptr [si+6]				;Direction
		push		word ptr [si+8]				;body
		push		word ptr [si+10]				;gun
		push		word ptr [si+12]				;tire
		invoke		TankProcess
		pop			cx
		pop			si
		ObjectNotFound:
		add			si, 14
		sub			cx, 7
		cmp			cx, 0
		jg			PrintLoop
	popa
endm
;The map format
;Example:
;map01 dw 0, 0, 50, 50     is a square from (0,0) to (50,50)
;	dw 100, 300, 150, 480
;	dw 300, 150, 350, 350
;	dw 550, 0, 580, 250
;	dw 580, 400, 639, 480, 0ffffh

setMap macro mapOffset
    Local           L1, L2, L3
	pusha
	mov 			di, mapOffset                                       ;mov the map offset to di
	L1:
		mov				cx, word ptr[di]                                ;start from the top left corner
		L2:                                                             
		mov				dx, word ptr[di+2]                              ;Draw from left to right 
			L3:                                                         ;Draw from up to down
					draw_pixel 	cx, dx, 0AFh
					inc			dx
					cmp			dx, word ptr[di+6]                      ;Reach bottom
					jle			L3
			inc				cx
			cmp				cx, word ptr[di+4]
			jle				L2                                          ;Reach the rightmost side
		add				di, 8			
		cmp				word ptr[di], 0FFFFh                            ;if the next content is not 0FFFFh
		jne				L1                                              ;draw next object
	popa
endm

;Will update the motion of bullet
Bullet_move macro
	Local Up, UpRight, Right, DownRight, Down, DownLeft, Left, UpLeft, bullet_set
	pusha
	mov			ax, word ptr[di+2]
	mov			bx, word ptr[di+4]
	cmp			word ptr[di+6], 1
	je			Up
	cmp			word ptr[di+6], 2
	je			UpRight
	cmp			word ptr[di+6], 3
	je			Right
	cmp			word ptr[di+6], 4
	je			DownRight
	cmp			word ptr[di+6], 5
	je			Down
	cmp			word ptr[di+6], 6
	je			DownLeft
	cmp			word ptr[di+6], 7
	je			Left
	cmp			word ptr[di+6], 8
	je			UpLeft
	Up: 
	sub			bx, speed_of_Bullet
	jmp bullet_set
	UpRight:
	add			ax, speed_of_Bullet
	sub			bx, speed_of_Bullet
	jmp bullet_set
	Right:
	add			ax, speed_of_Bullet
	jmp bullet_set
	DownRight:
	add			ax, speed_of_Bullet
	add			bx, speed_of_Bullet
	jmp bullet_set
	Down:
	add			bx, speed_of_Bullet
	jmp bullet_set
	DownLeft:
	sub			ax, speed_of_Bullet
	add			bx, speed_of_Bullet
	jmp bullet_set
	Left:
	sub			ax, speed_of_Bullet
	jmp bullet_set
	UpLeft:
	sub			ax, speed_of_Bullet
	sub			bx, speed_of_Bullet
	jmp bullet_set
	bullet_set:
	mov			word ptr[di+2], ax		;x in ax, y in bx
	mov			word ptr[di+4], bx
	popa
endm



Update_Bullet macro
    Local       checkLoop, Check_Collision, MeetBoundary, InYRange, Make_opposite, NextObject, L2, InXRange, ObjectOut
    Local       proc_end, L1, Recheck, Update, Make_oppositeX, Make_oppositeY, Recheck2
    pusha
	lea			di, object 
	mov			cx, LENGTHOF object
	checkLoop:								;object Number, xPara, yPara
		cmp			word ptr[di], 2
		jne			NextObject
		
		draw_circle word ptr[di+2], word ptr[di+4], 5, bg_color
		
		Check_Collision:
		mov			ax, word ptr Screen_Size[0]
		sub			ax, 10
		cmp			word ptr[di+2], ax
		jge			Make_oppositeY
		cmp			word ptr[di+2], 10
		jle			Make_oppositeY
		mov			ax, word ptr Screen_Size[2]
		sub			ax, 10
		cmp         word ptr[di+4], ax
		jge			Make_oppositeX
		cmp 		word ptr[di+4], 10
		jle			Make_oppositeX
		

		;check collision with obstacle
		mov 		si, mapType
		L1:
		mov			ax, word ptr[si+4]		;xMax of obstacle
		add			ax, 8
		cmp			word ptr[di+2], ax		;if xPosition is bigger than xMax
		jg			Recheck					;check next obstacle
		mov			ax, word ptr[si]		;xMin of obstacle
		sub			ax, 8
		cmp			word ptr[di+2], ax		;if xPosition is bigger than xMin
		jge			InYRange				;Mean it is in the range of obstacle in x asix 
		Recheck:
		add			si, 8			
		cmp			word ptr[si], 0FFFFh
		jne			L1
		mov 		si, mapType
		jmp			L2
		InYRange:
		mov			ax, word ptr[si+6]		;YMax of obstacle
		sub			ax, 5
		cmp			word ptr[di+4], ax		;if yPosition is bigger than yMax
		jg			L2						;check next obstacle
		mov			ax, word ptr[si+2]		;yMin of obstacle
		add ax,5
		cmp			word ptr[di+4], ax		;if yPosition is bigger than yMin
		jge			Make_oppositeY			;bullet meet obstacle
		jmp 		Recheck


		
		L2:

		mov			ax, word ptr[si+6]		;yMax of obstacle
		add 		ax, 8
		cmp			word ptr[di+4], ax		;if yPosition is bigger than yMax
		jg			Recheck2					;check next obstacle
		mov			ax, word ptr[si+2]		;yMin of obstacle
		sub			ax, 8
		cmp			word ptr[di+4], ax		;if yPosition is bigger than yMin
		jge			InXRange				;Mean it is in the range of obstacle in y asix 
		Recheck2:
		add			si, 8			
		cmp			word ptr[si], 0FFFFh
		jne			L2
		je			Update
		InXRange:
		mov			ax, word ptr[si+4]		;XMax of obstacle
		sub			ax, 5
		cmp			word ptr[di+2], ax		;if XPosition is bigger than XMax
		jg			Recheck2				;check next obstacle
		mov			ax, word ptr[si]		;XMin of obstacle
		add			ax, 5
		cmp			word ptr[di+2], ax		;if xPosition is bigger than xMin
		jge			Make_oppositeX			;bullet meet obstacle
		jmp 		Recheck2



		Make_oppositeX:
		xor			bx, bx
		xor			ax, ax
		mov			bl, byte ptr[di+6]
		dec    		bl
		mov			al, bound_handler[bx]
		mov			word ptr[di+6], ax
		jmp MeetBoundary

		Make_oppositeY:
		xor			bx, bx
		xor			ax, ax
		mov			bl, byte ptr[di+6]
		dec    		bl
		mov			al, bound_handler[bx+8]
		mov			word ptr[di+6], ax
		jmp MeetBoundary

		MeetBoundary:
		Bullet_move
		inc			word ptr[di+8]
		cmp			word ptr [di+8], 1
		jle         Update
		mov			word ptr[di], 0
		mov			word ptr[di+2], 0
		mov			word ptr[di+4], 0
		mov			word ptr[di+6], 0
		mov			word ptr[di+8], 0
		jmp 		NextObject
		Update:
		Bullet_move
		ObjectOut:
		
		cmp			word ptr[di], 2
		jne			NextObject
		Collision_With_Tank word ptr[di+2], word ptr[di+4]
		draw_circle word ptr[di+2], word ptr[di+4], 5, 0Ah
		NextObject:
		add			di, 10
		sub			cx, 5
		cmp			cx, 0
		jg			checkLoop
	proc_end:
		
    popa
endm

Collision_With_Tank macro xPara, yPara
	Local checkLoop, checkNext, xSquare, ySquare, L1, L2
	pusha
	push		sp
	push		word ptr yPara
	push		word ptr xPara
	
	mov			bp, sp
	mov			si, offset object_tank
	mov			cx, LENGTHOF object_tank
	xor			ax, ax
	xor			bx, bx
	mov			bl, 28
	mov			al, 28
	mul			bl
	push		ax
	checkLoop:
	mov			ax, word ptr[si+2]
	sub			ax, word ptr SS:[BP]
	xSquare:
	mov			bx, ax
	imul		bx
	push		dx
	push		ax
	mov			ax, word ptr[si+4]
	sub			ax, word ptr SS:[BP+2]
	ySquare:
	mov			bx, ax
	imul		bx

	pop			bx
	add			ax, bx
	pop			bx
	adc			dx, bx

	
	cmp			ax, SS:[BP-2]
	ja			checkNext
	cmp			dx, 0
	jg			checkNext
	xor			ax, ax
	mov			al, 0Ah
	mov			word ptr[di], 0
	mov			word ptr[si+8], ax
	mov			word ptr[si+10], ax
	mov			word ptr[si+12], ax
	mov			word ptr SS:[BP+8], si
	Print_Tank
	push		0
	invoke		musicInit
	invoke		PlayLoopMusic
	mov			sp, SS:[BP+4]
	popa
	jmp			GameSet
	checkNext:
	add			si, 14
	sub			cx, 7
	cmp			cx, 0
	jg			checkLoop

	mov			sp, SS:[BP+4]
	popa
endm

Print_Bullet macro
	Local PrintLoop, ObjectNotFound
	pusha
	lea			di, object
	mov			cx, LENGTHOF object
	PrintLoop:								;object Number, xPara, yPara
		cmp			word ptr[di], 1
		jne			ObjectNotFound
		cmp			word ptr[di+8], 1
		jg 			ObjectNotFound
		draw_circle word ptr[di+2], word ptr[di+4], 5, 0Ah
		ObjectNotFound:
		add			di, 10
		sub			cx, 5
		cmp			cx, 0
		jg			PrintLoop
	popa
endm

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


Discharge_Bullet macro
	Local Discharge1, Discharge2, Discharge3, Discharge4, Discharge5, Discharge6, Discharge7, Discharge8, Finish
	mov			di, word ptr[si+6]
	cmp			di, 1
	je			Discharge1
	cmp			di, 2
	je			Discharge2
	cmp			di, 3
	je			Discharge3
	cmp			di, 4
	je			Discharge4
	cmp			di, 5
	je			Discharge5
	cmp			di, 6
	je			Discharge6
	cmp			di, 7
	je			Discharge7
	cmp			di, 8
	je			Discharge8
	Discharge1:
	add			ax, 0
	sub			bx, 35
	jmp 		Finish
	Discharge2:
	add			ax, 27
	sub			bx, 25
	jmp			Finish
	Discharge3:
	add			ax, 35
	add			bx, 2
	jmp			Finish
	Discharge4:
	add			ax, 26
	add			bx, 26
	jmp			Finish
	Discharge5:
	add			ax, 0
	add			bx, 35
	jmp			Finish
	Discharge6:
	sub			ax, 26
	add			bx, 27
	jmp			Finish
	Discharge7:
	sub			ax, 32
	add			bx, 1
	jmp			Finish
	Discharge8:
	sub			ax, 26
	sub			bx, 24
	jmp			Finish
	Finish:
	Create_Bullet ax, bx, di

endm

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
;x Position, y Position, Direction, Count of rebound
Create_Bullet macro xPara, yPara, Direction                             ;Will draw a bullet
	Local		checkLoop, FindAvailable, NoStorage
	pusha
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
	mov			word ptr[di+2], xPara
	mov			word ptr[di+4], yPara
	mov			word ptr[di+6], Direction
	mov			word ptr[di+8], 0			
	NoStorage:
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
	mov 			di, mapOffset                                       ;mov the map offset to di
	L1:
		mov				cx, word ptr[di]                                ;start from the top left corner
		L2:                                                             
		mov				dx, word ptr[di+2]                              ;Draw from left to right 
			L3:                                                         ;Draw from up to down
					draw_pixel 	cx, dx, 01h
					inc			dx
					cmp			dx, word ptr[di+6]                      ;Reach bottom
					jle			L3
			inc				cx
			cmp				cx, word ptr[di+4]
			jle				L2                                          ;Reach the rightmost side
		add				di, 8			
		cmp				word ptr[di], 0FFFFh                            ;if the next content is not 0FFFFh
		jne				L1                                              ;draw next object

endm

;Will update the motion of bullet
Update_Bullet macro
    Local       checkLoop, Up, UpRight, Right, DownRight, Down, DownLeft, Left, UpLeft, bullet_set, Check_Collision, MeetBoundary, InYRange, Make_opposite, NextObject
    Local       proc_end, PrintLoop, ObjectNotFound, L1, Recheck
    pusha
	lea			di, offset object 
	mov			cx, LENGTHOF object
	checkLoop:								;object Number, xPara, yPara
		cmp			word ptr[di], 2
		jne			NextObject
		draw_circle word ptr[di+2], word ptr[di+4], 5, 00h
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
		Check_Collision:
		mov			ax, word ptr Screen_Size[0]
		sub			ax, 5
		cmp			word ptr[di+2], ax
		jge			MeetBoundary
		cmp			word ptr[di+2], 5
		jle			MeetBoundary
		mov			ax, word ptr Screen_Size[2]
		sub			ax, 5
		cmp         word ptr[di+4], ax
		jge			MeetBoundary
		cmp 		word ptr[di+4], 5
		jle			MeetBoundary
		

		;check collision with obstacle
		mov 		si, mapType
		L1:
		mov			ax, word ptr[si+4]		;xMax of obstacle
		add			ax, 10
		cmp			word ptr[di+2], ax		;if xPosition is bigger than xMax
		jg			Recheck					;check next obstacle
		mov			ax, word ptr[si]		;xMin of obstacle
		sub			ax, 10
		cmp			word ptr[di+2], ax		;if xPosition is bigger than xMin
		jge			InYRange				;Mean it is in the range of obstacle in x asix 
		Recheck:
		add			si, 8			
		cmp			word ptr[si], 0FFFFh
		jne			L1
		je			NextObject
		InYRange:
		mov			ax, word ptr[si+6]		;YMax of obstacle
		add			ax, 10
		cmp			word ptr[di+4], ax		;if yPosition is bigger than yMax
		jg			Recheck					;check next obstacle
		mov			ax, word ptr[si+2]		;yMin of obstacle
		sub			ax, 10
		cmp			word ptr[di+4], ax		;if yPosition is bigger than yMin
		jge			MeetBoundary			;bullet meet obstacle
		jmp 		Recheck					

		MeetBoundary:
		inc			word ptr[di+8]
		cmp			word ptr [di+8], 1
		jle         Make_opposite
		mov			word ptr[di], 0
		Make_opposite:
		add			byte ptr[di+6], 4
		cmp			byte ptr[di+6], 8
		jle 		NextObject
		sub			byte ptr[di+6], 8
		NextObject:
		add			di, 10
		sub			cx, 5
		cmp			cx, 0
		jg			checkLoop
	proc_end:
	lea			di, object
	mov			cx, LENGTHOF object
	PrintLoop:								;object Number, xPara, yPara
		cmp			word ptr[di], 2
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

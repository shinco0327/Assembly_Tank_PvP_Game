;uProcessor Final Project
;File name: GameObject.h
;Date: 2020/1/1
;By B10707009 and B10707049
;National Taiwan University of Science And Technology
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

;player number, xPara, yPara, direction, body color, gun color, tire color
Create_Tank macro userID, xPara, yPara, Direction, body_color, gun_color, tire_color
Local		checkLoop, FindAvailable, NoStorage
	pusha
	lea			di, object_tank                                         ;load object storage
	mov			cx, LENGTHOF object_tank
	checkLoop:								                            
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
	mov			ax, body_color
	mov			word ptr[di+8], ax
	mov			ax, gun_color
	mov			word ptr[di+10], ax
	mov			ax, tire_color
	mov			word ptr[di+12], ax			
	NoStorage:
	popa
endm

Clear_All_Object macro													;will clear object and object_tank 
	pusha
	push		es
	mov			ax, ds
	mov			es, ax													;es = @data
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
		push		word ptr [si+10]			;gun
		push		word ptr [si+12]			;tire
		invoke		TankProcess					;TankProcess at pj5
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
;map dw 0, 0, 50, 50     is a square from (0,0) to (50,50)
;	 dw 100, 300, 150, 480
;	 dw 300, 150, 350, 350, 0ffffh
;	 dw 550, 0, 580, 250
; 	 dw 580, 400, 639, 480, 0ffffh, 0ff87h

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
	cmp			word ptr[di+6], 1										;Direction determine how x and y change
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
	mov			word ptr[di+2], ax												;x in ax, y in bx
	mov			word ptr[di+4], bx
	popa
endm



Update_Bullet macro
    Local       checkLoop, Check_Collision, MeetBoundary, InYRange, Make_opposite, NextObject, L2, InXRange, ObjectOut
    Local       proc_end, L1, Out_Range, positive1, positive2, positive3, positive4, No_Move
    pusha
	lea			di, object 
	mov			cx, LENGTHOF object
	checkLoop:																	;object Number, xPara, yPara, direction, bound counter
		cmp			word ptr[di], 2
		jne			NextObject
		
		draw_circle word ptr[di+2], word ptr[di+4], 5, bg_color					;erase the bullet
		xor			dx, dx														
		Check_Collision:														;check the collion with the boundary
		mov			ax, word ptr Screen_Size[0]
		sub			ax, 13
		.if			word ptr[di+2] >= ax
			bts			dx, 0		
			jmp			Make_oppositeY
		.endif
		.if			word ptr[di+2] <= 13
			bts			dx, 0		
			jmp			Make_oppositeY
		.endif
		mov			ax, word ptr Screen_Size[2]
		sub			ax, 13
		.if			word ptr[di+4] >= ax
			bts			dx, 0		
			jmp			Make_oppositeX
		.endif
		.if			word ptr[di+4] <= 13
			bts			dx, 0		
			jmp			Make_oppositeX
		.endif
		

		;check collision with obstacle
		mov 		si, mapType
		L1:
			mov			ax, word ptr[si+4]
			add			ax, 13
			.if			word ptr DS:[di+2] > ax
				jmp			Out_Range
			.endif
			mov			ax, word ptr[si]
			sub			ax, 13
			.if			word ptr DS:[di+2] < ax
				jmp			Out_Range
			.endif
			mov			ax, word ptr[si+6]
			add			ax, 13
			.if			word ptr DS:[di+4] > ax
				jmp			Out_Range
			.endif
			mov			ax, word ptr[si+2]
			sub			ax, 13
			cmp			word ptr DS:[di+4], ax
			jle			Out_Range
			
			
			push		sp
			mov			bp, sp
			mov			ax, word ptr[si]		;With obstacle X0
			sub			ax, word ptr[di+2]
			cmp			ax, 0
			jge			positive1
			dec			ax
			not			ax
			positive1:
			push		ax
			mov			ax, word ptr[di+2]
			sub			ax, word ptr[si+4]		;With obstacle X1
			cmp			ax, 0
			jge			positive2
			dec			ax
			not			ax
			positive2:
			push		ax
			mov			ax, word ptr[si+2]		;With obstacle y0
			sub			ax, word ptr[di+4]
			cmp			ax, 0
			jge			positive3
			dec			ax
			not			ax
			positive3:
			push		ax
			mov			ax, word ptr[si+6]		;With  obstacle y1
			sub			ax, word ptr[di+4]
			cmp			ax, 0
			jge			positive4
			dec			ax
			not			ax
			positive4:
			push		ax
			push		cx
			xor			bx, bx
			mov			dx, 0FFFFh
			mov			cx, 4

			L2:									;Find its near x-axis or y-axis
			sub			bp, 2
				.if 		dx >= word ptr SS:[bp] && word ptr SS:[BP] < 13
					mov			dx, word ptr SS:[bp]
					mov			bx, cx
				.endif
			loop 		L2
			pop			cx
			mov			sp, word ptr SS:[bp+8]
			mov			ax, word ptr DS:[di+2]
			mov			dx, word ptr DS:[di+4]
			.if			bx == 4 || bx ==3  
				.if			dx < word ptr[si+2] || dx > word ptr[si+6]
					bts			dx, 0
					jmp			Make_oppositeX
				.endif
				jmp		Make_oppositeY			
			.endif
			.if			bx == 2 || bx == 1
				.if			ax < word ptr[si] || ax > word ptr[si+4] 
					bts			dx, 0
					jmp			Make_oppositeY
				.endif
				jmp		Make_oppositeX
			.endif

		Out_Range:
		add			si, 8						;Find next object
		cmp			word ptr[si], 0FFFFh
		jne			L1
		jmp			Update
		

		Make_oppositeX:							;bound with Y-axis
		xor			bx, bx
		xor			ax, ax
		mov			bl, byte ptr[di+6]
		dec    		bl
		mov			al, bound_handler[bx]
		mov			word ptr[di+6], ax
		jmp MeetBoundary

		Make_oppositeY:							;bound with X-axis
		xor			bx, bx
		xor			ax, ax
		mov			bl, byte ptr[di+6]
		dec    		bl
		mov			al, bound_handler[bx+8]
		mov			word ptr[di+6], ax
		jmp MeetBoundary

		MeetBoundary:							;Different direction & bound counter+1
		bt			dx, 0
		jnc			No_Move
		mov			speed_of_Bullet, 5
		Bullet_move
		mov			speed_of_Bullet, 8
		No_Move:
		inc			word ptr[di+8]
		mov			ax, bound_time
		cmp			word ptr [di+8], ax
		jle         Update
		mov			word ptr[di], 0
		mov			word ptr[di+2], 0
		mov			word ptr[di+4], 0
		mov			word ptr[di+6], 0
		mov			word ptr[di+8], 0
		jmp 		NextObject
		Update:									;Move bullet
		Bullet_move
		ObjectOut:								;print bullet
		cmp			word ptr[di], 2
		jne			NextObject
		Collision_With_Tank word ptr[di+2], word ptr[di+4]
		draw_circle word ptr[di+2], word ptr[di+4], 5, 0Ah
		NextObject:								;Process next bullet
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
	xSquare:								;(Bullet X - Tank X)^2
	mov			bx, ax
	imul		bx
	push		dx
	push		ax
	mov			ax, word ptr[si+4]
	sub			ax, word ptr SS:[BP+2]
	ySquare:								;(Bullet Y - Tank Y)^2
	mov			bx, ax
	imul		bx

	pop			bx
	add			ax, bx
	pop			bx
	adc			dx, bx

	
	cmp			ax, SS:[BP-2]				;(Bullet X - Tank X)^2 + ;(Bullet Y - Tank Y)^2 < 28^2
	ja			checkNext
	cmp			dx, 0
	jg			checkNext					;Got shoot
	xor			ax, ax
	mov			al, 0Ah
	mov			word ptr[di], 0
	mov			word ptr[si+8], ax			;Show hit color
	mov			word ptr[si+10], ax
	mov			word ptr[si+12], ax
	mov			word ptr SS:[BP+8], si
	Print_Tank								
	push		0
	invoke		musicInit					;Play hit music
	invoke		PlayLoopMusic
	mov			sp, SS:[BP+4]
	popa
	jmp			GameSet
	checkNext:								;check next tank
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
	PrintLoop:								;object Number, xPara, yPara, direction, bound counter
		cmp			word ptr[di], 1
		jne			ObjectNotFound
		mov			ax, bound_time
		cmp			word ptr[di+8], ax
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
	Discharge1:								;Update bullet coordinate base on its direction
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

Introdution macro Para1, Para2
	Local		L1										;The introduction page
	pusha
	set_Background 00h
	SetCursor	0, 0
	lea			dx, Para1
	mov 		ah, 09h
	int			21h
	SetCursor	0, 3
	lea			dx, Para2
	mov 		ah, 09h
	int			21h
	L1:
		cmp			char_status[0], 1					;ESC to homepage
	jne			L1
	popa
endm

print_title macro x,y, color							;Macro to print title
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

WrPixel macro x, y, color				;If keys get pressed, pause the process to print title 
	.if char_status[0] == 1 || char_status[2] == 1 || char_status[3] == 1
		jmp print_k4_initial
	.endif
	.if char_status[5] == 1 && char_status[10] == 1 
		jmp print_k4_initial
	.endif
	draw_pixel x, y, color
endm

Update_Tank macro UserID, Para			;Update tanks' position
	Local FindLoop, ObjectNotFound, ObjectFound, Act_Control, exit_macro, Forward_Process, Reverse_Process, Left_Process, Right_Process
	Local Forward1, Forward2, Forward3, Forward4, Forward5, Forward6, Forward7, Forward8
	Local Reverse1, Reverse2, Reverse3, Reverse4, Reverse5, Reverse6, Reverse7, Reverse8
	Local CheckComplete, Under_Xmax, Above_Xmin, Under_Ymax, DischargeProcess
	Local checkObstacle, L1, Recheck, InYRange, MeetObstacle
	pusha
	lea			si, object_tank
	mov			cx, LENGTHOF object_tank
	FindLoop:							;find tank offset
		cmp			word ptr [si], UserID
		je			ObjectFound
		ObjectNotFound:
		add			si, 14
		sub			cx, 7
		cmp			cx, 0
		jle			exit_macro
		jmp			FindLoop
	ObjectFound:
	Erase_Tank 							;erase tank
	mov			ax, word ptr[si+2]		;x
	mov			bx, word ptr[si+4]		;y
	mov			cx, Para				;what to act
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
	Right_Process:						;inc direction
	add			word ptr[si+6], 1
	cmp			word ptr[si+6], 9
	jl			exit_macro
	mov			word ptr[si+6], 1
	jmp 		exit_macro
	Left_Process:						;dec direction
	sub			word ptr[si+6], 1
	cmp			word ptr[si+6], 0
	jg			exit_macro
	mov			word ptr[si+6], 8
	jmp 		exit_macro
	Forward_Process:					;mov tank forward
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
	Reverse_Process:					;Reverse the tank
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
	DischargeProcess:					;Discharge the bullet
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
	Under_Xmax:							;Check with boundary
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
	
	checkObstacle:							;check with obstacle
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

GameA_Keyboard macro						;Will check keyboard input
	Local		exit_macro, checkP1_Down, checkP1_Down, checkP1_Left, checkP1_Right
	Local		checkP2_Up, checkP2_Down, checkP2_Left, checkP2_Right, checkP2_Discharge
	Local		P1_Left_Write, P1_Right_Write, P2_Left_Write, P2_Right_Write, P1_Discharge_Write, P2_Discharge_Write

	cmp			byte ptr char_status[0], 1				;ESC
	je			exit_game
	cmp			byte ptr char_status[1], 1				;W
	jne			checkP1_Down
	;P1 up 
	Update_Tank 1, 1
	checkP1_Down:
	cmp			byte ptr char_status[2], 1				;S
	jne			checkP1_Left
	;P2 Down
	Update_Tank 1,3
	checkP1_Left:
	cmp			byte ptr char_status[3], 1				;A
	jne			checkP1_Right
	
	Update_Tank 1, 4
	checkP1_Right:
	cmp			byte ptr char_status[4], 1				;D
	jne			checkP1_Discharge
	
	Update_Tank 1, 2
	checkP1_Discharge:
	cmp			byte ptr char_status[5], 1				;SPACE
	jne			checkP2_Up
	;P1 Discharge
	mov 		ah, 2ch									;cool down time
	int 		21h
	sub			dx, word ptr game_timer[10]
	cmp 		dx, 5
	jge			P1_Discharge_Write
	sub			cx, word ptr game_timer[8]
	jg			P1_Discharge_Write
	jmp			checkP2_Up
	P1_Discharge_Write:
	mov 		ah, 2ch
	int 		21h
	mov 		word ptr game_timer[8], cx
	mov			word ptr game_timer[10], dx
	Update_Tank 1, 5
	checkP2_Up:
	cmp			byte ptr char_status[6], 1				;UP
	jne			checkP2_Down
	;P2 Up
	Update_Tank 2,1
	checkP2_Down:
	cmp			byte ptr char_status[7], 1				;DOWN
	jne			checkP2_Left
	;P2 Down
	Update_Tank 2, 3
	checkP2_Left:
	cmp			byte ptr char_status[8], 1				;LEFT
	jne			checkP2_Right
	;P2 Left
	
	Update_Tank 2, 4
	checkP2_Right:
	cmp			byte ptr char_status[9], 1				;RIGHT
	jne			checkP2_Discharge
	;P2 Right
	
	Update_Tank 2, 2
	checkP2_Discharge:
	cmp			byte ptr char_status[10], 1				;ENTER
	jne			exit_macro
	;P2 Discharge
	mov 		ah, 2ch
	int 		21h
	sub			dx, word ptr game_timer[14]
	cmp 		dx, 5
	jge			P2_Discharge_Write
	sub			cx, word ptr game_timer[12]
	jg			P2_Discharge_Write
	jmp			exit_macro
	P2_Discharge_Write:
	mov 		ah, 2ch
	int 		21h
	mov 		word ptr game_timer[12], cx
	mov			word ptr game_timer[14], dx
	Update_Tank 2, 5
	exit_macro:
endm
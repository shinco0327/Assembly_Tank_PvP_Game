;uProcessor Final Project
;File name: Game.asm
;Date: 2019/11/29
;Author: Yu Shan Huang
;StudentID: B10707049
;National Taiwan University of Science Technology
;Department of Electrical Engineering
include .\INCLUDE\Irvine16.inc
include GameDraw.h
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

.stack 100h

.code


test_shoot macro
    ;draw_pixel 600, 450, 08h
    draw_circle 320, 240, 180, 0Ah
endm

main proc
    mov         ax, @data
    mov         ds, ax

    mov     ax, 0012h
    int     10h

    call    init_Page
    test_shoot
    exit_game:
    mov     ah, 10h
    int     16h
    mov     ax, 0003h                       ;Back to text mode
    int     10h
    mov     ax, 4c00h                       ;Exit to DOS
    int     21h
main endp

init_Page proc
    mov     ah, 0Bh
	mov     bh, 00h
	mov     bl, 06h
	int     10h
    
    ret
init_Page endp

font_set proc 
    ret
font_set endp
end main
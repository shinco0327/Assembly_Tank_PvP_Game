.NOLIST
; Irvine16.inc - Include file for programs using
; the Irvine16.lib (real-mode library)
; Contains procedures that are not yet in the Irvine32 library:
;   Get_Commandtail, Str_compare, Str_copy, Str_length

; Last update: 12/12/01

.model small,stdcall
.stack 4096
.386

ClrScr PROTO
Crlf PROTO
Delay PROTO
DumpMem PROTO
DumpRegs PROTO
Get_Commandtail PROTO
Get_Time PROTO
Gotoxy PROTO
IsDigit PROTO
Randomize PROTO
RandomRange PROTO
Random32 PROTO
ReadHex PROTO
ReadInt PROTO
ReadChar PROTO
ReadString PROTO
WaitMsg PROTO
WriteBin PROTO
WriteChar PROTO
WriteDec PROTO
WriteHex PROTO
WriteInt PROTO
WriteString PROTO

; Copy a source string to a target string.
Str_copy PROTO,
 	source:PTR BYTE,
 	target:PTR BYTE

; Return the length of a null-terminated string..
Str_length PROTO,
	pString:PTR BYTE

; Compare string1 to string2. Set the Zero and
; Carry flags in the same way as the CMP instruction.
Str_compare PROTO,
	string1:PTR BYTE,
	string2:PTR BYTE

; Trim a given trailing character from a string.
; The second argument is the character to trim.
Str_trim PROTO,
	pString:PTR BYTE,
	char:BYTE

; Convert a null-terminated string to upper case.
Str_ucase PROTO,
	pString:PTR BYTE


exit EQU <.EXIT>
@cmdline EQU <OFFSET __98765765cmdline>

;-----------------------------------
; STANDARD 4-bit COLOR DEFINITIONS
;-----------------------------------
black        = 0000b
blue         = 0001b
green        = 0010b
cyan         = 0011b
red          = 0100b
magenta      = 0101b
brown        = 0110b
lightGray    = 0111b
gray         = 1000b
lightBlue    = 1001b
lightGreen   = 1010b
lightCyan    = 1011b
lightRed     = 1100b
lightMagenta = 1101b
yellow       = 1110b
white        = 1111b


;--------------------------------------------------
; Useful Structures
;--------------------------------------------------

; ExtGetDskFreSpcStruc is used by INT 21h Function 7303h
; (Get Disk Free Space):

ExtGetDskFreSpcStruc STRUC
    StructSize                WORD  ?
    Level                     WORD  ?
    SectorsPerCluster         DWORD ?
    BytesPerSector            DWORD ?
    AvailableClusters         DWORD ?
    TotalClusters             DWORD ?
    AvailablePhysSectors      DWORD ?
    TotalPhysSectors          DWORD ?
    AvailableAllocationUnits  DWORD ?
    TotalAllocationUnits      DWORD ?
    Rsvd                      DWORD 2 DUP (?)
ExtGetDskFreSpcStruc ENDS

; TimeRecord structure. Will be copied from an include file.

TimeRecord STRUCT
	hours    BYTE ?
	minutes  BYTE ?
	seconds  BYTE ?
	hhss     BYTE ?
TimeRecord ENDS



;---------------------------------------------------
startup MACRO
; Copy the MS-DOS command line to a variable
; and initialize both ES and DS to the data segment.

.data
__98765765cmdline BYTE 130 DUP(?)
.code
    mov  ax,@data
    mov  ds,ax
    mov  dx,OFFSET __98765765cmdline
    call Get_Commandtail
ENDM

.LIST
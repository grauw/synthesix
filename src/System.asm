; BIOS defines
RDSLT: equ 0CH
CALSLT: equ 1CH
ENASLT: equ 24H
VERID1: equ 2DH
VERID2: equ 2EH
INITXT: equ 6CH
CHSNS: equ 9CH
CHPUT: equ 0A2H
RSLREG: equ 138H
SNSMAT: equ 141H
KILBUF: equ 156H
SCNCNT: equ 0F3F6H
LINL40: equ 0F3AEH
CLIKSW: equ 0F3DBH
NEWKEY: equ 0FBE5H
JIFFY: equ 0FC9EH
EXPTBL: equ 0FCC1H
SLTTBL: equ 0FCC5H
H.KEYI: equ 0FD9AH
H.TIMI: equ 0FD9FH
H.MDIN: equ 0FF75H
H.MDTM: equ 0FF93H

PPI_PORT_A: equ 0A8H
PPI_PORT_B: equ 0A9H
PPI_PORT_C: equ 0AAH

; a = character
; Modifies: none
System_PrintChar: equ CHPUT

; hl = string (0-terminated)
; Modifies: none
System_Print:
	push af
	push hl
System_Print_Loop:
	ld a,(hl)
	and a
	jp z,System_Print_Done
	call System_PrintChar
	inc hl
	jp System_Print_Loop
System_Print_Done:
	pop hl
	pop af
	ret

; hl = string (0-terminated)
; Modifies: none
System_PrintLn:
	push hl
	call System_Print
	ld hl,System_crlf
	call System_Print
	pop hl
	ret

; hl = value
; Modifies: none
System_PrintHexHL:
	push af
	ld a,h
	call System_PrintHexA
	ld a,l
	call System_PrintHexA
	pop af
	ret

; a = value
; Modifies: none
System_PrintHexA:
	push af
	and 0F0H
	rrca
	rrca
	rrca
	rrca
	call System_PrintHex
	pop af
	call System_PrintHex
	ret

; a = value (0 - 15)
; Modifies: none
System_PrintHex:
	push af
	and 0FH
	add a,"0"
	cp ":"
	jr c,System_PrintHex_Done
	add a,"A" - ":"
System_PrintHex_Done:
	call System_PrintChar
	pop af
	ret

System_EnableROMInPage2:
	call System_GetPage1Slot
	ld h,80H
	call ENASLT
	ei
	ret

System_GetPage1Slot:
	call RSLREG
	and 00001100B
	rrca
	rrca
	ld c,a
	ld b,0
	ld hl,EXPTBL
	add hl,bc
	ld c,a
	ld a,(hl)
	and 80H
	or c
	ld c,a
	inc hl  ; move to SLTTBL
	inc hl
	inc hl
	inc hl
	ld a,(hl)
	and 00001100B
	or c
	ret

System_GetPage3Slot:
	call RSLREG
	and 11000000B
	rlca
	rlca
	ld c,a
	ld b,0
	ld hl,EXPTBL
	add hl,bc
	ld c,a
	ld a,(hl)
	and 80H
	or c
	ld c,a
	inc hl  ; move to SLTTBL
	inc hl
	inc hl
	inc hl
	ld a,(hl)
	and 11000000B
	rrca
	rrca
	rrca
	rrca
	or c
	ret

System_Stop:
	di
	halt
	jp System_Stop

System_ThrowException:
	pop de
	call System_PrintExceptionMessage
	jp System_Stop

; hl = message
System_ThrowExceptionWithMessage:
	pop de
	push hl
	call System_PrintExceptionMessage
	pop hl
	call System_PrintLn
	jp System_Stop

; de = address
System_PrintExceptionMessage:
	push de
	ld hl,System_exceptionMessage
	call System_Print
	pop hl
	dec hl
	dec hl
	dec hl
	call System_PrintHexHL
	ld hl,System_crlf
	call System_Print
	ret

; hl = handler address
System_InstallTIMIHook:
	ld (System_TIMIHook.address),hl
	ld hl,H.TIMI
	ld de,System_OldTIMIHook
	di
	ldi
	ldi
	ldi
	ldi
	ldi
	ld a,0C3H  ; jp
	ld (H.TIMI),a
	ld hl,System_TIMIHook
	ld (H.TIMI + 1),hl
	ei
	ret

System_RestoreTIMIHook:
	ld hl,System_OldTIMIHook
	ld de,H.TIMI
	di
	ldi
	ldi
	ldi
	ldi
	ldi
	ei
	ret

	SECTION RAM
System_TIMIHook: PROC
	push af
	call System_OldTIMIHook
	ld a,(System_suspendTIMIHook)
	and a
	jp nz,Return
	dec a
	ld (System_suspendTIMIHook),a
	ei
	call System_ThrowException
address: equ $ - 2
	di
	xor a
	ld (System_suspendTIMIHook),a
Return:
	ld a,255
	ld (SCNCNT),a  ; skip the expensive key handling bits of the ISR
	pop af
	ENDP
System_OldTIMIHook:
	ds 5
	ENDS


System_exceptionMessage:
	db "An exception occurred on address: ", 0

System_crlf:
	db "\r\n", 0

	SECTION RAM

System_suspendTIMIHook:
	db 0

	ENDS

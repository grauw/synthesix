; BIOS defines
ENASLT: equ 24H
INITXT: equ 6CH
CHSNS: equ 9CH
CHPUT: equ 0A2H
SNSMAT: equ 141H
CLIKSW: equ 0F3DBH
NEWKEY: equ 0FBE5H
JIFFY: equ 0FC9EH
EXPTBL: equ 0FCC1H
SLTTBL: equ 0FCC5H
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
	in a,(PPI_PORT_A)
	and 00001100B
	rrca
	rrca
	ld hl,EXPTBL + 1
	or (hl)
	jp p,System_EnableROMInPage2_noSubslot
	ld b,a
	ld a,(SLTTBL + 1)
	and 00001100B
	or b
System_EnableROMInPage2_noSubslot:
	ld h,80H
	call ENASLT
	ei
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



System_exceptionMessage:
	db "An exception occurred on address: ", 0

System_crlf:
	db "\r\n", 0


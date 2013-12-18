; BIOS defines
ENASLT: equ 24H
INITXT: equ 6CH
CHPUT: equ 0A2H
SNSMAT: equ 141H
CLIKSW: equ 0F3DBH
NEWKEY: equ 0FBE5H
JIFFY: equ 0FC9EH
EXPTBL: equ 0FCC1H
SLTTBL: equ 0FCC5H
PPI_PORT_A: equ 0A8H

; hl = string (0-terminated)
; Modifies: none
Utils_PrintLn:
	push hl
	call Utils_Print
	ld hl,Utils_crlf
	call Utils_Print
	pop hl
	ret

; hl = string (0-terminated)
; Modifies: none
Utils_Print:
	push af
	push hl
Utils_Print_Loop:
	ld a,(hl)
	and a
	jp z,Utils_Print_Done
	call CHPUT
	inc hl
	jp Utils_Print_Loop
Utils_Print_Done:
	pop hl
	pop af
	ret

; hl = value
; Modifies: none
Utils_PrintHexHL:
	push af
	ld a,h
	call Utils_PrintHexA
	ld a,l
	call Utils_PrintHexA
	pop af
	ret

; a = value
; Modifies: none
Utils_PrintHexA:
	push af
	and 0F0H
	rrca
	rrca
	rrca
	rrca
	call Utils_PrintHex
	pop af
	call Utils_PrintHex
	ret

; a = value (0 - 15)
; Modifies: none
Utils_PrintHex:
	push af
	and 0FH
	add a,"0"
	cp ":"
	jr c,Utils_PrintHex_Done
	add a,"A" - ":"
Utils_PrintHex_Done:
	call CHPUT
	pop af
	ret

Utils_EnableROMInPage2:
	in a,(PPI_PORT_A)
	and 00001100B
	rrca
	rrca
	ld hl,EXPTBL + 1
	or (hl)
	jp p,Utils_EnableROMInPage2_noSubslot
	ld b,a
	ld a,(SLTTBL + 1)
	and 00001100B
	or b
Utils_EnableROMInPage2_noSubslot:
	ld h,80H
	call ENASLT
	ei
	ret

Utils_Stop:
	di
	halt
	jp Utils_Stop

Utils_ThrowException:
	pop de
	call Utils_PrintExceptionMessage
	jp Utils_Stop

; hl = message
Utils_ThrowExceptionWithMessage:
	pop de
	push hl
	call Utils_PrintExceptionMessage
	pop hl
	call Utils_PrintLn
	jp Utils_Stop

; de = address
Utils_PrintExceptionMessage:
	push de
	ld hl,Utils_exceptionMessage
	call Utils_Print
	pop hl
	dec hl
	dec hl
	dec hl
	call Utils_PrintHexHL
	ld hl,Utils_crlf
	call Utils_Print
	ret



Utils_exceptionMessage:
	db "An exception occurred on address: ", 0

Utils_crlf:
	db "\r\n", 0


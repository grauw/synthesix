; BIOS defines
ENASLT: equ 24H
INITXT: equ 6CH
CHPUT: equ 0A2H
SNSMAT: equ 141H
CLIKSW: equ 0F3DBH
NEWKEY: equ 0FBE5H
EXPTBL: equ 0FCC1H
SLTTBL: equ 0FCC5H
PPI_PORT_A: equ 0A8H

Utils_PrintLn:
	call Utils_Print
	ld hl,Utils_crlf
	call Utils_Print
	ret

Utils_Print:
	ld a,(hl)
	and a
	ret z
	call CHPUT
	inc hl
	jp Utils_Print

Utils_PrintHexHL:
	push hl
	ld a,h
	call Utils_PrintHexA
	pop hl
	ld a,l
	call Utils_PrintHexA
	ret

Utils_PrintHexA:
	push af
	and 0F0H
	rrca
	rrca
	rrca
	rrca
	call Utils_PrintHex
	pop af
	and 0FH
	call Utils_PrintHex
	ret

Utils_PrintHex:
	ld hl,Utils_hexNumbers
	ld b,0
	ld c,a
	add hl,bc
	ld a,(hl)
	call CHPUT
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
	call Utils_PrintHexHL
	ld hl,Utils_crlf
	call Utils_Print
	ret



Utils_exceptionMessage:
	db "An exception occurred on address: ", 0

Utils_hexNumbers:
	db "0123456789ABCDEF"

Utils_crlf:
	db "\r\n", 0


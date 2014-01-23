;
; System routines
;

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
	ld bc,5
	di
	ldir
	ld a,0C3H  ; jp
	ld (H.TIMI),a
	ld hl,System_TIMIHook
	ld (H.TIMI + 1),hl
	ei
	ret

System_RestoreTIMIHook:
	ld hl,System_OldTIMIHook
	ld de,H.TIMI
	ld bc,5
	di
	ldir
	ei
	ret

System_EnableInterruptHandler:
	ld a,System_im2Table >> 8
	ld i,a
	im 2
	ret

System_DisableInterruptHandler:
	im 1
	ret

; Note: interrupts must be disabled
; hl = new hook (5 bytes)
; de = old hook (5 bytes)
System_InstallInterruptHook:
	push hl
	ld hl,System_InterruptHandler
	ld bc,5
	ldir
	pop hl
	ld de,System_InterruptHandler
	ld bc,5
	ldir
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

;
; Interrupt handler
;
	ALIGN 101H  ; address MSB and LSB must be the same for IM 2
System_InterruptHandler:
	jp 38H
	nop
	nop

	ENDS


System_exceptionMessage:
	db "An exception occurred on address: ", 0

System_crlf:
	db "\r\n", 0

	SECTION RAM

System_suspendTIMIHook:
	db 0

	ALIGN 100H
System_im2Table:
	; 257, in case data bus is 0FFH (which it is)
	ds 257,System_InterruptHandler & 0FFH

	ENDS

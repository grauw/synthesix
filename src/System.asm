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
	call System_GetSlotPage1
	ld h,80H
	call ENASLT
	ei
	ret

System_EnableRAMInPage2:
	call System_GetSlotPage3
	ld h,80H
	call ENASLT
	ei
	ret

System_GetSlot:
	ld a,h
	sub 64
	jp c,System_GetSlotPage0
	sub 64
	jp c,System_GetSlotPage1
	sub 64
	jp c,System_GetSlotPage2
	jp System_GetSlotPage3

System_GetSlotPage0:
	call RSLREG
	and 00000011B
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
	and 00000011B
	rlca
	rlca
	or c
	ret

System_GetSlotPage1:
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

System_GetSlotPage2:
	call RSLREG
	and 00110000B
	rrca
	rrca
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
	and 00110000B
	rrca
	rrca
	or c
	ret

System_GetSlotPage3:
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

;
; Search all slots and subslots for a match.
; Invoke Continue to continue searching where a previous search left off.
;
; hl = detection routine (receives a = slot ID, can modify all)
; f <- c: found
; a <- slot number
; Modifies: af, bc, de
;
System_SearchSlots: PROC
	ld a,0
PrimaryLoop:
	ex de,hl
	ld hl,EXPTBL
	ld b,0
	ld c,a
	add hl,bc
	ld a,(hl)
	ex de,hl
	and 10000000B
	or c
SecondaryLoop:
	push af
	push hl
	call CallHL
	pop hl
	jp c,Found
	pop af
Continue:
	add a,00000100B
	jp p,NextPrimary
	bit 4,a
	jp z,SecondaryLoop
NextPrimary:
	inc a
	and 00000011B
	ret z  ; not found
	jp PrimaryLoop
Found:
	pop af
	scf
	ret
CallHL:
	jp hl
	ENDP

;
; Match a string in a slot.
;
; a = slot
; bc = string length
; de = string
; hl = address
; f <- c: found
; Modifies: f, bc, de, hl
;
System_MatchSlotString: PROC
	push af
	push bc
	push de
	call RDSLT
	pop de
	pop bc
	ex de,hl
	cpi
	jr nz,NotFound
	jp po,Found
	inc de
	ex de,hl
	pop af
	jp System_MatchSlotString
Found:
	pop af
	scf
	ret
NotFound:
	pop af
	and a
	ret
	ENDP

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


;
; Unit tests
;
System_UnitTest:
	call System_TestSearchSlots
	ret

System_TestSearchSlots:
	di
	; does searching for test string yield the current slot?
	ld hl,System_TestSearchSlots_id
	call System_GetSlot
	push af
	ld hl,System_TestSearchSlots_Matcher
	call System_SearchSlots
	pop bc
	call nc,System_ThrowException
	cp b
	call nz,System_ThrowException

	; negative test
	ld hl,System_TestSearchSlots_MatcherNotFound
	call System_SearchSlots
	call c,System_ThrowException
	ei
	ret

System_TestSearchSlots_Matcher:
	ld hl,System_TestSearchSlots_id
	ld de,System_TestSearchSlots_id
	ld bc,8
	call System_MatchSlotString
	ret

System_TestSearchSlots_MatcherNotFound:
	ld hl,System_TestSearchSlots_id + 4
	ld de,System_TestSearchSlots_id
	ld bc,8
	call System_MatchSlotString
	ret

System_TestSearchSlots_id:
	db "UNITTEST"

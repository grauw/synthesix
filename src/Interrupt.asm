;
; IM2 interrupt framework
;

; hl = handler address
Interrupt_InstallTIMIHook:
	ld (Interrupt_TIMIHook.address),hl
	ld hl,H.TIMI
	ld de,Interrupt_OldTIMIHook
	ld bc,5
	di
	ldir
	ld a,0C3H  ; jp
	ld (H.TIMI),a
	ld hl,Interrupt_TIMIHook
	ld (H.TIMI + 1),hl
	ei
	ret

Interrupt_RestoreTIMIHook:
	ld hl,Interrupt_OldTIMIHook
	ld de,H.TIMI
	ld bc,5
	di
	ldir
	ei
	ret

Interrupt_EnableInterruptHandler:
	ld a,Interrupt_im2Table >> 8
	ld i,a
	im 2
	ret

Interrupt_DisableInterruptHandler:
	im 1
	ret

; Note: interrupts must be disabled
; hl = new hook (5 bytes)
; de = old hook (5 bytes)
Interrupt_InstallInterruptHook:
	push hl
	ld hl,Interrupt_InterruptHandler
	ld bc,5
	ldir
	pop hl
	ld de,Interrupt_InterruptHandler
	ld bc,5
	ldir
	ret

	SECTION RAM

Interrupt_TIMIHook: PROC
	push af
	call Interrupt_OldTIMIHook
	ld a,(Interrupt_suspendTIMIHook)
	and a
	jp nz,Return
	dec a
	ei
	ld (Interrupt_suspendTIMIHook),a
	call System_ThrowException
address: equ $ - 2
	xor a
	di
	ld (Interrupt_suspendTIMIHook),a
Return:
	ld a,255
	ld (SCNCNT),a  ; skip the expensive key handling bits of the ISR
	pop af
	ENDP
Interrupt_OldTIMIHook:
	ds 5

;
; Interrupt handler
;
	ALIGN 101H  ; address MSB and LSB must be the same for IM 2
Interrupt_InterruptHandler:
	jp 38H
	nop
	nop

Interrupt_suspendTIMIHook:
	db 0

	ALIGN 100H
Interrupt_im2Table:
	; 257, in case data bus is 0FFH (which it is)
	ds 257,Interrupt_InterruptHandler & 0FFH

	ENDS

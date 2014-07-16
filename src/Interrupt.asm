;
; IM2 interrupt framework
;
Interrupt_Init:
	ld hl,Interrupt_KEYIHandler.Hook
	ld de,Interrupt_KEYIHandler.OldHook
	call Interrupt_InstallInterruptHook
	ld hl,Interrupt_VDPHandler.Hook
	ld de,Interrupt_VDPHandler.OldHook
	call Interrupt_InstallInterruptHook
	ret

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

;
; Handle VDP interrupts
;
Interrupt_VDPHandler: PROC
	push af
	in a,(99H)
	and a
	jp p,NotFromVDP
	ld (STATFL),a
	push hl
	ld hl,(JIFFY)
	inc hl
	ld (JIFFY),hl
	push bc
	push de
	ex af,af'
	exx
	push af
	push bc
	push de
	push hl
	push ix
	push iy
	call H.TIMI
	pop iy
	pop ix
	pop hl
	pop de
	pop bc
	pop af
	exx
	ex af,af'
	pop de
	pop bc
	pop hl
	pop af
	ei
	reti
NotFromVDP:
	pop af
OldHook:
	ds 5
Hook:
	jp Interrupt_VDPHandler
	ENDP

;
; Handler for unrecognised interrupts.
; Falls back on calling H.KEYI.
;
Interrupt_KEYIHandler: PROC
	push af
	push bc
	push de
	push hl
	ex af,af'
	exx
	push af
	push bc
	push de
	push hl
	push ix
	push iy
	call H.KEYI
	pop iy
	pop ix
	pop hl
	pop de
	pop bc
	pop af
	exx
	ex af,af'
	pop hl
	pop de
	pop bc
	pop af
OldHook:
	ds 5
Hook:
	jp Interrupt_KEYIHandler
	ENDP

;
; Synthesix H.TIMI hook
;
Interrupt_TIMIHook: PROC
	push af
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
	ei
	reti
	nop
	nop

Interrupt_suspendTIMIHook:
	db 0

	ALIGN 100H
Interrupt_im2Table:
	; 257, in case data bus is 0FFH (which it is)
	ds 257,Interrupt_InterruptHandler & 0FFH

	ENDS

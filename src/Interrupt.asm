;
; IM2 interrupt framework
;
Interrupt_Init:
	ld hl,Interrupt_KEYIHandler.Hook
	ld de,Interrupt_KEYIHandler.OldHook
	call Interrupt_Hook
	ld hl,Interrupt_VDPHRHandler.Hook
	ld de,Interrupt_VDPHRHandler.OldHook
	call Interrupt_Hook
	ld hl,Interrupt_VDPHandler.Hook
	ld de,Interrupt_VDPHandler.OldHook
	call Interrupt_Hook
	ret

; hl = handler address
Interrupt_InstallTIMIHook:
	ld (Interrupt_TIMIHook.address),hl
	ld hl,H.TIMI
	ld de,Interrupt_TIMIHook.OldHook
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
	ld hl,Interrupt_TIMIHook.OldHook
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
	call VDP_EnableLineInt
	ret

Interrupt_DisableInterruptHandler:
	call VDP_DisableLineInt
	im 1
	ret

; hl = new hook (5 bytes)
; de = old hook (5 bytes)
Interrupt_Hook:
	ld a,r
	push af
	di
	push hl
	ld hl,Interrupt_InterruptHandler
	ld bc,5
	ldir
	pop hl
	ld de,Interrupt_InterruptHandler
	ld bc,5
	ldir
	pop af
	ret po
	ei
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
Handle:
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

Interrupt_VDPHRHandler: PROC
	push af
	ld a,1
	out (99H),a
	ld a,15 + 128
	out (99H),a
	in a,(99H)
	rrca
	ld a,0
	out (99H),a
	ld a,15 + 128
	out (99H),a
	jp c,Interrupt_VDPHandler.Handle
NotFromVDPHR:
	pop af
OldHook:
	ds 5
Hook:
	jp Interrupt_VDPHRHandler
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
	pop af
OldHook:
	ds 5
	ENDP

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

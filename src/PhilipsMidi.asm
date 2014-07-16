;
; Philips MIDI driver
;
; Philips MIDI uses the M6850 ACIA UART.
; See http://www.mccm.hetlab.tk/millennium/milc/midi/ for documentation (Dutch).
;
PhilipsMidi_COMMAND: equ 00H
PhilipsMidi_TRANSMIT: equ 01H
PhilipsMidi_STATUS: equ 04H
PhilipsMidi_RECEIVE: equ 05H


PhilipsMidi: MACRO
	super: MidiIn PhilipsMidi_buffer
	found:
		db 0
	ENDM

; ix = this
PhilipsMidi_Install:
	call PhilipsMidi_Detect
	ret nc
	di
	ld (ix + PhilipsMidi.found),-1
	call PhilipsMidi_SetHook
	call PhilipsMidi_Configure
	ei
	ret

; ix = this
PhilipsMidi_Uninstall:
	ld a,(ix + PhilipsMidi.found)
	and a
	ret z
	di
	call PhilipsMidi_RestoreHook
	call PhilipsMidi_Reset
	ei
	ret

;
; Set hook
; ix = this
;
PhilipsMidi_SetHook:
	ld e,ixl
	ld d,ixh
	ld hl,PhilipsMidi.super.WriteByte
	add hl,de
	ld (PhilipsMidi_InterruptHandler.writeByte),hl
	ld hl,PhilipsMidi_NewHook
	ld de,PhilipsMidi_InterruptHandler.OldHook
	call Interrupt_InstallInterruptHook
	ret

;
; Restore hook
; ix = this
;
PhilipsMidi_RestoreHook:
	ret

;
; Configure MIDI Interface
; ix = this
;
PhilipsMidi_Configure:
	ld a,00000011B  ; reset
	out (PhilipsMidi_COMMAND),a

	ld a,10010101B  ; 1 stop bit, no parity, 8 bits, 16x baud (31250 baud)
	out (PhilipsMidi_COMMAND),a

	; reset interrupt flag
	in a,(PhilipsMidi_RECEIVE)
	ret

;
; Reset MIDI interface
; ix = this
;
PhilipsMidi_Reset:
	ld a,00000011B
	out (PhilipsMidi_COMMAND),a
	ret

;
; Check for overrun, and clear flag if needed.
; ix = this
; f <- z: no overrun
;
PhilipsMidi_CheckOverrun: PROC
	ld a,(ix + PhilipsMidi.found)
	and a
	ret z
	ret
	ENDP

;
; Interrupt handler
;
	SECTION RAM

PhilipsMidi_InterruptHandler: PROC
	push af
	in a,(PhilipsMidi_STATUS)
	rrca
	jr nc,NotPhilipsMidi
	push hl
	in a,(PhilipsMidi_RECEIVE)
	call System_ThrowException
writeByte: equ $ - 2
	pop hl
	pop af
	ei
	reti
NotPhilipsMidi:
	pop af
OldHook:
	ds 5
	ENDP

	ENDS

PhilipsMidi_NewHook:
	jp PhilipsMidi_InterruptHandler

;
; Detect MIDI interface
;
; After doing some simple checks and a quick configuration, it checks whether
; the TxRDY status flag goes from 1 to 0 when sending a byte.
;
; ix = this
; f <- c: found
;
PhilipsMidi_Detect:
	in a,(PhilipsMidi_STATUS)
	and 00001100B   ; these should always be 0
	ret nz
	ld a,00000011B  ; reset
	out (PhilipsMidi_COMMAND),a
	ld a,00010101B  ; 1 stop bit, no parity, 8 bits, 16x baud (31250 baud)
	out (PhilipsMidi_COMMAND),a
	in a,(PhilipsMidi_STATUS)
	bit 1,a         ; check TxRDY
	ret z
	and 10001100B   ; these should be 0
	ret nz
	ld a,0FEH       ; send active sensing message (dummy)
	out (PhilipsMidi_TRANSMIT),a
	in a,(PhilipsMidi_STATUS)
	bit 1,a         ; check TxRDY again
	ret nz
	scf
	ret

;
; Workarea definition
;
	SECTION RAM

PhilipsMidi_instance:
	PhilipsMidi

	ALIGN 100H
PhilipsMidi_buffer:
	ds 256, 0FEH

	ENDS

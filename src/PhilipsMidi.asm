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
	ret c
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
	call System_InstallInterruptHook
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
	and 00000001B
	jr z,NotPhilipsMidi
	push hl
	in a,(PhilipsMidi_RECEIVE)
	push af
	in a,(PhilipsMidi_STATUS)
	and 00000001B
	jr nz,NotPhilipsMidi2
	pop af
	call System_ThrowException
writeByte: equ $ - 2
	pop hl
	pop af
	ei
	reti
NotPhilipsMidi2:
	pop af
	pop hl
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
; ix = this
; f <- c: not found, nc: found
;
PhilipsMidi_Detect:
	and a
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

;
; MSX-MIDI driver
;
; MSX-MIDI uses the 8251 UART and the 8253 timer.
; See http://map.grauw.nl/resources/midi/msx-midi.php for documentation.
;
MSXMidi_IOSETTING: equ 0E2H
MSXMidi_UART_SEND: equ 0E8H
MSXMidi_UART_RECEIVE: equ 0E8H
MSXMidi_UART_COMMAND: equ 0E9H
MSXMidi_UART_STATUS: equ 0E9H
MSXMidi_TIMER_INT: equ 0EAH
MSXMidi_TIMER_COUNTER0: equ 0ECH
MSXMidi_TIMER_COUNTER1: equ 0EDH
MSXMidi_TIMER_COUNTER2: equ 0EEH
MSXMidi_TIMER_COMMAND: equ 0EFH
MSXMidi_ID_ADDRESS: equ 401CH

S1990_TIMER_CLEAR: equ 0E6H
S1990_TIMER_LSB: equ 0E6H
S1990_TIMER_MSB: equ 0E7H

MSXMidi: MACRO
	super: MidiIn MSXMidi_buffer
	found:
		db 0
	ENDM

; ix = this
MSXMidi_Install:
	call MSXMidi_Detect
	ret nc
	di
	ld (ix + MSXMidi.found),-1
	call MSXMidi_SetHook
	call MSXMidi_Configure
	ei
	ret

; ix = this
MSXMidi_Uninstall:
	ld a,(ix + MSXMidi.found)
	and a
	ret z
	di
	call MSXMidi_RestoreHook
	call MSXMidi_Reset
	ei
	ret

;
; Set hook
; ix = this
;
MSXMidi_SetHook:
	ld e,ixl
	ld d,ixh
	ld hl,MSXMidi.super.WriteByte
	add hl,de
	ld (MSXMidi_InterruptHandler.writeByte),hl
	ld hl,MSXMidi_NewHook
	ld de,MSXMidi_InterruptHandler.OldHook
	call System_InstallInterruptHook
	ret

;
; Restore hook
; ix = this
;
MSXMidi_RestoreHook:
	ret

;
; Configure MIDI Interface
; ix = this
;
MSXMidi_Configure:
	call MSXMidi_ConfigureExternal

	; 8253 timer 0: 500 KHz for UART
	ld a,00010110B  ; counter 0, lsb only, mode 3 (square wave), binary
	out (MSXMidi_TIMER_COMMAND),a
	ld a,8          ; 4MHz / 8 = 500KHz
	out (MSXMidi_TIMER_COUNTER0),a

	; 8251 UART: reset
	xor a
	out (MSXMidi_UART_COMMAND),a
	call MSXMidi_Wait
	out (MSXMidi_UART_COMMAND),a
	call MSXMidi_Wait
	out (MSXMidi_UART_COMMAND),a
	call MSXMidi_Wait
	ld a,40H
	out (MSXMidi_UART_COMMAND),a
	call MSXMidi_Wait

	; 8251 UART: set mode
	ld a,01001110B  ; 1 stop bit, no parity, 8 bits, 16x baud (31250 baud)
	out (MSXMidi_UART_COMMAND),a
	call MSXMidi_Wait

	; 8251 UART: set command
	ld a,00100101B  ; enable interrupt, rx, timer interrupt, tx
	ld (MSXMidi_commandSave),a
	out (MSXMidi_UART_COMMAND),a

	; 8251 UART: reset interrupt flag
	in a,(MSXMidi_UART_RECEIVE)
	ret

; ix = this
MSXMidi_ConfigureExternal:
	call MSXMidi_DetectInternal
	ret c
	xor a           ; let external MSX-MIDI I/O ports match internal ones
	out (MSXMidi_IOSETTING),a
	ret

;
; Reset MIDI interface
; ix = this
;
MSXMidi_Reset:
	ld a,00000001B  ; reset all except for transmission enable
	out (MSXMidi_UART_COMMAND),a
	ret

;
; Check for overrun, and clear flag if needed.
; ix = this
; f <- z: no overrun
;
MSXMidi_CheckOverrun: PROC
	ld a,(ix + MSXMidi.found)
	and a
	ret z
	in a,(MSXMidi_UART_STATUS)
	and 00010000B
	ret z
	ld a,(MSXMidi_commandSave)
	or 00010000B
	out (MSXMidi_UART_COMMAND),a
	call System_ThrowException
	ret
	ENDP

;
; Interrupt handler
;
	SECTION RAM

MSXMidi_InterruptHandler: PROC
	push af
	in a,(MSXMidi_UART_STATUS)
	and 00000010B
	jr z,NotMSXMidi
	push hl
	in a,(MSXMidi_UART_RECEIVE)
	call System_ThrowException
writeByte: equ $ - 2
	pop hl
	pop af
	ei
	reti
NotMSXMidi:
	pop af
OldHook:
	ds 5
	ENDP

	ENDS

MSXMidi_NewHook:
	jp MSXMidi_InterruptHandler

;
; Detect MIDI interface
;
; ix = this
; f <- c: found
;
MSXMidi_Detect: PROC
	call MSXMidi_DetectInternal
	ret c
	ld hl,MSXMidi_MatchExternal
	call System_SearchSlots
	ret
	ENDP

;
; ix = this
; f <- c: found
;
MSXMidi_DetectInternal: PROC
	ld a,(EXPTBL)
	ld hl,IDBYT3
	call RDSLT
	rra
	ret
	ENDP

;
; Check slot for MIDI ID
;
; ix = this
; a = slot address
; f <- c: found
;
MSXMidi_MatchExternal:
	ld de,MSXMidi_idString
	ld hl,MSXMidi_ID_ADDRESS
	call System_MatchSlotString
	ret

;
; Wait 1ms between UART command register writes
; Note that this is unnecessarily long; only a 5 µs wait is required.
; ix = this
;
MSXMidi_Wait: PROC
	push af
	push bc
	ld c,1
	out (S1990_TIMER_CLEAR),a
Loop:
	in a,(S1990_TIMER_MSB)
	cp c
	jr c,Loop
	pop bc
	pop af
	ret
	ENDP

MSXMidi_idString:
	db "MIDI",0

;
; Workarea definition
;
	SECTION RAM

MSXMidi_commandSave:
	db 0            ;8251 command save area

MSXMidi_instance:
	MSXMidi

	ALIGN 100H
MSXMidi_buffer:
	ds 256, 0FEH

	ENDS

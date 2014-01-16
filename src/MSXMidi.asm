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

;
; Set hooks
;
setmidi:
	call MSXMidi_Detect
	ret c           ; No
	di
	ld a,IM2Table >> 8
	ld i,a
	im 2
	jr nz,inimdp
	xor a           ; let external MSX-MIDI I/O ports match internal ones
	out (MSXMidi_IOSETTING),a
	jr z,inimdp

;
; Initialize MIDI Interface
;
inimdp:
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
	ei
	ret

;
; Check for overrun, and clear flag if needed.
; f <- z: no overrun
;
MSXMidi_CheckOverrun: PROC
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
; Reset MIDI interface and reset hooks
;
rstmidi:
	di
	; reset all except for transmission enable
	ld a,00000001B
	out (MSXMidi_UART_COMMAND),a

	; restore interrupt to IM 1
	im 1
	ei
	ret

;
; Interrupt handler
;
	SECTION RAM
	ALIGN 101H  ; address MSB and LSB must be the same for IM 2
mdintr:
	push af
	in a,(MSXMidi_UART_STATUS)
	and 00000010B
	jr z,mdint1
	push hl
	in a,(MSXMidi_UART_RECEIVE)
	call MidiIn_WriteByte
	pop hl
	pop af
	ei
	ret
mdint1:
	pop af
	jp 38H

	ENDS

;
; Detect MIDI interface
;
; f <- c: not found, nc: found, z: external, nz: internal
;
MSXMidi_Detect: PROC
	call MSXMidi_DetectInternal
	ret nz          ;MIDI interface is built in
	ld b,4
PrimaryLoop:
	push bc         ;save counter
	ld a,4
	sub b           ;primary slot number
	ld c,a          ;save
	ld hl,EXPTBL
	ld a,c
	add a,l         ;set EXPTBL
	ld l,a
	ld a,(hl)
	and 10000000B   ;expanded ?
	jr z,SearchPrimary  ;no
	ld b,4          ;number of expanded slots
SecondaryLoop:      ;search expanded slot
	push bc
	ld a,00100100B
	sub b           ;001000nnB
	rlc a
	rlc a           ;1000nn00B
	or c            ;1000nnmmB = slot address
	call MSXMidi_DetectInSlot
	pop bc
	jr z,FoundIDPop  ;found MIDI ID
	djnz SecondaryLoop  ;next expanded slot
	pop bc
	jr NextSlot     ;next slot
SearchPrimary:      ;search primary slot
	ld a,c          ;set slot address
	call MSXMidi_DetectInSlot
	pop bc
	jr z,FoundID    ;found MIDI ID
NextSlot:
	djnz PrimaryLoop  ;search next slot
	scf             ;no MIDI ID
	ret
FoundIDPop:
	pop bc
FoundID:
	xor a           ;set Z flag, reset Cy flag
	ret
	ENDP

;
; f <- z: built in MIDI found
;
MSXMidi_DetectInternal: PROC
	ld a,(EXPTBL)
	ld hl,IDBYT3
	call RDSLT      ;read MIDI interface ID
	and 1           ;set Zflag
	ret
	ENDP

;
; Check slot for MIDI ID
;
; a = slot address
; f <- z: MIDI ID found
;
MSXMidi_DetectInSlot: PROC
	push bc
	ld de,MSXMidi_idString
	ld hl,MSXMidi_ID_ADDRESS
	ld b,4          ;length of MSXMidi_idString
Loop:
	push af
	push bc
	push de
	call RDSLT      ;read data
	pop de
	pop bc
	ld c,a          ;save data
	ld a,(de)       ;get char
	cp c            ;same ?
	jr nz,NotFound  ;no
	pop af          ;restore slot address
	inc de          ;next char
	inc hl
	djnz Loop       ;check next char
	pop bc          ;restore environment
	xor a           ;I found ID
	ret
NotFound:
	pop af          ;restore slot address
	pop bc          ;restore environment
	xor a
	inc a           ;worng ID
	ret
	ENDP

;
; Wait 1ms between UART command register writes
; Note that this is unnecessarily long; only a 5 µs wait is required.
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
	db "MIDI"

;
; Workarea definition
;
	SECTION RAM

MSXMidi_commandSave:
	db 0            ;8251 command save area

	ALIGN 100H
IM2Table:
	ds 257,mdintr & 0FFH  ; 257, in case data bus is 0FFH (which it is)

	ENDS

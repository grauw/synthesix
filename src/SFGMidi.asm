;
; SFG-01 / SFG-05 FM Sound Synthesizer Unit MIDI driver
;
; The SFG modules uses the YM2148.
; See http://map.grauw.nl/resources/midi/ym2148.php for documentation.
;
SFGMidi_DATA: equ 3FF5H
SFGMidi_STATUS: equ 3FF6H
SFGMidi_COMMAND: equ 3FF6H
SFGMidi_ID_ADDRESS: equ 80H

SFGMidi: MACRO
	super: MidiIn SFGMidi_buffer
	found:
		db 0
	slot:
		db 0
	slotBits:
		dw 0
	ENDM

; ix = this
SFGMidi_Install:
	call SFGMidi_Detect
	ret nc
	di
	call SFGMidi_SetSlot
	ld (ix + SFGMidi.found),-1
	call SFGMidi_SetHook
	call SFGMidi_Configure
	ei
	ret

; ix = this
SFGMidi_Uninstall:
	ld a,(ix + SFGMidi.found)
	and a
	ret z
	di
	call SFGMidi_RestoreHook
	call SFGMidi_Reset
	ei
	ret

; ix = this
; a = slot
SFGMidi_SetSlot:
	ld (ix + SFGMidi.slot),a
	ld b,a
	and 00000011B
	ld c,a
	rrca
	rrca
	or c
	ld (ix + SFGMidi.slotBits + 1),a
	ld a,b
	and 00001100B
	rrca
	rrca
	ld (ix + SFGMidi.slotBits),a
	ret

;
; Set hook
; ix = this
;
SFGMidi_SetHook:
	ld e,ixl
	ld d,ixh
	ld hl,SFGMidi.super.WriteByte
	add hl,de
	ld (SFGMidi_InterruptHandler.writeByte),hl
	ld hl,SFGMidi_NewHook
	ld de,SFGMidi_InterruptHandler.OldHook
	call Interrupt_Hook
	ret

;
; Restore hook
; ix = this
;
SFGMidi_RestoreHook:
	ret

;
; Configure MIDI Interface
; ix = this
;
SFGMidi_Configure:
	; YM2148 UART: reset
	ld e,10000000B
	ld a,(ix + SFGMidi.slot)
	ld hl,SFGMidi_COMMAND
	call WRSLT

	; YM2148 UART: set command
	ld e,00001101B  ; enable rx interrupt
	ld a,e
	ld (SFGMidi_commandSave),a
	ld a,(ix + SFGMidi.slot)
	ld hl,SFGMidi_COMMAND
	call WRSLT

	; YM2148 UART: reset interrupt flag
	ld a,(ix + SFGMidi.slot)
	ld hl,SFGMidi_DATA
	call RDSLT
	ret

;
; Reset MIDI interface
; ix = this
;
SFGMidi_Reset:
	ld e,00000000B  ; reset all
	ld a,(ix + SFGMidi.slot)
	ld hl,SFGMidi_COMMAND
	call WRSLT
	ret

;
; Check for overrun, and clear flag if needed.
; ix = this
; f <- z: no overrun
;
SFGMidi_CheckOverrun: PROC
	ld a,(ix + SFGMidi.found)
	and a
	ret z
	ld a,(ix + SFGMidi.slot)
	ld hl,SFGMidi_STATUS
	call RDSLT
	ei
	and 00110000B
	ret z
	push af
	ld a,(SFGMidi_commandSave)
	or 00010000B
	ld e,a
	ld a,(ix + SFGMidi.slot)
	ld hl,SFGMidi_COMMAND
	call WRSLT
	ei
	pop af
	and 00010000B
	ld hl,MidiIn_overrunErrorMessage
	call nz,System_ThrowExceptionWithMessage
	and 00100000B
	ld hl,MidiIn_framingErrorMessage
	call nz,System_ThrowExceptionWithMessage
	ret
	ENDP

;
; Interrupt handler
;
	SECTION RAM

SFGMidi_InterruptHandler: PROC
	push af
	push bc
	push de
	push hl
	ld de,(SFGMidi_instance.slotBits)
	ld hl,SFGMidi_STATUS
	call SFGMidi_Read
	and 00000010B
	jr z,NotSFGMidi
	ld hl,SFGMidi_DATA
	call SFGMidi_Read
	call System_ThrowException
writeByte: equ $ - 2
	pop hl
	pop de
	pop bc
	pop af
	ei
	reti
NotSFGMidi:
	pop hl
	pop de
	pop bc
	pop af
OldHook:
	ds 5
	ENDP

	ENDS

SFGMidi_NewHook:
	jp SFGMidi_InterruptHandler

	SECTION ROM_BANK0

;
; Does a quick interslot read using prepared slot bits
; de = prepared slot bits (d = primary, e = secondary)
; hl = address
; a <- value
; Modifies: af, bc, hl
;
; XXX: There is a flaw here: it expects Synthesix to be in page 1.
;      This is not necessarily the case (e.g. during disk I/O).
;
SFGMidi_Read:
	IF $ < 4000H
		ERROR "Can not be in page 0."
	ENDIF
	in a,(0A8H)
	ld b,a
	and 00111100B
	or d
	out (0A8H),a
	ld a,(0FFFFH)
	cpl
	ld c,a
	and 11111100B
	or e
	ld (0FFFFH),a
	ld a,(hl)
	ld hl,0FFFFH
	ld (hl),c
	ld c,0A8H
	out (c),b
	ret
	IF $ >= 0C000H
		ERROR "Can not be in page 3."
	ENDIF

	ENDS

;
; Detect MIDI interface
;
; ix = this
; f <- c: found
; a <- slot
;
SFGMidi_Detect:
	ld hl,MSXMidi_MatchID
	call Memory_SearchSlots
	ret

;
; Check slot for MIDI ID
;
; ix = this
; a = slot address
; f <- z: MIDI ID found
;
MSXMidi_MatchID:
	ld de,SFGMidi_id
	ld hl,SFGMidi_ID_ADDRESS
	ld bc,6
	call Memory_MatchSlotString
	ret

SFGMidi_id:
	db "MCHFM0"

;
; Workarea definition
;
	SECTION RAM

SFGMidi_commandSave:
	db 0            ;YM2148 command save area

SFGMidi_instance: SFGMidi

	ALIGN 100H
SFGMidi_buffer:
	ds 256, 0FEH

	ENDS

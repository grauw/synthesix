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
	super: MidiIn MidiIn_buffer4
	found:
		db 0
	slot:
		db 0
	preparedSlot:
		dw 0
	commandSave:
		db 0
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

	call Memory_PrepareSlotPage0
	ld (ix + SFGMidi.preparedSlot),e
	ld (ix + SFGMidi.preparedSlot + 1),d
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
	ld c,10000000B
	ld (ix + SFGMidi.commandSave),c
	ld e,(ix + SFGMidi.preparedSlot)
	ld d,(ix + SFGMidi.preparedSlot + 1)
	ld hl,SFGMidi_COMMAND
	call Memory_WritePreparedSlot

	; YM2148 UART: set command
	ld c,00001101B  ; enable rx interrupt
	ld (ix + SFGMidi.commandSave),c
	ld e,(ix + SFGMidi.preparedSlot)
	ld d,(ix + SFGMidi.preparedSlot + 1)
	ld hl,SFGMidi_COMMAND
	call Memory_WritePreparedSlot

	; YM2148 UART: reset interrupt flag
	ld e,(ix + SFGMidi.preparedSlot)
	ld d,(ix + SFGMidi.preparedSlot + 1)
	ld hl,SFGMidi_DATA
	call Memory_ReadPreparedSlot
	ret

;
; Reset MIDI interface
; ix = this
;
SFGMidi_Reset:
	ld c,00000000B  ; reset all
	ld (ix + SFGMidi.commandSave),c
	ld e,(ix + SFGMidi.preparedSlot)
	ld d,(ix + SFGMidi.preparedSlot + 1)
	ld hl,SFGMidi_COMMAND
	call Memory_WritePreparedSlot
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
	ld e,(ix + SFGMidi.preparedSlot)
	ld d,(ix + SFGMidi.preparedSlot + 1)
	ld hl,SFGMidi_STATUS
	call Memory_ReadPreparedSlot
	ei
	and 00110000B
	ret z
	push af
	ld a,(ix + SFGMidi.commandSave)
	or 00010000B
	ld c,a
	ld e,(ix + SFGMidi.preparedSlot)
	ld d,(ix + SFGMidi.preparedSlot + 1)
	ld hl,SFGMidi_COMMAND
	call Memory_WritePreparedSlot
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
	ld de,(SFGMidi_instance.preparedSlot)
	call SFGMidi_ReadStatusData
	jr z,NotSFGMidi
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
; Does a quick interslot status/data read using a prepared slot id (2)
; de = prepared slot id (2)
; a <- value
; Modifies: af, bc, de, hl
;
SFGMidi_ReadStatusData: PROC
	ld c,0A8H
	ld hl,0FFFFH
	in b,(c)
	out (c),d
	ld a,(hl)
	ld (hl),e
	ld e,a
	ld a,(SFGMidi_STATUS)
	and 00000010B
	jr z,NotSFGMidi
	ld a,(SFGMidi_DATA)
NotSFGMidi:
	ld (hl),e
	out (c),b
	ret
	ENDP

	ENDS

;
; Detect MIDI interface
;
; ix = this
; f <- c: found
; a <- slot
;
SFGMidi_Detect:
	ld hl,SFGMidi_MatchID
	call Memory_SearchSlots
	ret

;
; Check slot for MIDI ID
;
; ix = this
; a = slot id
; f <- c: found
;
SFGMidi_MatchID:
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

SFGMidi_instance: SFGMidi

	ENDS

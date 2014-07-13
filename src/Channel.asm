;
; A MIDI channel
;
; One channel can control multiple timbres.
; It contains one note pool per sound chip / patch.
; All MIDI messages are forwarded to the note pools.
;
Channel: MACRO ?keys, ?controllers
	MAX_NOTE_POOLS: equ 4
	keys:
		dw ?keys
	controllers:
		dw ?controllers
	program:
		Value 0
	channelPressure:
		Value 0
	pitchBendFine:
		Value 0
	pitchBendCoarse:
		Value 0
	notePools:
		REPT MAX_NOTE_POOLS
		dw 0
		ENDM
	size:
	ENDM

	dw Channel.size
Channel_class: Channel 0, 0

; ix <- new class
Channel_New:
	ld iy,Channel_class
	call Class_New
	call Channel_Constructor
	ret

; ix = this
; ix <- this
Channel_Constructor: PROC
	ret
	ENDP

; ix = this
; b = note number (0-127)
; c = velocity (0-127)
Channel_NoteOn: PROC
	ld a,b
	call Channel_GetKey
	ld (hl),c
	;
	inc c
	dec c
	jp z,NoteOff
	REPT Channel.MAX_NOTE_POOLS, ?pool
	ld e,(ix + Channel.notePools + ?pool * 2)
	ld d,(ix + Channel.notePools + ?pool * 2 + 1)
	inc d
	dec d
	ret z
	push ix
	push af
	push bc
	ld ixl,e
	ld ixh,d
	call NotePool_NoteOn
	pop bc
	pop af
	pop ix
	ENDM
	ret
NoteOff:
	ld c,64
	jp Channel_NoteOff
	ENDP

; ix = this
; b = note number (0-127)
; c = velocity (0-127)
Channel_NoteOff:
	ld a,b
	call Channel_GetKey
	ld (hl),0
	;
	REPT Channel.MAX_NOTE_POOLS, ?pool
	ld e,(ix + Channel.notePools + ?pool * 2)
	ld d,(ix + Channel.notePools + ?pool * 2 + 1)
	inc d
	dec d
	ret z
	push ix
	push af
	push bc
	ld ixl,e
	ld ixh,d
	call NotePool_NoteOff
	pop bc
	pop af
	pop ix
	ENDM
	ret

; ix = this
; b = controller
; c = value
Channel_ControlChange:
	ld a,b
	cp 121
	jr nc,Channel_ChannelMode
	call Channel_GetController
	ld (hl),c
	ret

Channel_ChannelMode:
	ret

Channel_PolyPressure:
	ret

Channel_ProgramChange:
	ld (ix + Channel.program),b
	ret

Channel_ChannelPressure:
	ld (ix + Channel.channelPressure),b
	ret

Channel_PitchBend:
	ld a,c
	xor 40H
	ld c,a
	rla
	rla
	rla
	rl b
	rla
	rl b
	rl c
	ld (ix + Channel.pitchBendFine),b
	ld (ix + Channel.pitchBendCoarse),c
	ret

; ix = this
Channel_Update:
	REPT Channel.MAX_NOTE_POOLS, ?pool
	ld e,(ix + Channel.notePools + ?pool * 2)
	ld d,(ix + Channel.notePools + ?pool * 2 + 1)
	inc d
	dec d
	ret z
	push ix
	ld ixl,e
	ld ixh,d
	call NotePool_Update
	pop ix
	ENDM
	ret

; ix = this
; a = key number
; hl <- key
; Modifies: de, hl
Channel_GetKey:
	ld l,(ix + Channel.keys)
	ld h,(ix + Channel.keys + 1)
	jp ControllerBank_GetController

; ix = this
; a = controller number
; hl <- controller
; Modifies: de, hl
Channel_GetController:
	ld l,(ix + Channel.controllers)
	ld h,(ix + Channel.controllers + 1)
	jp ControllerBank_GetController

; ix = this
; ix <- controller bank
Channel_GetControllerBank:
	ld e,(ix + Channel.controllers)
	ld d,(ix + Channel.controllers + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
; hl = note pool
Channel_AddNotePool: PROC
	REPT Channel.MAX_NOTE_POOLS, ?pool
	ld a,(ix + Channel.notePools + ?pool * 2 + 1)
	and a
	jr nz,Next
	ld (ix + Channel.notePools + ?pool * 2),l
	ld (ix + Channel.notePools + ?pool * 2 + 1),h
	ret
Next:
	ENDM
	call System_ThrowException
	ENDP

;
Channels_Init:
	REPT 16, ?channel
	ld ix,Channel_channels + ?channel * Channel.size
	call Channel_Constructor
	ENDM
	ret

Channels_Update:
	REPT 1, ?channel
	ld ix,Channel_channels + ?channel * Channel.size
	call Channel_Update
	ENDM
	ret

;
	SECTION RAM

	ALIGN 100H
Channel_channels: REPT 16, ?channel
	Channel Channel_keysBanks + ?channel * ControllerBank.size, Channel_controllerBanks + ?channel * ControllerBank.size
	IF ($ & 0FH) != 0
		ERROR "Channel size must be exactly 16."
	ENDIF
	ENDM

Channel_keysBanks: REPT 16
	ControllerBank
	ENDM

Channel_controllerBanks: REPT 16
	ControllerBank
	ENDM

	ENDS

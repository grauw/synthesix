;
; A MIDI channel
;
; One channel can control multiple timbres.
; It contains one voice pool per sound chip / patch.
; All MIDI messages are forwarded to the voice pools.
;
Channel: MACRO
	MAX_VOICE_POOLS: equ 8
	patches:
		REPT MAX_VOICE_POOLS
		dw 0
		ENDM
	size:
	ENDM

	dw Channel.size
Channel_class: Channel

; ix <- new class
Channel_New:
	ld iy,Channel_class
	call Class_New
	call Channel_Constructor
	ret

; ix = this
; ix <- this
Channel_Constructor:
	push ix
	call SCCPatch_New
	push ix
	pop hl
	pop ix
	call Channel_AddPatch
	ret

; ix = this
; b = note number (0-127)
; c = velocity (0-127)
Channel_NoteOn:
	inc c
	dec c
	jp z,Channel_NoteOff
	REPT Channel.MAX_VOICE_POOLS, ?pool
	ld e,(ix + Channel.patches + ?pool * 2)
	ld d,(ix + Channel.patches + ?pool * 2 + 1)
	inc d
	dec d
	ret z
	push ix
	push af
	push bc
	ld ixl,e
	ld ixh,d
	call Patch_NoteOn
	pop bc
	pop af
	pop ix
	ENDM
	ret

; ix = this
; b = note number (0-127)
; c = velocity (0-127)
Channel_NoteOff:
	REPT Channel.MAX_VOICE_POOLS, ?pool
	ld e,(ix + Channel.patches + ?pool * 2)
	ld d,(ix + Channel.patches + ?pool * 2 + 1)
	inc d
	dec d
	ret z
	push ix
	push af
	push bc
	ld ixl,e
	ld ixh,d
	call Patch_NoteOff
	pop bc
	pop af
	pop ix
	ENDM
	ret

; ix = this
; b = controller
; c = value
Channel_ControlChange:
	REPT Channel.MAX_VOICE_POOLS, ?pool
	ld e,(ix + Channel.patches + ?pool * 2)
	ld d,(ix + Channel.patches + ?pool * 2 + 1)
	inc d
	dec d
	ret z
	push ix
	push af
	push bc
	ld ixl,e
	ld ixh,d
	call Patch_ControlChange
	pop bc
	pop af
	pop ix
	ENDM
	ret

Channel_PolyPressure:
	ret

Channel_ProgramChange:
	ret

Channel_ChannelPressure:
	ret

Channel_PitchBend:
	ret

; ix = this
Channel_Update:
	REPT Channel.MAX_VOICE_POOLS, ?pool
	ld e,(ix + Channel.patches + ?pool * 2)
	ld d,(ix + Channel.patches + ?pool * 2 + 1)
	inc d
	dec d
	ret z
	push ix
	ld ixl,e
	ld ixh,d
	call Patch_Update
	pop ix
	ENDM
	ret

; ix = this
; hl = voice pool
Channel_AddPatch:
	REPT Channel.MAX_VOICE_POOLS, ?pool
	ld a,(ix + Channel.patches + ?pool * 2 + 1)
	and a
	jr nz,Channel_AddPatch_Next
	ld (ix + Channel.patches + ?pool * 2),l
	ld (ix + Channel.patches + ?pool * 2 + 1),h
	ret
Channel_AddPatch_Next:
	ENDM
	call System_ThrowException

;
	SECTION RAM

	ALIGN 100H
Channel_channels: REPT 16
	Channel
	IF ($ & 0FH) != 0
		ERROR "Channel size must be exactly 16."
	ENDIF
	ENDM

	ENDS

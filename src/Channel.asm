;
; A MIDI channel
;
; One channel can control multiple timbres.
; It contains one voice pool per sound chip / patch.
; All MIDI messages are forwarded to the voice pools.
;
Channel: MACRO
	MAX_VOICE_POOLS: equ 7
	controllers:
		dw 0
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
Channel_Constructor: PROC
	push ix
	call Channel_CreateControllerArray
	pop ix
	ld (ix + Channel.controllers),l
	ld (ix + Channel.controllers + 1),h
	ret
	ENDP

; hl <- array address
; Modifies: af, bc, de, hl, ix
Channel_CreateControllerArray: PROC
	ld bc,128 * 2
	call Heap_Allocate
	push de
	ld b,128
Loop:
	push bc
	push de
	call Value_New
	pop de
	ld a,ixl
	ld (de),a
	inc de
	ld a,ixh
	ld (de),a
	inc de
	pop bc
	djnz Loop
	pop hl
	ret
	ENDP

; ix = this
; b = note number (0-127)
; c = velocity (0-127)
Channel_NoteOn: PROC
	inc c
	dec c
	jp z,NoteOff
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
NoteOff:
	ld c,64
	jp Channel_NoteOff
	ENDP

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
	ld a,b
	call Channel_GetController
	ld a,d
	or e
	ret z
	ld iyl,e
	ld iyh,d
	ld (iy),c

	REPT Channel.MAX_VOICE_POOLS, ?pool
	ld e,(ix + Channel.patches + ?pool * 2)
	ld d,(ix + Channel.patches + ?pool * 2 + 1)
	inc d
	dec d
	ret z
	push ix
	ld ixl,e
	ld ixh,d
	call Patch_ControlChange
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
; a = controller number
; de <- controller (null if not available)
; Modifies: af, de, hl
Channel_GetController:
	ld e,(ix + Channel.controllers)
	ld d,(ix + Channel.controllers + 1)
	add a,a
	ld l,a
	ld h,0
	ld a,e
	or d
	ret z
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl)
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
Channels_Init:
	REPT 1, ?channel
	ld ix,Channel_channels + ?channel * Channel.size
	call Channel_Constructor
	ENDM

	ld ix,Channel_channels.0
	call SCCPatch_New
	push ix
	pop hl
	ld ix,Channel_channels.0
	call Channel_AddPatch
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
Channel_channels: REPT 16
	Channel
	IF ($ & 0FH) != 0
		ERROR "Channel size must be exactly 16."
	ENDIF
	ENDM

	ENDS

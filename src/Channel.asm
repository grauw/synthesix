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
	voicePools:
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
	call ControllerBank_New
	ex (sp),ix
	pop hl
	ld (ix + Channel.controllers),l
	ld (ix + Channel.controllers + 1),h
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
	ld e,(ix + Channel.voicePools + ?pool * 2)
	ld d,(ix + Channel.voicePools + ?pool * 2 + 1)
	inc d
	dec d
	ret z
	push ix
	push af
	push bc
	ld ixl,e
	ld ixh,d
	call VoicePool_NoteOn
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
	ld e,(ix + Channel.voicePools + ?pool * 2)
	ld d,(ix + Channel.voicePools + ?pool * 2 + 1)
	inc d
	dec d
	ret z
	push ix
	push af
	push bc
	ld ixl,e
	ld ixh,d
	call VoicePool_NoteOff
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
	ex de,hl
	ld (hl),c
	ret

Channel_ChannelMode:
	ret

Channel_PolyPressure:
	ret

Channel_ProgramChange:
	ld a,127
	call Channel_GetController
	ex de,hl
	ld (hl),b
	ret

Channel_ChannelPressure:
	ld a,123
	call Channel_GetController
	ex de,hl
	ld (hl),b
	ret

Channel_PitchBend:
	ld a,124
	call Channel_GetController
	ex de,hl
	ld (hl),b
	ld a,125
	call Channel_GetController
	ex de,hl
	ld (hl),c
	ret

; ix = this
Channel_Update:
	REPT Channel.MAX_VOICE_POOLS, ?pool
	ld e,(ix + Channel.voicePools + ?pool * 2)
	ld d,(ix + Channel.voicePools + ?pool * 2 + 1)
	inc d
	dec d
	ret z
	push ix
	ld ixl,e
	ld ixh,d
	call VoicePool_Update
	pop ix
	ENDM
	ret

; ix = this
; a = controller number
; de <- controller
; Modifies: af, de, hl
Channel_GetController:
	ld e,(ix + Channel.controllers)
	ld d,(ix + Channel.controllers + 1)
	jp ControllerBank_GetController

; ix = this
; hl = voice pool
Channel_AddVoicePool: PROC
	REPT Channel.MAX_VOICE_POOLS, ?pool
	ld a,(ix + Channel.voicePools + ?pool * 2 + 1)
	and a
	jr nz,Next
	ld (ix + Channel.voicePools + ?pool * 2),l
	ld (ix + Channel.voicePools + ?pool * 2 + 1),h
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
Channel_channels: REPT 16
	Channel
	IF ($ & 0FH) != 0
		ERROR "Channel size must be exactly 16."
	ENDIF
	ENDM

	ENDS

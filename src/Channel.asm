;
; A MIDI channel
;
; One channel can control multiple timbres.
; It contains one voice pool per sound chip / patch.
; All MIDI messages are forwarded to the voice pools.
;
	dw Channel_size
Channel:
Channel_MAX_VOICE_POOLS: equ 2
Channel_voicePools: equ $ - Channel
	REPT Channel_MAX_VOICE_POOLS
	dw 0
	ENDM
Channel_size: equ $ - Channel

; ix <- new class
Channel_New:
	ld iy,Channel
	call Class_New
	push ix
	call SCCVoicePool_New
	push ix
	pop hl
	pop ix
	call Channel_AddVoicePool
	ret

; ix = this
; a = note number (0-127)
; b = velocity (0-127)
Channel_NoteOn:
	REPT Channel_MAX_VOICE_POOLS, ?pool
	ld l,(ix + Channel_voicePools + ?pool * 2)
	ld h,(ix + Channel_voicePools + ?pool * 2 + 1)
	inc h
	dec h
	ret z
	push hl
	ex (sp),ix
	push af
	push bc
	call VoicePool_NoteOn
	pop bc
	pop af
	pop ix
	ENDM
	ret

; ix = this
; a = note number (0-127)
; b = velocity (0-127)
Channel_NoteOff:
	REPT Channel_MAX_VOICE_POOLS, ?pool
	ld l,(ix + Channel_voicePools + ?pool * 2)
	ld h,(ix + Channel_voicePools + ?pool * 2 + 1)
	inc h
	dec h
	ret z
	push hl
	ex (sp),ix
	push af
	push bc
	call VoicePool_NoteOff
	pop bc
	pop af
	pop ix
	ENDM
	ret

; ix = this
; hl = voice pool
Channel_AddVoicePool:
	REPT Channel_MAX_VOICE_POOLS, ?pool
	PROC
	LOCAL Channel_AddVoicePool_next
	ld a,(ix + Channel_voicePools + ?pool * 2 + 1)
	inc a
	dec a
	jr nz,Channel_AddVoicePool_next
	ld (ix + Channel_voicePools + ?pool * 2),l
	ld (ix + Channel_voicePools + ?pool * 2 + 1),h
	ret
Channel_AddVoicePool_next:
	ENDP
	ENDM
	call Utils_ThrowException

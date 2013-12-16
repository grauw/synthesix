;
; A MIDI channel
;
; One channel can control multiple timbres.
; It contains one voice pool per sound chip / patch.
; All MIDI messages are forwarded to the voice pools.
;
	dw Channel_size
Channel:
Channel_voicePools: equ $ - Channel
	dw 0, 0  ; max 2 voice pools
Channel_size: equ $ - Channel

; ix <- new class
Channel_New:
	ld iy,Channel
	call Class_New
	ld (Channel_channel1),ix
	push ix
	call VoicePool_New
	push ix
	pop hl
	pop ix
	ld (ix + Channel_voicePools + 0),l
	ld (ix + Channel_voicePools + 1),h
	ret

; ix = this
; a = note number (0-127)
; b = velocity (0-127)
Channel_NoteOn:
	IRP ?pool, 0, 1
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
	IRP ?pool, 0, 1
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

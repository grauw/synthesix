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

; max 2 voice pools
Channel_channel1:
Channel:
Channel_voicePools: equ $ - Channel
	dw VoicePool_voicePool1, 0

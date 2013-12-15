; ix = this
; a = note number (0-127)
; b = velocity (0-127)
Channel_NoteOn:
	IRP ?offset, 0, 2
	ld l,(ix + Channel_voicePools + ?offset)
	ld h,(ix + Channel_voicePools + ?offset + 1)
	inc h
	dec h
	ret z
	push hl
	ex (sp),ix
	call VoicePool_NoteOn
	pop ix
	ENDM
	ret

; ix = this
; a = note number (0-127)
; b = velocity (0-127)
Channel_NoteOff:
	IRP ?offset, 0, 2
	ld l,(ix + Channel_voicePools + ?offset)
	ld h,(ix + Channel_voicePools + ?offset + 1)
	inc h
	dec h
	ret z
	push hl
	ex (sp),ix
	call VoicePool_NoteOff
	pop ix
	ENDM
	ret

Channel_channel1:
Channel:
Channel_voicePools: equ $ - Channel
	dw VoicePool_voicePool1, 0  ; max 2 voice pools

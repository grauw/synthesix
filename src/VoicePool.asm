; ix = this
; a = note number (0-127)
; b = velocity (0-127)
VoicePool_NoteOn:
	ld l,(ix + VoicePool_voices + 0)
	ld h,(ix + VoicePool_voices + 1)
	push hl
	ex (sp),ix
	call SCCVoice_NoteOn
	pop ix
	ret

; ix = this
; a = note number (0-127)
; b = velocity (0-127)
VoicePool_NoteOff:
	ld l,(ix + VoicePool_voices + 0)
	ld h,(ix + VoicePool_voices + 1)
	push hl
	ex (sp),ix
	call SCCVoice_NoteOff
	pop ix
	ret

VoicePool_voicePool1:
VoicePool:
VoicePool_mono: equ $ - VoicePool
	db -1;
VoicePool_voices: equ $ - VoicePool
	dw SCC_voice1, 0, 0, 0, 0  ; max 5 voices / pool

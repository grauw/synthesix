;
; A voice pool
;
; Pools voices for polyphonic playback.
; When a note is played it binds a voice to it until it is
; released. When a voice is bound, it will try the next one.
; Each sound chip has a separate voice pool implementation.
;
	dw VoicePool_size
VoicePool:
VoicePool_noteOn: equ $ - VoicePool
	dw 0
VoicePool_noteOff: equ $ - VoicePool
	dw 0
VoicePool_mono: equ $ - VoicePool
	db -1;
VoicePool_notes: equ $ - VoicePool
	db -1, -1, -1, -1, -1
VoicePool_voices: equ $ - VoicePool
	dw 0, 0, 0, 0, 0  ; max 5 voices / pool
VoicePool_size: equ $ - VoicePool

VoicePool_NoteOn:
	ld e,(ix + VoicePool_noteOn + 0)
	ld d,(ix + VoicePool_noteOn + 1)
	ex de,hl
	jp (hl)

VoicePool_NoteOff:
	ld e,(ix + VoicePool_noteOff + 0)
	ld d,(ix + VoicePool_noteOff + 1)
	ex de,hl
	jp (hl)

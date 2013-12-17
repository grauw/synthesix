;
; An SCC voice pool
;
; Pools voices for polyphonic playback.
; When a note is played it binds a voice to it until it is
; released. When a voice is bound, it will try the next one.
; Each sound chip has a separate voice pool implementation.
;
	dw SCCVoicePool_size
SCCVoicePool:
SCCVoicePool_noteOn: equ $ - VoicePool
	dw SCCVoicePool_NoteOn
SCCVoicePool_noteOff: equ $ - VoicePool
	dw SCCVoicePool_NoteOff
SCCVoicePool_mono: equ $ - SCCVoicePool
	db -1;
SCCVoicePool_notes: equ $ - SCCVoicePool
	db -1, -1, -1, -1, -1
SCCVoicePool_voices: equ $ - SCCVoicePool
	dw SCC_voice1, SCC_voice2, SCC_voice3, SCC_voice4, 0  ; max 5 voices / pool
SCCVoicePool_size: equ $ - SCCVoicePool

; ix <- new class
SCCVoicePool_New:
	ld iy,SCCVoicePool
	call Class_New
	ret

; ix = this
; a = note number (0-127)
; b = velocity (0-127)
SCCVoicePool_NoteOn:
	IRP ?voice, 0, 1, 2, 3, 4
	PROC  ; make LOCAL work
	LOCAL SCCVoicePool_NoteOn_next
	bit 7,(ix + SCCVoicePool_notes + ?voice)
	jr z,SCCVoicePool_NoteOn_next
	ld l,(ix + SCCVoicePool_voices + ?voice * 2)
	ld h,(ix + SCCVoicePool_voices + ?voice * 2 + 1)
	inc h
	dec h
	jr z,SCCVoicePool_NoteOn_break
	ld (ix + SCCVoicePool_notes + ?voice),a
	push hl
	pop ix
	jp SCCVoice_NoteOn
SCCVoicePool_NoteOn_next:
	ENDP
	ENDM
SCCVoicePool_NoteOn_break:
	; no free note found
	ret

; ix = this
; a = note number (0-127)
; b = velocity (0-127)
SCCVoicePool_NoteOff:
	IRP ?voice, 0, 1, 2, 3, 4
	PROC  ; make LOCAL work
	LOCAL SCCVoicePool_NoteOff_next
	cp (ix + SCCVoicePool_notes + ?voice)
	jr nz,SCCVoicePool_NoteOff_next
	ld l,(ix + SCCVoicePool_voices + ?voice * 2)
	ld h,(ix + SCCVoicePool_voices + ?voice * 2 + 1)
	ld a,-1
	ld (ix + SCCVoicePool_notes + ?voice),a
	push hl
	pop ix
	jp SCCVoice_NoteOff
SCCVoicePool_NoteOff_next:
	ENDP
	ENDM
	; note not found
	ret

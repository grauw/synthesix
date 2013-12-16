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
VoicePool_mono: equ $ - VoicePool
	db -1;
VoicePool_notes: equ $ - VoicePool
	db -1, -1, -1, -1, -1
VoicePool_voices: equ $ - VoicePool
	dw SCC_voice1, SCC_voice2, SCC_voice3, SCC_voice4, 0  ; max 5 voices / pool
VoicePool_size: equ $ - VoicePool

; ix <- new class
VoicePool_New:
	ld iy,VoicePool
	call Class_New
	ret

; ix = this
; a = note number (0-127)
; b = velocity (0-127)
VoicePool_NoteOn:
	IRP ?voice, 0, 1, 2, 3, 4
	PROC  ; make LOCAL work
	LOCAL VoicePool_NoteOn_next
	bit 7,(ix + VoicePool_notes + ?voice)
	jr z,VoicePool_NoteOn_next
	ld l,(ix + VoicePool_voices + ?voice * 2)
	ld h,(ix + VoicePool_voices + ?voice * 2 + 1)
	inc h
	dec h
	jr z,VoicePool_NoteOn_break
	ld (ix + VoicePool_notes + ?voice),a
	push hl
	pop ix
	jp SCCVoice_NoteOn
VoicePool_NoteOn_next:
	ENDP
	ENDM
VoicePool_NoteOn_break:
	; no free note found
	ret

; ix = this
; a = note number (0-127)
; b = velocity (0-127)
VoicePool_NoteOff:
	IRP ?voice, 0, 1, 2, 3, 4
	PROC  ; make LOCAL work
	LOCAL VoicePool_NoteOff_next
	cp (ix + VoicePool_notes + ?voice)
	jr nz,VoicePool_NoteOff_next
	ld l,(ix + VoicePool_voices + ?voice * 2)
	ld h,(ix + VoicePool_voices + ?voice * 2 + 1)
	ld a,-1
	ld (ix + VoicePool_notes + ?voice),a
	push hl
	pop ix
	jp SCCVoice_NoteOff
VoicePool_NoteOff_next:
	ENDP
	ENDM
	; note not found
	ret

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

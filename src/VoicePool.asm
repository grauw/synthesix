;
; A voice pool
;
; Pools voices for polyphonic playback.
; When a note is played it binds a voice to it until it is
; released. When a voice is bound, it will try the next one.
;
VoicePool: MACRO
	MAX_VOICES: equ 5
	polyphony:
		db 0
	nextNote:
		db -1
	lastNote:
		db -1
	voices:
		REPT MAX_VOICES, ?voice
		NoteVoicePair
		ENDM
	size:
	ENDM

NoteVoicePair: MACRO
	note:
		db -1
	voice:
		dw 0
	size:
	ENDM

	dw VoicePool.size
VoicePool_class: VoicePool

; ix <- new class
VoicePool_New:
	ld iy,VoicePool_class
	call Class_New
	ret

; TODO if no notes are available, pick the one most recently played
;      (or, at least retrigger the missed one once another is released)
;
; ix = this
; b = note number (0-127)
; c = velocity (0-127)
VoicePool_NoteOn:
	ld a,(ix + VoicePool.nextNote)
	cp (ix + VoicePool.lastNote)
	ret z
	REPT VoicePool.MAX_VOICES, ?voice
	cp (ix + VoicePool.voices + ?voice * NoteVoicePair.size + NoteVoicePair.note)
	jr nz,Next
	dec a
	or 80H
	ld (ix + VoicePool.nextNote),a
	ld a,b
	ld (ix + VoicePool.voices + ?voice * NoteVoicePair.size + NoteVoicePair.note),a
	ld e,(ix + VoicePool.voices + ?voice * NoteVoicePair.size + NoteVoicePair.voice)
	ld d,(ix + VoicePool.voices + ?voice * NoteVoicePair.size + NoteVoicePair.voice + 1)
	ld ixl,e
	ld ixh,d
	jp Voice_NoteOn
Next:
	ENDM
	call System_ThrowException
	ret

; ix = this
; b = note number (0-127)
; c = velocity (0-127)
VoicePool_NoteOff:
	ld a,b
	REPT VoicePool.MAX_VOICES, ?voice
	cp (ix + VoicePool.voices + ?voice * NoteVoicePair.size + NoteVoicePair.note)
	jr nz,Next
	ld a,(ix + VoicePool.lastNote)
	ld (ix + VoicePool.voices + ?voice * NoteVoicePair.size + NoteVoicePair.note),a
	dec a
	or 80H
	ld (ix + VoicePool.lastNote),a
	ld e,(ix + VoicePool.voices + ?voice * NoteVoicePair.size + NoteVoicePair.voice)
	ld d,(ix + VoicePool.voices + ?voice * NoteVoicePair.size + NoteVoicePair.voice + 1)
	ld ixl,e
	ld ixh,d
	jp Voice_NoteOff
Next:
	ENDM
	; note not found
	ret

; ix = this
VoicePool_Update: PROC
	ld a,(ix + VoicePool.polyphony)
	and a
	ret z
Loop:
	ld e,(ix + VoicePool.voices + NoteVoicePair.voice)
	ld d,(ix + VoicePool.voices + NoteVoicePair.voice + 1)
	push ix
	ld ixl,e
	ld ixh,d
	push af
	call Voice_Update
	pop af
	pop ix
	inc ix  ; next voice
	inc ix
	inc ix
	dec a
	jp nz,Loop
	ret
	ENDP

; ix = this
; hl = callback
VoicePool_ForEach: PROC
	ld a,(ix + VoicePool.polyphony)
	and a
	ret z
Loop:
	ld e,(ix + VoicePool.voices + NoteVoicePair.voice)
	ld d,(ix + VoicePool.voices + NoteVoicePair.voice + 1)
	push ix
	ld ixl,e
	ld ixh,d
	push hl
	push af
	call CallHL
	pop af
	pop hl
	pop ix
	inc ix  ; next voice
	inc ix
	inc ix
	dec a
	jp nz,Loop
	ret
CallHL:
	jp hl
	ENDP

; ix = this
; hl = voice
VoicePool_AddVoice:
	REPT VoicePool.MAX_VOICES, ?voice
	ld a,(ix + VoicePool.voices + ?voice * NoteVoicePair.size + NoteVoicePair.voice + 1)
	and a
	jr nz,Next
	ld (ix + VoicePool.voices + ?voice * NoteVoicePair.size + NoteVoicePair.voice),l
	ld (ix + VoicePool.voices + ?voice * NoteVoicePair.size + NoteVoicePair.voice + 1),h
	ld a,(ix + VoicePool.lastNote)
	ld (ix + VoicePool.voices + ?voice * NoteVoicePair.size + NoteVoicePair.note),a
	dec a
	or 80H
	ld (ix + VoicePool.lastNote),a
	inc (ix + VoicePool.polyphony)
	ret
Next:
	ENDM
	call System_ThrowException

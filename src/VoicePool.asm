;
; A voice pool
;
; Pools voices for polyphonic playback.
; When a note is played it binds a voice to it until it is
; released. When a voice is bound, it will try the next one.
;
VoicePool: MACRO
	MAX_VOICES: equ 5
	MAX_QUEUEDNOTES: equ 5
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
	queuedNoteCount:
		db 0
	queuedNotes:
		REPT MAX_QUEUEDNOTES
		QueuedNote
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

QueuedNote: MACRO
	note:
		db -1
	velocity:
		db 0
	size:
	ENDM

	dw VoicePool.size
VoicePool_class: VoicePool

; ix <- new class
VoicePool_New:
	ld iy,VoicePool_class
	call Class_New
	ret

; ix = this
; b = note number (0-127)
; c = velocity (0-127)
VoicePool_NoteOn: PROC
	ld a,(ix + VoicePool.nextNote)
	cp (ix + VoicePool.lastNote)
	jp z,VoicePool_QueueNote
	push ix
	pop iy
	ld de,NoteVoicePair.size
Loop:
	cp (iy + VoicePool.voices + NoteVoicePair.note)
	jr z,Found
	add iy,de  ; next voice
	jp Loop
Found:
	ld (iy + VoicePool.voices + NoteVoicePair.note),b
	ld e,(iy + VoicePool.voices + NoteVoicePair.voice)
	ld d,(iy + VoicePool.voices + NoteVoicePair.voice + 1)
	dec a
	or 80H
	ld (ix + VoicePool.nextNote),a
	ld ixl,e
	ld ixh,d
	jp Voice_NoteOn
	ENDP

; ix = this
; b = note number (0-127)
; c = velocity (0-127)
VoicePool_NoteOff: PROC
	ld a,(ix + VoicePool.polyphony)
	and a
	jp z,VoicePool_UnqueueNote
	push ix
	pop iy
	ld l,a
	ld a,b
	ld de,NoteVoicePair.size
Loop:
	cp (iy + VoicePool.voices + NoteVoicePair.note)
	jr z,Found
	add iy,de
	dec l
	jp nz,Loop
	jp VoicePool_UnqueueNote
Found:
	call VoicePool_PopQueuedNote
	jr nc,Replace
	ld a,(ix + VoicePool.lastNote)
	ld (iy + VoicePool.voices + NoteVoicePair.note),a
	dec a
	or 80H
	ld (ix + VoicePool.lastNote),a
	ld e,(iy + VoicePool.voices + NoteVoicePair.voice)
	ld d,(iy + VoicePool.voices + NoteVoicePair.voice + 1)
	ld ixl,e
	ld ixh,d
	jp Voice_NoteOff
Replace:
	ld (iy + VoicePool.voices + NoteVoicePair.note),b
	ld e,(iy + VoicePool.voices + NoteVoicePair.voice)
	ld d,(iy + VoicePool.voices + NoteVoicePair.voice + 1)
	ld ixl,e
	ld ixh,d
	jp Voice_NoteOn
	ENDP

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
	ld de,NoteVoicePair.size  ; next voice
	add ix,de
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
	ld de,NoteVoicePair.size  ; next voice
	add ix,de
	dec a
	jp nz,Loop
	ret
CallHL:
	jp hl
	ENDP

; ix = this
; hl = voice
VoicePool_AddVoice:
	ld a,(ix + VoicePool.polyphony)
	cp VoicePool.MAX_VOICES
	call nc,System_ThrowException
	ld c,a
	add a,c  ; * NoteVoicePair.size
	add a,c
	ld c,a
	ld b,0
	ld a,(ix + VoicePool.lastNote)
	push ix
	add ix,bc
	ld (ix + VoicePool.voices + NoteVoicePair.note),a
	ld (ix + VoicePool.voices + NoteVoicePair.voice),l
	ld (ix + VoicePool.voices + NoteVoicePair.voice + 1),h
	pop ix
	dec a
	or 80H
	ld (ix + VoicePool.lastNote),a
	inc (ix + VoicePool.polyphony)
	ret

; ix = this
; b = note number (0-127)
; c = velocity (0-127)
VoicePool_QueueNote:
	ld a,(ix + VoicePool.queuedNoteCount)
	cp VoicePool.MAX_QUEUEDNOTES
	ret nc
	inc (ix + VoicePool.queuedNoteCount)
	add a,a
	ld e,a
	ld d,0
	add ix,de
	ld (ix + VoicePool.queuedNotes + QueuedNote.note),b
	ld (ix + VoicePool.queuedNotes + QueuedNote.velocity),c
	ret

; ix = this
; b = note number (0-127)
; c = velocity (0-127)
VoicePool_UnqueueNote: PROC
	ld a,(ix + VoicePool.queuedNoteCount)
	and a
	ret z
	dec (ix + VoicePool.queuedNoteCount)
	ld e,a
	ld a,b
Loop:
	cp (ix + VoicePool.queuedNotes + QueuedNote.note)
	jr z,Found
	inc ix
	inc ix
	dec e
	jp nz,Loop
	ret
Found:
	dec e
	ret z
	ld a,(ix + VoicePool.queuedNotes + QueuedNote.note + QueuedNote.size)
	ld (ix + VoicePool.queuedNotes + QueuedNote.note),a
	ld a,(ix + VoicePool.queuedNotes + QueuedNote.velocity + QueuedNote.size)
	ld (ix + VoicePool.queuedNotes + QueuedNote.velocity),a
	inc ix
	inc ix
	jp Found
	ENDP

; ix = this
; b <- note number (0-127)
; c <- velocity (0-127)
; f <- c: queue empty (bc not modified)
VoicePool_PopQueuedNote:
	ld a,(ix + VoicePool.queuedNoteCount)
	sub 1
	ret c
	ld (ix + VoicePool.queuedNoteCount),a
	add a,a
	ld e,a
	ld d,0
	add ix,de
	ld b,(ix + VoicePool.queuedNotes + QueuedNote.note)
	ld c,(ix + VoicePool.queuedNotes + QueuedNote.velocity)
	ret

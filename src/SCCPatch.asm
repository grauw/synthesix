;
; An SCC voice pool
;
; Pools voices for polyphonic playback.
; When a note is played it binds a voice to it until it is
; released. When a voice is bound, it will try the next one.
; Each sound chip has a separate voice pool implementation.
;
SCCPatch: MACRO
	super:
		Patch SCCPatch_NoteOn, SCCPatch_NoteOff, SCCPatch_Update
	MAX_VOICES: equ 5
	polyphony:
		db 4
	pitch:
		db 0
	notes:
		db -1, -1, -1, -1, -1
	nextNote:
		db -1
	lastNote:
		db -1
	voices:
		REPT MAX_VOICES, ?voice
		dw 0
		ENDM
	size:
	ENDM

	dw SCCPatch.size
SCCPatch_class: SCCPatch

; ix <- new class
SCCPatch_New:
	ld iy,SCCPatch_class
	call Class_New
	jp SCCPatch_Constructor

; ix = this
; ix <- this
SCCPatch_Constructor: PROC
	ld b,(ix + SCCPatch.polyphony)
Loop:
	push bc
	push ix
	call SCC_GetFreeVoice
	ex (sp),ix
	pop hl
	call SCCPatch_AddVoice
	pop bc
	djnz Loop
	ret
	ENDP

; TODO if no notes are available, pick the one most recently played
;      (or, at least retrigger the missed one once another is released)
;
; ix = this
; b = note number (0-127)
; c = velocity (0-127)
SCCPatch_NoteOn:
	ld a,(ix + SCCPatch.nextNote)
	cp (ix + SCCPatch.lastNote)
	ret z
	REPT SCCPatch.MAX_VOICES, ?voice
	cp (ix + SCCPatch.notes + ?voice)
	jr nz,Next
	dec a
	or 80H
	ld (ix + SCCPatch.nextNote),a
	ld a,b
	ld (ix + SCCPatch.notes + ?voice),a

	add a,(ix + SCCPatch.pitch)
	ld e,(ix + SCCPatch.voices + ?voice * 2)
	ld d,(ix + SCCPatch.voices + ?voice * 2 + 1)
	ld ixl,e
	ld ixh,d
	jp SCCVoice_NoteOn
Next:
	ENDM
	call System_ThrowException
	ret

; ix = this
; b = note number (0-127)
; c = velocity (0-127)
SCCPatch_NoteOff:
	ld a,b
	REPT SCCPatch.MAX_VOICES, ?voice
	cp (ix + SCCPatch.notes + ?voice)
	jr nz,Next
	ld a,(ix + SCCPatch.lastNote)
	ld (ix + SCCPatch.notes + ?voice),a
	dec a
	or 80H
	ld (ix + SCCPatch.lastNote),a
	ld e,(ix + SCCPatch.voices + ?voice * 2)
	ld d,(ix + SCCPatch.voices + ?voice * 2 + 1)
	ld ixl,e
	ld ixh,d
	jp SCCVoice_NoteOff
Next:
	ENDM
	; note not found
	ret

; ix = this
SCCPatch_Update:
	REPT SCCPatch.MAX_VOICES, ?voice
	ld e,(ix + SCCPatch.voices + ?voice * 2)
	ld d,(ix + SCCPatch.voices + ?voice * 2 + 1)
	inc d
	dec d
	ret z
	push ix
	ld ixl,e
	ld ixh,d
	call SCCVoice_Update
	pop ix
	ENDM
	ret

; ix = this
; hl = callback
SCCPatch_ForEach: PROC
	REPT SCCPatch.MAX_VOICES, ?voice
	ld e,(ix + SCCPatch.voices + ?voice * 2)
	ld d,(ix + SCCPatch.voices + ?voice * 2 + 1)
	inc d
	dec d
	ret z
	push ix
	ld ixl,e
	ld ixh,d
	push hl
	call CallHL
	pop hl
	pop ix
	ENDM
	ret
CallHL:
	jp hl
	ENDP

; ix = this
; hl = voice
SCCPatch_AddVoice:
	REPT SCCPatch.MAX_VOICES, ?voice
	ld a,(ix + SCCPatch.voices + ?voice * 2 + 1)
	and a
	jr nz,Next
	ld (ix + SCCPatch.voices + ?voice * 2),l
	ld (ix + SCCPatch.voices + ?voice * 2 + 1),h
	ld a,(ix + SCCPatch.lastNote)
	ld (ix + SCCPatch.notes + ?voice),a
	dec a
	or 80H
	ld (ix + SCCPatch.lastNote),a
	ret
Next:
	ENDM
	call System_ThrowException

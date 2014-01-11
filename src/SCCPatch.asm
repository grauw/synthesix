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
		Patch SCCPatch_NoteOn, SCCPatch_NoteOff, SCCPatch_ControlChange, SCCPatch_Update
	MAX_VOICES: equ 5
	noteOn:
		dw SCCPatch_NoteOn
	noteOff:
		dw SCCPatch_NoteOff
	controlChange:
		dw SCCPatch_ControlChange
	update:
		dw SCCPatch_Update
	polyphony:
		db 4
	level:
		db 127
	pitch:
		db 0
	wave:
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
SCCPatch_Constructor:
	ld b,(ix + SCCPatch.polyphony)
SCCPatch_New_Loop:
	push bc
	push ix
	call SCC_GetFreeVoice
	ex (sp),ix
	pop hl
	call SCCPatch_AddVoice
	pop bc
	djnz SCCPatch_New_Loop
	ld a,(ix + SCCPatch.wave)
	call SCCPatch_SetWave
	ret

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
	jr nz,SCCPatch_NoteOn_Next
	dec a
	or 80H
	ld (ix + SCCPatch.nextNote),a
	ld a,b
	ld (ix + SCCPatch.notes + ?voice),a

	add a,(ix + SCCPatch.pitch)
	ex af,af'
	ld a,c
	ld l,(ix + SCCPatch.level)
	call Math_Multiply127x127
	ld c,a
	ex af,af'
	ld e,(ix + SCCPatch.voices + ?voice * 2)
	ld d,(ix + SCCPatch.voices + ?voice * 2 + 1)
	ld ixl,e
	ld ixh,d
	jp SCCVoice_NoteOn
SCCPatch_NoteOn_Next:
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
	jr nz,SCCPatch_NoteOff_Next
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
SCCPatch_NoteOff_Next:
	ENDM
	; note not found
	ret

; ix = this
; b = controller
; c = value
SCCPatch_ControlChange:
	ld a,c
	call SCCPatch_SetWave
	ret

; ix = this
; b = time delta
SCCPatch_Update:
	REPT SCCPatch.MAX_VOICES, ?voice
	ld e,(ix + SCCPatch.voices + ?voice * 2)
	ld d,(ix + SCCPatch.voices + ?voice * 2 + 1)
	inc d
	dec d
	jr z,SCCPatch_Update_Next
	push ix
	ld ixl,e
	ld ixh,d
	call SCCVoice_Update
	pop ix
SCCPatch_Update_Next:
	ENDM
	ret

; ix = this
; a = wave number
SCCPatch_SetWave:
	ld l,a
	ld h,0
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ld bc,SCCWaveTable_table1
	add hl,bc

	ld a,ROM_WaveTableBank
	ld (ROM_BANK_3_CHANGE),a
	REPT SCCPatch.MAX_VOICES, ?voice
	ld e,(ix + SCCPatch.voices + ?voice * 2)
	ld d,(ix + SCCPatch.voices + ?voice * 2 + 1)
	inc d
	dec d
	jr z,SCCPatch_SetWave_Done
	push de
	ex (sp),ix
	push hl
	call SCCVoice_SetWave
	pop hl
	pop ix
	ENDM
SCCPatch_SetWave_Done:
	ld a,ROM_Bank3Default
	ld (ROM_BANK_3_CHANGE),a
	ret

; ix = this
; hl = voice
SCCPatch_AddVoice:
	REPT SCCPatch.MAX_VOICES, ?voice
	ld a,(ix + SCCPatch.voices + ?voice * 2 + 1)
	and a
	jr nz,SCCPatch_AddVoice_Next
	ld (ix + SCCPatch.voices + ?voice * 2),l
	ld (ix + SCCPatch.voices + ?voice * 2 + 1),h
	ld a,(ix + SCCPatch.lastNote)
	ld (ix + SCCPatch.notes + ?voice),a
	dec a
	or 80H
	ld (ix + SCCPatch.lastNote),a
	ret
SCCPatch_AddVoice_Next:
	ENDM
	call System_ThrowException

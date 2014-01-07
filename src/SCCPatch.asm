;
; An SCC voice pool
;
; Pools voices for polyphonic playback.
; When a note is played it binds a voice to it until it is
; released. When a voice is bound, it will try the next one.
; Each sound chip has a separate voice pool implementation.
;
	dw SCCPatch_size
SCCPatch:
SCCPatch_MAX_VOICES: equ 5
SCCPatch_noteOn: equ $ - SCCPatch
	dw SCCPatch_NoteOn
SCCPatch_noteOff: equ $ - SCCPatch
	dw SCCPatch_NoteOff
SCCPatch_controlChange: equ $ - SCCPatch
	dw SCCPatch_ControlChange
SCCPatch_update: equ $ - SCCPatch
	dw SCCPatch_Update
SCCPatch_polyphony: equ $ - SCCPatch
	db 4
SCCPatch_level: equ $ - SCCPatch
	db 127
SCCPatch_pitch: equ $ - SCCPatch
	db 0
SCCPatch_wave: equ $ - SCCPatch
	db 0
SCCPatch_notes: equ $ - SCCPatch
	db -1, -1, -1, -1, -1
SCCPatch_nextNote: equ $ - SCCPatch
	db -1
SCCPatch_lastNote: equ $ - SCCPatch
	db -1
SCCPatch_voices: equ $ - SCCPatch
	REPT SCCPatch_MAX_VOICES, ?voice
	dw 0
	ENDM
SCCPatch_size: equ $ - SCCPatch

; ix <- new class
SCCPatch_New:
	ld iy,SCCPatch
	call Class_New
	jp SCCPatch_Constructor

; ix = this
; ix <- this
SCCPatch_Constructor:
	ld b,(ix + SCCPatch_polyphony)
SCCPatch_New_Loop:
	push bc
	push ix
	call SCC_GetFreeVoice
	ex (sp),ix
	pop hl
	call SCCPatch_AddVoice
	pop bc
	djnz SCCPatch_New_Loop
	ld a,(ix + SCCPatch_wave)
	call SCCPatch_LoadWave
	ret

; ix = this
; a = note number (0-127)
; b = velocity (0-127)
SCCPatch_NoteOn:
	ld c,a
	ld a,(ix + SCCPatch_nextNote)
	cp (ix + SCCPatch_lastNote)
	ret z
	REPT SCCPatch_MAX_VOICES, ?voice
	cp (ix + SCCPatch_notes + ?voice)
	jr nz,SCCPatch_NoteOn_Next
	dec a
	or 80H
	ld (ix + SCCPatch_nextNote),a
	ld a,c
	ld (ix + SCCPatch_notes + ?voice),a

	add a,(ix + SCCPatch_pitch)
	ex af,af'
	ld a,b
	ld l,(ix + SCCPatch_level)
	call Math_Multiply127x127
	ld b,a
	ex af,af'
	ld e,(ix + SCCPatch_voices + ?voice * 2)
	ld d,(ix + SCCPatch_voices + ?voice * 2 + 1)
	ld ixl,e
	ld ixh,d
	jp SCCVoice_NoteOn
SCCPatch_NoteOn_Next:
	ENDM
	call System_ThrowException
	ret

; ix = this
; a = note number (0-127)
; b = velocity (0-127)
SCCPatch_NoteOff:
	REPT SCCPatch_MAX_VOICES, ?voice
	cp (ix + SCCPatch_notes + ?voice)
	jr nz,SCCPatch_NoteOff_Next
	ld a,(ix + SCCPatch_lastNote)
	ld (ix + SCCPatch_notes + ?voice),a
	dec a
	or 80H
	ld (ix + SCCPatch_lastNote),a
	ld e,(ix + SCCPatch_voices + ?voice * 2)
	ld d,(ix + SCCPatch_voices + ?voice * 2 + 1)
	ld ixl,e
	ld ixh,d
	jp SCCVoice_NoteOff
SCCPatch_NoteOff_Next:
	ENDM
	; note not found
	ret

; ix = this
; a = value
; b = controller
SCCPatch_ControlChange:
	call SCCPatch_LoadWave
	ret

; ix = this
; b = time delta
SCCPatch_Update:
	REPT SCCPatch_MAX_VOICES, ?voice
	ld e,(ix + SCCPatch_voices + ?voice * 2)
	ld d,(ix + SCCPatch_voices + ?voice * 2 + 1)
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
SCCPatch_LoadWave:
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
	REPT SCCPatch_MAX_VOICES, ?voice
	ld e,(ix + SCCPatch_voices + ?voice * 2)
	ld d,(ix + SCCPatch_voices + ?voice * 2 + 1)
	inc d
	dec d
	jr z,SCCPatch_LoadWave_Done
	push de
	ex (sp),ix
	push hl
	call SCCVoice_LoadWave
	pop hl
	pop ix
	ENDM
SCCPatch_LoadWave_Done:
	ld a,ROM_Bank3Default
	ld (ROM_BANK_3_CHANGE),a
	ret

; ix = this
; hl = voice
SCCPatch_AddVoice:
	REPT SCCPatch_MAX_VOICES, ?voice
	ld a,(ix + SCCPatch_voices + ?voice * 2 + 1)
	and a
	jr nz,SCCPatch_AddVoice_Next
	ld (ix + SCCPatch_voices + ?voice * 2),l
	ld (ix + SCCPatch_voices + ?voice * 2 + 1),h
	ld a,(ix + SCCPatch_lastNote)
	ld (ix + SCCPatch_notes + ?voice),a
	dec a
	or 80H
	ld (ix + SCCPatch_lastNote),a
	ret
SCCPatch_AddVoice_Next:
	ENDM
	call System_ThrowException

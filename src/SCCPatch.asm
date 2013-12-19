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
SCCPatch_polyphony: equ $ - SCCPatch
	db 4
SCCPatch_level: equ $ - SCCPatch
	db 127
SCCPatch_pitch: equ $ - SCCPatch
	db 0
SCCPatch_wave: equ $ - SCCPatch
	db 7FH, 7FH, 7FH, 7FH, 7FH, 7FH, 7FH, 7FH, 7FH, 7FH, 7FH, 7FH, 7FH, 7FH, 7FH, 7FH
	db 80H, 80H, 80H, 80H, 80H, 80H, 80H, 80H, 80H, 80H, 80H, 80H, 80H, 80H, 80H, 80H
SCCPatch_notes: equ $ - SCCPatch
	db -1, -1, -1, -1, -1
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
	ld hl,SCCPatch_wave
	ld c,ixl
	ld b,ixh
	add hl,bc
	call SCC_GetFreeVoice
	call SCCVoice_Bind
	call SCCVoice_LoadWave
	ex (sp),ix
	pop hl
	call SCCPatch_AddVoice
	pop bc
	djnz SCCPatch_New_Loop
	ret

; ix = this
; a = note number (0-127)
; b = velocity (0-127)
SCCPatch_NoteOn:
	REPT SCCPatch_MAX_VOICES, ?voice
	PROC  ; make LOCAL work
	LOCAL SCCPatch_NoteOn_Next
	bit 7,(ix + SCCPatch_notes + ?voice)
	jr z,SCCPatch_NoteOn_Next
	ld l,(ix + SCCPatch_voices + ?voice * 2)
	ld h,(ix + SCCPatch_voices + ?voice * 2 + 1)
	inc h
	dec h
	jp z,SCCPatch_NoteOn_Break
	ld (ix + SCCPatch_notes + ?voice),a

	add a,(ix + SCCPatch_pitch)
	push hl
	ex af,af'
	ld a,b
	ld l,(ix + SCCPatch_level)
	call Math_Multiply127x127
	ld b,a
	ex af,af'
	pop ix
	jp SCCVoice_NoteOn
SCCPatch_NoteOn_Next:
	ENDP
	ENDM
SCCPatch_NoteOn_Break:
	; no free note found
	ret

; ix = this
; a = note number (0-127)
; b = velocity (0-127)
SCCPatch_NoteOff:
	REPT SCCPatch_MAX_VOICES, ?voice
	PROC  ; make LOCAL work
	LOCAL SCCPatch_NoteOff_Next
	cp (ix + SCCPatch_notes + ?voice)
	jr nz,SCCPatch_NoteOff_Next
	ld l,(ix + SCCPatch_voices + ?voice * 2)
	ld h,(ix + SCCPatch_voices + ?voice * 2 + 1)
	ld a,-1
	ld (ix + SCCPatch_notes + ?voice),a
	push hl
	pop ix
	jp SCCVoice_NoteOff
SCCPatch_NoteOff_Next:
	ENDP
	ENDM
	; note not found
	ret

; ix = this
; a = value
; b = controller
SCCPatch_ControlChange:
	ret

; ix = this
; hl = voice
SCCPatch_AddVoice:
	REPT SCCPatch_MAX_VOICES, ?voice
	PROC
	LOCAL SCCPatch_AddVoice_Next
	ld a,(ix + SCCPatch_voices + ?voice * 2 + 1)
	and a
	jr nz,SCCPatch_AddVoice_Next
	ld (ix + SCCPatch_voices + ?voice * 2),l
	ld (ix + SCCPatch_voices + ?voice * 2 + 1),h
	ret
SCCPatch_AddVoice_Next:
	ENDP
	ENDM
	call System_ThrowException

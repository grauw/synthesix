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
SCCVoicePool_MAX_VOICES: equ 5
SCCVoicePool_noteOn: equ $ - SCCVoicePool
	dw SCCVoicePool_NoteOn
SCCVoicePool_noteOff: equ $ - SCCVoicePool
	dw SCCVoicePool_NoteOff
SCCVoicePool_polyphony: equ $ - SCCVoicePool
	db 4
SCCVoicePool_mono: equ $ - SCCVoicePool
	db -1;
SCCVoicePool_notes: equ $ - SCCVoicePool
	db -1, -1, -1, -1, -1
SCCVoicePool_voices: equ $ - SCCVoicePool
	REPT SCCVoicePool_MAX_VOICES, ?voice
	dw 0
	ENDM
SCCVoicePool_size: equ $ - SCCVoicePool

; ix <- new class
SCCVoicePool_New:
	ld iy,SCCVoicePool
	call Class_New
	jp SCCVoicePool_Constructor

; ix = this
; ix <- this
SCCVoicePool_Constructor:
	ld b,(ix + SCCVoicePool_polyphony)
SCCVoicePool_New_Loop:
	push bc
	push ix
	call SCC_GetFreeVoice
	call SCCVoice_Bind
	ld hl,SCC_sawWave
	call SCCVoice_LoadWave
	ex (sp),ix
	pop hl
	call SCCVoicePool_AddVoice
	pop bc
	djnz SCCVoicePool_New_Loop
	ret

; ix = this
; a = note number (0-127)
; b = velocity (0-127)
SCCVoicePool_NoteOn:
	REPT SCCVoicePool_MAX_VOICES, ?voice
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
	REPT SCCVoicePool_MAX_VOICES, ?voice
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

; ix = this
; hl = voice
SCCVoicePool_AddVoice:
	REPT SCCVoicePool_MAX_VOICES, ?voice
	PROC
	LOCAL SCCVoicePool_AddVoice_next
	ld a,(ix + SCCVoicePool_voices + ?voice * 2 + 1)
	and a
	jr nz,SCCVoicePool_AddVoice_next
	ld (ix + SCCVoicePool_voices + ?voice * 2),l
	ld (ix + SCCVoicePool_voices + ?voice * 2 + 1),h
	ret
SCCVoicePool_AddVoice_next:
	ENDP
	ENDM
	call Utils_ThrowException

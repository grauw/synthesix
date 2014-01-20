;
; An attack-release envelope
;
AREnvelope: MACRO
	super: Value 0
	attack:
		db 8
	release:
		db 8
	sign:
		db 0
	phase:
		db -1
	counter:
		db 0
	size:
	ENDM

	dw AREnvelope.size
AREnvelope_class: AREnvelope

; ix <- new class
AREnvelope_New:
	ld iy,AREnvelope_class
	call Class_New
	call AREnvelope_Constructor
	ret

; ix = this
AREnvelope_Constructor:
	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Clock_60Hz
	ld hl,AREnvelope_Update
	call Clock_AddListener
	pop ix
	ret

; ix = voice
; de = this
AREnvelope_SetKeyTrigger:
	ld hl,AREnvelope_NoteOn
	call SCCVoice_AddNoteOnListener
	ld hl,AREnvelope_NoteOff
	call SCCVoice_AddNoteOffListener
	ret

; ix = this
AREnvelope_NoteOn:
	ld (ix + AREnvelope.phase),0
	ld (ix + AREnvelope.counter),0
	ret

; ix = this
AREnvelope_NoteOff:
	ld (ix + AREnvelope.phase),-1
	ret

; ix = this
AREnvelope_Update:
	bit 7,(ix + AREnvelope.phase)  ; to test a third phase: rlc (ix) ; jp po
	jr nz,AREnvelope_UpdateRelease
	jp AREnvelope_UpdateAttack

; ix = this
AREnvelope_UpdateAttack: PROC
	ld a,(ix + AREnvelope.counter)
	add a,(ix + AREnvelope.attack)
	jr c,Complete
	ld (ix + AREnvelope.counter),a
	rra
	ld (ix + AREnvelope.super.value),a
	bit 0,(ix + AREnvelope.sign)
	ret z
	cpl
	ld (ix + AREnvelope.super.value),a
	ret
Complete:
	ld (ix + AREnvelope.counter),255
	ld (ix + AREnvelope.super.value),127
	bit 0,(ix + AREnvelope.sign)
	ret z
	ld (ix + AREnvelope.super.value),~127
	ret
	ENDP

; ix = this
AREnvelope_UpdateRelease: PROC
	ld a,(ix + AREnvelope.counter)
	sub (ix + AREnvelope.release)
	jr c,Complete
	ld (ix + AREnvelope.counter),a
	rra
	ld (ix + AREnvelope.super.value),a
	bit 0,(ix + AREnvelope.sign)
	ret z
	cpl
	ld (ix + AREnvelope.super.value),a
	ret
Complete:
	ld (ix + AREnvelope.counter),0
	ld (ix + AREnvelope.super.value),0
	bit 0,(ix + AREnvelope.sign)
	ret z
	ld (ix + AREnvelope.super.value),~0
	ret
	ENDP

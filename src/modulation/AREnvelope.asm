;
; An attack-release envelope
;
AREnvelope: MACRO
	super: Value 0
	attack:
		dw Value_values.32
	release:
		dw Value_values.8
	gate:
		dw Value_values.0
	sign:
		db 0
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
	ret

; ix = this
AREnvelope_NoteOn:
	ld (ix + AREnvelope.counter),0
	ret

; ix = this
AREnvelope_Update:
	ld l,(ix + AREnvelope.gate)
	ld h,(ix + AREnvelope.gate + 1)
	bit 6,(hl)
	jr z,AREnvelope_UpdateRelease
	jp AREnvelope_UpdateAttack

; ix = this
AREnvelope_UpdateAttack: PROC
	ld a,(ix + AREnvelope.counter)
	ld l,(ix + AREnvelope.attack)
	ld h,(ix + AREnvelope.attack + 1)
	add a,(hl)
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
	ld l,(ix + AREnvelope.release)
	ld h,(ix + AREnvelope.release + 1)
	sub (hl)
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

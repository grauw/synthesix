;
; An attack-decay envelope
;
ADEnvelope: MACRO
	super: Value 0
	attack:
		db 128
	decay:
		db 4
	sign:
		db 0
	phase:
		db 0
	counter:
		db 0
	size:
	ENDM

	dw ADEnvelope.size
ADEnvelope_class: ADEnvelope

; ix <- new class
ADEnvelope_New:
	ld iy,ADEnvelope_class
	call Class_New
	call ADEnvelope_Constructor
	ret

; ix = this
ADEnvelope_Constructor:
	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Clock_60Hz
	ld hl,ADEnvelope_Update
	call Clock_AddListener
	pop ix
	ret

; ix = voice
; de = this
ADEnvelope_SetKeyTrigger:
	ld hl,ADEnvelope_NoteOn
	call SCCVoice_AddNoteOnListener
	ret

; ix = this
ADEnvelope_NoteOn:
	ld (ix + ADEnvelope.phase),0
	ld (ix + ADEnvelope.counter),0
	ret

; ix = this
ADEnvelope_Update:
	bit 7,(ix + ADEnvelope.phase)  ; to test a third phase: rlc (ix) ; jp po
	jr nz,ADEnvelope_UpdateDecay
	jp ADEnvelope_UpdateAttack

; ix = this
ADEnvelope_UpdateAttack: PROC
	ld a,(ix + ADEnvelope.counter)
	add a,(ix + ADEnvelope.attack)
	ld (ix + ADEnvelope.counter),a
	jr c,Complete
	rra
	ld (ix + ADEnvelope.super.value),a
	bit 0,(ix + ADEnvelope.sign)
	ret z
	cpl
	ld (ix + ADEnvelope.super.value),a
	ret
Complete:
	ld (ix + ADEnvelope.phase),-1
	jp ADEnvelope_UpdateDecay.ContinueFromAttack
	ENDP

; ix = this
ADEnvelope_UpdateDecay: PROC
	ld a,(ix + ADEnvelope.counter)
	add a,(ix + ADEnvelope.decay)
	jr c,Complete
ContinueFromAttack:
	ld (ix + ADEnvelope.counter),a
	cpl
	rra
	ld (ix + ADEnvelope.super.value),a
	bit 0,(ix + ADEnvelope.sign)
	ret z
	cpl
	ld (ix + ADEnvelope.super.value),a
	ret
Complete:
	ld (ix + ADEnvelope.counter),255
	ld (ix + ADEnvelope.super.value),0
	bit 0,(ix + ADEnvelope.sign)
	ret z
	ld (ix + ADEnvelope.super.value),~0
	ret
	ENDP

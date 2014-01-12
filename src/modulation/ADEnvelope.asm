;
; An AR envelope
;
ADEnvelope: MACRO
	super:
		Modulation ADEnvelope_NoteOn, ADEnvelope_NoteOff, ADEnvelope_Update
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

; iy = this
ADEnvelope_NoteOn:
	ld (iy + ADEnvelope.phase),0
	ld (iy + ADEnvelope.counter),0
	ret

; iy = this
ADEnvelope_NoteOff:
	ret

; iy = this
; a <- value
ADEnvelope_Update:
	bit 7,(iy + ADEnvelope.phase)  ; to test a third phase: rlc (iy) ; jp po
	jr nz,ADEnvelope_UpdateDecay
	jp ADEnvelope_UpdateAttack

; iy = this
; a <- value
ADEnvelope_UpdateAttack:
	ld a,(iy + ADEnvelope.counter)
	add a,(iy + ADEnvelope.attack)
	ld (iy + ADEnvelope.counter),a
	jr c,ADEnvelope_UpdateAttack_Complete
	rra
	bit 0,(iy + ADEnvelope.sign)
	ret z
	cpl
	ret
ADEnvelope_UpdateAttack_Complete:
	ld (iy + ADEnvelope.phase),-1
	jp ADEnvelope_UpdateDecay_FromAttack

; iy = this
; a <- value
ADEnvelope_UpdateDecay:
	ld a,(iy + ADEnvelope.counter)
	add a,(iy + ADEnvelope.decay)
	jr c,ADEnvelope_UpdateDecay_Complete
ADEnvelope_UpdateDecay_FromAttack:
	ld (iy + ADEnvelope.counter),a
	cpl
	rra
	bit 0,(iy + ADEnvelope.sign)
	ret z
	cpl
	ret
ADEnvelope_UpdateDecay_Complete:
	ld (iy + ADEnvelope.counter),255
	xor a
	bit 0,(iy + ADEnvelope.sign)
	ret z
	cpl
	ret

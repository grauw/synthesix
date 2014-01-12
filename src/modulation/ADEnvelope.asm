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
; a <- value (one’s complement)
ADEnvelope_Update:
	bit 7,(iy + ADEnvelope.phase)  ; to test a third phase: rlc (iy) ; jp po
	jr nz,ADEnvelope_UpdateDecay
	jp ADEnvelope_UpdateAttack

; iy = this
; a <- value (one’s complement)
ADEnvelope_UpdateAttack: PROC
	ld a,(iy + ADEnvelope.counter)
	add a,(iy + ADEnvelope.attack)
	ld (iy + ADEnvelope.counter),a
	jr c,Complete
	rra
	bit 0,(iy + ADEnvelope.sign)
	ret z
	cpl
	ret
Complete:
	ld (iy + ADEnvelope.phase),-1
	jp ADEnvelope_UpdateDecay.ContinueFromAttack
	ENDP

; iy = this
; a <- value (one’s complement)
ADEnvelope_UpdateDecay: PROC
	ld a,(iy + ADEnvelope.counter)
	add a,(iy + ADEnvelope.decay)
	jr c,Complete
ContinueFromAttack:
	ld (iy + ADEnvelope.counter),a
	cpl
	rra
	bit 0,(iy + ADEnvelope.sign)
	ret z
	cpl
	ret
Complete:
	ld (iy + ADEnvelope.counter),255
	xor a
	bit 0,(iy + ADEnvelope.sign)
	ret z
	cpl
	ret
	ENDP

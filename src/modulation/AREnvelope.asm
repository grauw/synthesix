;
; An AR envelope
;
AREnvelope: MACRO
	super:
		Modulation AREnvelope_NoteOn, AREnvelope_NoteOff, AREnvelope_Update
	attack:
		db 255 / 30  ; inverse speed
	release:
		db 255 / 30  ; inverse speed
	sign:
		db 0
	phase:
		db 0
	counter:
		db 0
	size:
	ENDM

	dw AREnvelope.size
AREnvelope_class: AREnvelope

; iy = this
AREnvelope_NoteOn:
	ld (iy + AREnvelope.phase),0
	ld (iy + AREnvelope.counter),0
	ret

; iy = this
AREnvelope_NoteOff:
	ld (iy + AREnvelope.phase),-1
	ret

; iy = this
; a <- value
AREnvelope_Update:
	bit 7,(iy + AREnvelope.phase)  ; to test a third phase: rlc (iy) ; jp po
	jr nz,AREnvelope_UpdateRelease
	jp AREnvelope_UpdateAttack

; iy = this
; a <- value
AREnvelope_UpdateAttack:
	ld a,(iy + AREnvelope.counter)
	add a,(iy + AREnvelope.attack)
	jr c,AREnvelope_UpdateAttack_Complete
	ld (iy + AREnvelope.counter),a
	rra
	bit 0,(iy + AREnvelope.sign)
	ret z
	cpl
	ret
AREnvelope_UpdateAttack_Complete:
	ld (iy + AREnvelope.counter),255
	ld a,127
	bit 0,(iy + AREnvelope.sign)
	ret z
	cpl
	ret

; iy = this
; a <- value
AREnvelope_UpdateRelease:
	ld a,(iy + AREnvelope.counter)
	sub (iy + AREnvelope.release)
	jr c,AREnvelope_UpdateRelease_Complete
	ld (iy + AREnvelope.counter),a
	rra
	bit 0,(iy + AREnvelope.sign)
	ret z
	cpl
	ret
AREnvelope_UpdateRelease_Complete:
	ld (iy + AREnvelope.counter),0
	xor a
	bit 0,(iy + AREnvelope.sign)
	ret z
	cpl
	ret

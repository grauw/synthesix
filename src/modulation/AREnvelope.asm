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
	phase:
		db 0
	counter:
		db 0
	size:
	ENDM

	dw AREnvelope.size
AREnvelope_class: AREnvelope

; iy = this
; a <- value
AREnvelope_NoteOn:
	ld (iy + AREnvelope.phase),0
	ld (iy + AREnvelope.counter),0
	ld a,(iy + AREnvelope.attack)
	rra
	ret

; iy = this
; a <- value
AREnvelope_NoteOff:
	ld (iy + AREnvelope.phase),-1
	ld a,(iy + AREnvelope.counter)
	sub (iy + AREnvelope.release)
	rra
	ret nc
	xor a
	ret

; iy = this
; b = time delta
; a <- value
; b <- time delta
AREnvelope_Update:
	bit 7,(iy + AREnvelope.phase)  ; to test a third phase: rlc (iy) ; jp po
	jr nz,AREnvelope_UpdateRelease
	jp AREnvelope_UpdateAttack

; iy = this
; b = time delta
; a <- value
; b <- time delta
AREnvelope_UpdateAttack:
	ld a,(iy + AREnvelope.counter)
	ld h,b
AREnvelope_UpdateAttack_Loop:
	add a,(iy + AREnvelope.attack)
	jr c,AREnvelope_UpdateAttack_Complete
	djnz AREnvelope_UpdateAttack_Loop
	ld b,h
	ld (iy + AREnvelope.counter),a
	rra
	ret
AREnvelope_UpdateAttack_Complete:
	ld b,h
	ld (iy + AREnvelope.counter),255
	ld a,127
	ret

; iy = this
; b = time delta
; a <- value
; b <- time delta
AREnvelope_UpdateRelease:
	ld a,(iy + AREnvelope.counter)
	ld h,b
AREnvelope_UpdateRelease_Loop:
	sub (iy + AREnvelope.release)
	jr c,AREnvelope_UpdateRelease_Complete
	djnz AREnvelope_UpdateRelease_Loop
	ld b,h
	ld (iy + AREnvelope.counter),a
	rra
	ret
AREnvelope_UpdateRelease_Complete:
	ld b,h
	ld (iy + AREnvelope.counter),0
	xor a
	ret

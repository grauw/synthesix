;
; An AR envelope
;
AREnvelope: MACRO
	super:
		Modulation AREnvelope_NoteOn, AREnvelope_NoteOff, AREnvelope_Update
	attack:
		db 8
	release:
		db 8
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

; ix <- new class
AREnvelope_New:
	ld iy,AREnvelope_class
	call Class_New
	ret

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
; a <- value (one’s complement)
AREnvelope_Update:
	bit 7,(iy + AREnvelope.phase)  ; to test a third phase: rlc (iy) ; jp po
	jr nz,AREnvelope_UpdateRelease
	jp AREnvelope_UpdateAttack

; iy = this
; a <- value (one’s complement)
AREnvelope_UpdateAttack: PROC
	ld a,(iy + AREnvelope.counter)
	add a,(iy + AREnvelope.attack)
	jr c,Complete
	ld (iy + AREnvelope.counter),a
	rra
	bit 0,(iy + AREnvelope.sign)
	ret z
	cpl
	ret
Complete:
	ld (iy + AREnvelope.counter),255
	ld a,127
	bit 0,(iy + AREnvelope.sign)
	ret z
	cpl
	ret
	ENDP

; iy = this
; a <- value (one’s complement)
AREnvelope_UpdateRelease: PROC
	ld a,(iy + AREnvelope.counter)
	sub (iy + AREnvelope.release)
	jr c,Complete
	ld (iy + AREnvelope.counter),a
	rra
	bit 0,(iy + AREnvelope.sign)
	ret z
	cpl
	ret
Complete:
	ld (iy + AREnvelope.counter),0
	xor a
	bit 0,(iy + AREnvelope.sign)
	ret z
	cpl
	ret
	ENDP

;
; An AR envelope
;
AREnvelope: MACRO
	attack:
		db 255 / 30  ; inverse speed
	release:
		db 255 / 30  ; inverse speed
	envelopePhase:
		db 0
	envelopeCounter:
		db 0
	size:
	ENDM

	dw AREnvelope.size
AREnvelope_class: AREnvelope

; ix = this
AREnvelope_NoteOn:
	ld (ix + AREnvelope.envelopeCounter),0
	ld b,1
	call AREnvelope_UpdateAttack
	ld (ix + AREnvelope.envelopeCounter),0
	ld (ix + AREnvelope.envelopePhase),0
	ret

; ix = this
AREnvelope_NoteOff:
	ld c,(ix + AREnvelope.envelopeCounter)
	ld b,1
	call AREnvelope_UpdateRelease
	ld (ix + AREnvelope.envelopeCounter),c
	ld (ix + AREnvelope.envelopePhase),-1
	ret

; ix = this
; b = time delta
; a <- envelope value
; b <- time delta
AREnvelope_Update:
	bit 7,(ix + AREnvelope.envelopePhase)  ; to test a third phase: rlc (ix) ; jp po
	jr nz,AREnvelope_UpdateRelease
	jp AREnvelope_UpdateAttack

; ix = this
; b = time delta
; a <- envelope value
; b <- time delta
AREnvelope_UpdateAttack:
	ld a,(ix + AREnvelope.envelopeCounter)
	ld h,b
AREnvelope_UpdateAttack_Loop:
	add a,(ix + AREnvelope.attack)
	jr c,AREnvelope_UpdateAttack_Complete
	djnz AREnvelope_UpdateAttack_Loop
	ld b,h
	ld (ix + AREnvelope.envelopeCounter),a
	rra
	ret
AREnvelope_UpdateAttack_Complete:
	ld b,h
	ld (ix + AREnvelope.envelopeCounter),255
	ld a,127
	ret

; ix = this
; b = time delta
; a <- envelope value
; b <- time delta
AREnvelope_UpdateRelease:
	ld a,(ix + AREnvelope.envelopeCounter)
	ld h,b
AREnvelope_UpdateRelease_Loop:
	sub (ix + AREnvelope.release)
	jr c,AREnvelope_UpdateRelease_Complete
	djnz AREnvelope_UpdateRelease_Loop
	ld b,h
	ld (ix + AREnvelope.envelopeCounter),a
	rra
	ret
AREnvelope_UpdateRelease_Complete:
	ld b,h
	ld (ix + AREnvelope.envelopeCounter),0
	ld a,0
	ret

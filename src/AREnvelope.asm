;
; An AR envelope
;
	dw AREnvelope_size
AREnvelope:
AREnvelope_attack: equ $ - AREnvelope
	db 255 / 30  ; inverse speed
AREnvelope_release: equ $ - AREnvelope
	db 255 / 30  ; inverse speed
AREnvelope_envelopePhase: equ $ - AREnvelope
	db 0
AREnvelope_envelopeCounter: equ $ - AREnvelope
	db 0
AREnvelope_size: equ $ - AREnvelope

; ix = this
AREnvelope_NoteOn:
	ld (ix + AREnvelope_envelopeCounter),0
	ld b,1
	call AREnvelope_UpdateAttack
	ld (ix + AREnvelope_envelopeCounter),0
	ld (ix + AREnvelope_envelopePhase),0
	ret

; ix = this
AREnvelope_NoteOff:
	ld c,(ix + AREnvelope_envelopeCounter)
	ld b,1
	call AREnvelope_UpdateRelease
	ld (ix + AREnvelope_envelopeCounter),c
	ld (ix + AREnvelope_envelopePhase),-1
	ret

; ix = this
; b = time delta
; a <- envelope value
; b <- time delta
AREnvelope_Update:
	bit 7,(ix + AREnvelope_envelopePhase)  ; to test a third phase: rlc (ix) ; jp po
	jr nz,AREnvelope_UpdateRelease
	jp AREnvelope_UpdateAttack

; ix = this
; b = time delta
; a <- envelope value
; b <- time delta
AREnvelope_UpdateAttack:
	ld a,(ix + AREnvelope_envelopeCounter)
	ld h,b
AREnvelope_UpdateAttack_Loop:
	add a,(ix + AREnvelope_attack)
	jr c,AREnvelope_UpdateAttack_Complete
	djnz AREnvelope_UpdateAttack_Loop
	ld b,h
	ld (ix + AREnvelope_envelopeCounter),a
	rra
	ret
AREnvelope_UpdateAttack_Complete:
	ld b,h
	ld (ix + AREnvelope_envelopeCounter),255
	ld a,127
	ret

; ix = this
; b = time delta
; a <- envelope value
; b <- time delta
AREnvelope_UpdateRelease:
	ld a,(ix + AREnvelope_envelopeCounter)
	ld h,b
AREnvelope_UpdateRelease_Loop:
	sub (ix + AREnvelope_release)
	jr c,AREnvelope_UpdateRelease_Complete
	djnz AREnvelope_UpdateRelease_Loop
	ld b,h
	ld (ix + AREnvelope_envelopeCounter),a
	rra
	ret
AREnvelope_UpdateRelease_Complete:
	ld b,h
	ld (ix + AREnvelope_envelopeCounter),0
	ld a,0
	ret

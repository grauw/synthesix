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

; iy = this
ADEnvelope_NoteOn:
	ld (iy + ADEnvelope.phase),0
	ld (iy + ADEnvelope.counter),0
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
	ld (iy + ADEnvelope.super.value),a
	bit 0,(iy + ADEnvelope.sign)
	ret z
	cpl
	ld (iy + ADEnvelope.super.value),a
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
	ld (iy + ADEnvelope.super.value),a
	bit 0,(iy + ADEnvelope.sign)
	ret z
	cpl
	ld (iy + ADEnvelope.super.value),a
	ret
Complete:
	ld (iy + ADEnvelope.counter),255
	ld (iy + ADEnvelope.super.value),0
	bit 0,(iy + ADEnvelope.sign)
	ret z
	ld (iy + ADEnvelope.super.value),~0
	ret
	ENDP

;
; An attack-decay envelope
;
EnvelopeAD: MACRO
	outputs:
	value:
		Value 0
	outputsEnd:
	inputs:
	attack:
		dw Constants_instance + 127
	decay:
		dw Constants_instance + 4
	trigger:
		dw Constants_instance + 0
	inputsEnd:
	sign:
		db 0
	phase:
		db -1
	counter:
		db 0
	labels: equ EnvelopeAD_labels
	_size:
	ENDM

	dw EnvelopeAD._size
EnvelopeAD_class: EnvelopeAD

; ix, de <- new object
EnvelopeAD_New:
	ld iy,EnvelopeAD_class
	call Class_New
	call EnvelopeAD_Constructor
	ret

; ix = this
; ix, de <- this
EnvelopeAD_Constructor:
	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Updater_60Hz
	ld hl,EnvelopeAD_Update
	call Updater_AddListener
	pop ix
	ret

; ix = this
EnvelopeAD_Reset:
	ld (ix + EnvelopeAD.phase),0
	ld (ix + EnvelopeAD.counter),0
	ret

; ix = this
EnvelopeAD_Update:
	ld l,(ix + EnvelopeAD.trigger)
	ld h,(ix + EnvelopeAD.trigger + 1)
	bit 6,(hl)
	call nz,EnvelopeAD_Reset
	bit 7,(ix + EnvelopeAD.phase)  ; to test a third phase: rlc (ix) ; jp po
	jr nz,EnvelopeAD_UpdateDecay
	jp EnvelopeAD_UpdateAttack

; ix = this
EnvelopeAD_UpdateAttack: PROC
	ld a,(ix + EnvelopeAD.counter)
	ld l,(ix + EnvelopeAD.attack)
	ld h,(ix + EnvelopeAD.attack + 1)
	add a,(hl)
	ld (ix + EnvelopeAD.counter),a
	jr c,Complete
	rra
	ld (ix + EnvelopeAD.value),a
	bit 0,(ix + EnvelopeAD.sign)
	ret z
	cpl
	ld (ix + EnvelopeAD.value),a
	ret
Complete:
	ld (ix + EnvelopeAD.phase),-1
	ld a,255
	and a
	jp EnvelopeAD_UpdateDecay.ContinueFromAttack
	ENDP

; ix = this
EnvelopeAD_UpdateDecay: PROC
	ld a,(ix + EnvelopeAD.counter)
	ld l,(ix + EnvelopeAD.decay)
	ld h,(ix + EnvelopeAD.decay + 1)
	sub (hl)
	jr c,Complete
ContinueFromAttack:
	ld (ix + EnvelopeAD.counter),a
	rra
	ld (ix + EnvelopeAD.value),a
	bit 0,(ix + EnvelopeAD.sign)
	ret z
	cpl
	ld (ix + EnvelopeAD.value),a
	ret
Complete:
	ld (ix + EnvelopeAD.counter),0
	ld (ix + EnvelopeAD.value),0
	bit 0,(ix + EnvelopeAD.sign)
	ret z
	ld (ix + EnvelopeAD.value),~0
	ret
	ENDP

;
EnvelopeAD_labels:
	db "AD envelope",0
	db "Value",0
	db "Attack",0
	db "Decay",0
	db "Trigger",0

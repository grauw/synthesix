;
; An attack-release envelope
;
EnvelopeAR: MACRO
	value:
		Value 0
	attack:
		dw Value_values.32
	release:
		dw Value_values.8
	gate:
		dw Value_values.0
	trigger:
		dw Value_values.0
	sign:
		db 0
	counter:
		db 0
	size:
	ENDM

	dw EnvelopeAR.size
EnvelopeAR_class: EnvelopeAR

; ix, de <- new object
EnvelopeAR_New:
	ld iy,EnvelopeAR_class
	call Class_New
	call EnvelopeAR_Constructor
	ret

; ix = this
; ix, de <- this
EnvelopeAR_Constructor:
	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Clock_60Hz
	ld hl,EnvelopeAR_Update
	call Clock_AddListener
	pop ix
	ret

; ix = this
EnvelopeAR_Reset:
	ld (ix + EnvelopeAR.counter),0
	ret

; ix = this
EnvelopeAR_Update:
	ld l,(ix + EnvelopeAR.trigger)
	ld h,(ix + EnvelopeAR.trigger + 1)
	bit 6,(hl)
	call nz,EnvelopeAR_Reset
	ld l,(ix + EnvelopeAR.gate)
	ld h,(ix + EnvelopeAR.gate + 1)
	bit 6,(hl)
	jr z,EnvelopeAR_UpdateRelease
	jp EnvelopeAR_UpdateAttack

; ix = this
EnvelopeAR_UpdateAttack: PROC
	ld a,(ix + EnvelopeAR.counter)
	ld l,(ix + EnvelopeAR.attack)
	ld h,(ix + EnvelopeAR.attack + 1)
	add a,(hl)
	jr c,Complete
	ld (ix + EnvelopeAR.counter),a
	rra
	ld (ix + EnvelopeAR.value),a
	bit 0,(ix + EnvelopeAR.sign)
	ret z
	cpl
	ld (ix + EnvelopeAR.value),a
	ret
Complete:
	ld (ix + EnvelopeAR.counter),255
	ld (ix + EnvelopeAR.value),127
	bit 0,(ix + EnvelopeAR.sign)
	ret z
	ld (ix + EnvelopeAR.value),~127
	ret
	ENDP

; ix = this
EnvelopeAR_UpdateRelease: PROC
	ld a,(ix + EnvelopeAR.counter)
	ld l,(ix + EnvelopeAR.release)
	ld h,(ix + EnvelopeAR.release + 1)
	sub (hl)
	jr c,Complete
	ld (ix + EnvelopeAR.counter),a
	rra
	ld (ix + EnvelopeAR.value),a
	bit 0,(ix + EnvelopeAR.sign)
	ret z
	cpl
	ld (ix + EnvelopeAR.value),a
	ret
Complete:
	ld (ix + EnvelopeAR.counter),0
	ld (ix + EnvelopeAR.value),0
	bit 0,(ix + EnvelopeAR.sign)
	ret z
	ld (ix + EnvelopeAR.value),~0
	ret
	ENDP

;
; A logical hold operator
;
; Prevents a gate signal from going low if hold is high.
; A value between 0 and 63 is considered low.
;
Sustain: MACRO
	outputs:
	value:
		Value 0
	outputsEnd:
	inputs:
	gate:
		dw Value_values.0
	hold:
		dw Value_values.0
	inputsEnd:
	_size:
	ENDM

	dw Sustain._size
Sustain_class: Sustain

; ix, de <- new object
Sustain_New:
	ld iy,Sustain_class
	call Class_New
	call Sustain_Constructor
	ret

; ix = this
; ix, de <- this
Sustain_Constructor:
	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Clock_60Hz
	ld hl,Sustain_Update
	call Clock_AddListener
	pop ix
	ret

; ix = this
Sustain_Update: PROC
	ld l,(ix + Sustain.gate)
	ld h,(ix + Sustain.gate + 1)
	ld a,(hl)
	cp 40H
	jr nc,Set
	ld e,a
	ld l,(ix + Sustain.hold)
	ld h,(ix + Sustain.hold + 1)
	ld a,(hl)
	cp 40H
	ret nc
	ld a,e
Set:
	ld (ix + Sustain.value),a
	ret
	ENDP

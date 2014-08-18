;
; A dividing counter (aka clock divider)
;
DivCounter: MACRO
	outputs:
	counter:
		Value 0
	tally:
		Value 0
	overflow:
		Value 0
	outputsEnd:
	inputs:
	trigger:
		dw Constants_instance + 127
	maximum:
		dw Constants_instance + 0
	reset:
		dw Constants_instance + 0
	inputsEnd:
	labels: equ DivCounter_labels
	_size:
	ENDM

	dw DivCounter._size
DivCounter_class: DivCounter

; ix, de <- new object
DivCounter_New:
	ld iy,DivCounter_class
	call Class_New
	call DivCounter_Constructor
	ret

; ix = this
; ix, de <- this
DivCounter_Constructor:
	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Updater_60Hz
	ld hl,DivCounter_Update
	call Updater_AddListener
	pop ix
	ret

; ix = this
DivCounter_Update: PROC
	ld l,(ix + MultCounter.reset)
	ld h,(ix + MultCounter.reset + 1)
	bit 6,(hl)
	call nz,Reset
	ld l,(ix + DivCounter.trigger)
	ld h,(ix + DivCounter.trigger + 1)
	bit 6,(hl)
	ret z
	ld a,(ix + DivCounter.counter)
	inc a
	jr z,IncrementOverflow
	ld l,(ix + DivCounter.maximum)
	ld h,(ix + DivCounter.maximum + 1)
	sub (hl)
	jr c,NoOverflow
	ld (ix + DivCounter.counter),a
	ld (ix + DivCounter.overflow),127
	inc (ix + DivCounter.tally)
	ret
NoOverflow:
	add a,(hl)
	ld (ix + DivCounter.counter),a
	ld (ix + DivCounter.overflow),0
	ret
IncrementOverflow:
	ld (ix + DivCounter.counter),a
	ld (ix + DivCounter.overflow),127
	inc (ix + DivCounter.tally)
	ret
Reset:
	ld (ix + MultCounter.counter),0
	ld (ix + MultCounter.tally),0
	ret
	ENDP

;
DivCounter_labels:
	db "Div Counter",0
	db "Counter",0
	db "Tally",0
	db "Overflow",0
	db "Trigger",0
	db "Maximum",0
	db "Reset",0

;
; A multiplying counter
;
MultCounter: MACRO
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
	increment:
		dw Constants_instance + 0
	reset:
		dw Constants_instance + 0
	inputsEnd:
	labels: equ MultCounter_labels
	_size:
	ENDM

	dw MultCounter._size
MultCounter_class: MultCounter

; ix, de <- new object
MultCounter_New:
	ld iy,MultCounter_class
	call Class_New
	call MultCounter_Constructor
	ret

; ix = this
; ix, de <- this
MultCounter_Constructor:
	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Clock_60Hz
	ld hl,MultCounter_Update
	call Clock_AddListener
	pop ix
	ret

; ix = this
MultCounter_Update: PROC
	ld l,(ix + MultCounter.reset)
	ld h,(ix + MultCounter.reset + 1)
	bit 6,(hl)
	call nz,Reset
	ld l,(ix + MultCounter.trigger)
	ld h,(ix + MultCounter.trigger + 1)
	bit 6,(hl)
	ret z
	ld a,(ix + MultCounter.counter)
	ld l,(ix + MultCounter.increment)
	ld h,(ix + MultCounter.increment + 1)
	add a,(hl)
	jp c,Overflow
	ld (ix + MultCounter.counter),a
	ld (ix + MultCounter.overflow),0
	ret
Overflow:
	ld (ix + MultCounter.counter),a
	inc (ix + MultCounter.tally)
	ld (ix + MultCounter.overflow),127
	ret
Reset:
	ld (ix + MultCounter.counter),0
	ld (ix + MultCounter.tally),0
	ret
	ENDP

;
MultCounter_labels:
	db "Clock Divider",0
	db "Counter",0
	db "Tally",0
	db "Overflow",0
	db "Trigger",0
	db "Increment",0
	db "Reset",0

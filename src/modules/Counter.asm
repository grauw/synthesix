;
; A counter (aka clock divider)
;
Counter: MACRO
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
	maximum:
		dw Constants_instance + 0
	inputsEnd:
	labels: equ Counter_labels
	_size:
	ENDM

	dw Counter._size
Counter_class: Counter

; ix, de <- new object
Counter_New:
	ld iy,Counter_class
	call Class_New
	call Counter_Constructor
	ret

; ix = this
; ix, de <- this
Counter_Constructor:
	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Clock_60Hz
	ld hl,Counter_Update
	call Clock_AddListener
	pop ix
	ret

; ix = this
Counter_Update: PROC
	ld l,(ix + Counter.trigger)
	ld h,(ix + Counter.trigger + 1)
	bit 6,(hl)
	ret z
	ld a,(ix + Counter.counter)
	ld l,(ix + Counter.increment)
	ld h,(ix + Counter.increment + 1)
	add a,(hl)
	call c,IncrementOverflow
	ld l,(ix + Counter.maximum)
	ld h,(ix + Counter.maximum + 1)
	ld b,(hl)
	rl b
	rr b
	jp z,Done
RepeatSub:
	sub b
	jr c,Done
	ld (ix + Counter.overflow),127
	inc (ix + Counter.tally)
	jp RepeatSub
Done:
	add a,b
	ld (ix + Counter.counter),a
	ld (ix + Counter.overflow),0
	ret
IncrementOverflow:


	ld (ix + Counter.overflow),127
	inc (ix + Counter.tally)

	; if maximum = 0: add 1 to tally
	; if maximum = 1: add 256 to tally
	; if maximum = 2: add 128 to tally
	; if maximum = 3: add 85 to tally + 1 remainder
	; if maximum = 4: add 64 to tally
	; push af ; ld a,100H; sub
	ret
	ENDP

;
Counter_labels:
	db "Clock Divider",0
	db "Counter",0
	db "Tally",0
	db "Overflow",0
	db "Trigger",0
	db "Increment",0
	db "Maximum",0

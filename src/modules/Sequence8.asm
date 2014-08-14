;
; An 8-step sequence
;
Sequence8: MACRO
	outputs:
	value:
		Value 0
	position:
		Value 0
	outputsEnd:
	inputs:
	trigger:
		dw Constants_instance + 0
	length:
		dw Constants_instance + 0
	reset:
		dw Constants_instance + 0
	steps:
		REPT 8
		dw Constants_instance + 0
		ENDM
	inputsEnd:
	labels: equ Sequence8_labels
	_size:
	ENDM

	dw Sequence8._size
Sequence8_class: Sequence8

; ix, de <- new object
Sequence8_New:
	ld iy,Sequence8_class
	call Class_New
	call Sequence8_Constructor
	ret

; ix = this
; ix, de <- this
Sequence8_Constructor:
	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Clock_60Hz
	ld hl,Sequence8_Update
	call Clock_AddListener
	pop ix
	ret

; ix = this
Sequence8_Update: PROC
	ld l,(ix + Sequence8.reset)
	ld h,(ix + Sequence8.reset + 1)
	bit 6,(hl)
	jr z,NoReset
	ld (ix + Sequence8.position),0
NoReset:
	ld l,(ix + Sequence8.trigger)
	ld h,(ix + Sequence8.trigger + 1)
	bit 6,(hl)
	ret z
	ld a,(ix + Sequence8.position)
	push ix
	add a,a
	ld c,a
	ld b,0
	add ix,bc
	ld l,(ix + Sequence8.steps)
	ld h,(ix + Sequence8.steps + 1)
	ld a,(hl)
	pop ix
	ld (ix + Sequence8.value),a
	ld a,(ix + Sequence8.position)
	inc a
	and 7
	ld l,(ix + Sequence8.length)
	ld h,(ix + Sequence8.length + 1)
	cp (hl)
	jr nz,NoLoop
	xor a
NoLoop:
	ld (ix + Sequence8.position),a
	ret
	ENDP

;
Sequence8_labels:
	db "Sequence 8",0
	db "Value",0
	db "Position",0
	db "Trigger",0
	db "Length",0
	db "Reset",0
	db "Step 0",0
	db "Step 1",0
	db "Step 2",0
	db "Step 3",0
	db "Step 4",0
	db "Step 5",0
	db "Step 6",0
	db "Step 7",0

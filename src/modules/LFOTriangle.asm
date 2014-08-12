;
; A triangle LFO
;
LFOTriangle: MACRO
	outputs:
	value:
		Value 0
	outputsEnd:
	inputs:
	speed:
		dw Constants_instance + 2
	reset:
		dw Constants_instance + 0
	inputsEnd:
	counter:
		db 0
	labels: equ LFOTriangle_labels
	_size:
	ENDM

	dw LFOTriangle._size
LFOTriangle_class: LFOTriangle

; ix, de <- new object
LFOTriangle_New:
	ld iy,LFOTriangle_class
	call Class_New
	call LFOTriangle_Constructor
	ret

; ix = this
; ix, de <- this
LFOTriangle_Constructor:
	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Clock_60Hz
	ld hl,LFOTriangle_Update
	call Clock_AddListener
	pop ix
	ret

; ix = this
LFOTriangle_Reset:
	ld (ix + LFOTriangle.counter),0
	ret

; ix = this
LFOTriangle_Update: PROC
	ld l,(ix + LFOTriangle.reset)
	ld h,(ix + LFOTriangle.reset + 1)
	bit 6,(hl)
	call nz,LFOTriangle_Reset
	ld l,(ix + LFOTriangle.speed)
	ld h,(ix + LFOTriangle.speed + 1)
	ld a,(ix + LFOTriangle.counter)
	add a,(hl)
	ld (ix + LFOTriangle.counter),a
	jp p,Positive
	cpl
Positive:
	ld (ix + LFOTriangle.value),a
	ret
	ENDP

;
LFOTriangle_labels:
	db "Tri LFO",0
	db "Value",0
	db "Speed",0
	db "Reset",0

;
; A triangle LFO
;
LFOTriangle: MACRO
	value:
		Value 0
	speed:
		db 2
	trigger:
		dw Value_values.0
	counter:
		db 0
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
	ld l,(ix + LFOTriangle.trigger)
	ld h,(ix + LFOTriangle.trigger + 1)
	bit 6,(hl)
	call nz,LFOTriangle_Reset
	ld a,(ix + LFOTriangle.counter)
	add a,(ix + LFOTriangle.speed)
	ld (ix + LFOTriangle.counter),a
	jp p,Positive
	cpl
Positive:
	ld (ix + LFOTriangle.value),a
	ret
	ENDP

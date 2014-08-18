;
; An 8-step selector
;
Select8: MACRO
	outputs:
	value:
		Value 0
	outputsEnd:
	inputs:
	position:
		dw Constants_instance + 0
	steps:
		REPT 8
		dw Constants_instance + 0
		ENDM
	inputsEnd:
	labels: equ Select8_labels
	_size:
	ENDM

	dw Select8._size
Select8_class: Select8

; ix, de <- new object
Select8_New:
	ld iy,Select8_class
	call Class_New
	call Select8_Constructor
	ret

; ix = this
; ix, de <- this
Select8_Constructor:
	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Updater_60Hz
	ld hl,Select8_Update
	call Updater_AddListener
	pop ix
	ret

; ix = this
Select8_Update: PROC
	ld l,(ix + Select8.position)
	ld h,(ix + Select8.position + 1)
	ld a,(hl)
	and 7
	push ix
	add a,a
	ld c,a
	ld b,0
	add ix,bc
	ld l,(ix + Select8.steps)
	ld h,(ix + Select8.steps + 1)
	ld a,(hl)
	pop ix
	ld (ix + Select8.value),a
	ret
	ENDP

;
Select8_labels:
	db "Select 8",0
	db "Value",0
	db "Position",0
	db "Step 0",0
	db "Step 1",0
	db "Step 2",0
	db "Step 3",0
	db "Step 4",0
	db "Step 5",0
	db "Step 6",0
	db "Step 7",0

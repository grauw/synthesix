Clock: MACRO
	value:
		dw 0
	listeners: Listeners 32
	ENDM

; ix = this
Clock_Update:
	ld a,(ix + Clock.value)
	inc a
	ld (ix + Clock.value),a
	jp nc,Clock_UpdateListeners
	ld a,(ix + Clock.value + 1)
	inc a
	ld (ix + Clock.value + 1),a
	jp Clock_UpdateListeners

; ix = this
Clock_UpdateListeners:
	ld bc,Clock.listeners.Update
	add ix,bc
	jp ix

; ix = this
; Remaining parameters are the same as Listeners_AddListener
Clock_AddListener:
	push ix
	ld bc,Clock.listeners
	add ix,bc
	call Listeners_AddListener
	pop ix
	ret

;
	SECTION RAM

Clock_60Hz:
	Clock

Clock_60HzLate:
	Clock

	ENDS

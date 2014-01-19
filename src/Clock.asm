Clock: MACRO
	value:
		dw 0
	listeners: Listeners
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
Clock_AddListener:
	ld bc,Clock.listeners
	add ix,bc
	call Listeners_AddListener
	ret

;
	SECTION RAM

Clock_60Hz:
	Clock

	ENDS

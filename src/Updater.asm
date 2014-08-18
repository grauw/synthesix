Updater: MACRO
	value:
		dw 0
	listeners: Listeners 64
	ENDM

; ix = this
Updater_Update:
	ld a,(ix + Updater.value)
	inc a
	ld (ix + Updater.value),a
	jp nc,Updater_UpdateListeners
	ld a,(ix + Updater.value + 1)
	inc a
	ld (ix + Updater.value + 1),a
	jp Updater_UpdateListeners

; ix = this
Updater_UpdateListeners:
	ld bc,Updater.listeners.Update
	add ix,bc
	jp ix

; ix = this
; Remaining parameters are the same as Listeners_AddListener
Updater_AddListener:
	push ix
	ld bc,Updater.listeners
	add ix,bc
	call Listeners_AddListener
	pop ix
	ret

;
	SECTION RAM

Updater_60Hz:
	Updater

Updater_60HzLate:
	Updater

	ENDS

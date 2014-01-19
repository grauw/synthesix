Listeners: MACRO
	MAX_LISTENERS: equ 32
	size:
		db 0
	Update:
		REPT MAX_LISTENERS
		Listener
		ENDM
	ENDM

Listener: MACRO
	Update:
		ld iy,0
	object: equ $ - 2
	jump:
		jp Listeners_DefaultListener
	method: equ $ - 2
	size:
	ENDM

; ix = this
; de = object
; hl = callback
Listeners_AddListener: PROC
	ld a,(ix + Listeners.size)
	cp Listeners.MAX_LISTENERS
	call nc,System_ThrowException
	inc (ix + Listeners.size)
	call Listeners_GetListener
	and a
	jp z,First
	ld (ix + Listener.jump - Listener.size),0CDH  ; change previous jp to call
First:
	ld (ix + Listener.object),e
	ld (ix + Listener.object + 1),d
	ld (ix + Listener.method),l
	ld (ix + Listener.method + 1),h
	ret
	ENDP

; ix = this
; a = listener number
; ix <- listener
; Modifies: bc
Listeners_GetListener:
	ld bc,Listeners.Update
	add ix,bc
	ld c,a
	ld b,0
	REPT 7  ; ix += bc * Listener.size
	add ix,bc
	ENDM
	ret

Listeners_DefaultListener:
	ret

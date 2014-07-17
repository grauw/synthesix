;
; Display a virtual keyboard
;
UIChannel: MACRO
	super: UINode UIChannel_Update
	channel:
		dw 0
	size:
	ENDM

	dw UIChannel.size
UIChannel_class: UIChannel

; ix = parent
; de = y / x coordinate
; hl = channel
; ix <- instance
UIChannel_New:
	push ix
	push hl
	push de
	ld iy,UIChannel_class
	call Class_New
	pop de
	pop hl
	pop iy
	call UIChannel_Constructor
	ret

; ix = parent
; de = y / x coordinate
; hl = channel
; de <- instance
UIChannel_New_DE:
	call UIChannel_New
	ld e,ixl
	ld d,ixh
	ret

; ix = this
; hl = channel
UIChannel_Constructor:
	ld (ix + UIChannel.channel),l
	ld (ix + UIChannel.channel + 1),h
	push hl
	call UINode_SetBuffer
	pop hl

	push hl
	ld hl,UIChannel_background
	ld de,0000H
	ld bc,0610H
	call UINode_CopyToBuffer
	pop hl
	ret

; ix = this
UIChannel_Update:
	ld e,(ix + UIChannel.channel)
	ld d,(ix + UIChannel.channel + 1)
	ld iyl,e
	ld iyh,d

	ld de,010AH
	call UINode_GetBufferPosition
	ld a,(iy + Channel.program)
	call UIValue_Paint

	ld de,020AH
	call UINode_GetBufferPosition
	ld a,(iy + Channel.channelPressure)
	call UIValue_Paint

	ld de,030AH
	call UINode_GetBufferPosition
	ld a,(iy + Channel.pitchBendCoarse)
	call UIValue_Paint

	ld de,040AH
	call UINode_GetBufferPosition
	ld a,(iy + Channel.pitchBendFine)
	call UIValue_Paint
	ret

;
UIChannel_background:
	db 24,23,23,23," Channel ",23,23,25
	db 22," Program 0000 ",28
	db 22," C.Press 0000 ",28
	db 22," Bend C  0000 ",28
	db 22," Bend F  0000 ",28
	db 26,23,23,23,23,23,23,23,23,23,23,23,23,23,23,27

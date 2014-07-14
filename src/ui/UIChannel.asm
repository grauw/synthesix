;
; Display a virtual keyboard
;
UIChannel: MACRO
	super: UINode UIChannel_Update
	channel:
		dw 0
	program:
		dw 0
	channelPressure:
		dw 0
	pitchBendFine:
		dw 0
	pitchBendCoarse:
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

	push hl
	push ix
	ld bc,Channel.program
	add hl,bc
	ld de,010AH
	call UIValue_New_DE
	pop ix
	pop hl
	ld (ix + UIChannel.program),e
	ld (ix + UIChannel.program + 1),d

	push hl
	push ix
	ld bc,Channel.channelPressure
	add hl,bc
	ld de,020AH
	call UIValue_New_DE
	pop ix
	pop hl
	ld (ix + UIChannel.channelPressure),e
	ld (ix + UIChannel.channelPressure + 1),d

	push hl
	push ix
	ld bc,Channel.pitchBendCoarse
	add hl,bc
	ld de,030AH
	call UIValue_New_DE
	pop ix
	pop hl
	ld (ix + UIChannel.pitchBendCoarse),e
	ld (ix + UIChannel.pitchBendCoarse + 1),d

	push hl
	push ix
	ld bc,Channel.pitchBendFine
	add hl,bc
	ld de,040AH
	call UIValue_New_DE
	pop ix
	pop hl
	ld (ix + UIChannel.pitchBendFine),e
	ld (ix + UIChannel.pitchBendFine + 1),d
	ret

; ix = this
UIChannel_Update:
	ld e,(ix + UIChannel.program)
	ld d,(ix + UIChannel.program + 1)
	call UINode_Update_DE

	ld e,(ix + UIChannel.channelPressure)
	ld d,(ix + UIChannel.channelPressure + 1)
	call UINode_Update_DE

	ld e,(ix + UIChannel.pitchBendCoarse)
	ld d,(ix + UIChannel.pitchBendCoarse + 1)
	call UINode_Update_DE

	ld e,(ix + UIChannel.pitchBendFine)
	ld d,(ix + UIChannel.pitchBendFine + 1)
	call UINode_Update_DE
	ret

;
UIChannel_background:
	db 24,23,23,23," Channel ",23,23,25
	db 22," Program 0000 ",22
	db 22," C.Press 0000 ",22
	db 22," Bend C  0000 ",22
	db 22," Bend F  0000 ",22
	db 26,23,23,23,23,23,23,23,23,23,23,23,23,23,23,27

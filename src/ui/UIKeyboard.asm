;
; Display a virtual keyboard
;
UIKeyboard: MACRO
	super: UINode UIKeyboard_Update
	channel:
		dw 0
	pitchBend:
		dw 0
	size:
	ENDM

	dw UIKeyboard.size
UIKeyboard_class: UIKeyboard

; ix = parent
; de = y / x coordinate
; hl = channel
; ix <- instance
UIKeyboard_New:
	push ix
	push hl
	push de
	ld iy,UIKeyboard_class
	call Class_New
	pop de
	pop hl
	pop iy
	call UIKeyboard_Constructor
	ret

; ix = parent
; de = y / x coordinate
; hl = channel
; de <- instance
UIKeyboard_New_DE:
	call UIKeyboard_New
	ld e,ixl
	ld d,ixh
	ret

; ix = this
; hl = channel
UIKeyboard_Constructor:
	ld (ix + UIKeyboard.channel),l
	ld (ix + UIKeyboard.channel + 1),h
	push hl
	call UINode_SetBuffer
	pop hl

	push hl
	ld hl,UIKeyboard_background
	ld de,0000H
	ld bc,0250H
	call UINode_CopyToBuffer
	pop hl

	push ix
	push hl
	ld bc,Channel.pitchBendCoarse
	add hl,bc
	ld de,0100H
	call UIValue_New_DE
	pop hl
	pop ix
	ld (ix + UIKeyboard.pitchBend),e
	ld (ix + UIKeyboard.pitchBend + 1),d
	ret

; ix = this
UIKeyboard_Update:
	ld e,(ix + UIKeyboard.pitchBend)
	ld d,(ix + UIKeyboard.pitchBend + 1)
	call UINode_Update_DE

	call UIKeyboard_UpdateKeys
	ret

; ix = this
UIKeyboard_UpdateKeys: PROC
	ld e,(ix + UIKeyboard.channel)
	ld d,(ix + UIKeyboard.channel + 1)
	ld iyl,e
	ld iyh,d
	ld c,(iy + Channel.keys)
	ld b,(iy + Channel.keys + 1)
	ld e,(ix + UINode.buffer)
	ld d,(ix + UINode.buffer + 1)
	ld hl,5
	add hl,de
	ex de,hl
	ld hl,80
	add hl,de
	call Octave  ; -2
	call Octave  ; -1
	call Octave  ;  0
	call Octave  ;  1
	call Octave  ;  2
	call Octave  ;  3
	call Octave  ;  4
	call Octave  ;  5
	call Octave  ;  6
	call Octave  ;  7
	call LastOctave
	ret
Octave:
	call Key  ; c
	ex de,hl
	call Key  ; c#
	ex de,hl
	call Key  ; d
	ex de,hl
	call Key  ; d#
	ex de,hl
	call Key  ; e
	inc de
	call Key  ; f
	ex de,hl
	call Key  ; f#
	ex de,hl
	call Key  ; g
	ex de,hl
	call Key  ; g#
	ex de,hl
	call Key  ; a
	ex de,hl
	call Key  ; a#
	ex de,hl
	call Key  ; b
	inc de
	ret
LastOctave:
	call Key  ; c
	ex de,hl
	call Key  ; c#
	ex de,hl
	call Key  ; d
	ex de,hl
	call Key  ; d#
	ex de,hl
	call Key  ; e
	inc de
	call Key  ; f
	ex de,hl
	call Key  ; f#
	ex de,hl
	call Key  ; g
	ret
Key:
	ld a,(bc)
	inc bc
	and a
	jr nz,KeyPressed
	res 0,(hl)
	inc hl
	ret
KeyPressed:
	set 0,(hl)
	inc hl
	ret
	ENDP

;
UIKeyboard_background:
	db "Bend ",10,12,14,10,12,12,14,10,12,14,10,12,12,14,10,12,14,10,12,12,14,10,12,14,10,12,12,14,10,12,14,10,12,12,14
	db 10,12,14,10,12,12,14,10,12,14,10,12,12,14,10,12,14,10,12,12,14,10,12,14,10,12,12,14,10,12,14,10,12,12,14,10,12,14,10,14
	db "     ",8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8
	db 8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8

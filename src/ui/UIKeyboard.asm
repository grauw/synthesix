;
; Display a virtual keyboard
;
; iy = channel
; hl = buffer
UIKeyboard_Paint:
	push hl
	ex de,hl
	ld hl,UIKeyboard_background
	ld bc,0250H
	call UIBuffer_CopyToBuffer
	pop hl

	push hl
	ld de,0100H
	call UIBuffer_GetRelativePosition
	ld a,(iy + Channel.pitchBendCoarse)
	call UIValue_Paint
	pop hl

	push hl
	call UIKeyboard_UpdateKeys
	pop hl
	ret

; iy = channel
; hl = buffer
UIKeyboard_UpdateKeys: PROC
	ld c,(iy + Channel.keys)
	ld b,(iy + Channel.keys + 1)
	ld de,5
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

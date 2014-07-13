;
; Display a virtual keyboard
;
UIVoice: MACRO
	super: UINode UIVoice_Update
	voice:
		dw 0
	key:
		dw 0
	velocity:
		dw 0
	trigger:
		dw 0
	gate:
		dw 0
	size:
	ENDM

	dw UIVoice.size
UIVoice_class: UIVoice

; ix = parent
; de = x / y coordinate
; hl = voice
; ix <- instance
UIVoice_New:
	push ix
	push hl
	push de
	ld iy,UIVoice_class
	call Class_New
	pop de
	pop hl
	pop iy
	call UIVoice_Constructor
	ret

; ix = parent
; de = x / y coordinate
; hl = voice
; de <- instance
UIVoice_New_DE:
	call UIVoice_New
	push iy
	ex (sp),ix
	pop de
	ret

; ix = this
; hl = voice
UIVoice_Constructor:
	ld (ix + UIVoice.voice),l
	ld (ix + UIVoice.voice + 1),h
	push hl
	call UINode_SetBuffer
	pop hl

	push hl
	ld hl,UIVoice_background
	ld de,0000H
	ld bc,1006H
	call UINode_CopyToBuffer
	pop hl

	push hl
	push ix
	ld bc,Voice.key
	add hl,bc
	ld de,010AH
	call UIValue_New_DE
	pop ix
	pop hl
	ld (ix + UIVoice.key),e
	ld (ix + UIVoice.key + 1),d

	push hl
	push ix
	ld bc,Voice.velocity
	add hl,bc
	ld de,020AH
	call UIValue_New_DE
	pop ix
	pop hl
	ld (ix + UIVoice.velocity),e
	ld (ix + UIVoice.velocity + 1),d

	push hl
	push ix
	ld bc,Voice.trigger
	add hl,bc
	ld de,030AH
	call UIValue_New_DE
	pop ix
	pop hl
	ld (ix + UIVoice.trigger),e
	ld (ix + UIVoice.trigger + 1),d

	push hl
	push ix
	ld bc,Voice.gate
	add hl,bc
	ld de,040AH
	call UIValue_New_DE
	pop ix
	pop hl
	ld (ix + UIVoice.gate),e
	ld (ix + UIVoice.gate + 1),d
	ret

; ix = this
UIVoice_Update:
	ld e,(ix + UIVoice.key)
	ld d,(ix + UIVoice.key + 1)
	call UINode_Update_DE

	ld e,(ix + UIVoice.velocity)
	ld d,(ix + UIVoice.velocity + 1)
	call UINode_Update_DE

	ld e,(ix + UIVoice.trigger)
	ld d,(ix + UIVoice.trigger + 1)
	call UINode_Update_DE

	ld e,(ix + UIVoice.gate)
	ld d,(ix + UIVoice.gate + 1)
	call UINode_Update_DE
	ret

;
UIVoice_background:
	db 24,23,23,23,23," Voice ",23,23,23,25
	db 22," Key     0000 ",22
	db 22," Velocit 0000 ",22
	db 22," Trigger 0000 ",22
	db 22," Gate    0000 ",22
	db 26,23,23,23,23,23,23,23,23,23,23,23,23,23,23,27

VDP_PORT_0: equ 98H
VDP_PORT_1: equ 99H
VDP_PORT_2: equ 9AH
VDP_PORT_3: equ 9BH

VDP_READ: equ 00000000B
VDP_WRITE: equ 01000000B
VDP_REGISTER: equ 10000000B

VDP_MIRROR_0: equ 0F3DFH
VDP_MIRROR_8: equ 0FFE7H - 8
VDP_MIRROR_25: equ 0FFFAH - 25

VDP_InitScreen0:
	ld a,80
	ld (LINL40),a
	call INITXT
	ret

VDP_Enable212Lines:
	ld a,(VDP_MIRROR_8 + 9)
	or 10000000B
	ld (VDP_MIRROR_8 + 9),a
	out (VDP_PORT_1),a
	ld a,VDP_REGISTER | 9
	out (VDP_PORT_1),a
	ret

; hl = address bits 0-15
; a = address bit 16
VDP_SetReadAddress:
	rlc h
	rla
	rlc h
	rla
	srl h
	srl h
	di
	out (VDP_PORT_1),a
	ld a,VDP_REGISTER | 14
	out (VDP_PORT_1),a
VDP_SetReadAddress14Bit:
	ld a,l
	nop
	out (VDP_PORT_1),a
	ld a,h
	or VDP_READ
	ei
	out (VDP_PORT_1),a
	ret

; hl = address bits 0-15
; a = address bit 16
VDP_SetWriteAddress:
	rlc h
	rla
	rlc h
	rla
	srl h
	srl h
	di
	out (VDP_PORT_1),a
	ld a,VDP_REGISTER | 14
	out (VDP_PORT_1),a
VDP_SetWriteAddress14Bit:
	ld a,l
	nop
	out (VDP_PORT_1),a
	ld a,h
	or VDP_WRITE
	ei
	out (VDP_PORT_1),a
	ret

; hl = source address
; bc = byte count
; Modifies: af
VDP_Read:
	ld a,b
	inc a
	ld b,c
	ld c,VDP_PORT_0
VDP_Read_Loop:
	inir
	dec a
	jp nz,VDP_Read_Loop
	ret

; hl = source address
; bc = byte count
; Modifies: af
VDP_Write:
	ld a,b
	inc a
	ld b,c
	ld c,VDP_PORT_0
VDP_Write_Loop:
	otir
	dec a
	jp nz,VDP_Write_Loop
	ret

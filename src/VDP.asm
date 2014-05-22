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

VDP_InitScreen0: PROC
	ld a,80
	ld (LINL40),a
	ld a,(IDBYT2)
	and a
	jr z,MSX1
	call INITXT
	ret
MSX1: ; complicated dance to enable TEXT 2 mode on MSX1 computers with v9938
	ld hl,1000H              ; increase pattern generator table address
	ld (TXTCGP),hl           ; so that it isn’t overwritten in 80x26.5 mode
	call INITXT
	ld a,(VDP_MIRROR_0)      ; change TEXT1 to TEXT2 mode
	or 4
	ld (VDP_MIRROR_0),a
	ld b,0
	call VDP_SetRegister
	ld a,(VDP_MIRROR_0 + 2)  ; without this we get masking
	or 3
	ld (VDP_MIRROR_0 + 2),a
	ld b,2
	call VDP_SetRegister
	ret
	ENDP

VDP_Enable212Lines:
	ld a,(VDP_MIRROR_8 + 9)
	or 10000000B
	ld (VDP_MIRROR_8 + 9),a
	ld b,9
	call VDP_SetRegister
	ret

;
; Test if the VDP is a TMS9918A.
;
; The VDP ID number was only introduced in the V9938, so we have to use a
; different method to detect the TMS9918A. In V9938 status register 2, bits 5
; and 6 (HR and VR) get set periodically, whereas the TMS9918A has only one
; status register whose bits 5 and 6 (5S and C) remain zero as long as we don’t
; show any sprites. So, we simply wait for bits 5 or 6 to go high and we know
; the VDP is a V9938 or higher. To not wait forever, we stop when bit 7 goes
; high, which is the vertical blanking interrupt flag on the TMS9918A and the
; TR flag on the V9938 which will remain 0 after we’ve reset it.
;
; f <- z: TMS9918A, nz: V99X8
;
VDP_IsTMS9918A: PROC
	ld a,7
	di
	out (VDP_PORT_1),a
	ld a,15 + 128
	out (VDP_PORT_1),a
	nop
	nop
	in a,(VDP_PORT_1)  ; reset TR flag if it was set
	ld a,2
	out (VDP_PORT_1),a
	ld a,15 + 128
	out (VDP_PORT_1),a
	nop
	nop
Loop:
	in a,(VDP_PORT_1)
	and 11100000B
	add a,a
	jp nz,Done
	jp nc,Loop
Done:
	ex af,af'
	xor a
	out (VDP_PORT_1),a
	ld a,15 + 128
	ei
	out (VDP_PORT_1),a
	ex af,af'
	ret
	ENDP

; a = value
; b = register
; Modifies: af
VDP_SetRegister:
	di
	out (VDP_PORT_1),a
	ld a,b
	or VDP_REGISTER
	ei
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

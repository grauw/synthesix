; Konami SCC mapper
PSG_REGISTER_SELECT: equ 0A0H
PSG_WRITE: equ 0A1H
PSG_READ: equ 0A2H

PSG_TONE_GENERATOR_CONTROL: equ 0
PSG_NOISE_GENERATOR_CONTROL: equ 6
PSG_MIXER_CONTROL: equ 7
PSG_AMPLITUDE_CONTROL: equ 8
PSG_ENVELOPE_PERIOD_CONTROL: equ 11
PSG_ENVELOPE_SHAPE_CONTROL: equ 13

psg_init:
	ld b,14
	ld hl,psg_init_values
psg_init_loop:
	ld a,14
	sub b
	out (PSG_REGISTER_SELECT),a
	ld a,(hl)
	out (PSG_WRITE),a
	inc hl
	djnz psg_init_loop
	ret

psg_dump:
	ld b,14
psg_dump_loop:
	push bc
	ld a,14
	sub b
	out (PSG_REGISTER_SELECT),a
	in a,(PSG_READ)
	call print_hex_a
	ld a," "
	call CHPUT
	pop bc
	djnz psg_dump_loop
	ret

; a = note number (0-127)
; b = velocity (0-127)
; c = channel (0-2)
psg_note_on:
	; frequency
	ld h,psg_frequency_table / 100H
	ld l,a
	sla l
	ld a,PSG_TONE_GENERATOR_CONTROL
	out (PSG_REGISTER_SELECT),a
	ld a,(hl)
	inc hl
	out (PSG_WRITE),a
	ld a,PSG_TONE_GENERATOR_CONTROL + 1
	out (PSG_REGISTER_SELECT),a
	ld a,(hl)
	out (PSG_WRITE),a

	; volume
	ld a,PSG_AMPLITUDE_CONTROL
	out (PSG_REGISTER_SELECT),a
	ld h,psg_volume_table / 100H
	ld l,b
	ld a,(hl)
	out (PSG_WRITE),a

	; note on
	ld a,PSG_MIXER_CONTROL
	out (PSG_REGISTER_SELECT),a
	ld a,10111110B
	out (PSG_WRITE),a
	ret

; c = channel (0-2)
psg_note_off:
	ld a,PSG_MIXER_CONTROL
	out (PSG_REGISTER_SELECT),a
	ld a,10111111B
	out (PSG_WRITE),a
	ret

;
;
;

psg_init_values:
	db 0, 0, 0, 0, 0, 0  ; tone frequency (x3)
	db 0                 ; noise frequency
	db 10111111B         ; mixer control 1, 0, noise (x3), tone (x3)
	db 0, 0, 0           ; level (x3)
	db 0BH, 00H          ; envelope frequency
	db 0B8H              ; envelope shape

	ALIGN 100H
psg_frequency_table:
	INCLUDE "psgftable.asm"

	ALIGN 100H
psg_volume_table:
	db  0,  1,  3,  4,  5,  6,  6,  7,  7,  7,  8,  8,  8,  8,  9,  9
	db  9,  9,  9,  9, 10, 10, 10, 10, 10, 10, 10, 10, 11, 11, 11, 11
	db 11, 11, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 12, 12, 12, 12
	db 12, 12, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 13, 13, 13, 13
	db 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 14, 14, 14
	db 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14
	db 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 15, 15, 15
	db 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15

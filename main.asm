;
; Synthesix
;
; MIDI synthesizer for MSX
;

	org 4000H

	db "AB"
	dw main
	ds 12

helloString:
	db "Hello world!", 0

main:
	ld hl,helloString
	
main_loop:
	ld a,(hl)
	call CHPUT
	inc hl
	and a
	jp nz,main_loop
	
halt_loop:
	halt
	jp halt_loop
	
	
	
	
	
	
	
	
	ds 0C000H - $
	
CHPUT equ 0A2H

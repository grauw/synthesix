main:
	call INITXT
	ld hl,hello_message
	call print

	call ram_init

	call psg_init
	ld a,69
	ld bc,7F00H
	call psg_note_on

	call scc_init
	ld hl,square_wave
	call scc_load_waveform
	ld a,69
	ld bc,7F00H
	call scc_note_on

	ld hl,done_message
	call println

	ld hl,0
	add hl,sp
	call print_hex_hl
	jp stop

ram_init:
	ld hl,ram_data_start
	ld de,ram_data_start_address
	ld bc,ram_data_size
	ldir
	ret

hello_message:
	db "Synthesix\r\n\nMIDI synthesizer for MSX\r\n", 0

done_message:
	db "Done.", 0

ram_data_start:
	include "ram.symbol"
	incbin "ram.bin"
ram_data_size: equ $ - ram_data_start

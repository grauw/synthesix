keys_init:
	ld a,0
	ld (CLIKSW),a  ; disable key click
	call keys_scan_update_last
	ret

keys_scan:
	ld de,NEWKEY
	ld hl,keys_last_scan
	ld ix,keys_note_mapping
	REPT 6  ; just the first 6 rows...
	call keys_process_row
	ENDM
keys_scan_update_last:
	ld hl,NEWKEY
	ld de,keys_last_scan
	REPT 6
	ldi
	ENDM
	ret

keys_process_row:
	ld b,8
	ld a,(de)
	ld c,(hl)
	xor c
	rrc c
keys_process_row_loop:
	rlc c
	rlca       ; does not affect sign register
	call c,keys_process_row_press
	inc ix
	djnz keys_process_row_loop
	inc de
	inc hl
	ret

keys_process_row_press:
	jp p,keys_process_row_release
	push af
	ld a,(ix)
	and a
	jp p,keys_process_row_press_note
	pop af
	ret
keys_process_row_release:
	push af
	ld a,(ix)
	and a
	jp p,keys_process_row_release_note
	pop af
	ret
keys_process_row_press_note:
	push bc
	push de
	push hl
	push ix
	ld bc,7F00H
	call scc_note_on
	pop ix
	pop hl
	pop de
	pop bc
	pop af
	ret
keys_process_row_release_note:
	push bc
	push de
	push hl
	push ix
	ld bc,4000H
	call scc_note_off
	pop ix
	pop hl
	pop de
	pop bc
	pop af
	ret

keys_note_mapping:
	db 58, 56, 54, -1, 51, 49, -1, 63  ; row 0: 7 6 5 4 3 2 1 0
	db 75, 67, 65, 68, 66, -1, 61, -1  ; row 1: ; ] [ \ = - 9 8
	db 67, -1, -1, 76, 74, 72, -1, -1  ; row 2: B A DEAD / . , ` '
	db 70, 60, 68, 66, -1, 52, 63, 64  ; row 3: J I H G F E D C
	db 53, 48, 64, 62, 69, 71, 73, -1  ; row 4: R Q P O N M L K
	db 60, 57, 62, 50, 65, 59, 55, 61  ; row 4: Z Y X W V U T S
	db -1, -1, -1, -1, -1, -1, -1, -1  ; row 4: F3 F2 F1 CODE CAPS GRAPH CTRL SHIFT
	db -1, -1, -1, -1, -1, -1, -1, -1  ; row 4: RET SELECT BS STOP TAB ESC F5 F4
	db -1, -1, -1, -1, -1, -1, -1, -1  ; row 4: → ↓ ↑ ← DEL INS HOME SPACE
	db -1, -1, -1, -1, -1, -1, -1, -1  ; row 4: NUM4 NUM3 NUM2 NUM1 NUM0 NUM/ NUM+ NUM*
	db -1, -1, -1, -1, -1, -1, -1, -1  ; row 4: NUM. NUM, NUM- NUM9 NUM8 NUM7 NUM6 NUM5

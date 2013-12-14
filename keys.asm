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
keys_process_row_loop:
	rrc c
	rrca       ; does not affect sign register
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
	db 63, -1, 49, 51, -1, 54, 56, 58  ; row 0: 0 1 2 3 4 5 6 7
	db -1, 61, -1, 66, 68, 65, 67, 75  ; row 1: 8 9 - = \ [ ] ;
	db -1, -1, 72, 74, 76, -1, -1, 67  ; row 2: ' ` , . / DEAD A B
	db 64, 63, 52, -1, 66, 68, 60, 70  ; row 3: C D E F G H I J
	db -1, 73, 71, 69, 62, 64, 48, 53  ; row 4: K L M N O P Q R
	db 61, 55, 59, 65, 50, 62, 57, 60  ; row 4: S T U V W X Y Z
	db -1, -1, -1, -1, -1, -1, -1, -1  ; row 4: SHIFT CTRL GRAPH CAPS CODE F1 F2 F3
	db -1, -1, -1, -1, -1, -1, -1, -1  ; row 4: F4 F5 ESC TAB STOP BS SELECT RET
	db -1, -1, -1, -1, -1, -1, -1, -1  ; row 4: SPACE HOME INS DEL ← ↑ ↓ →
	db -1, -1, -1, -1, -1, -1, -1, -1  ; row 4: NUM* NUM+ NUM/ NUM0 NUM1 NUM2 NUM3 NUM4
	db -1, -1, -1, -1, -1, -1, -1, -1  ; row 4: NUM5 NUM6 NUM7 NUM8 NUM9 NUM- NUM, NUM.

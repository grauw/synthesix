;
; Keyboard MIDI
;
; And other key handling.
;
KeyMidi: MACRO
	super: MidiIn MidiIn_buffer1
	lastScan:
		ds 11,0
	velocity:
		db 7FH
	keyBufferHead:
		dw KeyMidi_keyBuffer
	keyBufferTail:
		dw KeyMidi_keyBuffer
	escape:
		db 0
	shift:
		db 0
	ENDM

; ix = this
KeyMidi_Constructor:
	ld a,0
	ld (CLIKSW),a  ; disable key click
	ld e,ixl
	ld d,ixh
	ld hl,KeyMidi.lastScan
	add hl,de
	ex de,hl
	ld hl,NEWKEY
	ld bc,11
	ldir
	ret

; ix = this
; a = byte
; f <- z: buffer full
; Modifies: af, hl
KeyMidi_WriteKeyCode:
	ld l,(ix + KeyMidi.keyBufferHead)
	ld h,(ix + KeyMidi.keyBufferHead + 1)
	ld (hl),a
	inc l
	ld (ix + KeyMidi.keyBufferHead),l
	ld a,(ix + KeyMidi.keyBufferTail)
	cp l
	ret nz
	call System_ThrowException
	ret

; ix = this
; a <- byte
; f <- z: buffer empty
; Modifies: af, hl
KeyMidi_ReadKeyCode:
	ld l,(ix + KeyMidi.keyBufferTail)
	ld h,(ix + KeyMidi.keyBufferTail + 1)
	ld a,(ix + KeyMidi.keyBufferHead)
	cp l
	ret z
	ld a,(hl)
	inc l
	ld (ix + KeyMidi.keyBufferTail),l
	ret

; ix = this
KeyMidi_Scan:
	ld e,ixl
	ld d,ixh
	ld hl,KeyMidi.lastScan
	add hl,de
	ld de,KeyMidi_noteMapping
	REPT 11, ?row
	ld b,?row
	call KeyMidi_ProcessRow
	ENDM
	ret

; ix = this
KeyMidi_ProcessRow:
	di
	in a,(PPI_PORT_C)
	and 11110000B
	or b
	out (PPI_PORT_C),a
	ei
	in a,(PPI_PORT_B)
	ld c,(hl)
	ld (hl),a
	inc hl
	xor c
	jr z,KeyMidi_ProcessRow_NoChange
	ld b,8
KeyMidi_ProcessRow_Loop:
	rrc c
	rrca       ; preserves sign flag
	jp nc,KeyMidi_ProcessRow_Next
	push af
	push bc
	push de
	push hl
	push ix
	ld a,(de)
	call KeyMidi_ProcessKeyChange
	pop ix
	pop hl
	pop de
	pop bc
	pop af
KeyMidi_ProcessRow_Next:
	inc de
	djnz KeyMidi_ProcessRow_Loop
	ret
KeyMidi_ProcessRow_NoChange:
	ld a,e
	add a,8
	ld e,a
	ret nc
	inc d
	ret

; ix = this
; a = key / note identifier
; f = negative sign: press, positive sign: release
KeyMidi_ProcessKeyChange:
	jp p,KeyMidi_ProcessKeyRelease
	jp KeyMidi_ProcessKeyPress

; ix = this
; a = key / note identifier
KeyMidi_ProcessKeyPress:
	and a
	jp p,KeyMidi_PressNote
	cp -6
	jp z,KeyMidi_PressSpace
	cp -99
	jp z,KeyMidi_PressEscape
	cp -98
	jp z,KeyMidi_PressShift
	cp -1
	jp nz,KeyMidi_KeyCodePress
	ret

; ix = this
; a = key / note identifier
KeyMidi_ProcessKeyRelease:
	and a
	jp p,KeyMidi_ReleaseNote
	cp -6
	jp z,KeyMidi_ReleaseSpace
	cp -98
	jp z,KeyMidi_ReleaseShift
	ret

; ix = this
KeyMidi_PressNote:
	ld b,a
	ld a,(ix + KeyMidi.velocity)
	ld c,a
	ld a,0
	call MidiIn_NoteOn
	ret

; ix = this
KeyMidi_ReleaseNote:
	ld b,a
	ld c,40H
	ld a,0
	call MidiIn_NoteOff
	ret

; ix = this
; a = key identifier
KeyMidi_KeyCodePress:
	neg
	jp KeyMidi_WriteKeyCode

; ix = this
KeyMidi_PressEscape:
	ld a,-1
	ld (ix + KeyMidi.escape),a
	ret

; ix = this
KeyMidi_PressShift:
	ld a,-1
	ld (ix + KeyMidi.shift),a
	ret

; ix = this
KeyMidi_ReleaseShift:
	ld a,0
	ld (ix + KeyMidi.shift),a
	ret

; ix = this
KeyMidi_PressSpace:
	ld b,1
	ld c,7FH
	ld a,0
	call MidiIn_ControlChange
	ret

; ix = this
KeyMidi_ReleaseSpace:
	ld b,1
	ld c,0
	ld a,0
	call MidiIn_ControlChange
	ret

KeyMidi_noteMapping:
	db   75,  -1,  61,  63,  -1,  66,  68,  70  ; row 0: 0 1 2 3 4 5 6 7
	db   -1,  73,  -1,  78,  56,  77,  79,  63  ; row 1: 8 9 - = \ [ ] ;
	db   -1,  -1,  60,  62,  64,  -1,  -1,  55  ; row 2: ' ` , . / DEAD A B
	db   52,  51,  64,  -1,  54,  56,  72,  58  ; row 3: C D E F G H I J
	db   -1,  61,  59,  57,  74,  76,  60,  65  ; row 4: K L M N O P Q R
	db   49,  67,  71,  53,  62,  50,  69,  48  ; row 5: S T U V W X Y Z
	db  -98,  -1,  -1,  -1,  -1,  -1,  -1,  -1  ; row 6: SHIFT CTRL GRAPH CAPS CODE F1 F2 F3
	db   -1, -99, -27,  -9,  -1,  -8, -24, -13  ; row 7: F4 F5 ESC TAB STOP BS SELECT RET
	db   -6, -11, -18,-127, -29, -30, -31, -28  ; row 8: SPACE HOME INS DEL ← ↑ ↓ →
	db   -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1  ; row 9: NUM* NUM+ NUM/ NUM0 NUM1 NUM2 NUM3 NUM4
	db   -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1  ; row A: NUM5 NUM6 NUM7 NUM8 NUM9 NUM- NUM, NUM.

;
; Variables in RAM
;
	SECTION RAM

KeyMidi_instance: KeyMidi

	ALIGN 100H
KeyMidi_keyBuffer:
	ds 256

	ENDS

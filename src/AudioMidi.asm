;
; MSX-AUDIO Keyboard MIDI
;
; The Philips NMS1160 61-key keyboard has a different key layout than the 49-key
; Toshiba HX-MU901 and Yamaha YK-01 / YK-10 / YK-20 keyboards.
;
; Additionally, the Toshiba keyboard has a “multi sensor” whose row selection is
; controlled by the IO0 and IO1 bits. On the Philips, IO0 is used to enable the
; DAC, so as long as the Toshiba is not detected, these are not touched.
;
; This implementation operates in Philips mode by default, and if a key which
; does not exist on the Philips keyboard is pressed, it switches to Toshiba
; mode. These are the last two keys, B6 and C6.
;
AudioMidi: MACRO
	super: MidiIn MidiIn_buffer1
	found:
		db 0
	toshiba:
		db 0
	lastScan:
		ds 10, 11111111B
	ENDM

; ix = this
AudioMidi_Constructor:
	in a,(0C0H)
	cp 06H
	ret nz
	ld (ix + AudioMidi.found),-1
	ret

; ix = this
AudioMidi_Scan:
	bit 0,(ix + AudioMidi.found)
	ret nz
	call AudioMidi_GetNoteMapping
	ld c,ixl
	ld b,ixh
	ld hl,AudioMidi.lastScan
	add hl,bc
	REPT 8, ?row
	ld bc,1 << ?row
	call AudioMidi_ReadRow
	call AudioMidi_ProcessRow
	ENDM
	bit 0,(ix + AudioMidi.toshiba)
	ret z
	ld bc,1 << 8
	call AudioMidi_ReadRow
	call AudioMidi_ProcessRow
	ld bc,1 << 9
	call AudioMidi_ReadRow
	call AudioMidi_ProcessRow
	ret

;
; Returns the note mapping to use.
;
; ix = this
; de <- Note mapping
; Modifies: af, bc
;
AudioMidi_GetNoteMapping:
	call AudioMidi_CheckKeyboardType
	ld de,AudioMidi_noteMappingPhilips
	ret z
	ld de,AudioMidi_noteMappingToshiba
	ret

;
; Checks whether the keyboard is a Philips or Toshiba one.
;
; ix = this
; f <- z: Philips, nz: Toshiba / Yamaha
; Modifies: af, bc
;
AudioMidi_CheckKeyboardType:
	bit 0,(ix + AudioMidi.toshiba)
	ret nz
	ld bc,1 << 7
	call AudioMidi_ReadRow
	cpl
	and 11100000B
	jp nz,AudioMidi_SwitchToToshiba
	ret

;
; Switch to Toshiba mode.
; It sets IO0 and IO1 for output, these control the sensor matrix rows.
;
; ix = this
; Modifies: bc
;
AudioMidi_SwitchToToshiba:
	push af
	ld (ix + AudioMidi.toshiba),-1
	; set IO0 and IO1 for output
	ld a,18H
	out (0C0H),a
	ld a,0011B
	out (0C1H),a
	; initialise IO0 and IO1
	ld a,19H
	out (0C0H),a
	ld a,0000B
	out (0C1H),a
	pop af
	ret

; bc = row mask
; a <- row bits
AudioMidi_ReadRow:
	ld a,19H
	out (0C0H),a
	ld a,b
	nop
	out (0C1H),a
	ld a,6
	out (0C0H),a
	ld a,c
	nop
	out (0C1H),a
	ld a,5
	out (0C0H),a
	nop
	nop
	in a,(0C1H)
	ret

; ix = this
; a = row
AudioMidi_ProcessRow:
	ld c,(hl)
	ld (hl),a
	inc hl
	xor c
	jr z,AudioMidi_ProcessRow_NoChange
	ld b,8
AudioMidi_ProcessRow_Loop:
	rrc c
	rrca       ; preserves sign flag
	jp nc,AudioMidi_ProcessRow_Next
	push af
	push bc
	push de
	push hl
	push ix
	ld a,(de)
	call AudioMidi_ProcessKeyChange
	pop ix
	pop hl
	pop de
	pop bc
	pop af
AudioMidi_ProcessRow_Next:
	inc de
	djnz AudioMidi_ProcessRow_Loop
	ret
AudioMidi_ProcessRow_NoChange:
	ld a,e
	add a,8
	ld e,a
	ret nc
	inc d
	ret

; ix = this
; a = key / note identifier
; f = negative sign: press, positive sign: release
AudioMidi_ProcessKeyChange:
	jp p,AudioMidi_ProcessKeyRelease
	jp AudioMidi_ProcessKeyPress

; ix = this
; a = key / note identifier
AudioMidi_ProcessKeyPress:
	and a
	jp p,AudioMidi_PressNote
	cp -2
	jp z,AudioMidi_PressEnter
	cp -3
	jp z,AudioMidi_PressStop
	ret

; ix = this
; a = key / note identifier
AudioMidi_ProcessKeyRelease:
	and a
	jp p,AudioMidi_ReleaseNote
	cp -2
	jp z,AudioMidi_ReleaseEnter
	cp -3
	jp z,AudioMidi_ReleaseStop
	ret

; ix = this
AudioMidi_PressEnter:
	ld b,1
	ld c,7FH
	ld a,0
	call MidiIn_ControlChange
	ret

; ix = this
AudioMidi_ReleaseEnter:
	ld b,1
	ld c,0
	ld a,0
	call MidiIn_ControlChange
	ret

; ix = this
AudioMidi_PressStop:
	ld b,64
	ld c,7FH
	ld a,0
	call MidiIn_ControlChange
	ret

; ix = this
AudioMidi_ReleaseStop:
	ld b,64
	ld c,0
	ld a,0
	call MidiIn_ControlChange
	ret

; ix = this
AudioMidi_PressNote:
	ld b,a
	ld c,7FH
	ld a,0
	call MidiIn_NoteOn
	ret

; ix = this
AudioMidi_ReleaseNote:
	ld b,a
	ld c,40H
	ld a,0
	call MidiIn_NoteOff
	ret

AudioMidi_noteMappingPhilips:
	db 36, 37, 38, 39, 40, 41, 42, 43  ; row 0: C 2 C#2 D 2 D#2 E 2 F 2 F#2 G 2
	db 44, 45, 46, 47, 48, 49, 50, 51  ; row 1: G#2 A 3 A#3 B 3 C 3 C#3 D 3 D#3
	db 52, 53, 54, 55, 56, 57, 58, 59  ; row 2: E 3 F 3 F#3 G 3 G#3 A 4 A#4 B 4
	db 60, 61, 62, 63, 64, 65, 66, 67  ; row 3: C 4 C#4 D 4 D#4 E 4 F 4 F#4 G 4
	db 68, 69, 70, 71, 72, 73, 74, 75  ; row 4: G#4 A 5 A#5 B 5 C 5 C#5 D 5 D#5
	db 76, 77, 78, 79, 80, 81, 82, 83  ; row 5: E 5 F 5 F#5 G 5 G#5 A 6 A#6 B 6
	db 84, 85, 86, 87, 88, 89, 90, 91  ; row 6: C 6 C#6 D 6 D#6 E 6 F 6 F#6 G 6
	db 92, 93, 94, 95, 96, -1, -1, -1  ; row 7: G#6 A 7 A#7 B 7 C 7 --- --- ---

AudioMidi_noteMappingToshiba:
	db 37, 38, 39, -1, 40, 41, 42, 36  ; row 0: C#2 D 2 D#2 --- E 2 F 2 F#2 C 2
	db 43, 44, 45, -1, 46, 47, 48, -1  ; row 1: G 2 G#2 A 3 --- A#3 B 3 C 3 ---
	db 49, 50, 51, -1, 52, 53, 54, -1  ; row 2: C#3 D 3 D#3 --- E 3 F 3 F#3 ---
	db 55, 56, 57, -1, 58, 59, 60, -1  ; row 3: G 3 G#3 A 4 --- A#4 B 4 C 4 ---
	db 61, 62, 63, -1, 64, 65, 66, -1  ; row 4: C#4 D 4 D#4 --- E 4 F 4 F#4 ---
	db 67, 68, 69, -1, 70, 71, 72, -1  ; row 5: G 4 G#4 A 5 --- A#5 B 5 C 5 ---
	db 73, 74, 75, -1, 76, 77, 78, -1  ; row 6: C#5 D 5 D#5 --- E 5 F 5 F#5 ---
	db 79, 80, 81, -1, 82, 83, 84, -1  ; row 7: G 5 G#5 A 6 --- A#6 B 6 C 6 ---
	db 86, 87, 88, 89, 90, -3, -2, 85  ; row 8: R2  R3  R4  R5  R6  STP ENT R1
	db 92, 93, 94, 95, 96, -1, -1, 91  ; row 9: R8  R9  R10 R11 R12 --- --- R7

;
; Variables in RAM
;
	SECTION RAM

AudioMidi_instance: AudioMidi

	ENDS

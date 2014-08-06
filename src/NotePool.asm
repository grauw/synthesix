;
; A note pool
;
; Pools notes for polyphonic playback.
;
; Implements first note priority algorithm: When a note is played it binds a
; note to it until it is released. When a note is bound, it will try the next
; one. If no notes are available, the note will be queued until one is.
;
NotePool: MACRO
	MAX_NOTES: equ 5
	MAX_QUEUEDNOTES: equ 5
	polyphony:
		db 0
	nextNote:
		db -1
	lastNote:
		db -1
	notes:
		REPT MAX_NOTES, ?note
		KeyNotePair
		ENDM
	queuedNoteCount:
		db 0
	queuedNotes:
		REPT MAX_QUEUEDNOTES
		QueuedNote
		ENDM
	_size:
	ENDM

KeyNotePair: MACRO
	key:
		db -1
	note:
		dw 0
	_size:
	ENDM

QueuedNote: MACRO
	key:
		db -1
	velocity:
		db 0
	_size:
	ENDM

	dw NotePool._size
NotePool_class: NotePool

; ix, de <- new object
NotePool_New:
	ld iy,NotePool_class
	call Class_New
	jp NotePool_Constructor

; ix = this
; ix, de <- this
NotePool_Constructor:
	ld e,ixl
	ld d,ixh
	ret

; ix = this
; b = note number (0-127)
; c = velocity (0-127)
; Modifies: af, de, hl, iy
NotePool_NoteOn: PROC
	ld a,(ix + NotePool.nextNote)
	cp (ix + NotePool.lastNote)
	jp z,NotePool_QueueNote
	push ix
	pop iy
	ld de,KeyNotePair._size
Loop:
	cp (iy + NotePool.notes + KeyNotePair.key)
	jr z,Found
	add iy,de  ; next note
	jp Loop
Found:
	ld (iy + NotePool.notes + KeyNotePair.key),b
	ld e,(iy + NotePool.notes + KeyNotePair.note)
	ld d,(iy + NotePool.notes + KeyNotePair.note + 1)
	dec a
	or 80H
	ld (ix + NotePool.nextNote),a
	ld ixl,e
	ld ixh,d
	jp Note_NoteOn
	ENDP

; ix = this
; b = note number (0-127)
; c = velocity (0-127)
; Modifies: af, bc, de, hl, iy
NotePool_NoteOff: PROC
	ld a,(ix + NotePool.polyphony)
	and a
	jp z,NotePool_UnqueueNote
	push ix
	pop iy
	ld l,a
	ld a,b
	ld de,KeyNotePair._size
Loop:
	cp (iy + NotePool.notes + KeyNotePair.key)
	jr z,Found
	add iy,de
	dec l
	jp nz,Loop
	jp NotePool_UnqueueNote
Found:
	call NotePool_PopQueuedNote
	jr nc,Replace
	ld a,(ix + NotePool.lastNote)
	ld (iy + NotePool.notes + KeyNotePair.key),a
	dec a
	or 80H
	ld (ix + NotePool.lastNote),a
	ld e,(iy + NotePool.notes + KeyNotePair.note)
	ld d,(iy + NotePool.notes + KeyNotePair.note + 1)
	ld ixl,e
	ld ixh,d
	jp Note_NoteOff
Replace:
	ld (iy + NotePool.notes + KeyNotePair.key),b
	ld e,(iy + NotePool.notes + KeyNotePair.note)
	ld d,(iy + NotePool.notes + KeyNotePair.note + 1)
	ld ixl,e
	ld ixh,d
	jp Note_NoteOn
	ENDP

; ix = this
; hl = note
; Modifies: af, bc
NotePool_AddNote:
	ld a,(ix + NotePool.polyphony)
	cp NotePool.MAX_NOTES
	call nc,System_ThrowException
	ld c,a
	add a,c  ; * KeyNotePair._size
	add a,c
	ld c,a
	ld b,0
	ld a,(ix + NotePool.lastNote)
	push ix
	add ix,bc
	ld (ix + NotePool.notes + KeyNotePair.key),a
	ld (ix + NotePool.notes + KeyNotePair.note),l
	ld (ix + NotePool.notes + KeyNotePair.note + 1),h
	pop ix
	dec a
	or 80H
	ld (ix + NotePool.lastNote),a
	inc (ix + NotePool.polyphony)
	ret

; ix = this
; b = note number (0-127)
; c = velocity (0-127)
; Modifies: af, de, ix
NotePool_QueueNote:
	ld a,(ix + NotePool.queuedNoteCount)
	cp NotePool.MAX_QUEUEDNOTES
	ret nc
	inc (ix + NotePool.queuedNoteCount)
	add a,a
	ld e,a
	ld d,0
	add ix,de
	ld (ix + NotePool.queuedNotes + QueuedNote.key),b
	ld (ix + NotePool.queuedNotes + QueuedNote.velocity),c
	ret

; ix = this
; b = note number (0-127)
; c = velocity (0-127)
; Modifies: af, de, ix
NotePool_UnqueueNote: PROC
	ld a,(ix + NotePool.queuedNoteCount)
	and a
	ret z
	dec (ix + NotePool.queuedNoteCount)
	ld e,a
	ld a,b
Loop:
	cp (ix + NotePool.queuedNotes + QueuedNote.key)
	jr z,Found
	inc ix
	inc ix
	dec e
	jp nz,Loop
	ret
Found:
	dec e
	ret z
	ld a,(ix + NotePool.queuedNotes + QueuedNote.key + QueuedNote._size)
	ld (ix + NotePool.queuedNotes + QueuedNote.key),a
	ld a,(ix + NotePool.queuedNotes + QueuedNote.velocity + QueuedNote._size)
	ld (ix + NotePool.queuedNotes + QueuedNote.velocity),a
	inc ix
	inc ix
	jp Found
	ENDP

; ix = this
; b <- note number (0-127)
; c <- velocity (0-127)
; f <- c: queue empty (bc not modified)
; Modifies: af, bc, de, ix
NotePool_PopQueuedNote:
	ld a,(ix + NotePool.queuedNoteCount)
	sub 1
	ret c
	ld (ix + NotePool.queuedNoteCount),a
	add a,a
	ld e,a
	ld d,0
	add ix,de
	ld b,(ix + NotePool.queuedNotes + QueuedNote.key)
	ld c,(ix + NotePool.queuedNotes + QueuedNote.velocity)
	ret

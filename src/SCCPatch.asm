;
; An SCC patch
;
SCCPatch: MACRO
	polyphony:
		db 4
	voicePool:
		dw 0
	size:
	ENDM

	dw SCCPatch.size
SCCPatch_class: SCCPatch

; ix <- new class
SCCPatch_New:
	ld iy,SCCPatch_class
	call Class_New
	jp SCCPatch_Constructor

; ix = this
; ix <- this
SCCPatch_Constructor: PROC
	push ix
	call VoicePool_New
	ld b,(ix + SCCPatch.polyphony)
Loop:
	push bc
	push ix
	call SCC_GetFreeVoice
	ex (sp),ix
	pop hl
	call VoicePool_AddVoice
	pop bc
	djnz Loop
	ld e,ixl
	ld d,ixh
	pop ix
	ld (ix + SCCPatch.voicePool),e
	ld (ix + SCCPatch.voicePool + 1),d
	ret
	ENDP

SCCPatch_GetVoicePool:
	ld e,(ix + SCCPatch.voicePool)
	ld d,(ix + SCCPatch.voicePool + 1)
	ld ixl,e
	ld ixh,d
	ret

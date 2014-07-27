;
; A module meta information object
;
ModuleType: MACRO ?acquirer
	acquirer:
		dw ?acquirer
	size:
	ENDM

; ix = this
; iy = patch
ModuleType_Acquire:
	ld l,(ix + ModuleType.acquirer)
	ld h,(ix + ModuleType.acquirer + 1)
	jp hl

; hl = this
; iy = patch
ModuleType_Acquire_HL:
	push hl
	pop ix
	ld l,(ix + ModuleType.acquirer)
	ld h,(ix + ModuleType.acquirer + 1)
	jp hl

;
; ModuleType definitions
;
ModuleType_values: ModuleType ModuleType_ValuesFactory

ModuleType_ValuesFactory:
	ld ix,Value_values
	ret

ModuleType_channel: ModuleType ModuleType_ChannelFactory

ModuleType_ChannelFactory:
	ld ix,Channel_channels.0
	ret

ModuleType_controllerBank: ModuleType ModuleType_ControllerBankFactory

ModuleType_ControllerBankFactory:
	ld ix,Channel_channels.0
	call Channel_GetControllerBank
	ret

ModuleType_note: ModuleType ModuleType_NoteFactory

; iy = Patch
ModuleType_NoteFactory:
	ld l,(iy + Patch.notePool)
	ld h,(iy + Patch.notePool + 1)
	push hl
	call Note_New
	ex (sp),ix
	pop hl
	push hl
	call NotePool_AddNote
	pop ix
	ret

ModuleType_sccVoice: ModuleType ModuleType_SCCVoiceFactory

ModuleType_SCCVoiceFactory:
	ld ix,(Synthesix_scc)
	call SCC_GetFreeVoice
	ret

ModuleType_envelopeAD: ModuleType EnvelopeAD_New

ModuleType_envelopeAR: ModuleType EnvelopeAR_New

ModuleType_lfoTriangle: ModuleType LFOTriangle_New

ModuleType_lfoTriangleSigned: ModuleType LFOTriangleSigned_New

ModuleType_attenuate: ModuleType Attenuate_New

ModuleType_attenuateAdd: ModuleType AttenuateAdd_New

ModuleType_pitchBend: ModuleType PitchBend_New

ModuleType_addPitch: ModuleType AddPitch_New

ModuleType_sustain: ModuleType Sustain_New

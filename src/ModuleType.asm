;
; A module meta information object
;
ModuleType: MACRO ?core, ?acquirer
	acquirer:
		dw ?acquirer
	size:
		db ?core._size
	outputs:
		db ?core.outputs
	outputCount:
		db ?core.outputsEnd - ?core.outputs
	inputs:
		db ?core.inputs
	inputCount:
		db (?core.inputsEnd - ?core.inputs) >> 1
	_size:
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
ModuleType_values: ModuleType Value, ModuleType_ValuesFactory

ModuleType_ValuesFactory:
	ld ix,Value_values
	ret

ModuleType_channel: ModuleType Channel, ModuleType_ChannelFactory

ModuleType_ChannelFactory:
	ld ix,Channel_channels.0
	ret

ModuleType_controllerBank: ModuleType ControllerBank, ModuleType_ControllerBankFactory

ModuleType_ControllerBankFactory:
	ld ix,Channel_channels.0
	call Channel_GetControllerBank
	ret

ModuleType_note: ModuleType Note, ModuleType_NoteFactory

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

ModuleType_sccVoice: ModuleType SCCVoice, ModuleType_SCCVoiceFactory

ModuleType_SCCVoiceFactory:
	ld ix,(Synthesix_scc)
	call SCC_GetFreeVoice
	ret

ModuleType_envelopeAD: ModuleType EnvelopeAD, EnvelopeAD_New

ModuleType_envelopeAR: ModuleType EnvelopeAR, EnvelopeAR_New

ModuleType_lfoTriangle: ModuleType LFOTriangle, LFOTriangle_New

ModuleType_lfoTriangleSigned: ModuleType LFOTriangleSigned, LFOTriangleSigned_New

ModuleType_attenuate: ModuleType Attenuate, Attenuate_New

ModuleType_attenuateAdd: ModuleType AttenuateAdd, AttenuateAdd_New

ModuleType_pitchBend: ModuleType PitchBend, PitchBend_New

ModuleType_addPitch: ModuleType AddPitch, AddPitch_New

ModuleType_sustain: ModuleType Sustain, Sustain_New

Synthesix - Modular MIDI synthesizer for MSX
============================================

Copyright 2013 Laurens Holst

Project information
-------------------

Author: Laurens Holst <laurens.nospam@grauw.nl>  
Site: <https://bitbucket.org/grauw/synthesix>  
Issues: <https://bitbucket.org/grauw/synthesix/issues>  
Support: <http://www.msx.org/forum/msx-talk/software/synthesix>  
License: Simplified BSD License

Synthesix is synthesizer for MSX sound chips. It lets you play and tweak your
MSX sound chips in real-time, using external MIDI controllers and DAW software.

Patches are edited in a modular sound design paradigm. This architecture lets
you insert modules which perform various functions into the control chain
between your MIDI keyboard and the sound chip. This gives you great and flexible
control over the sound that is played.


System Requirements
-------------------

  * MSX2, MSX2+, MSX turboR or MSX1 models with V9938 VDP
  * 16kB video RAM
  * 64kB main RAM
  * 64kB Konami 4/5 ROM


Supported output devices
------------------------

  * Konami SCC

Support for more sound chips will be added in the future.


Supported input devices
-----------------------

Synthesix currently supports the following input devices:

  * Internal MSX-MIDI (turboR GT)
  * External MSX-MIDI (µ-Pack), on all MSX models
  * Philips NMS-1205 Music Module MIDI
  * Yamaha SFG-01 / 05 FM Sound Synthesizer Unit MIDI
  * Philips NMS-1160 Music Keyboard, connected to NMS-1205
  * Toshiba HX-MU901 Music Keyboard, connected to HX-MU900 or FS-CA1
  * Yamaha YK-01/10/20 Music Keyboard, connected to HX-MU900 or FS-CA1
  * Computer alphanumeric keys

If you have another input device which you’d like to be supported, let me know
or file a ticket for it in the issue tracker.


Usage instructions
------------------

Synthesix can be loaded on an MSX using a Konami Snatcher SCC+ cartridge,
or compatible devices such as the MegaFlashROM SCC+ or the ESE Mega-SCC+
(built into the One Chip MSX).

When Synthesix boots you are presented with a list of modules, these are the
elementary building blocks of a sound. A specific configuration of modules is
called a *patch*. The simplest patch takes input from a Note source module, and
connects it to a Voice destination module.

A module has inputs and/or outputs. Inputs are indicated by notches on the left
and outputs have notches on the right. The modules are linked together by
defining virtual “patch cords” between their inputs and an outputs. How you
connect up the inputs determines the output of the module.

You can scroll through the modules with the cursor keys. Moving up and down
selects the module’s input and output ports. Select an input port of one module
and press `return` to make a connection. The cursor will move to the currently
connected output, and you can select a new one and press `return` again to
establish a new connection. The cursor will turn gray if you select a port which
is not an output, and you can press `escape` to cancel the selection.

You can also select an output port and press return to make a connection,
however as one output can be linked to no or multiple inputs, the cursor will
stay in place and turn gray until you select an input port to connect to.

Taking the simplest patch consisting of Note and SCCVoice modules as an example,
to produce the most primitive sound connect the SCCVoice.note input to the
Note.key output, and the SCCVoice.amplitude input to the Note.gate output.

Note that all inputs are always connected, if not to another module with
variable outputs, they are connected to a fixed value provided by the Constants
module. To disconnect an input from its current output, press the `backspace`
key and it will replace the connection with one to Constants. To quickly
increase / decrease a constant value press the `insert` and `delete` keys.
This will also replace it with a constant connection.

By default you see bars indicating the signed values, with the middle position
representing 0, however by pressing `caps lock` you can see the actual values
which range from -127 to +127. Because the values are one’s complement, there
are two representations of 0: -0 and +0, usually these are treated identically.

Some final notes; the polyphony of the patch is predefined to 4, this means that
for every module you see there are actually four copies operating independently,
one for each note / SCC voice. Essentially, there are 4 layers of modules.

Also, it is currently not possible to add or remove modules, so you are limited
to the pre-defined set of modules for your sonic exploration.

If you experience stuck notes, you can send a MIDI All Notes Off message or
press the `shift-F5` key combination.


Module information
------------------

**Constants** All 256 different unchanging output values.

**Channel** MIDI channel values. *Program* provides the currently selected
program. *C.Press* provides the channel pressure (aftertouch). Finally,
*Bend Course* and *Bend Fine* provide the pitch bend amount.

**Controllers** MIDI controller values.

**Note** MIDI note information for each note pressed. *Key* specifies the note
number, *Velocity* the note’s velocity, *Gate* indicates whether the key is
currently being pressed, *Trigger* provides an impulse when the note gets
pressed, and *Off velocity* provides the note-off velocity (a seldom-used MIDI
feature).

**AD envelope** A triggered attack-decay envelope function. *Attack* specifies
the speed at which the value increases, *Decay* the speed at which the value
decreases after the peak has been reached, *Trigger* connects to an impulse
which (re)starts the attack phase, and *Reset* resets the value, used if you
want retriggered in stead of legato envelopes.

**AR envelope** A gated attack-release envelope function. *Attack* specifies the
speed at which the value increases, *Release* the speed at which the value
decreases after the peak has been reached, *Gate* connects to a gate which will
keep the attack phase active until it goes low, and *Reset* resets the value,
used if you want retriggered in stead of legato envelopes.

**Sustain** Latches high gate values while held. *Gate* provides the gate value,
low (off) when below 40H, *Hold* specifies when the gate value needs to be held.
Typically connected to the sustain pedal (CC# 64).

**Mult counter** Increases a counter by a value for each trigger. *Trigger* makes
the counter increase, *Increment* specifies by how much the counter is
increased, *Reset* resets the counter if it receives an impulse, *Counter*
outputs the current counter value, *Tally* maintains a count of how often the
counter overflows, and *Overflow* generates an impulse every time the counter
overflows. If the trigger is connected to constant 127, the counter will run at
control rate (60 ticks per second).

**Sine wave bipolar** Takes a signed *Phase* input representing a -180 to 180
degrees phase, *Value* outputs the corresponding signed sine wave. Typically
phase is connected to a counter to generate a bipolar sine modulation.

**Triangle wave** Takes a signed *Phase* input representing a -180 to 180 degrees
phase, *Value* outputs the corresponding position of an unsigned triangle wave.
Typically phase is connected to a counter to generate a triangle modulation.

**Attenuate** Attenuates (weakens) a signal. The *Multiplicand* specifies the
value to attenuate, and the *Multiplier* the value to attenuate it with, *Value*
is the output. For example, attenuating value 0, 64 and 127 by 80 results in 0,
40 and 80 respectively.

**Attenu-add** Attenuates a signal and then adds a value. *Addend* specifies the
value to add after the attenuation, see attenuate for the description of the
remaining values. Typically used to coax an input value into a certain range,
e.g. n ⋅ 80 + 30 makes values 0-127 go between 30 and 110.

**Pitch bend** Translates a pitch bend value to a note range. *Bend coarse* and
*Bend fine* specify the signed input bend value, *Range Up* and *Range Down*
specify the range of the bend in the up and down directions, and *Note* and
*Detune* output the bended note and detune values. Typically connected to an
add-pitch module.

**Add pitch** Adds pairs of note and detune values. *Note A* and *Note B* specify
the notes to add, and *Detune A* and *Detune B* specify the detune values to
add. The result of the addition is found in *Node* and *Detune*. Typically
connected to a voice.

**MIDI clock** MIDI clock generator with divider functionality. *Port* selects
the source of the MIDI clock, 0 being the internal clock (fixed to 150 bpm).
*Divider* selects how many ticks it takes to trigger and increase the counter;
there are 24 ticks in an 1/4 beat, 12 ticks in an 1/8th beath, etc. *Trigger*
generates an impulse when the number of ticks were reached, *Counter* counts how
many impulses were generated and *Fraction* is the divider’s remainder.

**Sequence 8** Steps through a sequence of 8 *Steps* on every *Trigger* impulse.
*Length* indicates how many steps to step through before wrapping. *Reset*
restarts at step 0. *Value* outputs the value of the current step, and
*Position* counts the number of triggers, selected step is position modulo 8.

**SCC voice** Produces an SCC voice. *Note* selects the note, *Detune* specifies
a signed detune in the range -50 .. +50 cents. *Amplitude* specifies the
amplitude of the sound. *Wave* specifies which wave to choose from the
pre-defined 128-entry wave table. *Phase reset* restarts the wave’s phase.


Development information
-----------------------

Synthesix is free and open source software. If you want to contribute to the
project you are very welcome to. Please contact me at any one of the places
mentioned in the project information section.

You are also free to re-use code such as the MIDI support routines for your own
projects, provided you abide by the license terms.

Label naming convention:

  * Constants: UPPERCASE
  * Variables: Class_variableName
  * Methods: Class_MethodName
  * Method-local labels: Class_MethodName_localName

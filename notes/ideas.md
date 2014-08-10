Ideas
=====

General
-------

* Terminology
  * Control signal flow / chain
  * Trigger impulse
  * Control sampling rate (60Hz)
  * Module cores
  * Part, in stead of note pool

* Mode without UI updates to minimise latency
  * E.g. pressing STOP key; in stead, it will process MIDI messages
  * Window pops up informing the user while this mode is enabled
    * And telling him how to exit
  * Interrupt checks if buffer is empty, if not yields

* Connect to the cloud through MIDI and a PC host application

* Patch loading / saving
  * Save to spare cartridge FlashROM
  * Save to disk
  * Save to Sony HBI-55 / Yamaha UDC-01 Data Memory / PAC
  * Save to MIDI out (dump)
  * Save to cloud

* Put all core code in bank 1, all UI in bank 2, and shared stuff in bank 0
  * Create core folder to group them
  * UI should have no need to access the core code

* Deallocate / reallocate all objects when heap is fragmented

* Add MIDI implementation chart

* Submit v1.0 to synthtopia, sonicstate, gearslutz, createdigitalmusic, etc...


Synthesis core
--------------

* Simple module ideas
  * Mix, does simple 50/50 mix (see wt interp)
  * Parametrix mix, mixes based on control (-127..127), also useful for panning
  * S&H / latch, samples a value at trigger (default 127) or gate (default 0)
    * Hold, the same as sustain?
  * Threshold (if), outputs one value above and another below threshold
  * Threshold (gate), outputs gate signal above threshold
  * Inverter / negate / complement, toggles the sign
    * Logical values check bit 6, so negate doubles as not
  * Gate to trigger, generates a trigger at the rising slope, orr falling slope
    * Diff comparator / edge detector, signal if value - previous is positive
    * Rising Edge, Falling Edge
  * Value / thru, just repeats the input value
  * Counter, w/ max value and reset inputs, value, step and trigger outputs
    * Subdivision counter w/ MSB and LSB step
  * Swing counter
  * Difference counter, increases by the difference from last frame
  * Accumulator, w/ max value and reset inputs, and value and trigger outputs
  * Select (relay), selects one of several inputs based on value
    * Select (bool), select-4, select-8, select-16, select-32...
  * Sequence, same as select but triggered and with length parameter
    * Seq-2, seq-4, seq-8, seq-16, seq-32...
  * Switch, which switches two values based on gate (or trigger?)
  * Clip/min/max/clamp, passes through the highest or lowest of two values
  * Sign extend, outputs -127 or 127 based on the sign
  * Sine / cosine / tangent, input -pi..pi = -127..127 (LFOs)
  * Linear to parabolic, logarithmic, exponential, sine, and vice versa
    * Parametric to control amount?
  * Amplify, multiplies a value by a certain amount (in .5 db steps?)
  * Bipolar to unipolar, changes a value -127..127 to 0..127
  * Envelope follower, with attack/decay parameters
  * Peak detector, with decay time parameter
  * Clock divider, filters clock events by division ratio parameter
  * Clock generator, at the specified frequency (hmm…)
  * Clock period, estimates the period between triggers
  * Random generator, generate a random number on each trigger, seed, min/max
  * Saw (down) LFO
  * Complement, 1 - x, or -1 - x for negative values
  * Timer, schedule a trigger to occur some time in the future
    * Similar to divider w/ reset, but one-shot
  * Shift, left, right, signed, unsigned, with help text about multiply/divide
  * Rotate left, signed, unsigned, no carry, with help text about multiply
    * Parameterised versions as well
    * Show secondary purpose beneath heading in UI (e.g. Multiply 2)
  * Down-counter with reset and initial value
    * Up-counter should have initial value as well
    * Similarity to AD / AR?

* Typed links
  * Signed, unsigned, boolean, trigger, object
  * Poly, mono (rather a module property, isn’t it?)
  * Primitive type links are mostly useful for UI
  * Object type links have null object.

* Poly to mono
  * Indicate polyness on modules with notches in bottom right line
  * Auto-limit poly based on available resources (at least 1 of each)
  * Merge modules, merge-or, merge-max, add, average, interval, count, select
    * Useful for e.g. PSG envelope; merge-or the note trigger to its trigger
    * merge-halve, halves poly
  * Merge-halve, divides poly in half
  * Essentially these are array inputs

* Sound chip modules at the end of the chain! (poly to mono!)
  * Requires object links
  * Do these cross patches? Check settings and require them to match...

* NotePool parameters
  * Max polyphony, how many voices. Actual polyphony depends on resources.
  * Allocation, steal notes, priority, reuse, or round robin
  * Note memory, whether to remember excess and stolen notes or forget
  * New retrigger, whether a new note retriggers envelopes etc. or not
  * Old retrigger, whether an old note retriggers envelopes etc. or not
    * These determine what happens to trigger when a note gets overwritten
  * All of these parameters should ideally be linkable

* Note
  * Add note number

* Envelope segment curve selection; linear, log (attack), exp (decay)

* Numpad drumpad

* Sysex dump of current patch configuration
  * Including controller position
  * “A manufacturer must get a registered ID from the MMA if he wants to define
    his own SysEx messages, or use the following: Educational Use 0x7D. This ID
    is for educational or development use only, and should never appear in a
    commercial design.” <http://www.midi.org/techspecs/manid.php>

* Change LFOs so that they use a single phase input.

* Add poly pressure array to channel
  * Let notes pull from it
  * Should they take highest between channel and poly pressure?
    * Can also be done with a module...
    * Same goes for pitch bend

* When linking module A to B, make sure B is updated before A
  * Scan for module B, if A is found swap until B is reached

* Update listeners improvements
  * Replace update listeners with linked list on module cores? (like hooks)

* Rather than having channels, have parts which specify which port / channel /
  keys they listen to. Basically they filter, allowing you to create splits etc.
  The patch is contained inside the part.
  * Have note pool listeners register themselves on MIDI devices
  * Port number in addition to channel number

* Extraction modules, connecting to MIDI stream?
  * MIDI aftertouch, CC, etc. Only listen to what you need.
  * May not perform well...

* Don’t limit number of voice instances

* Course wavetable interpolation
  * Slow, but maybe convenient
  
      ld a,(bc)
      add a,(hl)
      rra
      ld (de),a
      inc l, c, e
  
      ld a,(bc)
      add a,(hl)
      rra
      add a,(hl)
      rra
      ld (de),a
      inc l, c, e

* Add note number to Note

* (MIDI) Clock module
  * Provides 8-bit timer and trigger outputs
  * Separate clock divider module?
  * Or multiple clocks with integrated divider? Or both?

* Packaging modules allows you to define new modules consisting of others
  * Name: “Composite module”, “Macro module” (Reaktor), “Patcher module” (Max)
  * The built-in modules are called primitive modules
  * Cleans up nicely
  * Allows for “hidden” values
  * Packages can be saved separately
  * Extra annotation on the inputs specifying the default value
    * Which can also be a nonconstant...

* Macro bank module
  * Combines 8 configurable controllers with attenuate-adds.

* Key release trigger

* Random generator source
  * Random LFO
  * Analog drifting
  * Have ability to hold after note-on

* Add number of notes pressed to Channel
  * Wolf_: simple example: you know the drill with FM, drive the modulator level
           too high and you get nasty FM noise. So, how about: you play one
           note, the registers are 'nice', so you get a clean sound. Next you
           play two notes, now you drive the modulator level and you get a nasty
           FM noise.

* Add scale detection to Channel
  * Distance between fundamental and the next note output
  * Wolf_: e.g. a minor chord could have different results compared to a major
           chord, and different compared to an octave.

* Wavetable ideas
  * Saxophone; sample wave for each note (127 waves)
  * voice; vowels have periods too (a, e, i, u, o)

* Something about Sub 37 note allocation http://youtu.be/DYzsz2U7RM0?t=4m21s
  * More Sub 37 stuff http://youtu.be/0N4xntZbdW0
    * Enveloped http://youtu.be/0N4xntZbdW0?t=6m44s
    * retrigger, multi-trigger, single-trigger, loop, delay, hold


Devices
-------

* FM architecture
  * Operators, have multiplier, ADSR, level, etc.
  * 2-op / 4-op voices, have gate, frequency, modulator, carrier, algorithm...
  * FM chip, has 2-op and 4-op inputs, global panning, allocation strategy, etc.

* PSG architecture
  * Tone voices, have frequency, volume, envelope enable, noise enable
  * Noise source, have frequency
  * Envelope, have frequency, type
  * PSG chip, has tone, noise, envelope inputs, allocation strategy
    * Envelope/noise input can be null, then tone enables will be ignored
      * Can we enforce this efficiently?

* PSG rate values are 1 higher than SCC

* Introduce Device class which provides common calls for detection,
  initialisation, hooking interrupts, providing timers, etc.

* Sample ADC’s for modulation signal (Philips Music Module MIC: clap!)
  * Envelope follower

* Add SCC+ detection

* Add PSG2 class to play the envelope  
  Saw wave up to 6930Hz, triangle wave up to 3460Hz

* MidiSaurus info
  * http://www.mccm.hetlab.tk/millennium/milc/midi/topic_6.htm
  * http://www.mccm.hetlab.tk/millennium/milc/architec/topic_1.htm zegt:
  * http://www.msx.org/forum/msx-talk/hardware/programming-bit2-midi-saurus
  * http://www.msx.org/forum/msx-talk/hardware/midi-saurus-data-sheetprogramming-guide
  * http://www.msx.org/wiki/MIDI-Saurus

* FAC MIDI interface
  * Intel 8251
  * 10 OUT 3,0: OUT 3,0: OUT 3,0: OUT 3,64: OUT 3,78: OUT 3,21
  * 20 OUT 2,&H90: OUT 2,60: OUT 2,64

* YIS503IIIR network module
  * The YM3802 UART has extensive MIDI support
  * Does it support the MIDI clock rate?
  * No opto-isolator though


User interface
--------------

* Detect and indicate feedback loops
  * Feedback is OK, but it causes 1 sample delay so we should be clear about it
  * In Reaktor, an indicator Z appears on the output when there is feedback

* Make sure UI doesn’t get starved
  * If UI update is still not done after 1s, yield until it does

* Detected devices screen
  * Detect AY-3-8910 / YM2149 difference

* While editing an input, ability to immediately insert a module (smartly)

* Keyboard
  * Switch layout depending on current mode
  * Store key presses into circular buffer (ignore when full, if debug: throw)
  * Use numpad to enter constant values quickly

* Add module selection list shows name + first line of help text
  * Or, help text in a panel to the right

* Fill in dots in module UI to indicate connection?

* In help texts, speak of trigger impulse

* For module help text, have general description, then enumerate parameters

* Oscilloscope view to show value changes over time

* Channel monitor like here: http://youtu.be/JBnk71WsKtc
  * Keyboard monitor like this: http://youtu.be/2EdRRgxoP-g?t=16m12s

* ADSR / wave viewer like this: http://youtu.be/ou5TMtUtUKI?t=2m55s

* F1-F5 accesses menus, use CTRL-* for shortcuts

* Indicate poly modules by giving them a double (or fatter) border
  * Indicate poly connections by showing double or triple wires

* Selecting a value and pressing ENTER enters link edit mode
  * Cursor turns green and selects
  * If input, selection moves to the current value target
  * Move selection to another field to choose
  * Link updates immediately to audit (and notice lucky coincidences)
  * Press ESC to cancel selection, press ENTER to commit
  * Hold SHIFT to enter MIDI learn mode (move controller to select)
  * Press BACKSPACE to delete link and fix the value
  * Draw line between input and source (when pressing SHIFT?)

* Selecting a module and pressing ENTER enters module edit mode
  * Pressing LEFT / RIGHT moves the module (w/ constraints?)
  * Pressing BACKSPACE removes it and fixes all links

* Show help window while in edit mode

* Include description with patch for description, tips, credits, etc.

* Small popup at the bottom showing control changes for a second

* Show memory meter (heap status)

* Show CPU load meter.
  * Employ timers with higher accuracy levels when available.

* Change BLINK colour depending on selection
  * For module selection, use orange foreground colour to change outline
  * For input value selection, use dark blue background
  * For output value selection, use purple background

* Do colour split at bottom to give a different colour

* Inspiration
  * Arturia Origin https://www.youtube.com/watch?v=IVj0Kah7bas


Performance
-----------

* MidiIn_ProcessMessages optimisations:
  * Running status optimisation
    * After a message has been processed, see if the next byte is no status byte
    * If so, loop immediately. Aftertouch, CC and bends will like this.
    * Can skip running status check, status decoding and reuse the channel ref
  * Also, use a jump table for the status bytes
  * Bypass MidiIn for nonmidi devices (KeyMidi / AudioMidi)
    * However for now it’s kept to increase testing coverage

* Embed small modules in the object
  * e.g. Or, ld a,(nn), ld hl,nn, or (hl), ld (nn),a -> 10 bytes in stead of 5
  * Listeners needs to adapt to support variable length
  * Or better, embed the modules into one long stream of code

* Copy code to RAM on turbo r

* Memory optimisation
  * Put all cores in a dedicated mapper page

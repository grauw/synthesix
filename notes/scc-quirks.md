Notes about SCC quirks
======================

What I undestand from Hiroyuki's doc is that channels 4 and 5 produce noise if
they are accessed/modified when the wave pointer is at 15th-16th byte of wave
ram. So when the MSX and SCC try to read those bytes at the same time, it
seems the MSX data bus has priority so it is sent to the DAC and not the wave
data.
<http://www.msx.org/forum/development/msx-development/pcm-player-using-scc?page=14#comment-57033>

  * The shape of waves is not neatly synthesized when pronouncing with SCC
    addition Megarom with channel D and channel E.
  * The noise enters when a wavy memory is accessed by both mega-ROM and
    Snatchar momentarily in the address rugged movement of a wavy memory under
    the reproduction.
  * The noise starts the movement of the address of a wavy memory under the
    reproduction to the 17th byte from the 16th byte by both mega-ROM and
    Snatchar.

Perhaps, these seem the troubles in which a wavy memory of each channel
happens because it is not treatable at the same time of two processing or
more. When MSX accesses a wavy memory at the same time when SCC reads to a
wavy memory as an example, it operates, and the value is output to DA
converter, the MSX side is given to priority, and SCC thinks data to be a
thing of becoming a noise it is not possible to read because of a wavy memory.
I want to examine these sooner or later in detail.
<http://www.msx.org/forum/development/msx-development/pcm-player-using-scc?page=15#comment-57040>

And there is a weird behaviour in this setting. It seems SCC sound is
corrupted in anyway with MSX databus or so. Try to activate them (with proper
waves, freqs, and vol.) and execute DIR command on DOS. You will hear "noise"
This seems to be fixed in SCC+.
<http://openmsx.sourceforge.net/doxygen/SCC_8cc_source.html>

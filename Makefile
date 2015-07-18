COPY_TARGET = /Volumes/MSXDOS2

all:
	mkdir -p gen bin
	node tools/genftable.js > gen/psgftable.asm
	node tools/genmulttable.js > gen/multtable.asm
	java -jar tools/glass.jar -I gen src/ROM.asm bin/synthe6.rom bin/synthe6.sym

dist: all
	cp README.md CHANGES.md LICENSE bin/
	rm -f bin/synthesix.zip
	cd bin && zip synthesix.zip synthe6.rom README.md CHANGES.md LICENSE

copy: all
	cp bin/synthe6.rom $(COPY_TARGET)/
	diskutil umountDisk `mount | grep $(COPY_TARGET) | cut -d" " -f 1`

run: all
	openmsx -cart bin/synthe6.rom -romtype KonamiSCC -machine Panasonic_FS-A1GT -script openmsx.tcl

run2: all
	openmsx -ext slotexpander -ext Konami_Snatcher_Sound_Cartridge -cart bin/synthe6.rom -romtype KonamiSCC -machine Philips_NMS_8245 -ext mu-PACK -script openmsx.tcl

run3: all
	openmsx -cart bin/synthe6.rom -romtype KonamiSCC -machine Yamaha_CX5MII -ext mu-PACK -script openmsx.tcl

run4: all
	openmsx -cart bin/synthe6.rom -romtype KonamiSCC -machine Sony_HB-F500P -ext mu-PACK -script openmsx.tcl

plug msx-midi-in Virtual\ IN
ext debugdevice
set debugoutput stdout
debug set_watchpoint read_io 0x2E

proc dumpwave {nr} {
	set str [ debug read_block Konami\ SD-Snatcher\ SCC+\ Cartridge\ SCC [ expr $nr * 32] 32 ]
	binary scan [ binary format a* $str ] H* hex
	puts $hex
	set fileId [ open "hex.txt" "w" ]
	puts $fileId $hex
	close $fileId
}

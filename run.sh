#!/bin/bash
SRC=./boot_rm.s

BOOT_L=boot_l.bin

LD_FLAGS="-Ttext 0x7c00 --oformat binary"
AS_FLAGS=""

comp_boot() {
	# first assembly it
	as $AS_FLAGS "$1" -o obj.o
	ld_boot "obj.o"
}

ld_boot() {
	# now link it
	ld $LD_FLAGS "$1" -o "$BOOT_L"
}

if [ -f "$SRC" ]; then
	comp_boot "$SRC"
fi

#!/bin/bash
SRC=./boot_rm.S

BOOT_L=boot_rm

LD_FLAGS="-Ttext 0x7c00 --oformat binary"
AS_FLAGS=""

QEMU_="qemu-system-x86_64"

QEMU_FLAGS="-drive format=raw,file="$BOOT_L""

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

if [ "$1" = "-d" ] || [ "$1" = "--debug" ]; then
	# this is for use with gdb,
	# it's setting the localhost as the root of the process
	# which means I can check the flags being set on registers as the boot is starting
	# 	for example the instruction process for the INT 12h | int $0x12 -> kb available for use
	
	QEMU_FLAGS="$QEMU_FLAGS -s -S"
	# i just need to run gdb on it and my stepin / si commands will change the program's running address pointer
fi

#if [ "$#" = "-ng" ] || [ "$1" = "--nographic" ]; then
#	QEMU_FLAGS= "$QEMU_FLAGS -nographic"
#fi

if [ -f "$BOOT_L" ]; then
	$QEMU_ $QEMU_FLAGS 
else
	echo -e "Some kinda error occurred!\n"
fi

rm "$BOOT_L" "obj.o"

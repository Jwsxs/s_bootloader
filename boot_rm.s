# após POST da BIOS, a CPU é inicializada no MODO REAL,
# é um modo 16-bit existente em todos os processadores x86
.code16

.globl	_start

_start:
	# limpo qualquer carry flag existente
	clc

	int	$0x12

# .fill repeat, size, value
.fill 510-(.-_start), 1, 0
.byte 0x55
.byte 0xaa

# após POST da BIOS, a CPU é inicializada no MODO REAL,
# que é um modo 16-bit existente em todos os processadores x86
.code16

.globl	_start

_start:
	# limpo qualquer carry flag existente, evitando jc ler qualquer CF de processos antigos, "sujos"
	clc
	# pois a chamada INT12h retorna, em %ax, o kb disponível para uso no lower memory (<640KB)
	int	$0x12
	# essa chamada é feita para estar sempre presente, podendo nem modificar a carry flag caso dê certo
	# caso contrário, e dê algum erro, como a BIOS não ser compatível com essa mudança, a carry flag indica erro
	# portanto:
	jc	.ERROR # ./incl/_errors.s

	mov $msg, %si
	call _print

	# reading the disk
	# messing with memory data segment

	#0x9000
	mov $0x9000, %bx
	mov $0x5, %dh
	mov $0x80, %dl # hard disk 0x80
	call disk_load

	jmp .

.include "./incl/_errors.S"
.include "./incl/boot_print.S"
.include "./incl/_disk.S"

# .asciz = \0 no final já implementado automatic
# .ascii = nenhum \0 no final, implementa manual
msg: .asciz "Hello, welcome!\r\nBootloader (apparently) running fine!\r\n"
# enche nosso espaço de memória, a partir de 0x0500 à 0x7ffff, com 0's
# no linker > ./run.sh > depois é definido o _start em 0x07c00, no meio desse emaranhado
# isso pois de 0x07c00 à 0x07dff é o setor de Boot da OS, 512 bytes no total
# .fill repeat, size, value
.fill 510-(.-_start), 1, 0

# nos últimos 2 bytes, define assinatura de identidade
# .byte 0x55
# .byte 0xaa

# não sei o motivo de ser 55aa, mas a causa mais provável é da improbabilidade de aparecer
# escrito exatamente nessa ordem, bytes seguidos, hexadecimal de 55 e de aa
# só pra ter contexto:
#	0x55_(16) = 5 * 16^1 + 5 * 16^0 = 01010101
#	0xaa_(16) = 10 * 16^1 + 10 * 16^0 = 10101010
#		= 01010101_10101010
# ou mesmo por escolha da IBM para versões BIOS mais antigas, apenas para id de boot mesmo
# padrão little-endian, só é ao contrário pq norte-americano é foda
.word 0xaa55 # 0x7dfe = 55 | 0x7dff = aa

# 4kb de espaço para stack
.space 4096
stack_top:

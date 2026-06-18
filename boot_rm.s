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

	mov	$msg, %si
	call	boot_print

	# setando %EAX = 0xE820
	# melhor maneira de detectar memória RAM disponível.. sendo a única podendo ler acima de 4GB
	# assim para chamar o kernel / os, antes verificando se é possivel tal, ou se não vai comer o pc
	mov	$0xe8, %ah # bios interrupt call wikipedia => Get Extended Memory Size (Newer function, since 1994). Gives results for memory size above 64 Mb.
	mov	$0x20, %al # bios inteerupt call wikipedia => Query System Address Map. The information returned from E820 supersedes what is returned from the older AX=E801h and AH=88h interfaces.
	# para detectar "upper memory" -> 0xA0000 para 0xFFFFF, a melhor maneira é a chamada INT 15h com as sub ah e al
	int	$0x15
	
	# o feito aqui foi só receber RAM disponível..
	
	# porém, tem um jeito mais "seguro", que mapeia a memória física e vai ser mandado para um "gerenciador"
	# no caso, a os recebe e entende (feito pelo dev no caso) quais endereços podem ser usáveis ou não

# physical memory manager
# .pmm_checker:
	# aponta ES:DI (o endereço) para o buffer the destino de uma lista -> essa que contém endereços livres
	# xor %ebx, %ebx # limpo ebx,
	# mov $0x534D4150, %edx # seto edx com esse número dos deuses
	
	# xor %ah, %ah # "high" parte do acumulador deve ser 0
	# mov $0xe820, %eax # chamada de interrupt da bios para Get Extended Memory Size
	# mov $24, %ecx # 8bytes base + 8bytes len + 4bytes type + 4bytes attr = 24
			# no final é uma estrutura que mapeia cada região da memória
	# int $0x15 # chamo a bios

	# se tudo der certo, %eax é setado com o número mágico e a carry flag vai ser resetada
	# %ebx recebe algum número diferente de zero, que deve ser usado posteriormente
	# %cl (8-bit "lower" do %ecx) recebe o número de bytes guardados em ES:DI -> diz ser geralmente 20
	# então seta tudo novamente (menos zerando ebx), adiciono 24 ao index de destino e continua
	# de endereço em endereço é assim que se mapeia a memória

.include "./incl/_errors.s"
.include "./incl/boot_print.s"

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

.code16

_print:
	# print function have to be on %ah
	mov	$0x0e, %ah
.l1:
	mov	(%si), %al
	cmp	$0, %al # compara com '\0' = final de string
	je	_done

	# juntamente com o mov $0x0, %ah, seta caractere para tua escrita em modo TTY
	# ao interrupt ser chamado, só executa a função em %ah com a chamada
	# INT10h é a call de chamada de serviço de vídeo ( Video Services )
	int	$0x10
	
	inc	%si
	jmp	.l1

_done:
	ret

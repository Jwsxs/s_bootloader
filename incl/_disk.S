.code16


disk_load:
	push %dx

	# C:H:S -> Cylinder : Head : Sector
	# is the way memory is allocated physically.
	# it uses a AD:OF => Address : Offset as a way to map them out
	# the formula is as follows - hexadecimal: (Address << 4) + Offset
	# so, for example: 0x0400:0x0123 => 0x4123
	# but, before mapping them, we have to get the point of the disk our memory's in

	mov $0x02, %ah # we have to set ah with the instruction we'll be using

	mov %dh, %al
	mov $0x0, %ch # cylinder 0
	mov $0x0, %dh # ler a partir do head 0
	mov $0x2, %cl # setor 2 ou seja 2 * 512

	int $0x13

	pop %dx

	# al é setado com a quantidade de setores que foram lidos, em oposição à quantidade pedida
	# caso seja igual, suave, se não, deu erro
	cmp %al, %dh
	jne .ERROR

	mov $disk_msg, %si
	call _print

	ret

disk_msg: .asciz "Disk correctly loaded!\r\n"

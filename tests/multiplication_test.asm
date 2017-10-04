.text

start:

	lda %r
	ldi B 4
	add
	sta %r

	lda %i
	dec
	sta %i

	jnz %start

	lda %r
	out 0
	hlt


.data

r = 0
i = 4

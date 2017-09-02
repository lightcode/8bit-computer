.program

start:

lda %r
ldi B 4
add
sta %r

lda %i
ldi B 1
sub
sta %i

jnz %start

lda %r
out
hlt


.data

r = 0
i = 4

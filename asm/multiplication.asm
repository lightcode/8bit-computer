.program

start:

lda %r
add %a
sta %r

lda %i
sub %k
sta %i

jnz %start

lda %r
out
hlt


.data

k = 1
r = 0
i = 4
a = 4

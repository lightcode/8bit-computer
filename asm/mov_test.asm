.program

start:

ldi B 42
mov M B %k
mov A M %k
out

ldi B 21
mov A B
out

hlt


.data

k = 255

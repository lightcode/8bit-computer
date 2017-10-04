.text

ldi B 42
mov M B %k
mov A M %k
out 0

ldi B 21
mov A B
out 0

hlt


.data

k = 255

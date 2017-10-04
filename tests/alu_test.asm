.text

ldi A 0xFF
ldi B 0x0F
and
mov G A

ldi A 0xFF
or
mov F A

ldi A 0xFF
xor
mov E A

ldi A 0xFF
add
mov D A

ldi A 1
ldi B 2
sub

hlt

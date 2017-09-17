.program

start:
ldi A 10
out 0
call %load
out 0
hlt

load:
push A
ldi A 42
call %output
pop A
ret

output:
out 0
ret

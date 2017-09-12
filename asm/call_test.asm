.program

start:

call %load
hlt

load:
ldi A 42
call %output
ret

output:
out 0
ret

jal begin
nop

fact:
slei r3,r1,0
bnez r3,putone
nop
subi r17,r1,1
jal fact
nop
mult r1,r17,r1
j end
nop

putone:
addi r1,r0,1

end:
ret
nop

begin:
jal fact
addi r1,r0,4
nop

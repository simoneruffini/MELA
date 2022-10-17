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

product:
addi r1,r0,1 ; M = 1
addi r2,r0,4 ; n = 4
addi r3,r0,0 ; i = 0
addi r4,r0,10 ; index = 10

; for (i = 0; i < 4; i++) M = M*A(i);
loop:
lw r5,0(r4)	; fetch element of A
mult r1,r5,r1   ; multiply M by A(index)
addi r3,r3,1    ; increment i
addi r4,r4,4    ; increment index
seq r6,r2,r3    ; is i = n?
beqz r6,loop    ; if no loop, otherwise, end
nop
sw 0(r7),r1
ret
nop

begin:
; load A = (2,8,6,5) in memory, starting from location 0
addi r1,r0,10
addi r2,r0,2
sw 0(r1),r2
addi r2,r0,8
sw 4(r1),r2
addi r2,r0,6
sw 8(r1),r2
addi r2,r0,5
sw 12(r1),r2

; compute productorial of A
jal product
addi r7,r0,20

; load result from memory and compute factorial of it divided by 128
lw r2,20(r0)
add r1,r0,r2

jal fact
srai r1,r1,7

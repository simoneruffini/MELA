addi r1, r0, 2
nop
nop
nop
ciclo:  
subi r1, r1, 1
nop
nop
nop
addi r5, r0, 2
bnez r1, ciclo
addi r2, r2, 100
slli r3, r1, 1
xori r4, r1, 1
addi r1, r0, -1
nop
nop
nop
ceeclo:
addi r1, r1, 1
nop
nop
nop
addi r4, r0, -10
beqz r1, ceeclo
andi r5, r3, r2
ori  r6, r2, r3
srai r7, r4, 2

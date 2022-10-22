addi r1, r0, 2
nop
nop
nop
addi r2, r1, 2
jal jal_label
jump_label:
nop
nop
xor r3,r2,r1
nop
nop
jal_label:
sne r5,r0,r1
j jump_label
addi r6,r0,-5
nop
subi r7,r0,-5





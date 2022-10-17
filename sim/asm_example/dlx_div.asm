addi r1, r0, 81
addi r2, r0, 9
xor r3, r3, r3
divide:
	slt r5, r1, r2
	bnez r5, finish
	sub r1, r1, r2
	addi r3, r3, 1
	j divide
finish:
add r4, r0, r1
nop
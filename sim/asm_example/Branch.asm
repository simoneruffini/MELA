
addi r1, r0, 100
xor r2, r2, r2

ciclo:
lw r3, 0(r2)
addi r3, r3, 10
sw 100(r2), r3
subi r1, r1, 1
addi r2, r2, 4
bnez r1, ciclo

addi r4, r0, 65535 
ori r5, r4, 100000
add r6, r4, r5

end:
j end
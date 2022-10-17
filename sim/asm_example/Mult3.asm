addi r1, r0, 6
addi r2, r0, 7
lw r4, 100(r1)
mult r3, r1, r4
j fine
mult r3, r1, r2

fine:
j fine
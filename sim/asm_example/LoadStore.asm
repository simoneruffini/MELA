myloop:

addi r1, r0, 4
nop
nop
nop
lw r2, 4(r1)
nop
nop
nop
sw 2(r0), r1
nop
nop
nop
addi r4, r3, 15     ; should stall
addi r7, r0, myloop ;move label into r7
nop
nop
nop
jalr r7        	    ;jump
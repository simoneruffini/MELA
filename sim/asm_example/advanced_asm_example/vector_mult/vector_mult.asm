; LOAD IN MEMORY
; A = (2, 8, -4, -16)
addi r1,r0,10
addi r2,r0,2
sw 0(r1),r2
addi r2,r0,8
sw 4(r1),r2
addi r2,r0,-4
sw 8(r1),r2
addi r2,r0,-16 
sw 12(r1),r2

;-------
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
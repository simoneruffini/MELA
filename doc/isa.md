Rs = register source 
Rt = register target
Rd = register destination

## Instruction Types
### I-type (load,store,reg-immediate alu op.)
I-type:         `OP rd, rs1, IMM`
31                                                                    0
[----6bit-----|---5bit---|---5bit---|--------------16bit--------------]
    OPCODE        Rs1        Rd                  IMMEDIATE

Encodes: Loads and stores of bytes, words, half words
All immediates (rd rs1 op immediate)
Conditional branch instructions (rs1 is register, rd unused)
Jump register, jump and link register
(rd = 0, rs1 = destination, immediate = 0)

### R-type (register-regiset alu op.)
R-type:         `OP rd, rs1, rs2`

31                                                                    0
[----6bit-----|---5bit---|---5bit---|---5bit---|--------11bit---------]
    OPCODE        Rs1        Rs2         Rd             FUNC 

Register–register ALU operations: rd rs1 func rs2
Function encodes the data path operation: Add, Sub, . . .
Read/write special registers and moves
### J-type (jump, jal, trap, return from except)
J-type:         `OP LABEL`

31                                                                    0
[----6bit-----|---------------------26bit-----------------------------]
    OPCODE                    IMMEDIATE/LABEL
Jump and jump and link
Trap and return from exception

# BASIC OPCODES

|Mnemonic |Type | OP-code hex | OP-code bin | Example          | Binary Representaion                        |
|---------|-----|-------------|-------------|------------------|---------------------------------------------|
|add      | r   | 0x20        | 0b100000    | add r9,r20,r10   | 0000 00.10 100.0 1010 .0100 1.000 0010 0000 |
|addi     | i   | 0x08        | 0b001000    | addi r1,r2,#-5   | 0010 00.00 010.0 0001 .1111 1111 1111 1011  |
|and      | r   | 0x24        | 0b100100    | and r9,r3,r10    | 0000 00.00 011.0 1010 .0100 1.000 0010 0100 |
|andi     | i   | 0x0c        | 0b001100    | andi r20,r9,#8   | 0011 00.01 001.1 0100 .0000 0000 0000 1000  |
|beqz     | i   | 0x04        | 0b000100    | beqz r0,#2       | 0001 00.00 000.0 0000 .1111 1111 1110 1110  |
|bnez     | i   | 0x05        | 0b000101    | bnez r2,#-6      | 0001 01.00 010.0 0000 .1111 1111 1110 0010  |
|j        | j   | 0x02        | 0b000010    | j l1             | 0000 10.11 1111 1111 1111 1111 0011 1100 (relative position from PC+4 of the tag) |
|jal      | j   | 0x03        | 0b000011    |                  |                                             |
|lw       | i   | 0x23        | 0b100011    | lw r19, 63(r8)   | 1000 11.01 000.1 0011 .0000 0000 0011 1111  |
|nop      | x   | 0x15        | 0b010101    | nop              | 0101 01.00 000.0 0000 .0000 0000 0000 0000  |
|or       | r   | 0x25        | 0b100101    | or r5, r3, r4    | 0000 00.00 011.0 0100 .0010 1.000 0010 0101 |
|ori      | i   | 0x0d        | 0b001101    | ori r5, r3, #342 | 0011 01.00 011.0 0101 .0000 0001 0101 0110  |
|sge      | r   | 0x2d        | 0b101101    | sge r1,r2,r10    | 0000 00.00 010.0 1010 .0000 1.000 0010 1101 |
|sgei     | i   | 0x1d        | 0b011101    | sgei r9,r20,#6   | 0111 01.10 100.0 1001 .0000 0000 0000 0110  |
|sle      | r   | 0x2c        | 0b101100    | sle r13,r2,r4    | 0000 00.00 010.0 0100 .0110 1.000 0010 1100 |
|slei     | i   | 0x1c        | 0b011100    | slei r1,r3,#-4   | 0111 00.00 011.0 0001 .1111 1111 1111 1100  |
|sll      | r   | 0x04        | 0b000100    | sll r1,r2,r3     | 0000 00.00 010.0 0011 .0000 1.000 0000 0100 | 
|slli     | i   | 0x14        | 0b010100    | slli r4,r1,#5    | 0101 00.00 001.0 0100 .0000 0000 0000 0101  |
|sne      | r   | 0x29        | 0b101001    | sne r1,r2,r3     | 0000 00.00 010.0 0011 .0000 1.000 0010 1001 | 
|snei     | i   | 0x19        | 0b011001    | snei r3,r5,#4    | 0110 01.00 101.0 0011 .0000 0000 0000 0100  |
|srl      | r   | 0x06        | 0b000110    | srl r5,r7,r8     | 0000 00.00 111.0 1000 .0010 1.000 0000 0110 |
|srli     | i   | 0x16        | 0b010110    | srli r7,r5,#2    | 0101 10.00 101.0 0111 .0000 0000 0000 0010  |
|sub      | r   | 0x22        | 0b100010    | sub r6,r12,r15   | 0000 00.01 100.0 1111 .0011 0.000 0010 0010 |
|subi     | i   | 0x0a        | 0b001010    | subi r7,r9,#-30  | 0010 10.01 001.0 0111 .1111 1111 1110 0010  |
|sw       | i   | 0x2b        | 0b101011    | sw 1(r0),r1      | 1010 11.00 000.0 0001 .0000 0000 0000 0001  |
|xor      | r   | 0x26        | 0b100110    | xor r6,r12,r15   | 0000 00.01 100.0 1111 .0011 0.000 0010 0110 |
|xori     | i   | 0x0e        | 0b001110    | xori r6,r12,#1   | 0011 10.01 100.0 0110 .0000 0000 0000 0001  |

# Solutions

add
Ex: add r1 ,r2 ,r3
R[Rd] <-- R[Rs1] + R[Rs2]
All are signed integers
IF ID EX MEM WB

addi
Ex: addi r5 ,r2 ,#5
R[Rs2] <-- R[Rs1] + imm16
All are signed integers

and
Ex: and r2 ,r3 ,r4
R[Rd] <-- R[Rs1] & R[Rs2]
All are unsigned integers . Logical ‘and’ is performed on a bitwise basis.

andi
Ex: andi r3 ,r4 ,#5
R[Rs2] <-- R[Rs1] & uimm16
All are unsigned integers . Logical ‘and’ is performed on a bitwise basis.

beqz
Ex: beqz r1 ,label
if (R[Rs1] == 0) PC <-- PC + imm16

bnez
Ex: bnez r1 ,label
if (R[Rs1] != 0) PC <-- PC + imm16

j
Ex: j label
PC <-- PC + imm26
Unconditionally jumps relative to the PC of the next instruction. imm26 is a 26-bit signed integer .

jal (jump and link)
Ex: jal label
R31 <-- PC + 4; PC <-- PC + imm26
Saves a return address in register 31 and jumps relative to the PC of the next instruction. imm26 is a 26-bit signed integer.

lw
Ex: lw r19 ,label +63( r8)
R[Rs2] <-- M[imm16 + R[Rs1]]
One word is read from the effective address computed by adding signed integer imm16 and unsigned integer R[Rs1] and is stored in R[Rs2 ].

nop
Ex: nop
Idles one cycle. 

or 
Ex: or r2 ,r3 ,r4
R[Rd] <-- R[Rs1] | R[Rs2]
All are unsigned integers . Logical ‘or’ is performed on a bitwise basis.

ori
Ex: ori r3 ,r4 ,#5
R[Rs2] <-- R[Rs1] | uimm16 
All are unsigned integers . Logical ‘or’ is performed on a bitwise basis.

sge
Ex: sge r1,r3,r4
if (R[Rs1] >= R[Rs2 ]) R[Rd] <-- 1 else R[Rd] <-- 0
All are signed integers.

sgei
Ex: sgei r2 ,r1 ,#6
if (R[Rs1] >= imm16 ) R[Rs2] <-- 1 else R[Rs2] <-- 0
All are signed integers.

sle
Ex: sle r1 ,r2 ,r3
if (R[Rs1] <= R[Rs2 ]) R[Rd] <-- 1 else R[Rd] <-- 0
All are signed integers . 

slei
Ex: slei r8 ,r5 ,#345
if (R[Rs1] <= imm16 ) R[Rs2] <-- 1 else R[Rs2] <-- 0
All are signed integers . 

sll
Ex: sll r6 ,r7 ,r11
R[Rd] <-- R[Rs1] << R[Rs2]_27..31
All are unsigned integers . R[Rs1] is logically shifted left by the low five bits of R[Rs2]. Zeros are shifted into the least-significant bit.

sne
Ex: sne r1 ,r2 ,r3
if (R[Rs1] != R[Rs2 ]) R[Rd] <-- 1 else R[Rd] <-- 0
All are signed integers . 

snei
Ex: snei r4 ,r5 ,#89
if (R[Rs1] != imm16) R[Rs2] <-- 1 else R[Rs2] <-- 0
All are signed integers .

srl
Ex: srl r15 ,r2 ,r3
R[Rd] <-- R[Rs1] >> R[Rs2]_27..31
All are unsigned integers . R[Rs1] is arithmetically shifted right by R[Rs2 ].
Zeros are shifted into the most significant bit.

srli
Ex: srli r1 ,r2 ,#5
R[Rs2] <-- R[Rs1] >> uimm16_27..31
All are unsigned integers . R[Rs1] is arithmetically shifted right by uimm16 .
Zeros are shifted into the most significant bit.

sub
Ex: sub r3 ,r2 ,r1
R[Rd] <-- R[Rs1] - R[Rs2]
All are signed integers.

subi
Ex: subi r15 ,r16 ,#964
R[Rs2] <-- R[Rs1] - imm16
All are signed integers . 

sw
Ex: sw 21(r13),r6
M[imm16 + R[Rs1 ]] <-- R[Rs2]
One word from integer register R[Rs2] is written to the effective address computed by adding signed integer imm16 and unsigned integer R[Rs1].

xor
Ex: xor r2 ,r3 ,r4
R[Rd] <-- F[Rs1] XOR R[Rs2]
All are unsigned integers . Logical ’xor’ is performed on a bitwise basis.

xori
Ex: xori r3 ,r4 ,#5
R[Rs2] <-- R[Rs1] XOR uimm16
All are unsigned integers . Logical ’xor’ is performed on a bitwise basis.

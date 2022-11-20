# ISA
The following are the supported instructions of this DLX implementation.

## Instruction Types

Naming: 
- `DLX naming` is the naming used by the assembly language in the DLX isa that you will see in the next paragraphs.
    - `Rd` = register destination
    - `Rs1/2` = register source 1/2
    - `IMM16/uIMM16` = immediate field for i-type like instructions (signed/unsigned encoding)
    - `LABEL` = immediate field for j-type like instructions
- `DP naming` means _DataPath naming_, is the associated nomenclature we gave in the datapath for each field.
    - `Rs1` = register field 1
    - `Rs2` = register field 2
    - `Rs3` = register field 3
    - `imm_i_type` = see `IMM16`
    - `imm_j_type` = see `LABEL`
`OPCODE` and `FUNC` are common to both baming conventions.

The `DP naming` convention was necessary because `Rd` field position is inconsistent across instructions, therefore we opted to enumerate the fields and then depending on the instruction treat either `Rs2` as `Rd` or `Rs3` as `Rd`.

Other Conventions:
- `num`: is an signed integer that can be expressed into the immediate field of that type
- `RF[]`: is the array representation of the register file (32 elements from 0 to 31)
- `MEM[]`: is the array representation of the data-memory 
- `OP`: is the operation applied to the fields that is expressed in binary by `OPCDOE` or `OPCODE+FUNC`
- `PC`: program counter register
- **as stated before all assembly syntax uses the `DLX naming` convention (otherwise it's explicitly stated)**

The below graphs show how the assembly language fields are placed in an instruction word.

### I-type (load,store,reg-immediate alu op.)

- Assembly syntax: `OP Rd, Rs1, IMM16`

- Result (for the most): `RF[Rd] <= RF[Rs1] OP IMM16`

```
POS 1->32  1            6 7       11 12      16 17                              32
POS 0->31  0            5 6       10 11      15 16                              31
POS 32->1  32          27 26      22 21      17 16                               1
POS 31->0  31          26 25      21 20      16 15                               0
           [----6bit-----|---5bit---|---5bit---|--------------16bit--------------]
DLX naming     OPCODE        Rs1        Rd                    IMM16
DP naming      OPCODE        Rs1        Rs2                 imm_i_type
```
Conditional branch instructions (`beqz`,`bnez`) `Rs1` field is used as is, `Rd` is unused.
Some exception on the position for load store, see further.

**Load exception**

Load instructions are i-type instructions but need extra interpretation:

- Assembly syntax: `load Rd, num(Rs1)`

- Result : `RF[Rd] <= MEM[num+RF[Rs1]]`

`num` is the value stored in `IMM16`/`imm_i_type` moreover the addressing range from the content of `Rs1` is `+-[-2^15,2^15-1]`.

```
POS 1->32  1            6 7       11 12      16 17                              32
POS 0->31  0            5 6       10 11      15 16                              31
POS 32->1  32          27 26      22 21      17 16                               1
POS 31->0  31          26 25      21 20      16 15                               0
           [----6bit-----|---5bit---|---5bit---|--------------16bit--------------]
DLX naming   LOAD_OPCODE     Rs1        Rd                    IMM16
DP naming    LOAD_OPCODE     Rs1        Rs2                 imm_i_type
```

**Store exception**

Store instructions are i-type instructions but need extra interpretation.
Store instructions are i-type instruction but layed out differently in the instruction.

**NOTE**: Here we can't use the `DLX naming` convention previosly adopted for all assmebly instructions (see [here](#instruction-types)), i.e.: there is no destination register (`Rd`) but a memory location where to write, therefore we will use the `DP naming` for the below assembly sytanx.

- Assembly syntax: `store num(Rs1), Rs2`

- Result : `MEM[num+RF[Rs1]] <= RF[Rs2]`

`num` is the value stored in `IMM16`/`imm_i_type` moreover the addressing range from `$Rs1` is `$Rs1+[-2^15,2^15-1]`.

```
POS 1->32  1            6 7       11 12      16 17                              32
POS 0->31  0            5 6       10 11      15 16                              31
POS 32->1  32          27 26      22 21      17 16                               1
POS 31->0  31          26 25      21 20      16 15                               0
           [----6bit-----|---5bit---|---5bit---|--------------16bit--------------]
DLX naming      XXXX         XXX        XXX                    XXX
DP naming   STORE_OPCODE     Rs1        Rs2                 imm_i_type
```

### R-type (register-regiset alu op.)

- Assembly syntax: `OP Rd, Rs1, Rs2`

- Result: `Rd <= RF[Rs1] OP RF[Rs2]`

```
POS 1->32  1            6 7       11 12      16 17      21 22                   32
POS 0->31  0            5 6       10 11      15 16      20 21                   31
POS 32->1  32          27 26      22 21      17 16      12 11                    1
POS 31->0  31          26 25      21 20      16 15      11 10                    0
           [----6bit-----|---5bit---|---5bit---|---5bit---|--------11bit---------]
DLX naming     OPCODE        Rs1        Rs2         Rd             FUNC 
DP naming      OPCODE        Rs1        Rs2         Rs3            FUNC
```

All r-type instructions have the same `OPCODE` value, therefore `FUNC`
(Function) encodes the data path operation: Add, Sub, ... 

### J-type (jump, jal, trap, return from except)

- Assembly Syntax: `OP LABEL`

- Result: `PC <= PC+LABEL` + possibile extras

```
POS 1->32  1            6 7                                                     32
POS 0->31  0            5 6                                                     31
POS 32->1  32          27 26                                                     1
POS 31->0  31          26 25                                                     0
           [----6bit-----|---------------------26bit-----------------------------]
DLX naming     OPCODE                          LABEL 
DP naming      OPCODE                        imm_j_type
```

Jump and jump and link

## Instructions Binary Representation 

|Mnemonic |Type | Opcode/Func hex | Opcode/Func bin | Example          | Example Binary Representaion                |
|---------|-----|-----------------|-----------------|------------------|---------------------------------------------|
|add      | r   | 0x00/x20        | 0/0b100000      | add r9,r20,r10   | 0000 00.10 100.0 1010 .0100 1.000 0010 0000 |
|addi     | i   | 0x08            | 0b001000        | addi r1,r2, -5   | 0010 00.00 010.0 0001 .1111 1111 1111 1011  |
|and      | r   | 0x00/0x24       | 0/0b100100      | and r9,r3,r10    | 0000 00.00 011.0 1010 .0100 1.000 0010 0100 |
|andi     | i   | 0x0c            | 0b001100        | andi r20,r9, 8   | 0011 00.01 001.1 0100 .0000 0000 0000 1000  |
|beqz     | i   | 0x04            | 0b000100        | beqz r12, 2      | 0001 00.01 100.0 0000 .1111 1111 1110 1110  |
|bnez     | i   | 0x05            | 0b000101        | bnez r2, -6      | 0001 01.00 010.0 0000 .1111 1111 1110 0010  |
|j        | j   | 0x02            | 0b000010        | j tag            | 0000 10.11 1111 1111 1111 1111 0011 1100    |
|jal      | j   | 0x03            | 0b000011        | jal tag          | 0000 11.11 1111 1111 1111 1111 0011 1100    |
|lw       | i   | 0x23            | 0b100011        | lw r19, 63(r8)   | 1000 11.01 000.1 0011 .0000 0000 0011 1111  |
|nop      | i   | 0x15            | 0b010101        | nop              | 0101 01.00 000.0 0000 .0000 0000 0000 0000  |
|or       | r   | 0x00/0x25       | 0/0b100101      | or r5, r3, r4    | 0000 00.00 011.0 0100 .0010 1.000 0010 0101 |
|ori      | i   | 0x0d            | 0b001101        | ori r5, r3,  342 | 0011 01.00 011.0 0101 .0000 0001 0101 0110  |
|sge      | r   | 0x00/0x2d       | 0/0b101101      | sge r1,r2,r10    | 0000 00.00 010.0 1010 .0000 1.000 0010 1101 |
|sgei     | i   | 0x1d            | 0b011101        | sgei r9,r20, 6   | 0111 01.10 100.0 1001 .0000 0000 0000 0110  |
|sle      | r   | 0x00/0x2c       | 0/0b101100      | sle r13,r2,r4    | 0000 00.00 010.0 0100 .0110 1.000 0010 1100 |
|slei     | i   | 0x1c            | 0b011100        | slei r1,r3, -4   | 0111 00.00 011.0 0001 .1111 1111 1111 1100  |
|sll      | r   | 0x00/0x04       | 0/0b000100      | sll r1,r2,r3     | 0000 00.00 010.0 0011 .0000 1.000 0000 0100 | 
|slli     | i   | 0x14            | 0b010100        | slli r4,r1, 5    | 0101 00.00 001.0 0100 .0000 0000 0000 0101  |
|sne      | r   | 0x00/0x29       | 0/0b101001      | sne r1,r2,r3     | 0000 00.00 010.0 0011 .0000 1.000 0010 1001 | 
|snei     | i   | 0x19            | 0b011001        | snei r3,r5, 4    | 0110 01.00 101.0 0011 .0000 0000 0000 0100  |
|srl      | r   | 0x00/0x06       | 0/0b000110      | srl r5,r7,r8     | 0000 00.00 111.0 1000 .0010 1.000 0000 0110 |
|srli     | i   | 0x16            | 0b010110        | srli r7,r5, 2    | 0101 10.00 101.0 0111 .0000 0000 0000 0010  |
|sub      | r   | 0x00/0x22       | 0/0b100010      | sub r6,r12,r15   | 0000 00.01 100.0 1111 .0011 0.000 0010 0010 |
|subi     | i   | 0x0a            | 0b001010        | subi r7,r9, -30  | 0010 10.01 001.0 0111 .1111 1111 1110 0010  |
|sw       | i   | 0x2b            | 0b101011        | sw 1(r2),r1      | 1010 11.00 010.0 0001 .0000 0.000 0000 0001 |
|xor      | r   | 0x00/0x26       | 0/0b100110      | xor r6,r12,r15   | 0000 00.01 100.0 1111 .0011 0.000 0010 0110 |
|xori     | i   | 0x0e            | 0b001110        | xori r6,r12, 1   | 0011 10.01 100.0 0110 .0000 0000 0000 0001  |

## ISA details

### add: add
- Ex: `add r1, r2, r3`
- `Rd=r1, Rs1=r2, Rs2=r3`
- `RF[Rd] <= RF[Rs1] + RF[Rs2]`

All are signed integers

### addi: add immediate
- Ex: `addi r5, r2,  5`
- `Rd=r5, Rs1=r2, IMM16=5`
- `RF[Rd] <= RF[Rs1] + IMM16`

All are signed integers

### and: logical and
- Ex: `and r2, r3, r4`
- `Rd=r2, Rs1=r3, Rs2=r4`
- `RF[Rd] <= RF[Rs1] & RF[Rs2]`

All are unsigned integers . Logical AND is performed on a bitwise basis.

### andi: logical and  immediate
- Ex: `andi r3, r4,  5`
- `Rd=r3, Rs1=r4, uIMM16=5`
- `RF[Rd] <= RF[Rs1] & uIMM16`

All are unsigned integers. Logical AND is performed on a bitwise basis.

### beqz: branch equal zero
- Ex: `beqz r1, LABEL`
- `Rs1=r1`
- `if (RF[Rs1] == 0) PC <= PC + IMM16`

### bnez: branch not equal zero
- Ex: `bnez r1, LABEL`
- `Rs1=r1`
- `if (RF[Rs1] != 0) PC <= PC + IMM16`

### j: jump
- Ex: `j LABEL`
- `PC <= PC + LABEL`

Unconditionally jumps relative to the PC of the next instruction.  
LABEL is a 26-bit signed integer .

### jal: jump and link
- Ex: `jal LABEL`
- `R31 <= PC + 4; PC <= PC + LABEL`

Saves a return address in register 31 and jumps relative to the PC of the next instruction.  
LABEL is a 26-bit signed integer.

### lw: load word
- Ex: `lw r19, +63(r8)`
- `Rs1=r8, Rd=r19`
- `RF[Rd] <= MEM[IMM16 + RF[Rs1]]`

One word is read from the effective address computed by adding signed integer IMM16 and unsigned integer RF[Rs1] and is stored in RF[Rd].

### nop: no operation
- Ex: `nop`
- Idles one cycle.


### or: logical or
- Ex: `or r2, r3, r4`
- `Rd=r2, Rs1=r3, Rs2=r4`
- `RF[Rd] <= RF[Rs1] | RF[Rs2]`

All are unsigned integers . Logical ‘or’ is performed on a bitwise basis.

### ori: logical or immediate
- Ex: `ori r3, r4,  5`
- `Rd=r3, Rs1=r4, uIMM16=5`
- `RF[Rd] <= RF[Rs1] | uIMM16`

All are unsigned integers . Logical ‘or’ is performed on a bitwise basis.

### sge: set greater-then-equal
- Ex: `sge r1,r3,r4`
- `Rd=r1, Rs1=r3, Rs2=r4`
- `if (RF[Rs1] >= RF[Rs2]) RF[Rd] <= 1 else RF[Rd] <= 0`

All are signed integers.

### sgei: set greater-then-equal immediate
- Ex: `sgei r2, r1,  6`
- `Rd=r2, Rs1=r1, IMM16=6`
- `if (RF[Rs1] >= IMM16 ) RF[Rd] <= 1 else RF[Rd] <= 0`

All are signed integers.

### sle: set less-then-equal
- Ex: `sle r1, r2, r3`
- `Rd=r1, Rs1=r2, Rs2=r3`
- `if (RF[Rs1] <= RF[Rs2]) RF[Rd] <= 1 else RF[Rd] <= 0`

All are signed integers . 

### slei: set less-then-equal immediate
- Ex: `slei r8, r5,  345`
- `Rd=r8, Rs1=r5, IMM16=345`
- `if (RF[Rs1] <= IMM16) RF[Rd] <= 1 else RF[Rd] <= 0`

All are signed integers. 

### sll: shift left logical
- Ex: `sll r6, r7, r11`
- `Rd=r6, Rs1=r7, Rs2=r11`
- `RF[Rd] <= RF[Rs1] << RF[Rs2]`

All are unsigned integers.  
RF[Rs1] is logically shifted left by RF[Rs2] positions.  
Zeros are shifted into the least-significant bit.  

### slli: shift left logical immediate
- Ex: `slli r6, r7,  8`
- `Rd=r6, Rs1=r7, uIMM16=8`
- `RF[Rd] <= RF[Rs1] << uIMM16`

All are unsigned integers.  
RF[Rs1] is logically shifted left by uIMM16 positions.  
Zeros are shifted into the least-significant bit.  

### sne: set not equal
- Ex: `sne r1, r2, r3`
- `Rd=r1, Rs1=r2, Rs2=r3`
- `if (RF[Rs1] != RF[Rs2]) RF[Rd] <= 1 else RF[Rd] <= 0`

All are signed integers . 

### snei: set not equal immediate
- Ex: ` snei r4, r5,  89`
- `Rd=r4, Rs1=r5, IMM16=89`
- `if (RF[Rs1] != IMM16) RF[Rd] <= 1 else RF[Rd] <= 0`

All are signed integers .

### srl: shift right logical
- Ex: `srl r15, r2, r3`
- `Rd=r15, Rs1=r2, Rs2=r3`
- `RF[Rd] <= RF[Rs1] >> RF[Rs2]`

All are unsigned integers.  
RF[Rs1] is logically shifted right by RF[Rs2] positions.  
Zeros are shifted into the most significant bit.  

### srli: shift right logical immediate
- Ex: `srli r1, r2,  5`
- `Rd=r1, Rs1=r2, uIMM16=5`
- `RF[Rd] <= RF[Rs1] >> uIMM16`

All are unsigned integers.  
RF[Rs1] is logically shifted right by uIMM16 positions. 
Zeros are shifted into the most significant bit.  

### sra: shift right arithmetical
- Ex: `sra r1, r2, r3`
- `Rd=r1, Rs1=r2, Rs2=r3`
- `RF[Rd] <= RF[Rs1] >a> RF[Rs2]`

lF[Rs1] is treated as signed integer RF[Rs2] is treated as an unsigned Integer.   
RF[rega] is arithmetically shifted right by RF[Rs] positions.   
The sign bit is shifted/repeated into the most significant bits.  

### srai: shift right arithmetical immediate
- Ex: `srli r1, r2,  5`
- `Rd=r1, Rs1=r2, uIMM16=5`
- `RF[Rd] <= RF[Rs1] >a> uIMM16`

RF[Rs1] is treated as signed integer uIMM16 is treated as an unsigned Integer.   
RF[Rs1] is arithmetically shifted right by uIMM16 positions.   
The sign bit is shifted/repeated into the most significant bits.  

### sub: subtract
- Ex: `sub r3, r2, r1`
- `Rd=r3, Rs1=r2, Rs2=r1`
- `RF[Rd] <= RF[Rs1] - RF[Rs2]`

All are signed integers.

### subi: subtract immediate
- Ex: `subi r15, r16,  964`
- `Rd=r15, Rs1=r16, IMM16=964`
- `RF[Rd] <= RF[Rs1] - IMM16`

All are signed integers. 

### sw: store word

- Ex: `sw 21(r13),r6`
- **USES DP naming**
- `Rs1=r13, IMM16=21, Rs2=r6`
- `MEM[IMM16 + RF[Rs1]] <= RF[Rs2]`

One word from integer register RF[Rs2] is written to the effective address computed by adding signed integer IMM16 and unsigned integer RF[Rs1].

### xor: logical exlusive or
- Ex: `xor r2, r3, r4`
- `Rd=r2, Rs1=r3, Rs2=r4`
- `RF[Rd] <= F[Rs1] XOR RF[Rs2]`

All are unsigned integers . Logical XOR is performed on a bitwise basis.

### xori: logical exlusive or immediate
- Ex: `xori r3, r4,  5`
- `Rd=r3, Rs1=r4, uIMM16=5`
- `RF[Rd] <= RF[Rs1] XOR uIMM16`

All are unsigned integers . Logical XOR is performed on a bitwise basis.

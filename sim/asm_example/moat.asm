; Mother Of All Tests

j start ; jump to actual start
nop
nop
nop
hello:
addi r8, r0, 69   ; nice                                           = 0x00000045
j going_back_down_bye
nop
nop
nop

start:
; init registers
addi r1, r0, 1
addi r2, r0, -1
nop
nop
nop
srli r3, r2, 1       ; intmax 0xFFFFFFF >> 1 = 2^31-1 = 2147483648 = 0x7FFFFFFF
slli r4, r1, 31      ; intmin 0x1 << 31 = -2^31 = -2147483648 = 0x80000000
addi r5, r0, -128
addi r6, r0, 85      ; 0x55
addi r7, r0, 170     ; 0xAA

nop                  ; remove possibile data hazards
nop
nop

; r-type
sll r8, r6, r1       ; 0x55 << 1                                   = 0x000000AA
sll r9, r6, r2       ; 0x55 << -1(xff...)                          = 0x00000000
sll r10, r4, r1      ; intmin << 1                                 = 0x00000000
sll r11, r1, r6      ; 1 << 85                                     = 0x00000000

srl r12, r7, r1      ; 0xAA >> 1                                   = 0x00000055
srl r13, r6, r2      ; 0x55 >> -1                                  = 0x00000000
srl r14, r5, r1      ; -128 >> 1                                   = 0x7FFFFFC0
srl r15, r1, r6      ; 1 >> 85                                     = 0x00000000

sra r16, r5, r1      ; -128 >>a 1 = -64                            = 0xFFFFFFC0
sra r17, r4, r1      ; intmin >>a 1                                = 0xC0000000
sra r18, r4, r6      ; intmin >>a 85                               = 0xFFFFFFFF

add r19, r1, r3      ; should overflow to intmin                   = 0x80000000
add r20, r6, r7      ; 85+170 = 255                                = 0x000000FF
add r21, r6, r5      ; 85+(-128) = -43                             = 0xFFFFFFD5

sub r22, r4, r1      ; intmin-1 = intmax                           = 0x7FFFFFFF
sub r23, r5, r7      ; -128 - 170 = -298                           = 0xFFFFFED6

and r24, r6, r7      ; 0x55 & 0xAA                                 = 0x00000000
and r25, r7, r5      ; 170 & -128 = 128                            = 0x00000080

or  r26, r6, r7      ; 0x55 | 0xAA                                 = 0x000000FF

xor r27, r6, r7      ; 0x55 xor 0xAA                               = 0x000000FF

; save r-type results
sw  0(r0), r8 
sw  1(r0), r9 
sw  2(r0), r10
sw  3(r0), r11
sw  4(r0), r12
sw  5(r0), r13
sw  6(r0), r14
sw  7(r0), r15
sw  8(r0), r16
sw  9(r0), r17
sw 10(r0), r18
sw 11(r0), r19
sw 12(r0), r20
sw 13(r0), r21
sw 14(r0), r22
sw 15(r0), r23
sw 16(r0), r24
sw 17(r0), r25
sw 18(r0), r26
sw 19(r0), r27

; comparators with same values
sle r8, r3, r3      ; r8 = 1                                       = 0x00000001
sne r9, r3, r3      ; r9 = 0                                       = 0x00000000
sge r10, r3, r3     ; r10 = 1                                      = 0x00000001

; comparators with different values
sge r11, r6, r7      ; 0x55 >= 0xAA => 0                           = 0x00000000
sge r12, r7, r6      ; 0x55 <= 0xAA => 1                           = 0x00000001
sle r13, r6, r7      ; 0x55 <= 0xAA => 1                           = 0x00000001
sle r14, r7, r8      ; 0x55 >= 0xAA => 0                           = 0x00000000
sne r15, r6, r7      ; 0x55 != 0xAA => 1                           = 0x00000001

; save r-type compares
sw 20(r0), r8 
sw 21(r0), r9 
sw 22(r0), r10
sw 23(r0), r11
sw 24(r0), r12
sw 25(r0), r13
sw 26(r0), r14
sw 27(r0), r15

; i-type (copy pasta from r-type)
slli r8, r6, 1        ; 0x55 << 1 = 0xAA                           = 0x000000AA
slli r9, r6, -1       ; 0xAA << -1 = 0                             = 0x00000000
slli r10, r4, 1       ; intmin << 1 = 0                            = 0x00000000
slli r11, r1, 85      ; 1 << 85 = 0                                = 0x00000000

srli r12, r7, 1       ; 0xAA >> 1 = 0x55                           = 0x00000055 
srli r13, r6, -1      ; 0x55 >> -1 = 0                             = 0x00000000 
srli r14, r5, 1       ; -128 >> 1 = 0x7FFFFFC0                     = 0x7FFFFFC0 
srli r15, r1, 85      ; 1 >> 85 = 0                                = 0x00000000 

srai r16, r5, 1       ; -128 >>a 1 = -64 (0xC0)                    = 0xFFFFFFC0
srai r17, r4, 1       ; intmin >>a 1 = 0xC0000000                  = 0xC0000000
srai r18, r4, 85      ; intmin >>a 85 = -1                         = 0xFFFFFFFF

addi r19, r1, 32767   ; 1+max15=0x8000                             = 0x00008000
addi r20, r6, 170     ; 85+170 = 255                               = 0x000000FF
addi r21, r6, -128    ; 85+(-128) = -43                            = 0xFFFFFFD5

subi r22, r4, 1       ; intmin-1 = intmax                          = 0x7FFFFFFF
subi r23, r5, 170     ; -128 - 170 = -298                          = 0xFFFFFED6

andi r24, r6, 170     ; 0x55 & 0xAA = 0                            = 0x00000000
andi r25, r7, -128    ; 170 & -128 = 128 (0x80)                    = 0x00000080

ori  r26, r6, 170     ; 0x55 | 0xAA = 0xFF                         = 0x000000FF

xori r27, r6, 170     ; 0x55 xor 0xAA = 0xFF                       = 0x000000FF

; save i-type results
sw 28(r0), r8  
sw 29(r0), r9  
sw 30(r0), r10
sw 31(r0), r11
sw 32(r0), r12
sw 33(r0), r13
sw 34(r0), r14
sw 35(r0), r15
sw 36(r0), r16
sw 37(r0), r17
sw 38(r0), r18
sw 39(r0), r19
sw 40(r0), r20
sw 41(r0), r21
sw 42(r0), r22
sw 43(r0), r23
sw 44(r0), r24
sw 45(r0), r25
sw 46(r0), r26
sw 47(r0), r27

; comparators with same values
slei r8, r3, 32767   ; r8 = 0                                      = 0x00000000
snei r9, r3, 32767   ; r9 = 1                                      = 0x00000001
sgei r10, r3, 32767  ; r10 = 1                                     = 0x00000001

; comparators with different values
sgei r11, r6, 170      ; 0x55 >= 0xAA => 0                         = 0x00000000
sgei r12, r7, 85       ; 0x55 <= 0xAA => 1                         = 0x00000001
slei r13, r6, 170      ; 0x55 <= 0xAA => 1                         = 0x00000001
slei r14, r7, 85       ; 0x55 >= 0xAA => 0                         = 0x00000000
snei r15, r6, 170      ; 0x55 != 0xAA => 1                         = 0x00000001

; save i-type compares
sw 48(r0), r8  
sw 49(r0), r9  
sw 50(r0), r10
sw 51(r0), r11
sw 52(r0), r12
sw 53(r0), r13
sw 54(r0), r14
sw 55(r0), r15

;
;      JUMP
;
j hello ; jump backwards

; random instructions that should not run
sw  56(r0),  r2      ; if this executes than DMEM 56=-1
sll r13, r6, r2      ; 0xAA << -1 = 0x55
sll r14, r4, r1      ; intmin << 1 = 0
sll r15, r1, r6      ; 1 << 85 = 0

going_back_down_bye:
jal subroutine
jr_is_missing_sad:

addi r12, r0, -1
nop
nop
nop
cycle_ez:
addi r12, r12, 1   ; final value if branch                         = 0x00000001
nop
nop
nop
beqz r12, cycle_ez

addi r13, r0, 2
nop
nop
nop
cycle_nez:
subi r13, r13, 1   ; final value if branch                         = 0x00000000
nop
nop
nop
bnez r13, cycle_nez

; load/store
sw 84(r0), r3   ; store intmax in 84
sw 0(r6) , r3   ; store intmaxr in 85
sw 1(r6) , r3   ; store intmaxr in 85+1=86
lw r14, 84(r0)  ; store dmem[84] in r14 == intmax
lw r15, 0(r6)   ; store dmem[85] in r15 == intmax
lw r16, 1(r6)   ; store dmem[86] in r16 == intmax

j end

subroutine:
add r9, r1, r3      ; overflow to intmin                           = 0x80000000
add r10, r6, r7     ; 85+55 = 255                                  = 0x000000FF
add r11, r6, r5     ; 85+(-128) = -43                              = 0xFFFFFFD5
j jr_is_missing_sad ; exit subroutine
; random instructions that should not run
srli r9, r7, 85   
srli r10, r6, 170
srli r11, r6, 1
srli r12, r1, 85   

end:
; save all jump results
sw 57(r0), r8  ; 69
sw 58(r0), r9  ; subrutine
sw 59(r0), r10 ; subrutine
sw 60(r0), r11 ; subrutine
sw 61(r0), r12 ; counter of beqz
sw 62(r0), r13 ; counter of bnez
sw 63(r0), r14 ; lw
sw 64(r0), r15 ; lw
sw 65(r0), r16 ; lw ; remember to look into mem[84,85,86]

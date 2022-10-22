addi r1, r0, 2
nop
nop
nop
ciclo:  
subi r1, r1, 1
nop
  --P_OPCODE_DELAY : process (CLK, RST_AN) is
  --begin

  --  if (RST_AN = '0') then
  --    -- non-existent opcode
  --    opcode_d <= (others => '1');
  --    opcode_e <= (others => '1');
  --    opcode_m <= (others => '1');
  --    opcode_w <= (others => '1');
  --  elsif (CLK'event and CLK = '1') then
  --    opcode_d <= opcode_f;
  --    opcode_e <= opcode_d;
  --    opcode_m <= opcode_e;
  --    opcode_w <= opcode_m;
  --  end if;

  --end process P_OPCODE_DELAY;

  -- DEBUG STUFF
  --P_DBG_PRINT : process (INSTR, opcode_f, opcode_d, opcode_e, opcode_m, opcode_w) is
  --begin

  --  dbg_fetch     <= print_instr(opcode_f, get_func(INSTR));
  --  dbg_decode    <= print_instr(opcode_d, get_func(INSTR));
  --  dbg_execute   <= print_instr(opcode_e, get_func(INSTR));
  --  dbg_memory    <= print_instr(opcode_m, get_func(INSTR));
  --  dbg_writeback <= print_instr(opcode_w, get_func(INSTR));

  --end process P_DBG_PRINT;
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

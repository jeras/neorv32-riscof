
-- ================================================================================ --
-- NEORV32 SoC - Simulation-Only Trace Logger for HDLDB                             --
-- -------------------------------------------------------------------------------- --
-- The NEORV32 RISC-V Processor - https://github.com/stnolting/neorv32              --
-- Copyright (c) NEORV32 contributors.                                              --
-- Copyright (c) 2020 - 2025 Stephan Nolting. All rights reserved.                  --
-- Licensed under the BSD-3-Clause license, see LICENSE for details.                --
-- SPDX-License-Identifier: BSD-3-Clause                                            --
-- ================================================================================ --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;

library neorv32;
use neorv32.neorv32_package.all;

use neorv32.neorv32_hdldb_io_pkg.all;

entity neorv32_hdldb is
  generic (
    XLEN     : natural := 32;
    GPR_SIZE : natural := 32;
    CSR_SIZE : natural := 0;
    MEM_SIZE : natural := 1024
  );
  port (
    -- system signals
    clk : in std_logic;  -- global clock line
    rst : in std_logic;  -- global reset line
  );
end neorv32_hdldb;

architecture neorv32_hdldb_behav of neorv32_hdldb is

  -- instruction trace port
  signal trace : trace_port_t; -- CPU trace port

begin

  ---------------------------------------
  -- dumping initial CPU state after reset
  ---------------------------------------

  state_dump: process
    -- CPU state
    variable gpr_v : array_std_logic_vector(0 to GPR_SIZE-1)(XLEN-1 downto 0);
    variable pc_v  :       std_logic_vector                 (XLEN-1 downto 0);
--  variable csr_v : array_std_logic_vector(0 to CSR_SIZE-1)(XLEN-1 downto 0);
    variable mem_v : array_bit_vector      (0 to MEM_SIZE-1)(XLEN-1 downto 0);
    -- trace dump file
    variable dumpfile : string := "neorv32.hdldb-dump";
  begin
    -- wait for reset release
    loop
      wait until rising_edge(clk);
      exit when (rst = '0');
    end loop;

    -- sample state
--    gpr_v := << signal .neorv32_riscof_tb.neorv32_top_inst.core_complex_gen(0).neorv32_cpu_inst.neorv32_cpu_regfile_inst.register_file_fpga.reg_file_inst.sdpram : gpr_v'subtype >>;
--    pc_v  := << signal .neorv32_riscof_tb.neorv32_top_inst.core_complex_gen(0).neorv32_cpu_inst.neorv32_cpu_frontend_inst.fetch.pc : pc_v'subtype >>;
--  csr_v := (
--    16#000# => << signal .neorv32_riscof_tb.neorv32_top_inst.neorv32_cpu_inst.,
--    others  => 32X"00000000"
--  );
--    mem_v := << variable .neorv32_riscof_tb.main.array8_v : mem_v'subtype >>;
    
    -- dump state
--    dump_bin(dumpfile, gpr_v);
--    dump_bin(dumpfile, pc_v);
--    dump_bin(dumpfile, mem_v);
    wait;
  end process state_dump;

  ---------------------------------------
  -- instruction trace log (binary file)
  ---------------------------------------

  trace <= << signal .neorv32_riscof_tb.neorv32_top_inst.trace_cpu0_o : trace_port_t >>;

  trace_log: process
    variable filename  : string := "neorv32.hdldb-trace";
    file     tracefile : char_file;
    variable timestamp : bit_vector(64-1 downto 0);
  begin
    -- open trace log file
    file_open(tracefile, filename, WRITE_MODE);
    loop
      -- on every clock cycle check the trace valid signal
      wait until rising_edge(clk);
      -- log if instruction trace is valid
      if (rst = '0') and (trace.valid = '1') then
        -- header
        -- [31:28] trace packet size in XLEN units
        -- [27   ] memory access write
        -- [   26] memory access read
        -- [25:24] memory access size (0 is byte, ...)
        --  
        -- timestamp
        write_bin(tracefile, to_bitvector(std_logic_vector(to_signed(now/(1 fs), 64))));
        -- IFU
        write_bin(tracefile, trace.pc_rdata);  -- instruction address (PC)
        write_bin(tracefile, trace.insn    );  -- instruction code
        -- GPR
        write_bin(tracefile, trace.rd_rdata);  -- destination register data
        -- LSU
        write_bin(tracefile, trace.mem_addr);  -- memory address
      end if;
    end loop;
    -- close trace log file
    file_close(tracefile);
    wait;
  end process trace_log;


end neorv32_hdldb_behav;

--  type trace_port_t is record
--    valid     : std_ulogic; -- all other signals are valid when set
--    -- instruction metadata --
--    order     : std_ulogic_vector(31 downto 0); -- instruction index
--    insn      : std_ulogic_vector(31 downto 0); -- instruction word
--    trap      : std_ulogic; -- set if the current instruction causes a sync exception
--    halt      : std_ulogic; -- set if last instruction before halting
--    intr      : std_ulogic; -- set if executing the first instruction of a trap handler
--    mode      : std_ulogic_vector(1 downto 0); -- 00 = user mode, 11 = machine mode
--    ixl       : std_ulogic_vector(1 downto 0); -- XLEN; 01 = 32-bit
--    debug     : std_ulogic; -- set if instruction is executed in debug-mode
--    compr     : std_ulogic; -- set if instruction is a decompressed instruction
--    -- integer register --
--    rs1_addr  : std_ulogic_vector(4 downto 0);  -- rs1 address
--    rs2_addr  : std_ulogic_vector(4 downto 0);  -- rs2 address
--    rs1_rdata : std_ulogic_vector(31 downto 0); -- rs1 read data
--    rs2_rdata : std_ulogic_vector(31 downto 0); -- rs2 read data
--    rd_addr   : std_ulogic_vector(4 downto 0);  -- rd address
--    rd_rdata  : std_ulogic_vector(31 downto 0); -- rd write data
--    -- program counter --
--    pc_rdata  : std_ulogic_vector(31 downto 0); -- current instruction address
--    pc_wdata  : std_ulogic_vector(31 downto 0); -- next instruction address
--    -- control and status register --
--    csr_addr  : std_ulogic_vector(11 downto 0); -- csr address
--    csr_rdata : std_ulogic_vector(31 downto 0); -- csr read data
--    csr_wdata : std_ulogic_vector(31 downto 0); -- csr write data
--    -- memory access --
--    mem_addr  : std_ulogic_vector(31 downto 0); -- address
--    mem_rmask : std_ulogic_vector(3 downto 0);  -- read-enable
--    mem_wmask : std_ulogic_vector(3 downto 0);  -- write-enable
--    mem_rdata : std_ulogic_vector(31 downto 0); -- read data
--    mem_wdata : std_ulogic_vector(31 downto 0); -- write data
--  end record;

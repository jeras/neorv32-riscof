
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

entity neorv32_hdldb is
  generic (
    -- file names
    STATE_FILE : string; -- state dump file
    TRACE_FILE : string; -- trace log file
    -- 
  );
  port (
    clk_i   : in std_ulogic;  -- global clock line
    rstn_i  : in std_ulogic;  -- global reset line, low-active, async
    -- state port
    gpr_i   : in is array (0 to 32-1) of std_ulogic_vector(XLEN-1 downto 0);
    mem_i   : in is array (<>) of std_ulogic_vector(8-1 downto 0);
    -- TODO: CSR
    -- trace port
    trace_i : in trace_port_t -- CPU trace port
  );
end neorv32_hdldb;

architecture neorv32_hdldb_behav of neorv32_hdldb is


begin

  -- Write Trace to Log File (SIMULATION ONLY) ----------------------------------------------
  -- -------------------------------------------------------------------------------------------
  sim_trace_gen:
  if is_simulation_c generate
    sim_trace: process(rstn_i, clk_i)
      file     file_v : text open write_mode is LOG_FILE;
      variable line_v : line;
    begin
      if (rstn_i = '0') then
        cycle_cnt <= (others => '0');
      elsif rising_edge(clk_i) then
        cycle_cnt <= std_ulogic_vector(unsigned(cycle_cnt) + 1);
        if (trace_i.valid = '1') then
          -- index --
          write(line_v, integer'(to_integer(unsigned(trace_i.order))));
          write(line_v, string'(" "));
          -- timestamp --
          write(line_v, integer'(to_integer(unsigned(cycle_cnt))));
          write(line_v, string'(" "));
          -- instruction address --
          write(line_v, string'("0x"));
          write(line_v, string'(to_hexstring_f(trace_i.pc_rdata)));
          write(line_v, string'(" "));
          -- instruction word --
          write(line_v, string'("0x"));
          write(line_v, string'(to_hexstring_f(trace_i.insn)));
          write(line_v, string'(" "));
          -- privilege level --
          if (trace_i.debug = '1') then
            write(line_v, string'("D "));
          elsif (trace_i.mode = "11") then
            write(line_v, string'("M "));
          elsif (trace_i.mode = "00") then
            write(line_v, string'("U "));
          else
            write(line_v, string'("? "));
          end if;
          -- decoded instruction --
          if (trace_i.compr = '1') then -- de-compressed instruction
            write(line_v, string'("c."));
          else
            write(line_v, string'("  "));
          end if;
          write(line_v, string'(decode_mnemonic_f(trace_i.insn)));
          write(line_v, string'(decode_operands_f(trace_i.insn)));
          -- trap entry --
          if (trace_i.intr = '1') then
            write(line_v, string'(" <TRAP_ENTRY>"));
          end if;
          --
          writeline(file_v, line_v);
        end if;
      end if;
    end process sim_trace;
  end generate;

end neorv32_hdldb_behav;


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

  -- trace port
  signal trace : trace_port_t; -- CPU trace port

begin

  ---------------------------------------
  -- dumping initial CPU state after reset
  ---------------------------------------

  state_dump: process
    -- state port
    variable gpr_v : array_bit_vector(0 to GPR_SIZE-1)(XLEN-1 downto 0);
    variable pc_v  :       bit_vector                 (XLEN-1 downto 0);
--  variable csr_v : array_bit_vector(0 to CSR_SIZE-1)(XLEN-1 downto 0);
    variable mem_v : array_bit_vector(0 to MEM_SIZE-1)(XLEN-1 downto 0);
  begin
    -- wait for reset release
    loop
      wait until rising_edge(clk);
      exit when (rst = '0');
    end loop;

    -- sample state
    gpr_v := << signal .neorv32_riscof_tb.neorv32_top_inst.neorv32_cpu_inst.neorv32_cpu_regfile_inst.register_file_fpga.reg_file_inst.sdpram : gpr_v'subtype >>;
    pc_v  := << signal .neorv32_riscof_tb.neorv32_top_inst.neorv32_cpu_inst.neorv32_cpu_frontend_inst.fetch.pc : pc_v'subtype >>;
--  csr_v := (
--    16#000# => << signal .neorv32_riscof_tb.neorv32_top_inst.neorv32_cpu_inst.,
--    others  => 32X"00000000"
--  );
    mem_v := << signal .neorv32_riscof_tb.main.array8_v : mem_v'subtype >>;
    
    -- dump state
    dump_bin("neorv32.hdldb-dump", gpr_v);
    wait;
  end process state_dump;

  ---------------------------------------
  -- instruction trace log (binary file)
  ---------------------------------------

  trace <= << signal .neorv32_riscof_tb.neorv32_top_inst.trace_cpu0_o : trace_port_t >>;


end neorv32_hdldb_behav;

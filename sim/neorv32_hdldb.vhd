
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

use neorv32.neorv32_io_pkg.all;

entity neorv32_hdldb is
  generic (
    GPR_SIZE : natural := 32;
    CSR_SIZE : natural := 0;
    MEM_SIZE : natural := 1024
  );
  port (
    -- system signals
    clk_i   : in std_ulogic;  -- global clock line
    rstn_i  : in std_ulogic;  -- global reset line, low-active, async
  );
end neorv32_hdldb;

architecture neorv32_hdldb_behav of neorv32_hdldb is

  -- trace port
  signal trace : trace_port_t; -- CPU trace port

begin

  state_dump: process
    -- state port
    variable gpr_v : array32_bv_t(0 to GPR_SIZE-1);
    variable csr_v : array32_bv_t(0 to CSR_SIZE-1);
    variable mem_v : array8_bv_t (0 to MEM_SIZE-1);
    -- TODO: CSR

  begin
    gpr_v := << signal .neorv32_riscof_tb.neorv32_top_inst.trace_cpu0_o : array32_bv_t >>;
    mem_v := << signal .neorv32_riscof_tb.main.array8_v : array8_bv_t >>;
    wait;
    --trace_i := << signal .neorv32_riscof_tb.neorv32_top_inst.trace_cpu0_o : trace_port_t >>
  end process state_dump;


end neorv32_hdldb_behav;

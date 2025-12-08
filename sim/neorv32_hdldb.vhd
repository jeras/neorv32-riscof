
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
    -- file names
    STATE_FILE : string; -- state dump file
    TRACE_FILE : string  -- trace log file
    -- 
  );
  port (
    clk_i   : in std_ulogic;  -- global clock line
    rstn_i  : in std_ulogic;  -- global reset line, low-active, async
    -- state port
    gpr_i   : in array32_bv_t;
    mem_i   : in array8_bv_t;
    -- TODO: CSR
    -- trace port
    trace_i : in trace_port_t -- CPU trace port
  );
end neorv32_hdldb;

architecture neorv32_hdldb_behav of neorv32_hdldb is


begin


end neorv32_hdldb_behav;

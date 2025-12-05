-- ================================================================================ --
-- neorv32_riscof_tb.vhd - Testbench for running RISCOF                             --
-- -------------------------------------------------------------------------------- --
-- https://github.com/stnolting/neorv32-riscof                                      --
-- Copyright (c) 2022 - 2025 Stephan Nolting. All rights reserved.                  --
-- Licensed under the BSD-3-Clause license, see LICENSE for details.                --
-- SPDX-License-Identifier: BSD-3-Clause                                            --
-- ================================================================================ --

library std;
use std.textio.all;
use std.env.finish;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library neorv32;
use neorv32.neorv32_package.all;

entity neorv32_riscof_tb is
  generic (
    -- test environment symbols for signature and HTIF
    BEGIN_SIGNATURE : string := "";
    END_SIGNATURE   : string := "";
    TOHOST          : string := "";
    FROMHOST        : string := "";
    -- path for memory initialization, dumping signature files and logging
    TEST_PATH       : string := ""
  );
end neorv32_riscof_tb;

architecture neorv32_riscof_tb_rtl of neorv32_riscof_tb is

  -- memory configuration --
  constant mem_size_c : natural := 4*1024*1024; -- bytes
  constant mem_base_c : std_ulogic_vector(31 downto 0) := x"80000000";

  -- memory type (bit_vector type for optimized system storage) --
  type mem8_bv_t is array (natural range <>) of bit_vector(7 downto 0);

  -- initialize mem8_bv_t array from plain binary file --
  impure function mem8_bv_init_bin_f(file_name : string; size : natural) return mem8_bv_t is
    type char_file is file of character;
    file     mem_f   : char_file;
    variable mem_v   : mem8_bv_t(0 to size-1);
    variable index_v : natural;
    variable data_v  : character;
  begin
    if (file_name /= "") then
      file_open(mem_f, file_name, READ_MODE);
      index_v := 0;
      while (endfile(mem_f) = false) and (index_v < size) loop
        read(mem_f, data_v);
        mem_v(index_v) := to_bitvector(std_logic_vector(to_unsigned(character'pos(data_v),8)));
        index_v := index_v + 1;
      end loop;
    end if;
    file_close(mem_f);
    return mem_v;
  end function mem8_bv_init_bin_f;

  -- dump mem8_bv_t array to plain binary file --
  procedure mem8_bv_dump_bin_f(file_name : string; mem : mem8_bv_t) is
    type char_file is file of character;
    file     mem_f   : char_file;
    variable data_v  : character;
  begin
    if (file_name /= "") then
      file_open(mem_f, file_name, WRITE_MODE);
      for index_v in mem'range loop
        data_v := character'val(to_integer(unsigned(to_stdlogicvector(mem(index_v)))));
        write(mem_f, data_v);
      end loop;
    end if;
    file_close(mem_f);
  end procedure mem8_bv_dump_bin_f;

  -- dump mem8_bv_t array to plain binary file --
  procedure mem8_bv_dump_hex32_f(file_name : string; mem : mem8_bv_t) is
    file     mem_f   : text;
    variable data_v  : bit_vector(32-1 downto 0);
    variable line_v  : line;
    variable byte_v  : integer range 0 to 3;
  begin
    if (file_name /= "") then
      file_open(mem_f, file_name, WRITE_MODE);
      for index_v in mem'range loop
        byte_v := index_v mod 4;
        case (byte_v) is
          when 0 => data_v(07 downto 00) := mem(index_v);
          when 1 => data_v(15 downto 08) := mem(index_v);
          when 2 => data_v(23 downto 16) := mem(index_v);
          when 3 => data_v(31 downto 24) := mem(index_v);
        end case;
        if byte_v = 3 then
          hwrite(line_v, data_v);
          for i in line_v'range loop
--          line_v(i) := to_lower(line_v(i));
            if line_v(i) >= 'A' and line_v(i) <= 'F' then
              line_v(i) := character'val (character'pos (line_v(i)) + 32);
            end if;
          end loop;
          writeline(mem_f, line_v);
        end if;
      end loop;
    end if;
    file_close(mem_f);
  end procedure mem8_bv_dump_hex32_f;

  -- parse string to unsigned
  function string2unsigned32 (str : string) return unsigned is
    variable line_v : line;
    variable value_v : unsigned(32-1 downto 0);
  begin
    line_v := new string'(str) ;
    hread(line_v, value_v);
    return value_v;
  end function string2unsigned32;

  -- memory word address --
  signal mem_addr : integer range 0 to mem_size_c-1;

  -- generators --
  signal clk_gen, rstn_gen : std_ulogic := '0';

  -- external bus interface --
  type xbus_t is record
    addr  : std_ulogic_vector(31 downto 0);
    wdata : std_ulogic_vector(31 downto 0);
    rdata : std_ulogic_vector(31 downto 0);
    we    : std_ulogic;
    sel   : std_ulogic_vector(03 downto 0);
    stb   : std_ulogic;
    cyc   : std_ulogic;
    ack   : std_ulogic;
  end record;
  signal xbus : xbus_t;

  signal mem_rdata : std_ulogic_vector(31 downto 0);
  signal ack : std_ulogic;
  signal msi, mei, mti : std_ulogic;

  -- simulation trace logger --
  component neorv32_tracer_simlog
    generic (
      LOG_FILE : string -- trace log file
    );
    port (
      clk_i   : in std_ulogic;  -- global clock line
      rstn_i  : in std_ulogic;  -- global reset line, low-active, async
      trace_i : in trace_port_t -- CPU trace port
    );
  end component;

begin

  -- Clock/Reset Generator ------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  clk_gen <= not clk_gen after 5 ns;
  rstn_gen <= '0', '1' after 100 ns;


  -- The Core of the Problem ----------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  neorv32_top_inst: neorv32_top
  generic map (
    -- Processor Clocking --
    CLOCK_FREQUENCY     => 100_000_000,
    -- Boot Configuration --
    BOOT_MODE_SELECT    => 1, -- boot from BOOT_ADDR_CUSTOM
    BOOT_ADDR_CUSTOM    => mem_base_c,
    -- RISC-V CPU Extensions --
    RISCV_ISA_C         => true,
    RISCV_ISA_M         => true,
    RISCV_ISA_U         => true,
    RISCV_ISA_Zaamo     => true,
    RISCV_ISA_Zcb       => true,
    RISCV_ISA_Zba       => true,
    RISCV_ISA_Zbb       => true,
    RISCV_ISA_Zbkb      => true,
    RISCV_ISA_Zbkc      => true,
    RISCV_ISA_Zbkx      => true,
    RISCV_ISA_Zbs       => true,
    RISCV_ISA_Zicntr    => true,
    RISCV_ISA_Zicond    => true,
    RISCV_ISA_Zimop     => true,
    RISCV_ISA_Zknd      => true,
    RISCV_ISA_Zkne      => true,
    RISCV_ISA_Zknh      => true,
    RISCV_ISA_Zksed     => true,
    RISCV_ISA_Zksh      => true,
    -- Tuning Options --
    CPU_FAST_MUL_EN     => true,
    CPU_FAST_SHIFT_EN   => true,
    -- Physical Memory Protection --
    PMP_NUM_REGIONS     => 16,
    PMP_MIN_GRANULARITY => 4,
    PMP_TOR_MODE_EN     => true,
    PMP_NAP_MODE_EN     => true,
    -- Internal memories --
    IMEM_EN             => false,
    DMEM_EN             => false,
    -- External bus interface --
    XBUS_EN             => true,
    XBUS_REGSTAGE_EN    => false,
    -- Processor peripherals --
    IO_CLINT_EN         => true,
    IO_TRACER_EN        => true,
    IO_TRACER_BUFFER    => 1
--  IO_TRACER_SIMLOG_EN => false
  )
  port map (
    -- Global control --
    clk_i       => clk_gen,
    rstn_i      => rstn_gen,
    -- External bus interface --
    xbus_adr_o  => xbus.addr,
    xbus_dat_i  => xbus.rdata,
    xbus_dat_o  => xbus.wdata,
    xbus_we_o   => xbus.we,
    xbus_sel_o  => xbus.sel,
    xbus_stb_o  => xbus.stb,
    xbus_cyc_o  => xbus.cyc,
    xbus_ack_i  => xbus.ack,
    xbus_err_i  => '0',
    -- CPU Interrupts --
    mtime_irq_i => mti,
    msw_irq_i   => msi,
    mext_irq_i  => mei
  );

  -- bus feedback --
  xbus.rdata <= mem_rdata;
  xbus.ack   <= ack;

  -- read/write address --
  mem_addr <= to_integer(unsigned(xbus.addr(index_size_f(mem_size_c/4)+1 downto 2))) * 4;


  -- Memory [rwx], Environment Control ------------------
  -- -------------------------------------------------------------------------------------------
  main: process(rstn_gen, clk_gen)
    -- memory (array of mem_size_c bytes)
    variable mem8_v : mem8_bv_t(0 to mem_size_c-1) := mem8_bv_init_bin_f(TEST_PATH & "main.bin", mem_size_c);
    -- test environment symbols
    variable begin_signature_v : unsigned(32-1 downto 0) := string2unsigned32(BEGIN_SIGNATURE);
    variable end_signature_v   : unsigned(32-1 downto 0) := string2unsigned32(END_SIGNATURE  );
    variable tohost_v          : unsigned(32-1 downto 0) := string2unsigned32(TOHOST         );
    variable fromhost_v        : unsigned(32-1 downto 0) := string2unsigned32(FROMHOST       );
    -- log file
    variable line_v : line;
    variable char_v : integer;
  begin
    if (rstn_gen = '0') then
      ack <= '1';
      msi <= '0';
      mti <= '0';
      mei <= '0';
    elsif rising_edge(clk_gen) then
      ack   <= '0';

      -- defaults --
      mem_rdata <= (others => '0');
      -- bus access --
      if (xbus.cyc = '1') and (xbus.stb = '1') then
        if (xbus.addr(31 downto 28) = mem_base_c(31 downto 28)) then
          ack <= '1';
          if (xbus.we = '1') then
            if (xbus.sel(0) = '1') then mem8_v(mem_addr+0) := to_bitvector(xbus.wdata(07 downto 00)); end if;
            if (xbus.sel(1) = '1') then mem8_v(mem_addr+1) := to_bitvector(xbus.wdata(15 downto 08)); end if;
            if (xbus.sel(2) = '1') then mem8_v(mem_addr+2) := to_bitvector(xbus.wdata(23 downto 16)); end if;
            if (xbus.sel(3) = '1') then mem8_v(mem_addr+3) := to_bitvector(xbus.wdata(31 downto 24)); end if;
          else
            mem_rdata(07 downto 00) <= to_stdulogicvector(mem8_v(mem_addr+0));
            mem_rdata(15 downto 08) <= to_stdulogicvector(mem8_v(mem_addr+1));
            mem_rdata(23 downto 16) <= to_stdulogicvector(mem8_v(mem_addr+2));
            mem_rdata(31 downto 24) <= to_stdulogicvector(mem8_v(mem_addr+3));
          end if;
        end if;
      end if;

      -- Environment Control
      if (xbus.cyc = '1') and (xbus.stb = '1') and (xbus.we = '1') then
        -- terminate simulation --
        if (xbus.addr = std_logic_vector(tohost_v)) then
          ack <= '1';
          mem8_bv_dump_hex32_f( TEST_PATH & "DUT-neorv32.signature",
            mem8_v(to_integer(begin_signature_v-unsigned(mem_base_c)) to
                   to_integer(  end_signature_v-unsigned(mem_base_c))) );
          assert false report "Finishing simulation." severity note;
          finish;
        -- interrupt triggers --
        elsif (xbus.addr = x"F000000C") then
          ack <= '1';
          msi <= xbus.wdata(3);
          mti <= xbus.wdata(7);
          mei <= xbus.wdata(11);
        end if;
      end if;

    end if;
  end process main;

  -- Tracer log ------------------
  -- -------------------------------------------------------------------------------------------
    neorv32_tracer_simlog0_inst: neorv32_tracer_simlog
    generic map (
      LOG_FILE => TEST_PATH & "neorv32.tracer"
    )
    port map (
      clk_i   => clk_gen,
      rstn_i  => rstn_gen,
      trace_i => << signal neorv32_top_inst.trace_cpu0_o : trace_port_t >>
    );

end neorv32_riscof_tb_rtl;

-- ================================================================================ --
-- neorv32_io_pkg.vhd - IO package for testbenches                                  --
-- -------------------------------------------------------------------------------- --
-- https://github.com/stnolting/neorv32-riscof                                      --
-- Copyright (c) 2022 - 2025 Stephan Nolting. All rights reserved.                  --
-- Licensed under the BSD-3-Clause license, see LICENSE for details.                --
-- SPDX-License-Identifier: BSD-3-Clause                                            --
-- ================================================================================ --

library std;
use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package neorv32_io_pkg is

  -- memory type (bit_vector type for optimized system storage) --
  type mem8_bv_t is array (natural range <>) of bit_vector(8-1 downto 0);
  type mem32_bv_t is array (natural range <>) of bit_vector(32-1 downto 0);

  impure function mem8_bv_init_bin_f(file_name : string; size : natural) return mem8_bv_t;
  procedure mem8_bv_dump_bin_f(file_name : string; mem : mem8_bv_t; mode : file_open_kind := WRITE_MODE);
  procedure mem8_bv_dump_hex32_f(file_name : string; mem : mem8_bv_t; mode : file_open_kind := WRITE_MODE);
  pure function string2unsigned32 (str : string) return unsigned;

end package neorv32_io_pkg;

package body neorv32_io_pkg is

  -- initialize mem8_bv_t array from plain binary file --
  impure function mem8_bv_init_bin_f(
    file_name : string;
    size      : natural
  ) return mem8_bv_t is
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
  procedure mem8_bv_dump_bin_f(
    file_name : string;
    mem       : mem8_bv_t;
    mode      : file_open_kind := WRITE_MODE
  ) is
    type char_file is file of character;
    file     mem_f   : char_file;
    variable data_v  : character;
  begin
    if (file_name /= "") then
      file_open(mem_f, file_name, mode);
      for index_v in mem'range loop
        data_v := character'val(to_integer(unsigned(to_stdlogicvector(mem(index_v)))));
        write(mem_f, data_v);
      end loop;
    end if;
    file_close(mem_f);
  end procedure mem8_bv_dump_bin_f;

  -- dump mem8_bv_t array to 32-bit hex file --
  procedure mem8_bv_dump_hex32_f(
    file_name : string;
    mem       : mem8_bv_t;
    mode      : file_open_kind := WRITE_MODE
  ) is
    file     mem_f   : text;
    variable data_v  : bit_vector(32-1 downto 0);
    variable line_v  : line;
    variable byte_v  : integer range 0 to 3;
  begin
    if (file_name /= "") then
      file_open(mem_f, file_name, mode);
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
  pure function string2unsigned32 (
    str : string
  ) return unsigned is
    variable line_v : line;
    variable value_v : unsigned(32-1 downto 0);
  begin
    line_v := new string'(str) ;
    hread(line_v, value_v);
    return value_v;
  end function string2unsigned32;

end package body neorv32_io_pkg;

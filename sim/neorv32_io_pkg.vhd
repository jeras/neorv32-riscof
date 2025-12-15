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
  subtype bv8_t is bit_vector(8-1 downto 0);
  subtype bv32_t is bit_vector(32-1 downto 0);
  type array_bv8_t is array (natural range <>) of bv8_t;
  type array_bv32_t is array (natural range <>) of bv32_t;

  impure function array_bv8_init_bin_f(file_name : string; size : natural) return array_bv8_t;
  procedure array_bv8_dump_bin_f(file_name : string; array_i : array_bv8_t; mode : file_open_kind := WRITE_MODE);
  procedure array_bv8_dump_hex32_f(file_name : string; array_i : array_bv8_t; mode : file_open_kind := WRITE_MODE);
  pure function string2unsigned32 (str : string) return unsigned;

end package neorv32_io_pkg;

package body neorv32_io_pkg is

  -- 8-bit bit_vector array, binary file IO ----------------------------------------------------
  -- -------------------------------------------------------------------------------------------

  -- initialize array_bv8_t array from plain binary file --
  impure function array_bv8_init_bin_f(
    file_name : string;
    size      : natural
  ) return array_bv8_t is
    type char_file is file of character;
    file     init_f : char_file;
    variable array_v : array_bv8_t(0 to size-1);
    variable index_v : natural;
    variable data_v  : character;
  begin
    if (file_name /= "") then
      file_open(init_f, file_name, READ_MODE);
      index_v := 0;
      while (endfile(init_f) = false) and (index_v < size) loop
        read(init_f, data_v);
        array_v(index_v) := to_bitvector(std_logic_vector(to_unsigned(character'pos(data_v),8)));
        index_v := index_v + 1;
      end loop;
    end if;
    file_close(init_f);
    return array_v;
  end function array_bv8_init_bin_f;

  -- dump array_bv8_t array to plain binary file --
  procedure array_bv8_dump_bin_f(
    file_name : string;
    array_i   : array_bv8_t;
    mode      : file_open_kind := WRITE_MODE
  ) is
    type char_file is file of character;
    file     dump_f   : char_file;
    variable data_v  : character;
  begin
    if (file_name /= "") then
      file_open(dump_f, file_name, mode);
      for index_v in array_i'range loop
        data_v := character'val(to_integer(unsigned(to_stdlogicvector(array_i(index_v)))));
        write(dump_f, data_v);
      end loop;
    end if;
    file_close(dump_f);
  end procedure array_bv8_dump_bin_f;

  -- 8-bit bit_vector array, 32-bit hex file IO ------------------------------------------------
  -- -------------------------------------------------------------------------------------------

  -- initialize array_bv8_t array from 32-bit hex file --
  impure function array_bv8_init_hex32_f(
    file_name : string;
    size      : natural
  ) return array_bv8_t is
    type char_file is file of character;
    file     init_f : text;
    variable array_v : array_bv8_t(0 to size-1);
    variable index_v : natural;
    variable line_v  : line;
    variable data_v  : bit_vector(32-1 downto 0);
  begin
    if (file_name /= "") then
      file_open(init_f, file_name, READ_MODE);
      index_v := 0;
      while (endfile(init_f) = false) and (index_v < size) loop
        readline(init_f, line_v);
        hread(line_v, data_v);
        array_v(index_v+0) := data_v(07 downto 00);
        array_v(index_v+1) := data_v(15 downto 08);
        array_v(index_v+2) := data_v(23 downto 16);
        array_v(index_v+3) := data_v(31 downto 24);
        index_v := index_v + 4;
      end loop;
    end if;
    file_close(init_f);
    return array_v;
  end function array_bv8_init_hex32_f;

  -- dump array_bv8_t array to 32-bit hex file --
  procedure array_bv8_dump_hex32_f(
    file_name : string;
    array_i   : array_bv8_t;
    mode      : file_open_kind := WRITE_MODE
  ) is
    file     dump_f : text;
    variable data_v  : bit_vector(32-1 downto 0);
    variable line_v  : line;
    variable byte_v  : integer range 0 to 3;
  begin
    if (file_name /= "") then
      file_open(dump_f, file_name, mode);
      for index_v in array_i'range loop
        byte_v := index_v mod 4;
        case (byte_v) is
          when 0 => data_v(07 downto 00) := array_i(index_v);
          when 1 => data_v(15 downto 08) := array_i(index_v);
          when 2 => data_v(23 downto 16) := array_i(index_v);
          when 3 => data_v(31 downto 24) := array_i(index_v);
        end case;
        if byte_v = 3 then
          hwrite(line_v, data_v);
          for i in line_v'range loop
--          line_v(i) := to_lower(line_v(i));
            if line_v(i) >= 'A' and line_v(i) <= 'F' then
              line_v(i) := character'val (character'pos (line_v(i)) + 32);
            end if;
          end loop;
          writeline(dump_f, line_v);
        end if;
      end loop;
    end if;
    file_close(dump_f);
  end procedure array_bv8_dump_hex32_f;

  -- miscellaneous -----------------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------

  -- parse string to unsigned
  pure function string2unsigned32 (
    str : string
  ) return unsigned is
    variable line_v  : line;
    variable value_v : unsigned(32-1 downto 0);
  begin
    line_v := new string'(str) ;
    hread(line_v, value_v);
    return value_v;
  end function string2unsigned32;

end package body neorv32_io_pkg;

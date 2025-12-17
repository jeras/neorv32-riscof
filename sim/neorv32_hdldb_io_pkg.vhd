-- ================================================================================ --
-- neorv32_hdldb_io_pkg.vhd - IO package for testbenches                                  --
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

package neorv32_hdldb_io_pkg is

  -- file types
  type char_file is file of character;

  procedure write_bin(file f : char_file; vector_i : bit_vector);
  procedure write_bin(file f : char_file; vector_i : std_logic_vector);

  -- generic types
  type array_bit_vector       is array (natural range <>) of bit_vector;
  type array_std_logic_vector is array (natural range <>) of std_logic_vector;
  -- generic functions/procedures
  procedure dump_bin(file_name : in string; vector_i : in       bit_vector      ; mode : in file_open_kind := WRITE_MODE);
  procedure dump_bin(file_name : in string; array_i  : in array_bit_vector      ; mode : in file_open_kind := WRITE_MODE);
  procedure dump_bin(file_name : in string; vector_i : in       std_logic_vector; mode : in file_open_kind := WRITE_MODE);
  procedure dump_bin(file_name : in string; array_i  : in array_std_logic_vector; mode : in file_open_kind := WRITE_MODE);

end package neorv32_hdldb_io_pkg;

package body neorv32_hdldb_io_pkg is

  procedure write_bin(file f : char_file; vector_i : bit_vector) is
    variable data_v : character;
  begin
    for byte_v in 0 to vector_i'length/8-1 loop
      data_v := character'val(to_integer(unsigned(to_stdlogicvector(vector_i((byte_v+1)*8-1 downto (byte_v+0)*8)))));
      write(f, data_v);
    end loop;
  end procedure write_bin;

  procedure write_bin(file f : char_file; vector_i : std_logic_vector) is
    variable data_v : character;
  begin
    for byte_v in 0 to vector_i'length/8-1 loop
      data_v := character'val(to_integer(unsigned(vector_i((byte_v+1)*8-1 downto (byte_v+0)*8))));
      write(f, data_v);
    end loop;
  end procedure write_bin;


  -- dump array_bit_vector to plain binary file --
  procedure dump_bin(
    file_name : in  string;
    vector_i  : in  bit_vector;
    mode      : in  file_open_kind := WRITE_MODE
  ) is
    file     dump_f : char_file;
    variable data_v : character;
  begin
    if (file_name /= "") then
      file_open(dump_f, file_name, mode);
      write_bin(dump_f, vector_i);
    end if;
    file_close(dump_f);
  end procedure dump_bin;

  -- dump array_bit_vector array to plain binary file --
  procedure dump_bin(
    file_name : in  string;
    array_i   : in  array_bit_vector;
    mode      : in  file_open_kind := WRITE_MODE
  ) is
    file     dump_f   : char_file;
    variable data_v   : character;
  begin
    if (file_name /= "") then
      file_open(dump_f, file_name, mode);
      for index_v in array_i'range loop
        write_bin(dump_f, array_i(index_v));
      end loop;
    end if;
    file_close(dump_f);
  end procedure dump_bin;

  -- dump array_std_logic_vector to plain binary file --
  procedure dump_bin(
    file_name : in  string;
    vector_i  : in  std_logic_vector;
    mode      : in  file_open_kind := WRITE_MODE
  ) is
    file     dump_f : char_file;
    variable data_v : character;
  begin
    if (file_name /= "") then
      file_open(dump_f, file_name, mode);
      write_bin(dump_f, vector_i);
    end if;
    file_close(dump_f);
  end procedure dump_bin;

  -- dump array_std_logic_vector array to plain binary file --
  procedure dump_bin(
    file_name : in  string;
    array_i   : in  array_std_logic_vector;
    mode      : in  file_open_kind := WRITE_MODE
  ) is
    file     dump_f   : char_file;
    variable vector_i : array_i'element'subtype;
    variable data_v   : character;
  begin
    if (file_name /= "") then
      file_open(dump_f, file_name, mode);
      for index_v in array_i'range loop
        write_bin(dump_f, array_i(index_v));
      end loop;
    end if;
    file_close(dump_f);
  end procedure dump_bin;

end package body neorv32_hdldb_io_pkg;

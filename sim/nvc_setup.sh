#!/usr/bin/env bash

set -e

cd $(dirname "$0")

NEORV32_RTL=${NEORV32_RTL:-../neorv32/rtl}
SRC_FOLDER=${SRC_FOLDER:-.}

HDL=""
HDL+=" $NEORV32_RTL/core/neorv32_prim.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_package.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_application_image.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_bootloader_image.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_boot_rom.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_bus.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_cache.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_cfs.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_clint.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_cpu_control.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_cpu_counters.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_cpu_cp_bitmanip.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_cpu_cp_cfu.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_cpu_cp_cond.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_cpu_cp_crypto.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_cpu_cp_fpu.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_cpu_cp_muldiv.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_cpu_cp_shifter.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_cpu_decompressor.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_cpu_frontend.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_cpu_hwtrig.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_cpu_alu.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_cpu_lsu.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_cpu_pmp.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_cpu_regfile.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_cpu_trace.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_cpu.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_debug_auth.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_debug_dm.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_debug_dtm.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_dma.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_dmem.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_gpio.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_gptmr.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_imem.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_neoled.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_onewire.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_pwm.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_sdi.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_slink.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_spi.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_sysinfo.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_sys.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_tracer.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_trng.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_twd.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_twi.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_uart.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_wdt.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_xbus.vhd"
HDL+=" $NEORV32_RTL/core/neorv32_top.vhd"

#HDL+=" neorv32_io_pkg.vhd"
#HDL+=" neorv32_hdldb.vhd"
HDL+=" neorv32_riscof_tb_2019.vhd"

nvc --std=2019 --work=neorv32 -a $HDL
nvc --std=2019 --work=neorv32 -e neorv32_riscof_tb

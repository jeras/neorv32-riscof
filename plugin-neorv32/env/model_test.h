// model_test.h for the NEORV32 RISC-V Processor
// SPDX-License-Identifier: BSD-3-Clause

#ifndef _COMPLIANCE_MODEL_H
#define _COMPLIANCE_MODEL_H

#define ALIGNMENT 2

#define RVMODEL_DATA_SECTION \
        .pushsection .tohost,"aw",@progbits;              \
        .align 8; .global tohost; tohost: .dword 0;       \
        .align 8; .global fromhost; fromhost: .dword 0;   \
        .popsection;                                      \
        .align 8; .global begin_regstate; begin_regstate: \
        .word 128;                                        \
        .align 8; .global end_regstate; end_regstate:     \
        .word 4;

//RV_COMPLIANCE_HALT
#define RVMODEL_HALT   \
  li x1, 1;            \
  write_tohost:        \
    sw x1, tohost, t5; \
    j write_tohost;

// initialize hardware platform: install default trap handler to cancel run
// [note] use ".word 0x30551073" instead of "csrrw x0, mtvec, x10" as Zicsr might not be enabled
#define RVMODEL_BOOT           \
    la    x10, boot_terminate; \
    .word 0x30551073;          \
    j     boot_end;            \
  boot_terminate:              \
    li    x10, 1;              \
    sw    x10, tohost, t5;     \
    j     boot_terminate;      \
  boot_end:

// PMP configuration
#define RVMODEL_NUM_PMPS 16
#define RVMODEL_PMP_GRAIN 0

//RV_COMPLIANCE_DATA_BEGIN
#define RVMODEL_DATA_BEGIN \
  RVMODEL_DATA_SECTION     \
  .align 4;                \
  .global begin_signature; \
  begin_signature:

//RV_COMPLIANCE_DATA_END
#define RVMODEL_DATA_END \
  .align 4;              \
  .global end_signature; \
  end_signature:

// initializes IO for debug output: unused
#define RVMODEL_IO_INIT

// write string to console: unused
#define RVMODEL_IO_WRITE_STR(_R, _STR)

// debug assertion that GPR should have value: unused
#define RVMODEL_IO_ASSERT_GPR_EQ(_S, _R, _I)

// address that causes an access fault when read or written
#define ACCESS_FAULT_ADDRESS 0xFFFFFF00

// set machine software interrupt via CLINT
#define RVMODEL_SET_MSW_INT \
  li x10, 0xFFF40001;       \
  sw x10, -1(x10);

// clear machine software interrupt via CLINT
#define RVMODEL_CLR_MSW_INT \
  li x10,  0xFFF40000;      \
  sw zero, 0(x10);

// set machine timer interrupt via CLINT
#define RVMODEL_SET_MTIMER_INT \
  li x10,  0xFFF44000;         \
  sw zero, 4(x10);             \
  sw zero, 0(x10);

// clear machine timer interrupt via CLINT
#define RVMODEL_CLR_MTIMER_INT \
  li x10, 0xFFF44000;          \
  li x11, -1;                  \
  sw x11, 4(x10);              \
  sw x11, 0(x10);

// set machine external interrupt via testbench
#define RVMODEL_SET_MEXT_INT \
  li x10, 0xF000000C;        \
  li x11, 1<<11;             \
  sw x11, 0(x10);

// clear machine external interrupt via testbench
#define RVMODEL_CLR_MEXT_INT \
  li x10,  0xF000000C;       \
  sw zero, 0(x10);

#endif // _COMPLIANCE_MODEL_H

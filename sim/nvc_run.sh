#!/usr/bin/env bash

set -e

cd $(dirname "$0")

# run arguments
NVC_RUN_ARGS="${@}"
echo "======="
echo ${@}
echo "======="

# run simulation
# timeout as fall-back - simulation should be terminated by the testbench using "finish;"
nvc --std=2008 -r --work=neorv32 neorv32_riscof_tb \
  $NVC_RUN_ARGS \
  --ieee-warnings=off \
  --exit-severity=error \
  --stop-time=4ms

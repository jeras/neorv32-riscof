#!/usr/bin/env bash

set -e

cd $(dirname "$0")

# run arguments
NVC_RUN_ENV="${@}"
echo "======="
echo ${@}
echo "======="

# run simulation
# timeout as fall-back - simulation should be terminated by the testbench using "finish;"
export $NVC_RUN_ENV
nvc --std=2019 --work=neorv32 -H 128m -r neorv32_riscof_tb --wave=test.fst \
  --ieee-warnings=off \
  --exit-severity=error \
  --stop-time=4ms

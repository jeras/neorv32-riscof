# Python virtual environment
python3 -m venv .venv
source .venv/bin/activate
pip3 install jsoncomment

# GCC for RISC-V
wget -q https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/download/v15.2.0-1/xpack-riscv-none-elf-gcc-15.2.0-1-linux-x64.tar.gz
tar -xzf xpack-riscv-none-elf-gcc-15.2.0-1-linux-x64.tar.gz
export PATH=`pwd`/xpack-riscv-none-elf-gcc-15.2.0-1/bin:$PATH

# Sail simulator for RISC-V
wget -q https://github.com/riscv/sail-riscv/releases/download/0.9/sail-riscv-Linux-x86_64.tar.gz
tar -xzf sail-riscv-Linux-x86_64.tar.gz
export PATH=`pwd`/sail-riscv-Linux-x86_64/bin:$PATH

# Python dependencies
# pip3 install git+https://github.com/riscv/riscof.git@d38859f85fe407bcacddd2efcd355ada4683aee4
git submodule add https://github.com/riscv/riscof.git
cd riscof
git checkout d38859f
cd ..
pip3 install --editable riscof

#!/bin/bash
mkdir -p build output

ISA_STRING="rv64imafdqc_h_zaamo_zba_zbb_zbc_zbs_zfa_zfh_zfhmin_zicond_zicsr_zifencei"

echo "Assembling and linking debug_1.s..."
riscv64-unknown-elf-as --march=${ISA_STRING} debug_1.s -g -o build/debug_1.o
riscv64-unknown-elf-ld -T linker.ld build/debug_1.o -o build/debug_1.elf
riscv64-unknown-elf-objdump -S ./build/debug_1.o > build/debug_1.o.dump
riscv64-unknown-elf-objdump -S ./build/debug_1.elf > build/debug_1.elf.dump

echo "Assembling and linking debug_2.s..."
riscv64-unknown-elf-as --march=${ISA_STRING} debug_2.s -g -o build/debug_2.o
riscv64-unknown-elf-ld -T linker.ld build/debug_2.o -o build/debug_2.elf
riscv64-unknown-elf-objdump -S ./build/debug_2.o > build/debug_2.o.dump
riscv64-unknown-elf-objdump -S ./build/debug_2.elf > build/debug_2.elf.dump

echo "Running debug_1.elf in normal mode with detailed commit log..."
spike --isa=${ISA_STRING} --log-commits ./build/debug_1.elf > output/debug_1_normal.txt 2>&1

echo "Running debug_1.elf in debug mode with detailed commit log..."
echo "c" | spike --isa=${ISA_STRING} -d --log-commits ./build/debug_1.elf > output/debug_1_debug.txt 2>&1

echo "Running debug_2.elf in normal mode with detailed commit log..."
spike --isa=${ISA_STRING} --log-commits ./build/debug_2.elf > output/debug_2_normal.txt 2>&1

echo "Running debug_2.elf in debug mode with detailed commit log..."
echo "c" | spike --isa=${ISA_STRING} -d --log-commits ./build/debug_2.elf > output/debug_2_debug.txt 2>&1

echo "Running debug_1.elf with rocket..."
../emulators/rocket_emulator +verbose build/debug_1.elf > output/debug_1_rocket.txt 2>&1
echo "Running debug_2.elf with rocket..."
../emulators/rocket_emulator +verbose build/debug_2.elf > output/debug_2_rocket.txt 2>&1


#!/bin/bash
mkdir -p build output

ISA_STRING="rv64iaf_zba_zbb_zbs"

echo "Assembling and linking debug.s..."
riscv64-unknown-elf-as --march=${ISA_STRING} debug.s -g -o build/debug.o
riscv64-unknown-elf-ld -T linker.ld build/debug.o -o build/debug.elf
riscv64-unknown-elf-objdump -S ./build/debug.o > build/debug.o.dump
riscv64-unknown-elf-objdump -S ./build/debug.elf > build/debug.elf.dump

echo "Running debug.elf in normal mode with detailed commit log..."
spike --isa=${ISA_STRING} ./build/debug.elf > output/debug_normal.txt 2>&1

echo "Running without isa debug.elf in normal mode with detailed commit log..."
spike ./build/debug.elf > output/debug_normal_no_isa.txt 2>&1
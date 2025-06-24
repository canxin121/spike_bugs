# Spike Bug Report

## Reproduction Environment
- **Spike commit**: 70687ccf41bb2696c55c6f6aa44b3949f2921ddf
- **march**: rv64imafdqc_h_zaamo_zba_zbb_zbc_zbs_zfa_zfh_zfhmin_zicond_zicsr_zifencei
- **system environment**: [environment](environment.md)

## Bug Discovery

This bug was discovered during random instruction sequence testing.

## Minimized Reproduction Program

### debug_1.s
```riscv
# existing code ...
binvi x6, x21, 31
bclr x30, x6, x14
amoand.d.rl x28, x2, (x14)
max x4, x9, x30
sh2add x1, x25, x6
amomaxu.w.rl x10, x4, (x1)
hlv.hu x7, 0(x21)
# existing code ...
```

### debug_2.s

Remove the last `hlv.hu` instruction of `debug_1.s` to create `debug_2.s`:

```riscv
# existing code ...
binvi x6, x21, 31
bclr x30, x6, x14
amoand.d.rl x28, x2, (x14)
max x4, x9, x30
sh2add x1, x25, x6
amomaxu.w.rl x10, x4, (x1)
# existing code ...
```

## Reproduction Steps

```bash
bash ./run.sh
```

Check the content of the `run` script to understand the specific execution steps and parameter settings.

## Spike Execution Results

### debug_1.s
- **Normal mode**: Crashes after executing the `amomaxu.w a0, tp, (ra)` instruction (i.e., `amomaxu.w.rl x10, x4, (x1)`)
- **Debug mode**: Crashes after executing the `amomaxu.w a0, tp, (ra)` instruction (i.e., `amomaxu.w.rl x10, x4, (x1)`)

### debug_2.s
- **Normal mode**: Completes execution normally with no error output
- **Debug mode**: Crashes after executing the `amomaxu.w a0, tp, (ra)` instruction (i.e., `amomaxu.w.rl x10, x4, (x1)`)

## Rocket Execution Results

### debug_1.s

*** PASSED *** Completed after 28712 cycles

### debug_2.s

*** PASSED *** Completed after 28712 cycles
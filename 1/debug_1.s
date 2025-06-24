.section .tohost, "aw", @progbits
.align 6
.globl tohost
tohost:   .dword 0
.globl fromhost
fromhost: .dword 0

.section .text
.globl _start

exception_handler:
    csrr t0, mepc
    addi t0, t0, 4
    csrw mepc, t0
    mret

_start:
    la   t0, exception_handler
    csrw mtvec, t0

    binvi x6, x21, 31
    bclr x30, x6, x14
    amoand.d.rl x28, x2, (x14)
    max x4, x9, x30
    sh2add x1, x25, x6
    amomaxu.w.rl x10, x4, (x1)
    hlv.hu x7, 0(x21)

    li   t0, 1
    la   t1, tohost
    sd   t0, 0(t1)

infinite_loop:
    j infinite_loop

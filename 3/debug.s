# ----------------------------------------------------------------------------
# .macro EXIT_SIM
# ----------------------------------------------------------------------------
.macro EXIT_SIM
    li   t0, 1; la   t1, tohost; sd   t0, 0(t1)
infinite_exit_loop_\@: j infinite_exit_loop_\@
.endm

.section .tohost, "aw", @progbits
.align 6
.globl tohost
tohost:   .dword 0
.globl fromhost
fromhost: .dword 0

.section .text
.globl _start

# ============================================================================
# Exception Handler
# ============================================================================
exception_handler:
    # Get exception instruction address
    csrr t0, mepc
    
    # Read exception instruction content to determine length
    lhu t1, 0(t0)
    andi t2, t1, 0x3
    li t3, 0x3
    bne t2, t3, compressed_inst
    
    # Standard instruction (4 bytes)
    addi t0, t0, 4
    j update_mepc
    
compressed_inst:
    # Compressed instruction (2 bytes)
    addi t0, t0, 2
    
update_mepc:
    csrw mepc, t0
    csrwi mcause, 0
    csrwi mtval, 0
    csrwi mip, 0

    mret

# ============================================================================
# Program Entry and Execution
# ============================================================================
_start:
    la t0, exception_handler
    csrw mtvec, t0

    ctzw x14, x1
    sh2add.uw x30, x14, x21
    slli.uw x17, x30, 32
    min x30, x3, x19
    bseti x30, x30, 31
    amoadd.d x14, x17, (x30)
    lhu x17, 545(x15)

_exit:
    EXIT_SIM

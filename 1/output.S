# ============================================================================
# 宏定义 - Macro Definitions
# ============================================================================

# ----------------------------------------------------------------------------
# .macro SAVE_T_REGS / RESTORE_T_REGS
# ----------------------------------------------------------------------------
.macro SAVE_T_REGS save_area_label
    csrw mscratch, t6
    la   t6, \save_area_label
    sd   t0,  0(t6); sd   t1,  8(t6); sd   t2, 16(t6)
    sd   t3, 24(t6); sd   t4, 32(t6); sd   t5, 40(t6)
    csrr t5, mscratch
    sd   t5, 48(t6)
    csrr t6, mscratch
.endm

.macro RESTORE_T_REGS save_area_label
    csrw mscratch, t6
    la   t6, \save_area_label
    ld   t0,  0(t6); ld   t1,  8(t6); ld   t2, 16(t6)
    ld   t3, 24(t6); ld   t4, 32(t6); ld   t5, 40(t6)
    ld   t6, 48(t6)
    csrr t6, mscratch
.endm

# ----------------------------------------------------------------------------
# .macro HTIF_PRINT_RAW
# ----------------------------------------------------------------------------
# 功能: 通过HTIF打印数据，不保护调用者寄存器
# 参数:
#   data_label: 要打印的数据标签
#   data_size: 数据大小
# 注意: 此宏会修改 t0-t6 寄存器，调用者需要自行保护
.macro HTIF_PRINT_RAW data_label, data_size
    la   t0, htif_communication_buffer
    li   t1, 64; sd t1, 0(t0); li   t1, 1;   sd t1, 8(t0)
    la   t1, \data_label; sd t1, 16(t0); li   t1, \data_size;   sd t1, 24(t0)
    fence; la   t1, tohost; sd t0, 0(t1)
wait_htif_print_\@:
    la   t2, fromhost; ld t3, 0(t2); beqz t3, wait_htif_print_\@
    sd   zero, 0(t2); fence
.endm

# ----------------------------------------------------------------------------
# .macro HTIF_PRINT
# ----------------------------------------------------------------------------
# 为了向后兼容，提供一个自动保存寄存器的版本
.macro HTIF_PRINT temp_save_area, data_label, data_size
    SAVE_T_REGS \temp_save_area
    HTIF_PRINT_RAW \data_label, \data_size
    RESTORE_T_REGS \temp_save_area
.endm

# ----------------------------------------------------------------------------
# .macro DUMP_ALL_REGS_RAW
# ----------------------------------------------------------------------------
# 功能: 转储所有寄存器，不保护调用者寄存器
# 注意: 此宏会修改 t0-t6 寄存器，调用者需要自行保护
.macro DUMP_ALL_REGS_RAW
    csrw mscratch, t6
    la t6, register_dump_buffer

    # 转储所有通用寄存器 (x0-x31)
    sd  x0,   0(t6); sd  x1,   8(t6); sd  x2,  16(t6); sd  x3,  24(t6)
    sd  x4,  32(t6); sd  x5,  40(t6); sd  x6,  48(t6); sd  x7,  56(t6)
    sd  x8,  64(t6); sd  x9,  72(t6); sd x10,  80(t6); sd x11,  88(t6)
    sd x12,  96(t6); sd x13, 104(t6); sd x14, 112(t6); sd x15, 120(t6)
    sd x16, 128(t6); sd x17, 136(t6); sd x18, 144(t6); sd x19, 152(t6)
    sd x20, 160(t6); sd x21, 168(t6); sd x22, 176(t6); sd x23, 184(t6)
    sd x24, 192(t6); sd x25, 200(t6); sd x26, 208(t6); sd x27, 216(t6)
    sd x28, 224(t6); sd x29, 232(t6); sd x30, 240(t6)
    csrr t5, mscratch
    sd t5, 248(t6)

#if __riscv_flen > 0
    # F/D 扩展存在: 转储浮点寄存器
    csrr t0, mstatus
    li   t1, (1 << 13) # MSTATUS_FS_INITIAL
    or   t1, t0, t1
    csrw mstatus, t1

    fsw f0,  256(t6); fsw f1,  264(t6); fsw f2,  272(t6); fsw f3,  280(t6)
    fsw f4,  288(t6); fsw f5,  296(t6); fsw f6,  304(t6); fsw f7,  312(t6)
    fsw f8,  320(t6); fsw f9,  328(t6); fsw f10, 336(t6); fsw f11, 344(t6)
    fsw f12, 352(t6); fsw f13, 360(t6); fsw f14, 368(t6); fsw f15, 376(t6)
    fsw f16, 384(t6); fsw f17, 392(t6); fsw f18, 400(t6); fsw f19, 408(t6)
    fsw f20, 416(t6); fsw f21, 424(t6); fsw f22, 432(t6); fsw f23, 440(t6)
    fsw f24, 448(t6); fsw f25, 456(t6); fsw f26, 464(t6); fsw f27, 472(t6)
    fsw f28, 480(t6); fsw f29, 488(t6); fsw f30, 496(t6); fsw f31, 504(t6)

    csrw mstatus, t0

    HTIF_PRINT_RAW reg_dump_prefix_x_and_f, 8
    HTIF_PRINT_RAW register_dump_buffer, 512
#else
    HTIF_PRINT_RAW reg_dump_prefix_x_only, 8
    HTIF_PRINT_RAW register_dump_buffer, 256
#endif
    csrw mscratch, zero
.endm

# ----------------------------------------------------------------------------
# .macro DUMP_ALL_REGS
# ----------------------------------------------------------------------------
.macro DUMP_ALL_REGS temp_save_area
    SAVE_T_REGS \temp_save_area
    DUMP_ALL_REGS_RAW
    RESTORE_T_REGS \temp_save_area
.endm

# ----------------------------------------------------------------------------
# .macro DUMP_EXCEPTION_CSRS_RAW
# ----------------------------------------------------------------------------
# 功能: 转储异常CSRs，不保护调用者寄存器
# 参数: marker_label: 标识前缀标签
# 注意: 此宏会修改 t0-t6 寄存器，调用者需要自行保护
.macro DUMP_EXCEPTION_CSRS_RAW marker_label
    la   t0, exception_csr_dump_buffer
    csrr t1, mstatus; sd t1,  0(t0); csrr t1, mcause;  sd t1,  8(t0)
    csrr t1, mepc;    sd t1, 16(t0); csrr t1, mtval;   sd t1, 24(t0)
    csrr t1, mie;     sd t1, 32(t0); csrr t1, mip;     sd t1, 40(t0)
    csrr t1, mtvec;   sd t1, 48(t0); csrr t1, mscratch;sd t1, 56(t0)
    csrr t1, mhartid; sd t1, 64(t0)
    HTIF_PRINT_RAW \marker_label, 8
    HTIF_PRINT_RAW exception_csr_dump_buffer, 72
.endm

# ----------------------------------------------------------------------------
# .macro DUMP_EXCEPTION_CSRS
# ----------------------------------------------------------------------------
.macro DUMP_EXCEPTION_CSRS temp_save_area1, temp_save_area2, marker_label
    SAVE_T_REGS \temp_save_area1
    DUMP_EXCEPTION_CSRS_RAW \marker_label
    RESTORE_T_REGS \temp_save_area1
.endm

# ----------------------------------------------------------------------------
# .macro EXIT_SIM
# ----------------------------------------------------------------------------
.macro EXIT_SIM
    li   t0, 1; la   t1, tohost; sd   t0, 0(t1)
infinite_exit_loop_\@: j infinite_exit_loop_\@
.endm

# ----------------------------------------------------------------------------
# .macro RESET_MACHINE_STATE
# ----------------------------------------------------------------------------
.macro RESET_MACHINE_STATE
    # 步骤 1: 重置关键的控制和状态寄存器 (CSRs)
    csrwi   mstatus, 0
    csrwi   mie, 0
    csrwi   mip, 0
    csrwi   mepc, 0
    csrwi   mtval, 0
    csrwi   mscratch, 0

#if __riscv_flen > 0
    # 步骤 2: 如果存在浮点扩展 (F或D)，清零浮点状态
    csrr t0, mstatus
    li   t1, (1 << 13)
    or   t0, t0, t1
    csrw mstatus, t0
    csrwi   fcsr, 0
    fmv.w.x f0, x0; fmv.w.x f1, x0; fmv.w.x f2, x0; fmv.w.x f3, x0
    fmv.w.x f4, x0; fmv.w.x f5, x0; fmv.w.x f6, x0; fmv.w.x f7, x0
    fmv.w.x f8, x0; fmv.w.x f9, x0; fmv.w.x f10, x0; fmv.w.x f11, x0
    fmv.w.x f12, x0; fmv.w.x f13, x0; fmv.w.x f14, x0; fmv.w.x f15, x0
    fmv.w.x f16, x0; fmv.w.x f17, x0; fmv.w.x f18, x0; fmv.w.x f19, x0
    fmv.w.x f20, x0; fmv.w.x f21, x0; fmv.w.x f22, x0; fmv.w.x f23, x0
    fmv.w.x f24, x0; fmv.w.x f25, x0; fmv.w.x f26, x0; fmv.w.x f27, x0
    fmv.w.x f28, x0; fmv.w.x f29, x0; fmv.w.x f30, x0; fmv.w.x f31, x0
#endif

    # 步骤 3: 清零所有通用寄存器 (GPRs)
    mv x1,  zero; mv x2,  zero; mv x3,  zero; mv x4,  zero
    mv x5,  zero; mv x6,  zero; mv x7,  zero; mv x8,  zero
    mv x9,  zero; mv x10, zero; mv x11, zero; mv x12, zero
    mv x13, zero; mv x14, zero; mv x15, zero; mv x16, zero
    mv x17, zero; mv x18, zero; mv x19, zero; mv x20, zero
    mv x21, zero; mv x22, zero; mv x23, zero; mv x24, zero
    mv x25, zero; mv x26, zero; mv x27, zero; mv x28, zero
    mv x29, zero; mv x30, zero; mv x31, zero
.endm

# ============================================================================
# 内存与数据区定义
# ============================================================================
.section .bss
.align 4
register_dump_buffer:       .zero 512
exception_csr_dump_buffer: .zero 72
framework_temp_save_area:   .zero 64

.section .data
.align 6
htif_communication_buffer: .zero 64

#if __riscv_flen > 0
reg_dump_prefix_x_and_f:
    .dword 0xFEEDC0DEBBBB0002
#endif

#if __riscv_flen == 0
reg_dump_prefix_x_only:
    .dword 0xFEEDC0DEAAAA0001
#endif

exc_csr_dump_prefix:
    .dword 0xBADBADBADBADBAD0

.section .tohost, "aw", @progbits
.align 6
.globl tohost
tohost:   .dword 0
.globl fromhost
fromhost: .dword 0

.section .text
.globl _start

# ============================================================================
# 异常处理程序
# ============================================================================
exception_handler:
    # 一次性保存寄存器，避免嵌套
    SAVE_T_REGS framework_temp_save_area
    
    # 转储异常CSR信息 - 使用RAW版本避免额外的保存/恢复
    DUMP_EXCEPTION_CSRS_RAW exc_csr_dump_prefix
    
    # 获取异常指令地址
    csrr t0, mepc
    
    # 读取异常指令的内容来判断长度
    lhu t1, 0(t0)
    andi t2, t1, 0x3
    li t3, 0x3
    bne t2, t3, compressed_inst
    
    # 标准指令(4字节)
    addi t0, t0, 4
    j update_mepc
    
compressed_inst:
    # 压缩指令(2字节)
    addi t0, t0, 2
    
update_mepc:
    csrw mepc, t0
    csrwi mcause, 0
    csrwi mtval, 0
    csrwi mip, 0

    # 一次性恢复寄存器
    RESTORE_T_REGS framework_temp_save_area
    mret

# ============================================================================
# 程序入口与执行
# ============================================================================
_start:
    # 1. 设置异常处理程序地址
    la t0, exception_handler
    csrw mtvec, t0

    # 2. 重置机器状态，确保一个干净的开始
    RESET_MACHINE_STATE

    # 3. 用户代码
  # ============================================================================
  # 自动生成的随机指令 - 531 条指令 (实际生成)
  # 目标指令数: 650 条 (来自 13 个扩展)
  # ISA March: rv64imafc_h_zaamo_zba_zbb_zbs_zfa_zicsr_zifencei
  # 目标: Rocket & Spike 差分测试
  # 覆盖的扩展: [Zifencei, C, I, Zbs, F, M, Zicsr, Zba, Zbb, H, S, Zaamo, Zalrsc]
  # ============================================================================
  c.sub x11, x9
  bclr x14, x22, x20
  srai x11, x26, 21
  amoand.w.rl x25, x7, (x5)
  fence.i
  clzw x25, x22
  subw x31, x31, x25
  hlv.b x31, 0(x16)
  fence.i
  cpopw x5, x2
  min x5, x9, x28
  fence.i
  csrrc x29, 0xc75, x11
  amoadd.w.aqrl x24, x29, (x16)
  amoswap.w x12, x17, (x30)
  mulhu x18, x25, x0
  fence.i
  sub x3, x2, x31
  fmadd.s f17, f12, f24, f10, dyn
  amoand.d x26, x3, (x4)
  c.swsp x10, 8(sp)
  c.andi x15, 0
  c.addiw x9, 22
  fence.i
  sb x4, -971(x14)
  hsv.w x3, 0(x19)
  fence.i
  max x30, x11, x26
  sh3add x2, x2, x31
  sh2add x14, x2, x4
  hlv.w x15, 0(x23)
  slli.uw x1, x26, 0
  fence.i
  hsv.d x16, 0(x30)
  fence.i
  fence.i
  c.addi x29, 15
  csrrs x13, 0x432, x14
  hlv.bu x27, 0(x21)
  remuw x14, x5, x11
  fence.i
  sext.h x14, x22
  mul x14, x2, x15
  csrrsi x15, 0x692, 5
  csrrci x5, 0xa6d, 30
  flt.s x0, f5, f29
  sh2add.uw x31, x10, x6
  bext x3, x4, x0
  sub x24, x27, x11
  or x17, x6, x2
  # 指令 51 - 100
  add.uw x23, x1, x5
  binvi x6, x21, 31
  amoadd.d.rl x3, x2, (x15)
  hlvx.hu x23, 0(x27)
  bexti x27, x16, 6
  c.addi4spn x13, sp, 212
  csrrc x30, 0x5f2, x16
  sraw x26, x22, x0
  xor x9, x20, x17
  c.lw x9, 8(x15)
  csrrs x25, 0xca4, x6
  c.subw x12, x9
  c.ebreak
  amominu.w.aq x26, x4, (x13)
  bexti x27, x19, 19
  remw x31, x28, x29
  fence.i
  hsv.b x27, 0(x16)
  sh2add x16, x27, x14
  bext x14, x5, x4
  amoxor.d.rl x7, x21, (x15)
  csrrc x6, 0x5ca, x16
  fence.i
  remuw x10, x30, x19
  bext x9, x14, x7
  divw x30, x13, x27
  fle.s x5, f30, f1
  max x19, x9, x18
  sh1add.uw x8, x2, x28
  zext.h x0, x14
  sext.h x21, x6
  sh3add x21, x18, x29
  hlv.w x10, 0(x27)
  csrrw x23, 0x257, x8
  hsv.w x28, 0(x4)
  fle.s x5, f15, f30
  sh2add x12, x18, x18
  fence.i
  remw x18, x28, x14
  fence.i
  bclr x30, x6, x14
  cpop x31, x2
  csrrw x24, 0x9aa, x26
  fnmadd.s f28, f6, f5, f2, rmm
  fdiv.s f23, f27, f24, dyn
  bexti x25, x12, 5
  addw x3, x19, x12
  cpopw x26, x0
  srli x16, x5, 51
  c.addi x23, -26
  # 指令 101 - 150
  csrrsi x6, 0xb93, 27
  c.or x9, x15
  csrrci x14, 0x324, 16
  c.slli x20, 19
  hlv.w x24, 0(x5)
  sh1add x14, x26, x9
  hlv.d x21, 0(x6)
  bclr x8, x31, x9
  amoadd.w.rl x25, x4, (x9)
  sh3add.uw x8, x24, x10
  mulhsu x22, x16, x17
  c.sd x9, 0(x11)
  mulw x13, x1, x27
  mulhsu x4, x1, x22
  fltq.s x27, f2, f25
  sext.b x29, x8
  amoand.d.rl x28, x2, (x14)
  max x4, x9, x30
  ld x26, 2040(x17)
  c.sd x13, 8(x10)
  amoswap.w x2, x21, (x22)
  sh2add x1, x25, x6
  fence.i
  bclri x22, x14, 42
  remu x2, x5, x15
  sh1add.uw x2, x16, x1
  cpopw x30, x6
  csrrci x29, 0x95a, 25
  bclri x15, x3, 43
  amomaxu.w.rl x10, x4, (x1)
  c.li x28, 21
  hlv.hu x7, 0(x21)
  c.addw x10, x15
  remuw x10, x7, x18
  rem x12, x23, x0
  csrrc x20, 0xe43, x29
  fence.i
  mulh x13, x18, x22
  fnmsub.s f12, f0, f10, f10, rmm
  csrrsi x31, 0x6e0, 24
  sh2add x13, x9, x21
  fence.i
  clzw x18, x30
  fclass.s x25, f28
  csrrwi x26, 0x273, 24
  or x17, x6, x14
  c.ld x12, 0(x14)
  lhu x27, -72(x23)
  bset x11, x5, x19
  divu x13, x31, x16
  # 指令 151 - 200
  cpopw x26, x10
  hlv.wu x13, 0(x22)
  addiw x13, x15, 1676
  orc.b x12, x23
  amoadd.w.aqrl x3, x21, (x5)
  slli.uw x10, x14, 28
  csrrci x2, 0xb4e, 3
  zext.h x14, x14
  fence.i
  sh2add.uw x4, x15, x25
  sh1add.uw x21, x15, x0
  sh3add x24, x16, x6
  maxu x3, x1, x23
  divuw x0, x7, x29
  slli.uw x17, x27, 45
  csrrw x7, 0xe2b, x20
  mulhu x4, x14, x11
  hlv.h x17, 0(x31)
  binv x26, x30, x26
  mulh x23, x30, x26
  slli.uw x25, x16, 59
  hlvx.wu x20, 0(x4)
  amoadd.w.aqrl x9, x16, (x30)
  amomax.d.aqrl x24, x23, (x24)
  sh2add.uw x7, x21, x9
  srli x29, x18, 4
  amoadd.d x26, x24, (x14)
  c.ldsp x8, 32(sp)
  bclr x5, x17, x25
  froundnx.s f31, f11, dyn
  c.subw x11, x10
  sh2add x10, x21, x17
  c.or x9, x15
  fence.i
  mul x7, x23, x12
  fsgnjn.s f20, f14, f10
  c.addi x13, -12
  fsgnjn.s f18, f22, f15
  csrrwi x16, 0x70a, 3
  slt x10, x5, x10
  slli.uw x1, x22, 43
  fcvt.s.wu f26, x20, rup
  sh3add x16, x14, x31
  sraw x27, x18, x27
  divuw x6, x7, x2
  bset x7, x14, x2
  c.addi16sp sp, -32
  remu x7, x18, x18
  amoswap.w.aq x14, x4, (x29)
  mulw x4, x29, x3
  # 指令 201 - 250
  fence.i
  orc.b x9, x12
  fence.i
  slli.uw x24, x5, 8
  c.sub x8, x9
  slli.uw x11, x20, 21
  fmadd.s f9, f14, f10, f19, rup
  slli.uw x2, x13, 1
  remuw x3, x21, x3
  binv x0, x18, x21
  hsv.b x24, 0(x30)
  c.ld x12, 0(x15)
  csrrwi x5, 0xc9d, 31
  amoxor.d x26, x8, (x17)
  mulhsu x26, x26, x1
  c.slli x5, 25
  c.addiw x12, -19
  hlv.h x7, 0(x31)
  sh3add x7, x13, x10
  c.and x11, x13
  amoswap.d.rl x14, x10, (x7)
  hlv.d x25, 0(x9)
  hlv.d x19, 0(x30)
  amomaxu.d.aq x31, x25, (x2)
  csrrc x19, 0x4e9, x23
  clz x6, x23
  hlv.bu x29, 0(x6)
  hsv.w x0, 0(x11)
  fence.i
  slt x1, x27, x20
  xor x6, x31, x14
  div x22, x14, x29
  bclr x30, x18, x23
  fli.s f6, 0x1.0p-7
  fround.s f12, f6, rtz
  csrrwi x27, 0x65a, 11
  hsv.h x25, 0(x7)
  bseti x10, x0, 40
  fence.i
  csrrwi x30, 0x66d, 26
  sh1add x12, x30, x17
  bseti x26, x28, 33
  fsgnjx.s f13, f27, f13
  c.add x15, x29
  bseti x0, x22, 46
  amomaxu.d.aq x7, x25, (x31)
  orc.b x9, x8
  fence.i
  addi x18, x20, 187
  csrrc x20, 0x753, x6
  # 指令 251 - 300
  fsgnj.s f29, f30, f13
  c.addi4spn x9, sp, 56
  mulw x8, x14, x24
  hlvx.hu x20, 0(x29)
  amominu.w.rl x15, x25, (x30)
  hlvx.hu x24, 0(x7)
  sh2add.uw x22, x6, x16
  binv x15, x15, x9
  sh3add.uw x12, x31, x18
  sh2add x5, x23, x14
  amoor.d x11, x2, (x10)
  fence.i
  fence.i
  bclri x24, x1, 0
  bclri x2, x20, 6
  c.sw x12, 24(x11)
  orc.b x18, x27
  c.addi x14, 14
  srlw x24, x12, x11
  addw x20, x14, x4
  flw f8, -1817(x8)
  fence.i
  fence.i
  zext.h x15, x31
  fnmsub.s f19, f13, f27, f12, dyn
  fence.i
  amomaxu.w.aq x6, x30, (x15)
  mulhu x29, x20, x18
  fence ior, ir
  csrrc x6, 0x32c, x6
  fsgnj.s f20, f21, f22
  min x3, x11, x18
  binvi x24, x25, 5
  fcvt.s.w f27, x31, dyn
  divu x2, x19, x13
  fence.i
  fence.i
  amoxor.d.aqrl x10, x29, (x2)
  bexti x13, x16, 49
  amoxor.w.rl x17, x15, (x26)
  fltq.s x27, f19, f29
  bclri x17, x13, 34
  sh3add.uw x28, x4, x13
  fence.i
  hlv.bu x2, 0(x18)
  fnmsub.s f22, f25, f13, f23, dyn
  hlv.h x1, 0(x0)
  mulw x20, x5, x19
  fence.i
  amoor.d.rl x23, x6, (x16)
  # 指令 301 - 350
  amominu.w.aqrl x1, x31, (x23)
  bset x11, x25, x16
  zext.h x10, x8
  sll x20, x26, x8
  csrrwi x5, 0x821, 2
  fence.i
  bclr x2, x29, x21
  amoadd.w.aqrl x25, x13, (x16)
  amominu.d.rl x17, x21, (x9)
  orc.b x10, x25
  zext.h x18, x4
  fclass.s x29, f1
  fence.i
  c.li x7, -9
  max x17, x18, x25
  csrrci x12, 0xda2, 7
  fcvt.l.s x24, f17, rdn
  amoxor.w.rl x18, x25, (x23)
  c.or x8, x9
  fleq.s x7, f31, f30
  csrrw x16, 0xf2a, x31
  bset x7, x7, x18
  fmsub.s f3, f28, f16, f21, rmm
  divw x12, x17, x19
  binv x12, x3, x13
  sh1add x29, x29, x26
  hsv.w x10, 0(x31)
  sh3add x8, x8, x18
  divw x26, x15, x3
  csrrwi x23, 0x137, 25
  fmul.s f14, f2, f24, dyn
  hlv.hu x15, 0(x18)
  binvi x15, x24, 46
  amominu.d.aq x14, x2, (x21)
  fence.i
  fsgnj.s f1, f16, f29
  csrrw x5, 0x4d5, x9
  divu x9, x19, x13
  max x27, x22, x23
  fcvt.s.lu f31, x31, rup
  div x31, x18, x21
  cpop x10, x11
  fround.s f18, f26, rne
  c.xor x9, x8
  fence.i
  fmsub.s f15, f1, f22, f1, rmm
  sh3add.uw x25, x11, x26
  amoadd.d x2, x18, (x9)
  slli.uw x31, x11, 60
  binvi x0, x19, 48
  # 指令 351 - 400
  mul x21, x18, x12
  ctzw x6, x0
  fence.i
  hlvx.hu x30, 0(x10)
  amominu.d.aq x28, x2, (x11)
  csrrwi x11, 0x273, 28
  mulw x19, x1, x12
  divu x12, x3, x28
  mulhu x11, x22, x10
  csrrci x21, 0xa2e, 8
  c.sdsp x5, 56(sp)
  fnmsub.s f23, f29, f6, f7, dyn
  cpopw x28, x10
  fence.i
  ctz x1, x18
  fence.i
  max x21, x20, x27
  hsv.d x28, 0(x4)
  fclass.s x6, f29
  fence ir, o
  fence.i
  c.ebreak
  amomaxu.d.aqrl x19, x22, (x20)
  rem x2, x0, x2
  sb x11, 1942(x12)
  fence.i
  csrrwi x27, 0x770, 2
  csrrs x21, 0xa85, x3
  fcvt.s.l f22, x13, dyn
  hlvx.hu x21, 0(x26)
  c.li x3, 31
  zext.h x25, x3
  amoor.d.rl x4, x3, (x31)
  hlv.bu x25, 0(x12)
  c.and x15, x10
  csrrs x25, 0x8ee, x19
  csrrwi x0, 0x320, 10
  bext x8, x12, x22
  binvi x0, x16, 52
  slti x30, x15, -366
  fence.i
  bset x30, x13, x19
  fcvt.w.s x26, f31, rup
  hsv.d x22, 0(x2)
  slli.uw x31, x19, 58
  sh3add.uw x5, x25, x5
  rem x11, x30, x17
  c.add x25, x14
  bseti x23, x9, 30
  c.sw x11, 28(x14)
  # 指令 401 - 450
  clzw x25, x0
  mul x19, x9, x11
  amoand.d.aqrl x2, x18, (x28)
  amomaxu.w.rl x25, x24, (x12)
  fence.i
  max x3, x7, x1
  sh1add.uw x9, x22, x6
  sh2add.uw x6, x26, x17
  csrrs x1, 0x50c, x12
  hlvx.hu x28, 0(x6)
  fmadd.s f30, f20, f16, f4, rmm
  fence.i
  fltq.s x23, f20, f29
  andi x18, x26, 46
  csrrci x10, 0xe19, 5
  fmv.x.w x5, f7
  c.ldsp x2, 16(sp)
  amoand.d.rl x4, x29, (x16)
  amoand.w.aq x0, x18, (x17)
  clz x17, x0
  sh3add x12, x20, x9
  amomaxu.w x14, x24, (x25)
  csrrc x20, 0xfbc, x5
  hsv.h x0, 0(x12)
  sext.b x29, x13
  minu x24, x21, x7
  csrrc x16, 0xd3f, x23
  hsv.d x14, 0(x22)
  csrrw x13, 0x65d, x13
  lhu x28, -1489(x23)
  ctz x8, x15
  flt.s x14, f13, f30
  mulw x27, x6, x19
  amoxor.d.aq x8, x4, (x29)
  amominu.d.aq x18, x30, (x5)
  fence.i
  hlvx.hu x31, 0(x7)
  binv x7, x30, x1
  c.addiw x3, -14
  andi x2, x8, 1897
  mulw x9, x11, x3
  hlv.d x6, 0(x0)
  csrrwi x21, 0x3aa, 20
  amoor.d x5, x31, (x8)
  remuw x9, x20, x10
  bclri x7, x12, 34
  bexti x16, x1, 52
  remu x13, x15, x26
  csrrw x30, 0xff1, x5
  hlv.d x26, 0(x16)
  # 指令 451 - 500
  bclri x9, x2, 55
  amomax.w.aq x23, x2, (x9)
  fmv.w.x f19, x0
  fence.i
  csrrw x4, 0x200, x23
  amomin.d.aq x6, x25, (x19)
  amomin.d.rl x30, x28, (x25)
  slli.uw x3, x25, 59
  ctz x27, x30
  sext.h x20, x26
  bexti x14, x9, 45
  add.uw x19, x18, x10
  ctzw x27, x18
  fence.i
  fence.i
  csrrw x9, 0x756, x21
  add.uw x3, x16, x0
  hlv.wu x28, 0(x19)
  sh2add x26, x25, x28
  csrrs x26, 0x71c, x20
  c.ld x12, 24(x10)
  hlv.h x1, 0(x28)
  csrrs x28, 0xd22, x9
  sltu x0, x25, x31
  c.xor x14, x9
  sltu x24, x16, x13
  min x16, x12, x14
  fmv.w.x f17, x24
  sh x22, 542(x28)
  amoadd.w.aq x14, x3, (x21)
  bclri x15, x1, 12
  fence.i
  bclri x24, x22, 59
  sll x1, x17, x13
  hsv.d x8, 0(x26)
  sh2add x16, x7, x23
  fminm.s f13, f28, f21
  divu x10, x15, x7
  clzw x18, x5
  sra x8, x29, x21
  bclr x27, x18, x10
  flw f28, 459(x3)
  fsgnj.s f13, f10, f20
  bexti x9, x2, 31
  sh3add x19, x16, x0
  hlv.w x7, 0(x13)
  csrrwi x27, 0x959, 5
  ctzw x16, x13
  fmsub.s f28, f25, f13, f21, rne
  bseti x3, x19, 55
  # 指令 501 - 531
  c.srli x10, 47
  sh2add x19, x0, x17
  remuw x2, x18, x27
  binvi x5, x21, 59
  csrrw x19, 0x3c3, x6
  divuw x9, x23, x10
  csrrs x20, 0x3b6, x6
  mulw x23, x19, x17
  fcvt.l.s x3, f17, dyn
  ld x25, -1598(x6)
  hlv.w x6, 0(x22)
  minu x24, x20, x26
  csrrw x0, 0xe77, x22
  hlv.hu x3, 0(x21)
  divu x17, x15, x16
  ld x17, -1997(x2)
  sh2add.uw x29, x5, x8
  bclr x2, x5, x16
  clzw x5, x31
  amoxor.d x16, x26, (x25)
  or x16, x29, x3
  c.lui x19, 0xfffee
  fnmsub.s f16, f0, f28, f22, rne
  bexti x27, x3, 48
  slli x25, x30, 45
  sraw x10, x17, x29
  amoand.w x5, x8, (x0)
  amoxor.d x3, x21, (x11)
  fminm.s f8, f31, f10
  remu x13, x11, x8
  sext.h x30, x5
  # ============================================================================
  # 随机指令生成完成 - 总共 531 条
  # ============================================================================

    # 4. 打印所有寄存器状态 - 使用RAW版本，在此处一次性保存/恢复
    SAVE_T_REGS framework_temp_save_area
    DUMP_ALL_REGS_RAW
    RESTORE_T_REGS framework_temp_save_area

    # 5. 结束程序
    EXIT_SIM

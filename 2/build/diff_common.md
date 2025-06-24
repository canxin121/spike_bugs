# Common Execution Output Diff Report

Comparison: Spike vs Rocket

## Differences Detected

| Diff Type | Count |
|----------|------|
| Register Content | 2 register dumps have content differences |
| Output Item Status | Item count or content differs |
| Exception Dumps | Exception information differs |

## Detailed Diff Analysis

### Register Content Differences

Found 2 dumps with differences:

#### Dump Index 0 (#1 in sequence)

# Register Dump Differences

Differences found in: Core CSRs

## Core CSR Differences

Difference count: 7

| CSR | Spike | Rocket |
|-----|------|------|
| misa | 0x80000000001411AF | 0x80000000009411AD |
| mideleg | 0x0000000000001444 | 0x0000000000000444 |
| mip | 0x0000000000000080 | 0x0000000000000400 |
| mcycle | 0x000000000000C4CC | 0x0000000000049547 |
| minstret | 0x000000000000C4CD | 0x00000000000292CF |
| marchid | 0x0000000000000005 | 0x0000000000000001 |
| mimpid | 0x0000000000000000 | 0x0000000020181004 |



#### Dump Index 1 (#2 in sequence)

# Register Dump Differences

Differences found in: Integer Registers, Core CSRs

## Integer Register Differences

Difference count: 1 / 32

| Register | ABI Name | Spike | Rocket |
|----------|----------|------|------|
| x20 | s4 | 0x0000000000000000 | 0x00000000DEADBEEF |

## Core CSR Differences

Difference count: 8

| CSR | Spike | Rocket |
|-----|------|------|
| misa | 0x80000000001411AF | 0x80000000009411AD |
| mideleg | 0x0000000000001444 | 0x0000000000000444 |
| mepc | 0x0000000080002462 | 0x000000008000272E |
| mip | 0x0000000000000080 | 0x0000000000000400 |
| mcycle | 0x000000000000EBD6 | 0x00000000000691F2 |
| minstret | 0x000000000000EBD7 | 0x000000000003A341 |
| marchid | 0x0000000000000005 | 0x0000000000000001 |
| mimpid | 0x0000000000000000 | 0x0000000020181004 |



### Output Item Status Difference

Status: Spike has 14 items, Rocket has 16 items

### Exception Dump Differences

# Exception List Diff Report

Comparison: Spike vs Rocket

## Difference Summary

| Category | Count |
|----------|-------|
| Exceptions only in Spike | 0 |
| Exceptions only in Rocket | 1 |
| Matched exception pairs (total) | 5 |
| Matched exception pairs (with differences) | 5 |
| Categorized differences | 2 |

## Exceptions only in Rocket

Total: 1

| # | MEPC | Disassembly | Original Assembly | MCAUSE | Exception Description | MTVAL | Position |
|---|------|-------------|-------------------|--------|----------------------|-------|----------|
| 1 | 0x000000008000272C | ld s4,48(sp) | c.ldsp x20, 48(sp) | 0x0000000000000005 | Load access fault | 0x0000000000001E58 | 1072 |

## Matched Exception Difference Details

Pairs with differences: 5 / 5 pairs

### Pair 1 - MEPC: 0x0000000080002448

#### Triggering Instruction

| PC Address | Disassembly | Original Assembly |
|------------|-------------|-------------------|
| 0x0000000080002448 | lw s5,32(sp) | lw s5,32(sp) |

| Item | Spike | Rocket |
|------|------------|------------|
| Position | 0 | 0 |
| MCAUSE | 0x0000000000000005 | 0x0000000000000005 |
| Exception Description | Load access fault | Load access fault |

#### CSR Field Differences

| CSR Field | Spike | Rocket | Difference Description |
|-----------|------------|------------|----------------------|
| mip | 0x0000000000000080 | 0x0000000000000400 | Values differ |

### Pair 2 - MEPC: 0x000000008000244A

#### Triggering Instruction

| PC Address | Disassembly | Original Assembly |
|------------|-------------|-------------------|
| 0x000000008000244A | lw t0,12(sp) | lw t0,12(sp) |

| Item | Spike | Rocket |
|------|------------|------------|
| Position | 80 | 80 |
| MCAUSE | 0x0000000000000005 | 0x0000000000000005 |
| Exception Description | Load access fault | Load access fault |

#### CSR Field Differences

| CSR Field | Spike | Rocket | Difference Description |
|-----------|------------|------------|----------------------|
| mip | 0x0000000000000080 | 0x0000000000000400 | Values differ |

### Pair 3 - MEPC: 0x000000008000244C

#### Triggering Instruction

| PC Address | Disassembly | Original Assembly |
|------------|-------------|-------------------|
| 0x000000008000244C | sw a4,28(sp) | sw a4,28(sp) |

| Item | Spike | Rocket |
|------|------------|------------|
| Position | 160 | 160 |
| MCAUSE | 0x0000000000000007 | 0x0000000000000007 |
| Exception Description | Store/AMO access fault | Store/AMO access fault |

#### CSR Field Differences

| CSR Field | Spike | Rocket | Difference Description |
|-----------|------------|------------|----------------------|
| mip | 0x0000000000000080 | 0x0000000000000400 | Values differ |

### Pair 4 - MEPC: 0x000000008000244E

#### Triggering Instruction

| PC Address | Disassembly | Original Assembly |
|------------|-------------|-------------------|
| 0x000000008000244E | sd s3,0(sp) | sd s3,0(sp) |

| Item | Spike | Rocket |
|------|------------|------------|
| Position | 240 | 240 |
| MCAUSE | 0x0000000000000007 | 0x0000000000000007 |
| Exception Description | Store/AMO access fault | Store/AMO access fault |

#### CSR Field Differences

| CSR Field | Spike | Rocket | Difference Description |
|-----------|------------|------------|----------------------|
| mip | 0x0000000000000080 | 0x0000000000000400 | Values differ |

### Pair 5 - MEPC: 0x0000000080002460

#### Triggering Instruction

| PC Address | Disassembly | Original Assembly |
|------------|-------------|-------------------|
| 0x0000000080002460 | sw t1,48(sp) | sw t1,48(sp) |

| Item | Spike | Rocket |
|------|------------|------------|
| Position | 320 | 320 |
| MCAUSE | 0x0000000000000007 | 0x0000000000000007 |
| Exception Description | Store/AMO access fault | Store/AMO access fault |

#### CSR Field Differences

| CSR Field | Spike | Rocket | Difference Description |
|-----------|------------|------------|----------------------|
| mip | 0x0000000000000080 | 0x0000000000000400 | Values differ |

## Categorized Exception Difference Summary

Total differences: 6

### Category 1

Category: Fixed MIP Difference (Value1=0x80, Value2=0x400)
Occurrence count: 5
Affected PCs: 5 addresses

#### PC Address and Instruction List

| # | PC Address | Disassembly | Original Assembly |
|---|------------|-------------|-------------------|
| 1 | 0x0000000080002448 | lw s5,32(sp) | lw s5,32(sp) |
| 2 | 0x000000008000244A | lw t0,12(sp) | lw t0,12(sp) |
| 3 | 0x000000008000244C | sw a4,28(sp) | sw a4,28(sp) |
| 4 | 0x000000008000244E | sd s3,0(sp) | sd s3,0(sp) |
| 5 | 0x0000000080002460 | sw t1,48(sp) | sw t1,48(sp) |

#### Description

Description: MIP register value has fixed difference between simulators.



### Category 2

Category: Only in Rocket (mcause: 0x5 - Load access fault)
Occurrence count: 1
Affected PCs: 1 addresses

#### PC Address and Instruction List

| # | PC Address | Disassembly | Original Assembly |
|---|------------|-------------|-------------------|
| 1 | 0x000000008000272C | ld s4,48(sp) | c.ldsp x20, 48(sp) |

#### Description

Description: Exception only triggered in Rocket, the other simulator continues execution or has no exception at this point.


---
Exception diff report generated at: 2025-06-24 18:35:24 UTC



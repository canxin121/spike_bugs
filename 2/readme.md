# Spike Fails to Trigger Exception for Invalid Memory Access with `c.ldsp` Instruction

## Bug Summary

The Spike simulator, when executing the compressed instruction `c.ldsp`, fails to trigger the expected "Load access fault" for a memory address that has been proven to be invalid. This leads to incorrect program behavior, where the destination register is erroneously updated. This behavior is not only inconsistent with Spike's own exception handling for write operations to the same address but also contradicts the correct behavior of the Rocket simulator.

## Reproduction Environment
- **Spike commit**: 70687ccf41bb2696c55c6f6aa44b3949f2921ddf
- **march**: rv64imafdqc_h_zaamo_zba_zbb_zbc_zbs_zfa_zfh_zfhmin_zicond_zicsr_zifencei
- **system environment**: [environment](environment.md)

## Bug Details

### **1. Correct Behavior**

1.  **Baseline Test:** First, a series of `c.lwsp` and `c.swsp` instructions confirm that when the stack pointer `sp` is `0`, both Spike and Rocket correctly trigger access faults for invalid addresses (e.g., `0x20`, `0xC`).

2.  **Establishing an Invalid Address:**
    *   Set the stack pointer `sp` (`x2`) to a seemingly valid but unmapped address: `li x2, 0x1E28`.
    *   Execute the write instruction `c.swsp t1, 48(sp)`, attempting to write to the address `0x1E58` (`0x1E28 + 48`).
    *   In this step, **both Spike and Rocket correctly trigger a "Store/AMO access fault"** (`mcause=7`, `mtval=0x1E58`). This proves that the address `0x1E58` is an invalid, non-writable memory location for both simulators.

### **2. Spike's Incorrect Behavior Analysis (Bug Present)**

1.  **Instruction Execution:**
    *   First, the `li x20, 0xDEADBEEF` instruction loads a known value into the `x20` register as a marker for subsequent verification.
    *   Next, the critical load instruction is executed: `c.ldsp x20, 48(sp)`.

2.  **Behavior Observation:**
    *   **Exception Handling Failure:** Spike's execution log shows that this instruction **did not trigger any exception**. This is in stark contrast to the behavior of `c.swsp` on the same address.
    *   **Register State Corrupted:** The second register dump shows that the value of the `x20` register was **incorrectly changed from `0xDEADBEEF` to `0x0`**. This indicates that Spike not only failed to catch the exception but also incorrectly completed the load operation, reading data (possibly the default `0`) from an invalid address and updating the architectural state.

### **3. Rocket's Correct Behavior Analysis (For Reference)**

1.  **Instruction Execution:** Rocket executes the exact same sequence of instructions.

2.  **Behavior Observation:**
    *   **Successful Exception Handling:** Executing `c.ldsp x20, 48(sp)` triggers a **`Load access fault`** (`mcause=5`, `mtval=0x1E58`).
    *   **Register State Protected:** The second register dump shows that the value of the `x20` register **remains `0xDEADBEEF`**. This is the correct behavior, as the exception prevents the instruction's write-back stage, thus protecting the original register value.

### **4. Summary**

*   **Internal Inconsistency:** Spike correctly reports an exception for a write operation to address `0x1E58` but fails to do so for a read operation. This is a logical contradiction, especially since it correctly reports exceptions for both reads and writes to other addresses in the test.
*   **Deviation from Specification:** The RISC-V specification requires that a load operation from an invalid address must generate a load access fault. Spike's behavior violates this specification, whereas Rocket's behavior conforms to it.

### Reproduction

Need to use the tools from my riscv_fuzz_test repo to conveniently parse the output.

```bash
cargo install --git https://github.com/canxin121/riscv_fuzz_test
```

Then directly use the `riscv_fuzz_test` tool for testing.

Set the environment variable ROCKET_EMULATOR_PATH to the path of your Rocket simulator. For Rocket emulator build configuration and version details, see [emulators/readme.md](../emulators/readme.md). There's a pre-compiled one for x86 Ubuntu in the emulators folder.

```bash
export ROCKET_EMULATOR_PATH=<path_to_your_rocket_emulator>
```

```bash
riscv_fuzz_test run -a ./debug.S -f common -b ./build
```
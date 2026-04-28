# A BF16 Gemm on AVX512

Investigate different ways of multiplying matrices using AVX512 BF16 extensions.

The goal is to write a BF16 gemm in inline asm in a Rust function.

## Agents

Always build with --release

## Available BF16 Instructions on Zen5

Zen5 supports the `AVX512_BF16` extension. The key instructions are:

* `VDPBF16PS zmm_dst, zmm_a, zmm_b` — the workhorse. For each adjacent pair of
  BF16 lanes in `a` and `b`, computes `a[2i]*b[2i] + a[2i+1]*b[2i+1]` and
  accumulates into the FP32 lane `dst[i]`. A single ZMM register holds 32 BF16
  values; `VDPBF16PS` produces 16 FP32 accumulators. This means one instruction
  retires 32 FMAs worth of arithmetic.
* `VCVTNEPS2BF16 ymm_dst, zmm_src` — convert 16 FP32 values to 16 BF16 values
  (round-to-nearest-even, storing result in a YMM register).
* `VCVTNE2PS2BF16 zmm_dst, zmm_a, zmm_b` — convert two FP32 ZMM registers to
  BF16 and interleave into one ZMM. Useful for packing.

Zen5 has 32 ZMM registers and dual 512-bit FMA units, so peak throughput is
2 × `VDPBF16PS` per cycle.

## Reference Implementation

Before writing inline asm, write a scalar/safe-Rust version using the `half`
crate (or `core::num::f32` with manual BF16 truncation) to have a correctness
oracle. The reference should:

1. Accept `A: &[bf16]` (M×K, row-major), `B: &[bf16]` (K×N, row-major), and
   accumulate into `C: &mut [f32]` (M×N, row-major).
2. Use tiles to reduce cache invalidation.
3. Be tested with small random matrices against an f32 reference to establish an
   acceptable error bound (BF16 has ~0.4% relative error).

## Matrix Layout and Packing

`VDPBF16PS` works best when the BF16 operands are laid out so that the K
dimension is contiguous in the inner loop. Two practical options:

**Option A – B transposed (dot-product view)**
Store `B` in column-major order (equivalently, pre-transpose to `Bᵀ` in
row-major). The inner-most loop over `k` then streams both a row of `A` and the
corresponding row of `Bᵀ` through ZMM registers, computing a full dot product
for one `(i, j)` pair. Simple but poor cache reuse for large N.

**Option B – packed micro-panels (BLIS-style)**
Pack `A` into row-panels of height `MR` and `B` into column-panels of width
`NR`. During packing, interleave BF16 values so that the micro-kernel inner
loop issues `VDPBF16PS` instructions with broadcast or sequential loads. This
is the standard approach for high-performance GEMM.

Start with Option A to get correctness, then move to Option B for performance.

## Micro-Kernel Design

With 32 ZMM registers, a good initial split:

```
MR = 6   (rows of A held in registers or reloaded each iter)
NR = 2   (each NR "slot" is one ZMM of 16 fp32 accumulators)
→  6×2 = 12 accumulator ZMMs
   + ~4 ZMMs for A broadcast/load
   + ~4 ZMMs for B load
   = 20 ZMMs used, 12 free for prefetch or spill
```

Each inner-loop iteration:
1. Load one ZMM from B panel (32 BF16).
2. For each of the MR A rows, broadcast/load the corresponding 32 BF16 values.
3. Issue `VDPBF16PS acc[i][j], a[i], b[j]` for each (i, j) accumulator.

This gives `MR × NR = 12` `VDPBF16PS` instructions per K-step, which should
keep both FMA ports busy.

## Tiling Strategy

Three levels of tiling (standard BLIS notation):

| Level | Loop var | Size target | Fits in |
|-------|----------|-------------|---------|
| Inner | k_c      | 512–1024    | L1 cache |
| Middle| n_c      | 4096–8192   | L2 cache |
| Outer | m_c      | varies      | L3 cache |

Zen5 L1D is 48 KB, L2 is 1 MB, L3 is shared. Start with k_c=512, n_c=4096 and
tune with `perf stat`.

## Implementation Steps

1. **Add dependencies** — add `half = { version = "2", features = ["std"] }` to
   `Cargo.toml`.
2. **Reference GEMM** — scalar triple-loop with BF16 inputs, F32 accumulator.
3. **Correctness test harness** — generate random matrices, compare against F32
   reference, assert max relative error < 1%.
4. **Naive AVX512 kernel** — use `std::arch` intrinsics (`_mm512_dpbf16_ps`,
   etc.) without inline asm to validate the algorithm before wrestling with asm
   constraints.
5. **Inline asm micro-kernel** — implement the MR×NR inner loop in
   `core::arch::asm!`, expose as `unsafe fn matmul_bf16_kernel(...)`.
6. **Packing routines** — pack A and B into the panel layouts expected by the
   micro-kernel.
7. **Tiled driver** — outer loops that call the micro-kernel over tiles.
8. **Benchmarking** — measure GFLOPS against theoretical peak (2 FMAs/cycle ×
   32 bf16-pairs × clock GHz).

## Register and Instruction Pressure Notes

* Prefer `zmm16`–`zmm31` for accumulators (caller-saved on Linux, no REX prefix
  needed in some encodings).
* Use `VPBROADCASTD` to broadcast a BF16 pair from A into a full ZMM before
  `VDPBF16PS` if doing an outer-product style update.
* Consider software prefetch (`PREFETCHT0`/`PREFETCHT1`) for B panels one
  iteration ahead.
* Instruction latency for `VDPBF16PS` on Zen5 is ~4 cycles; chain depth of 12
  accumulators should hide it comfortably.



# AVX512-BF16 GEMM - Option A  (pre-transposed B, dot-product view)
# AT&T / GNU as syntax
#
# void gemm_avx512_bf16_opt_a(
#     const uint16_t *a,   %rdi  M x K row-major bf16
#     const uint16_t *b_t, %rsi  N x K row-major bf16  (B transposed)
#     float          *c,   %rdx  M x N row-major f32   (accumulated into)
#     size_t          m,   %rcx
#     size_t          n,   %r8
#     size_t          k    %r9
# );
#
# Inner k-loop is unrolled x4 using 4 independent accumulators zmm2-zmm5,
# breaking the 4-cycle vdpbf16ps latency chain and allowing dual FMA dispatch.
# After the x4 loop the 4 accumulators are merged into zmm2, then a scalar x1
# cleanup loop handles any remaining full ZMM blocks, and a masked tail covers
# leftover bf16 elements.
#
# Register map (callee-saved: %rbx %rbp %r12-%r15):
#   %rdi   a_ptr base (constant)
#   %rsi   bt_base (constant)
#   %rdx   c_row  (walks by n*4 per outer iteration)
#   %rcx   m
#   %r8    n
#   %r9    k
#   %r10   i
#   %r11   j
#   %r12   k_bytes = k*2
#   %r13   n_bytes = n*4
#   %r14   a_row  = a_ptr + i*k*2
#   %r15   k_rem
#   %rbx   bt_row = bt_base + j*k*2
#   %rbp   byte_off (steps by 64 per x1 iter, 256 per x4 iter)
#   %rax   scratch
#   zmm2   accumulator 0  (also final merged accumulator)
#   zmm3   accumulator 1
#   zmm4   accumulator 2
#   zmm5   accumulator 3
#   zmm6   load temp A[0]   zmm7   load temp Bt[0]
#   zmm8   load temp A[1]   zmm9   load temp Bt[1]
#   zmm10  load temp A[2]   zmm11  load temp Bt[2]
#   zmm12  load temp A[3]   zmm13  load temp Bt[3]

        .text
        .globl gemm_avx512_bf16_opt_a
        .type  gemm_avx512_bf16_opt_a, @function
        .p2align 4

gemm_avx512_bf16_opt_a:
        pushq   %rbx
        pushq   %rbp
        pushq   %r12
        pushq   %r13
        pushq   %r14
        pushq   %r15

        testq   %rcx, %rcx
        jz      .Lret
        testq   %r8,  %r8
        jz      .Lret
        testq   %r9,  %r9
        jz      .Lret

        movq    %r9,  %r12
        shlq    $1,   %r12

        movq    %r8,  %r13
        shlq    $2,   %r13

        xorq    %r10, %r10
        movq    %rdi, %r14

.Li_loop:
        cmpq    %rcx, %r10
        jge     .Li_done

        xorq    %r11, %r11
        movq    %rsi, %rbx

.Lj_loop:
        cmpq    %r8, %r11
        jge     .Lj_done

        # Zero all four accumulators
        vpxord  %zmm2, %zmm2, %zmm2
        vpxord  %zmm3, %zmm3, %zmm3
        vpxord  %zmm4, %zmm4, %zmm4
        vpxord  %zmm5, %zmm5, %zmm5

        xorq    %rbp, %rbp
        movq    %r12, %r15
        shrq    $1,   %r15       # r15 = k  (k_bytes/2; %r9 is not touched)

        # x4 trip count in %rdi (%rdi = a_ptr base, free after prologue %r14 setup)
        movq    %r15, %rdi
        shrq    $7,   %rdi       # rdi = k / 128
        andq    $127, %r15       # r15 = k % 128 (residual for x1 + tail)
        testq   %rdi, %rdi
        jz      .Lk_loop_x4_done

.Lk_loop_x4:
        vmovdqu32  0*64(%r14,%rbp), %zmm6
        vmovdqu32  1*64(%r14,%rbp), %zmm8
        vmovdqu32  2*64(%r14,%rbp), %zmm10
        vmovdqu32  3*64(%r14,%rbp), %zmm12
        vmovdqu32  0*64(%rbx,%rbp), %zmm7
        vmovdqu32  1*64(%rbx,%rbp), %zmm9
        vmovdqu32  2*64(%rbx,%rbp), %zmm11
        vmovdqu32  3*64(%rbx,%rbp), %zmm13
        vdpbf16ps  %zmm7,  %zmm6,  %zmm2
        vdpbf16ps  %zmm9,  %zmm8,  %zmm3
        vdpbf16ps  %zmm11, %zmm10, %zmm4
        vdpbf16ps  %zmm13, %zmm12, %zmm5

        addq    $256, %rbp
        decq    %rdi
        jnz     .Lk_loop_x4

.Lk_loop_x4_done:
        # Merge zmm3, zmm4, zmm5 into zmm2
        vaddps  %zmm3, %zmm2, %zmm2
        vaddps  %zmm5, %zmm4, %zmm4
        vaddps  %zmm4, %zmm2, %zmm2

        # x1 trip count in %rdi; %r15 = tail element count
        movq    %r15, %rdi
        shrq    $5,   %rdi       # rdi = remaining / 32
        andq    $31,  %r15       # r15 = remaining % 32
        testq   %rdi, %rdi
        jz      .Lk_tail

.Lk_loop:
        vmovdqu32 (%r14,%rbp), %zmm6
        vmovdqu32 (%rbx,%rbp), %zmm7
        vdpbf16ps %zmm7, %zmm6, %zmm2

        addq    $64,  %rbp
        decq    %rdi
        jnz     .Lk_loop

.Lk_tail:
        testq   %r15, %r15
        jz      .Lk_done

        # Tail: r15 bf16 elements remain (1..31).
        # mask = (1 << k_rem) - 1  at bf16/u16 element granularity.
        # Save %rcx (m), borrow it as shift count register.
        movq    %rcx, %rax
        movq    %r15, %rcx
        movl    $1,   %r15d
        shll    %cl,  %r15d
        decl    %r15d
        movq    %rax, %rcx

        kmovd   %r15d, %k1

        vmovdqu16 (%r14,%rbp), %zmm6{%k1}{z}
        vmovdqu16 (%rbx,%rbp), %zmm7{%k1}{z}
        vdpbf16ps %zmm7, %zmm6, %zmm2

.Lk_done:
        # Horizontal sum of zmm2 (16 f32) -> scalar in xmm2
        vextractf64x4 $1, %zmm2, %ymm3
        vaddps        %ymm3, %ymm2, %ymm2

        vextractf128 $1, %ymm2, %xmm3
        vaddps       %xmm3, %xmm2, %xmm2

        vhaddps %xmm2, %xmm2, %xmm2
        vhaddps %xmm2, %xmm2, %xmm2

        leaq    (%rdx,%r11,4), %rax
        vaddss  (%rax), %xmm2, %xmm2
        vmovss  %xmm2, (%rax)

        addq    %r12, %rbx

        incq    %r11
        jmp     .Lj_loop

.Lj_done:
        addq    %r12, %r14
        addq    %r13, %rdx

        incq    %r10
        jmp     .Li_loop

.Li_done:
.Lret:
        vzeroupper
        popq    %r15
        popq    %r14
        popq    %r13
        popq    %r12
        popq    %rbp
        popq    %rbx
        ret

        .size gemm_avx512_bf16_opt_a, . - gemm_avx512_bf16_opt_a

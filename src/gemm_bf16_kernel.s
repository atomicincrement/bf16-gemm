/* GNU AT&T x86-64 assembly for BF16 GEMM kernel
 * 
 * Equivalent to: gemm_bf16_kernel_ref(ii, jj, k, alpha, a, lda, b, ldb, beta, c, ldc)
 * 
 * Calling convention (System V AMD64 ABI):
 *   rdi = ii (usize)
 *   rsi = jj (usize)
 *   rdx = k (usize)
 *   xmm0 = alpha (f32)
 *   rcx = a (*[bf16])
 *   r8 = lda (usize)
 *   r9 = b (*[bf16])
 *   stack + 8 = ldb (usize)
 *   xmm1 = beta (f32)
 *   stack + 16 = c (*mut [f32])
 *   stack + 24 = ldc (usize)
 * 
 * Accumulator layout (16 zmm registers):
 *   acc[ii_local][jj_local]:
 *   zmm0=acc[0][0]  zmm4=acc[0][1]  zmm10=acc[0][2]  zmm14=acc[0][3]
 *   zmm1=acc[1][0]  zmm5=acc[1][1]  zmm11=acc[1][2]  zmm15=acc[1][3]
 *   zmm2=acc[2][0]  zmm6=acc[2][1]  zmm12=acc[2][2]  zmm16=acc[2][3]
 *   zmm3=acc[3][0]  zmm7=acc[3][1]  zmm13=acc[3][2]  zmm17=acc[3][3]
 */

.text
.align 16
.globl gemm_bf16_kernel_asm
.type gemm_bf16_kernel_asm, @function

gemm_bf16_kernel_asm:
    push %rbp
    mov %rsp, %rbp
    push %r12
    push %r13
    push %r14
    push %r15
    
    /* Load stack arguments */
    mov 16(%rbp), %r10      /* ldb */
    mov 24(%rbp), %r12      /* c pointer */
    mov 32(%rbp), %r13      /* ldc */
    
    /* Preserve a, b pointers and dimensions */
    mov %rcx, %r14          /* a */
    mov %r8, %r15           /* lda */
    
    /* Clear all 16 accumulators */
    vpxorq %zmm0, %zmm0, %zmm0
    vpxorq %zmm1, %zmm1, %zmm1
    vpxorq %zmm2, %zmm2, %zmm2
    vpxorq %zmm3, %zmm3, %zmm3
    vpxorq %zmm4, %zmm4, %zmm4
    vpxorq %zmm5, %zmm5, %zmm5
    vpxorq %zmm6, %zmm6, %zmm6
    vpxorq %zmm7, %zmm7, %zmm7
    vpxorq %zmm10, %zmm10, %zmm10
    vpxorq %zmm11, %zmm11, %zmm11
    vpxorq %zmm12, %zmm12, %zmm12
    vpxorq %zmm13, %zmm13, %zmm13
    vpxorq %zmm14, %zmm14, %zmm14
    vpxorq %zmm15, %zmm15, %zmm15
    vpxorq %zmm16, %zmm16, %zmm16
    vpxorq %zmm17, %zmm17, %zmm17
    
    /* Pre-compute byte offsets */
    lea 0(,%r15,2), %r8     /* lda_bytes = lda * 2 */
    lea 0(,%r10,2), %rcx    /* ldb_bytes = ldb * 2 */
    
    /* Strength reduce: compute initial row offset for A (1 multiply) */
    mov %rdi, %r12
    imul %r8, %r12          /* a_row_offset = ii * lda_bytes */
    
    /* Strength reduce: compute initial column offset for B (1 multiply) */
    mov %rsi, %r13
    imul %rcx, %r13         /* b_col_offset = jj * ldb_bytes */
    
    /* K-loop: idx from 0 to k, increment by 32 */
    xor %rax, %rax          /* idx = 0 */
    
.Lk_loop:
    cmp %rdx, %rax          /* if idx >= k, exit */
    jge .Lk_done
    
    /* Compute base addresses for this k-iteration */
    lea 0(%r14, %rax, 2), %rbx  /* base_a = a + idx*2 */
    lea 0(%r9, %rax, 2), %r11   /* base_b = b + idx*2 */
    
    /* Load all 4 rows of A: unroll with strength reduction (add instead of multiply) */
    vmovups (%rbx, %r12), %zmm18        /* A[ii+0] */
    
    lea (%r12, %r8), %r14               /* next_offset = current + lda_bytes */
    vmovups (%rbx, %r14), %zmm19        /* A[ii+1] */
    
    lea (%r14, %r8), %r14               /* next_offset = current + lda_bytes */
    vmovups (%rbx, %r14), %zmm20        /* A[ii+2] */
    
    lea (%r14, %r8), %r14               /* next_offset = current + lda_bytes */
    vmovups (%rbx, %r14), %zmm21        /* A[ii+3] */
    
    /* jj_local = 0: Load B[jj+0, idx:idx+32], do 4 VDPBF16PS */
    vmovups (%r11, %r13), %zmm22        /* B[jj+0] with pre-computed offset */
    
    vdpbf16ps %zmm22, %zmm18, %zmm0
    vdpbf16ps %zmm22, %zmm19, %zmm1
    vdpbf16ps %zmm22, %zmm20, %zmm2
    vdpbf16ps %zmm22, %zmm21, %zmm3
    
    /* jj_local = 1: Load B[jj+1, idx:idx+32], do 4 VDPBF16PS */
    lea (%r13, %rcx), %r14              /* next B offset */
    vmovups (%r11, %r14), %zmm22        /* B[jj+1] */
    
    vdpbf16ps %zmm22, %zmm18, %zmm4
    vdpbf16ps %zmm22, %zmm19, %zmm5
    vdpbf16ps %zmm22, %zmm20, %zmm6
    vdpbf16ps %zmm22, %zmm21, %zmm7
    
    /* jj_local = 2: Load B[jj+2, idx:idx+32], do 4 VDPBF16PS */
    lea (%r14, %rcx), %r14              /* next B offset */
    vmovups (%r11, %r14), %zmm22        /* B[jj+2] */
    
    vdpbf16ps %zmm22, %zmm18, %zmm10
    vdpbf16ps %zmm22, %zmm19, %zmm11
    vdpbf16ps %zmm22, %zmm20, %zmm12
    vdpbf16ps %zmm22, %zmm21, %zmm13
    
    /* jj_local = 3: Load B[jj+3, idx:idx+32], do 4 VDPBF16PS */
    lea (%r14, %rcx), %r14              /* next B offset */
    vmovups (%r11, %r14), %zmm22        /* B[jj+3] */
    
    vdpbf16ps %zmm22, %zmm18, %zmm14
    vdpbf16ps %zmm22, %zmm19, %zmm15
    vdpbf16ps %zmm22, %zmm20, %zmm16
    vdpbf16ps %zmm22, %zmm21, %zmm17
    
    /* idx += 32 */
    add $32, %rax
    jmp .Lk_loop
    
.Lk_done:
    /* Horizontal reduction and write back */
    /* Accumulators: zmm0-3, zmm4-7, zmm10-13, zmm14-17 (4x4 tile) */
    /* Recovered: alpha in xmm8, beta in xmm9 */
    /* Available: r8-r11, r12=c, r13=ldc, rdi=ii, rsi=jj */
    
    /* Save c pointer and ldc */
    mov %r12, %r14          /* save c pointer */
    mov %r13, %r15          /* save ldc */
    
    /* For each accumulator, do horizontal sum and write back */
    /* Macro: reduce zmm reg to scalar in xmm via vextractf64x4 + hsum */
    
    /* Process each of 16 accumulators (4x4 tile) */
    /* ii_local=0, jj_local=0: zmm0 */
    vextractf64x4 $1, %zmm0, %ymm19
    vaddps %ymm19, %ymm0, %ymm0
    vextractf32x4 $1, %ymm0, %xmm19
    vaddps %xmm19, %xmm0, %xmm0
    vhaddps %xmm0, %xmm0, %xmm0
    vhaddps %xmm0, %xmm0, %xmm0
    
    /* Apply alpha * result + beta * C[0,0] */
    mov %rdi, %r8
    add %rsi, %r8
    imul %r15, %r8
    vmulss %xmm8, %xmm0, %xmm0         /* alpha * sum */
    vmulss %xmm9, (%r14, %r8, 4), %xmm19  /* beta * C[i,j] */
    vaddss %xmm19, %xmm0, %xmm0
    vmovss %xmm0, (%r14, %r8, 4)       /* write back */
    
    /* ii_local=1, jj_local=0: zmm1 */
    vextractf64x4 $1, %zmm1, %ymm19
    vaddps %ymm19, %ymm1, %ymm1
    vextractf32x4 $1, %ymm1, %xmm19
    vaddps %xmm19, %xmm1, %xmm1
    vhaddps %xmm1, %xmm1, %xmm1
    vhaddps %xmm1, %xmm1, %xmm1
    
    mov %rdi, %r8
    inc %r8
    add %rsi, %r8
    imul %r15, %r8
    vmulss %xmm8, %xmm1, %xmm1
    vmulss %xmm9, (%r14, %r8, 4), %xmm19
    vaddss %xmm19, %xmm1, %xmm1
    vmovss %xmm1, (%r14, %r8, 4)
    
    /* ii_local=2, jj_local=0: zmm2 */
    vextractf64x4 $1, %zmm2, %ymm19
    vaddps %ymm19, %ymm2, %ymm2
    vextractf32x4 $1, %ymm2, %xmm19
    vaddps %xmm19, %xmm2, %xmm2
    vhaddps %xmm2, %xmm2, %xmm2
    vhaddps %xmm2, %xmm2, %xmm2
    
    mov %rdi, %r8
    add $2, %r8
    add %rsi, %r8
    imul %r15, %r8
    vmulss %xmm8, %xmm2, %xmm2
    vmulss %xmm9, (%r14, %r8, 4), %xmm19
    vaddss %xmm19, %xmm2, %xmm2
    vmovss %xmm2, (%r14, %r8, 4)
    
    /* ii_local=3, jj_local=0: zmm3 */
    vextractf64x4 $1, %zmm3, %ymm19
    vaddps %ymm19, %ymm3, %ymm3
    vextractf32x4 $1, %ymm3, %xmm19
    vaddps %xmm19, %xmm3, %xmm3
    vhaddps %xmm3, %xmm3, %xmm3
    vhaddps %xmm3, %xmm3, %xmm3
    
    mov %rdi, %r8
    add $3, %r8
    add %rsi, %r8
    imul %r15, %r8
    vmulss %xmm8, %xmm3, %xmm3
    vmulss %xmm9, (%r14, %r8, 4), %xmm19
    vaddss %xmm19, %xmm3, %xmm3
    vmovss %xmm3, (%r14, %r8, 4)
    
    /* ii_local=0, jj_local=1: zmm4 */
    vextractf64x4 $1, %zmm4, %ymm19
    vaddps %ymm19, %ymm4, %ymm4
    vextractf32x4 $1, %ymm4, %xmm19
    vaddps %xmm19, %xmm4, %xmm4
    vhaddps %xmm4, %xmm4, %xmm4
    vhaddps %xmm4, %xmm4, %xmm4
    
    mov %rdi, %r8
    add %rsi, %r8
    inc %r8                             /* jj + 1 */
    imul %r15, %r8
    vmulss %xmm8, %xmm4, %xmm4
    vmulss %xmm9, (%r14, %r8, 4), %xmm19
    vaddss %xmm19, %xmm4, %xmm4
    vmovss %xmm4, (%r14, %r8, 4)
    
    /* ii_local=1, jj_local=1: zmm5 */
    vextractf64x4 $1, %zmm5, %ymm19
    vaddps %ymm19, %ymm5, %ymm5
    vextractf32x4 $1, %ymm5, %xmm19
    vaddps %xmm19, %xmm5, %xmm5
    vhaddps %xmm5, %xmm5, %xmm5
    vhaddps %xmm5, %xmm5, %xmm5
    
    mov %rdi, %r8
    inc %r8
    add %rsi, %r8
    inc %r8                             /* jj + 1 */
    imul %r15, %r8
    vmulss %xmm8, %xmm5, %xmm5
    vmulss %xmm9, (%r14, %r8, 4), %xmm19
    vaddss %xmm19, %xmm5, %xmm5
    vmovss %xmm5, (%r14, %r8, 4)
    
    /* ii_local=2, jj_local=1: zmm6 */
    vextractf64x4 $1, %zmm6, %ymm19
    vaddps %ymm19, %ymm6, %ymm6
    vextractf32x4 $1, %ymm6, %xmm19
    vaddps %xmm19, %xmm6, %xmm6
    vhaddps %xmm6, %xmm6, %xmm6
    vhaddps %xmm6, %xmm6, %xmm6
    
    mov %rdi, %r8
    add $2, %r8
    add %rsi, %r8
    inc %r8                             /* jj + 1 */
    imul %r15, %r8
    vmulss %xmm8, %xmm6, %xmm6
    vmulss %xmm9, (%r14, %r8, 4), %xmm19
    vaddss %xmm19, %xmm6, %xmm6
    vmovss %xmm6, (%r14, %r8, 4)
    
    /* ii_local=3, jj_local=1: zmm7 */
    vextractf64x4 $1, %zmm7, %ymm19
    vaddps %ymm19, %ymm7, %ymm7
    vextractf32x4 $1, %ymm7, %xmm19
    vaddps %xmm19, %xmm7, %xmm7
    vhaddps %xmm7, %xmm7, %xmm7
    vhaddps %xmm7, %xmm7, %xmm7
    
    mov %rdi, %r8
    add $3, %r8
    add %rsi, %r8
    inc %r8                             /* jj + 1 */
    imul %r15, %r8
    vmulss %xmm8, %xmm7, %xmm7
    vmulss %xmm9, (%r14, %r8, 4), %xmm19
    vaddss %xmm19, %xmm7, %xmm7
    vmovss %xmm7, (%r14, %r8, 4)
    
    /* ii_local=0, jj_local=2: zmm10 */
    vextractf64x4 $1, %zmm10, %ymm19
    vaddps %ymm19, %ymm10, %ymm10
    vextractf32x4 $1, %ymm10, %xmm19
    vaddps %xmm19, %xmm10, %xmm10
    vhaddps %xmm10, %xmm10, %xmm10
    vhaddps %xmm10, %xmm10, %xmm10
    
    mov %rdi, %r8
    add %rsi, %r8
    add $2, %r8                         /* jj + 2 */
    imul %r15, %r8
    vmulss %xmm8, %xmm10, %xmm10
    vmulss %xmm9, (%r14, %r8, 4), %xmm19
    vaddss %xmm19, %xmm10, %xmm10
    vmovss %xmm10, (%r14, %r8, 4)
    
    /* ii_local=1, jj_local=2: zmm11 */
    vextractf64x4 $1, %zmm11, %ymm19
    vaddps %ymm19, %ymm11, %ymm11
    vextractf32x4 $1, %ymm11, %xmm19
    vaddps %xmm19, %xmm11, %xmm11
    vhaddps %xmm11, %xmm11, %xmm11
    vhaddps %xmm11, %xmm11, %xmm11
    
    mov %rdi, %r8
    inc %r8
    add %rsi, %r8
    add $2, %r8                         /* jj + 2 */
    imul %r15, %r8
    vmulss %xmm8, %xmm11, %xmm11
    vmulss %xmm9, (%r14, %r8, 4), %xmm19
    vaddss %xmm19, %xmm11, %xmm11
    vmovss %xmm11, (%r14, %r8, 4)
    
    /* ii_local=2, jj_local=2: zmm12 */
    vextractf64x4 $1, %zmm12, %ymm19
    vaddps %ymm19, %ymm12, %ymm12
    vextractf32x4 $1, %ymm12, %xmm19
    vaddps %xmm19, %xmm12, %xmm12
    vhaddps %xmm12, %xmm12, %xmm12
    vhaddps %xmm12, %xmm12, %xmm12
    
    mov %rdi, %r8
    add $2, %r8
    add %rsi, %r8
    add $2, %r8                         /* jj + 2 */
    imul %r15, %r8
    vmulss %xmm8, %xmm12, %xmm12
    vmulss %xmm9, (%r14, %r8, 4), %xmm19
    vaddss %xmm19, %xmm12, %xmm12
    vmovss %xmm12, (%r14, %r8, 4)
    
    /* ii_local=3, jj_local=2: zmm13 */
    vextractf64x4 $1, %zmm13, %ymm19
    vaddps %ymm19, %ymm13, %ymm13
    vextractf32x4 $1, %ymm13, %xmm19
    vaddps %xmm19, %xmm13, %xmm13
    vhaddps %xmm13, %xmm13, %xmm13
    vhaddps %xmm13, %xmm13, %xmm13
    
    mov %rdi, %r8
    add $3, %r8
    add %rsi, %r8
    add $2, %r8                         /* jj + 2 */
    imul %r15, %r8
    vmulss %xmm8, %xmm13, %xmm13
    vmulss %xmm9, (%r14, %r8, 4), %xmm19
    vaddss %xmm19, %xmm13, %xmm13
    vmovss %xmm13, (%r14, %r8, 4)
    
    /* ii_local=0, jj_local=3: zmm14 */
    vextractf64x4 $1, %zmm14, %ymm19
    vaddps %ymm19, %ymm14, %ymm14
    vextractf32x4 $1, %ymm14, %xmm19
    vaddps %xmm19, %xmm14, %xmm14
    vhaddps %xmm14, %xmm14, %xmm14
    vhaddps %xmm14, %xmm14, %xmm14
    
    mov %rdi, %r8
    add %rsi, %r8
    add $3, %r8                         /* jj + 3 */
    imul %r15, %r8
    vmulss %xmm8, %xmm14, %xmm14
    vmulss %xmm9, (%r14, %r8, 4), %xmm19
    vaddss %xmm19, %xmm14, %xmm14
    vmovss %xmm14, (%r14, %r8, 4)
    
    /* ii_local=1, jj_local=3: zmm15 */
    vextractf64x4 $1, %zmm15, %ymm19
    vaddps %ymm19, %ymm15, %ymm15
    vextractf32x4 $1, %ymm15, %xmm19
    vaddps %xmm19, %xmm15, %xmm15
    vhaddps %xmm15, %xmm15, %xmm15
    vhaddps %xmm15, %xmm15, %xmm15
    
    mov %rdi, %r8
    inc %r8
    add %rsi, %r8
    add $3, %r8                         /* jj + 3 */
    imul %r15, %r8
    vmulss %xmm8, %xmm15, %xmm15
    vmulss %xmm9, (%r14, %r8, 4), %xmm19
    vaddss %xmm19, %xmm15, %xmm15
    vmovss %xmm15, (%r14, %r8, 4)
    
    /* ii_local=2, jj_local=3: zmm16 */
    vextractf64x4 $1, %zmm16, %ymm19
    vaddps %ymm19, %ymm16, %ymm16
    vextractf32x4 $1, %zmm16, %xmm19
    vaddps %xmm19, %xmm16, %xmm16
    vhaddps %xmm16, %xmm16, %xmm16
    vhaddps %xmm16, %xmm16, %xmm16
    
    mov %rdi, %r8
    add $2, %r8
    add %rsi, %r8
    add $3, %r8                         /* jj + 3 */
    imul %r15, %r8
    vmulss %xmm8, %xmm16, %xmm16
    vmulss %xmm9, (%r14, %r8, 4), %xmm19
    vaddss %xmm19, %xmm16, %xmm16
    vmovss %xmm16, (%r14, %r8, 4)
    
    /* ii_local=3, jj_local=3: zmm17 */
    vextractf64x4 $1, %zmm17, %ymm19
    vaddps %ymm19, %ymm17, %ymm17
    vextractf32x4 $1, %zmm17, %xmm19
    vaddps %xmm19, %xmm17, %xmm17
    vhaddps %xmm17, %xmm17, %xmm17
    vhaddps %xmm17, %xmm17, %xmm17
    
    mov %rdi, %r8
    add $3, %r8
    add %rsi, %r8
    add $3, %r8                         /* jj + 3 */
    imul %r15, %r8
    vmulss %xmm8, %xmm17, %xmm17
    vmulss %xmm9, (%r14, %r8, 4), %xmm19
    vaddss %xmm19, %xmm17, %xmm17
    vmovss %xmm17, (%r14, %r8, 4)
    
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbp
    ret

.size gemm_bf16_kernel_asm, .-gemm_bf16_kernel_asm

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
    
    /* Pre-compute row offsets for A */
    lea 0(,%r15,2), %r8     /* lda_bytes = lda * 2 */
    lea 0(,%r10,2), %rcx    /* ldb_bytes = ldb * 2 */
    
    /* K-loop: idx from 0 to k, increment by 32 */
    xor %rax, %rax          /* idx = 0 */
    
.Lk_loop:
    cmp %rdx, %rax          /* if idx >= k, exit */
    jge .Lk_done
    
    /* Compute base addresses for this k-iteration */
    lea 0(%r14, %rax, 2), %rbx  /* base_a = a + idx*2 */
    lea 0(%r9, %rax, 2), %r11   /* base_b = b + idx*2 */
    
    /* Load all 4 rows of A: a[ii+ii_local, idx:idx+32] for ii_local in 0..4 */
    mov %rdi, %r12
    imul %r8, %r12
    vmovups (%rbx, %r12), %zmm18        /* A[ii+0] */
    
    mov %rdi, %r12
    inc %r12
    imul %r8, %r12
    vmovups (%rbx, %r12), %zmm19        /* A[ii+1] */
    
    mov %rdi, %r12
    add $2, %r12
    imul %r8, %r12
    vmovups (%rbx, %r12), %zmm20        /* A[ii+2] */
    
    mov %rdi, %r12
    add $3, %r12
    imul %r8, %r12
    vmovups (%rbx, %r12), %zmm21        /* A[ii+3] */
    
    /* jj_local = 0: Load B[jj+0, idx:idx+32], do 4 VDPBF16PS */
    mov %rsi, %r12
    imul %rcx, %r12
    vmovups (%r11, %r12), %zmm22        /* B[jj+0] */
    
    vdpbf16ps %zmm22, %zmm18, %zmm0
    vdpbf16ps %zmm22, %zmm19, %zmm1
    vdpbf16ps %zmm22, %zmm20, %zmm2
    vdpbf16ps %zmm22, %zmm21, %zmm3
    
    /* jj_local = 1: Load B[jj+1, idx:idx+32], do 4 VDPBF16PS */
    mov %rsi, %r12
    inc %r12
    imul %rcx, %r12
    vmovups (%r11, %r12), %zmm22        /* B[jj+1] */
    
    vdpbf16ps %zmm22, %zmm18, %zmm4
    vdpbf16ps %zmm22, %zmm19, %zmm5
    vdpbf16ps %zmm22, %zmm20, %zmm6
    vdpbf16ps %zmm22, %zmm21, %zmm7
    
    /* jj_local = 2: Load B[jj+2, idx:idx+32], do 4 VDPBF16PS */
    mov %rsi, %r12
    add $2, %r12
    imul %rcx, %r12
    vmovups (%r11, %r12), %zmm22        /* B[jj+2] */
    
    vdpbf16ps %zmm22, %zmm18, %zmm10
    vdpbf16ps %zmm22, %zmm19, %zmm11
    vdpbf16ps %zmm22, %zmm20, %zmm12
    vdpbf16ps %zmm22, %zmm21, %zmm13
    
    /* jj_local = 3: Load B[jj+3, idx:idx+32], do 4 VDPBF16PS */
    mov %rsi, %r12
    add $3, %r12
    imul %rcx, %r12
    vmovups (%r11, %r12), %zmm22        /* B[jj+3] */
    
    vdpbf16ps %zmm22, %zmm18, %zmm14
    vdpbf16ps %zmm22, %zmm19, %zmm15
    vdpbf16ps %zmm22, %zmm20, %zmm16
    vdpbf16ps %zmm22, %zmm21, %zmm17
    
    /* idx += 32 */
    add $32, %rax
    jmp .Lk_loop
    
.Lk_done:
    /* TODO: Horizontal reduction and write back
     * For now, just return with accumulators in registers
     */
    
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbp
    ret

.size gemm_bf16_kernel_asm, .-gemm_bf16_kernel_asm

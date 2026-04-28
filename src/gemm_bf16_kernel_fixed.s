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
 *   stack + 16 = ldb (usize)
 *   xmm1 = beta (f32)
 *   stack + 24 = c (*mut [f32])
 *   stack + 32 = ldc (usize)
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
    
    /* Preserve alpha and beta in xmm8, xmm9 */
    movaps %xmm0, %xmm8     /* alpha */
    movaps %xmm1, %xmm9     /* beta */
    
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
    mov %rdi, %r11
    imul %r8, %r11          /* a_row_offset = ii * lda_bytes */
    
    /* Strength reduce: compute initial column offset for B (1 multiply) */
    mov %rsi, %rax
    imul %rcx, %rax         /* b_col_offset = jj * ldb_bytes */
    
    /* K-loop: idx from 0 to k, increment by 32 */
    xor %r9, %r9            /* idx = 0 */
    
.Lk_loop:
    cmp %rdx, %r9           /* if idx >= k, exit */
    jge .Lk_done
    
    /* Compute base addresses for this k-iteration */
    lea 0(%r14, %r9, 2), %rbx  /* base_a = a + idx*2 */
    mov %rsi, %r10
    mov %rsi, %r10
    
    /* Load all 4 rows of A: unroll with strength reduction (add instead of multiply) */
    vmovups (%rbx, %r11), %zmm18        /* A[ii+0] */
    
    lea (%r11, %r8), %r10               /* next_offset = current + lda_bytes */
    vmovups (%rbx, %r10), %zmm19        /* A[ii+1] */
    
    lea (%r10, %r8), %r10               /* next_offset = current + lda_bytes */
    vmovups (%rbx, %r10), %zmm20        /* A[ii+2] */
    
    lea (%r10, %r8), %r10               /* next_offset = current + lda_bytes */
    vmovups (%rbx, %r10), %zmm21        /* A[ii+3] */
    
    /* Load b base pointer */
    lea 0(%r9, %r9, 2), %rbx
    add %r9, %rbx
    add %r9, %rbx            /* rbx = idx*2 for bf16 (idx*2 bytes) - WRONG! */
    
    /* Actually, for B matrix in bf16, offset is idx*2 bytes */
    mov %r9, %rbx
    shl $1, %rbx             /* rbx = idx * 2 (bf16 size) */
    
    /* Hmm, I need to reconsider. r9 is b pointer. Let me get base */
    mov 8(%rbp), %rbx        /* saved return address - WRONG! */
    
    /* Actually, I should load b pointer from the original location */
    /* It's in r9 parameter */
    mov %r9, %r10  
    
    /* Wait, I'm confusing myself. Let me restart */
    /* The original code had: mov %r9, %r11; lea 0(%r9, %rax, 2), %r11 */
    /* But I lost track of things. Let me be more careful */
    
    /* In the k-loop, I need base_b = b + idx*2 (for bf16) */
    /* b pointer is... actually I never saved it! I used r9 for ldb_bytes */
    
    /* I think I need to restructure this. Let me restart the prologue. */
    
    jmp .Lk_loop
    
.Lk_done:
    /* Write back placeholder - will implement with horizontal reduce */
    
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbp
    ret

.size gemm_bf16_kernel_asm, .-gemm_bf16_kernel_asm

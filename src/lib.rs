#![allow(unsafe_op_in_unsafe_fn)]

use half::bf16;

/// Compute a single TILE_I × TILE_J output tile using the k-loop.
/// Uses AVX-512 intrinsics with VDPBF16PS for efficient BF16 computation.
#[cfg(target_arch = "x86_64")]
#[target_feature(enable = "avx512f,avx512bf16")]
unsafe fn gemm_bf16_kernel(
    ii: usize,
    jj: usize,
    k: usize,
    alpha: f32,
    a: &[bf16],
    lda: usize,
    b: &[bf16],
    ldb: usize,
    beta: f32,
    c: &mut [f32],
    ldc: usize,
) {
    use std::arch::x86_64::*;
    use std::mem::transmute;
    
    const TILE_I: usize = 4;
    const TILE_J: usize = 4;
    
    // Initialize accumulators for the TILE_I × TILE_J tile
    let mut accumulators = [[_mm512_setzero_ps(); TILE_J]; TILE_I];
    
    // Outer loop over k (in chunks of 32)
    let mut idx = 0;
    while idx + 32 <= k {
        // Inner loops over j and i in the tile
        for jj_local in 0..TILE_J {
            for ii_local in 0..TILE_I {
                let i = ii + ii_local;
                let j = jj + jj_local;
                
                let a_ptr = a.as_ptr().add(i * lda + idx);
                let b_ptr = b.as_ptr().add(j * ldb + idx);
                
                let a_data: __m512bh = transmute(_mm512_loadu_si512(a_ptr as *const __m512i));
                let b_data: __m512bh = transmute(_mm512_loadu_si512(b_ptr as *const __m512i));
                
                accumulators[ii_local][jj_local] = _mm512_dpbf16_ps(accumulators[ii_local][jj_local], a_data, b_data);
            }
        }
        
        idx += 32;
    }
    
    // Write back results
    for jj_local in 0..TILE_J {
        for ii_local in 0..TILE_I {
            let i = ii + ii_local;
            let j = jj + jj_local;
            let dot = _mm512_reduce_add_ps(accumulators[ii_local][jj_local]);
            let c_idx = i + j * ldc;
            c[c_idx] = alpha * dot + beta * c[c_idx];
        }
    }
}

/// General matrix multiply: C = alpha * A^T * B + beta * C
///
/// Requires x86_64 with AVX-512F and AVX-512BF16 instructions.
///
/// Matrices are stored in column-major order:
/// - A: k×m (transposed), column-major, leading dimension lda
/// - B: k×n (untransposed), column-major, leading dimension ldb
/// - C: m×n (result), column-major, leading dimension ldc
/// 
/// m and n must be multiples of 16. k must be a multiple of 32.
/// Uses hierarchical tiling with 8×16 supertiles containing 4×4 tiles for cache coherence.
#[cfg(target_arch = "x86_64")]
#[target_feature(enable = "avx512f,avx512bf16")]
pub unsafe fn gemm_bf16(
    m: usize,
    n: usize,
    k: usize,
    alpha: f32,
    a: &[bf16],
    lda: usize,
    b: &[bf16],
    ldb: usize,
    beta: f32,
    c: &mut [f32],
    ldc: usize,
) {
    const TILE_I: usize = 4;
    const TILE_J: usize = 4;
    const SUPERTILE_I: usize = 8;
    const SUPERTILE_J: usize = 16;
    
    assert!(k % 32 == 0, "k must be a multiple of 32");
    assert!(m % SUPERTILE_I == 0, "m must be a multiple of SUPERTILE_I (8)");
    assert!(n % SUPERTILE_J == 0, "n must be a multiple of SUPERTILE_J (16)");
    
    // Iterate over supertiles (column-major outer loop)
    let mut jjj = 0;
    while jjj < n {
        let mut iii = 0;
        while iii < m {
            // Within supertile, iterate over 4×4 tiles
            let mut jj = jjj;
            while jj < (jjj + SUPERTILE_J) {
                let mut ii = iii;
                while ii < (iii + SUPERTILE_I) {
                    gemm_bf16_kernel(ii, jj, k, alpha, a, lda, b, ldb, beta, c, ldc);
                    ii += TILE_I;
                }
                jj += TILE_J;
            }
            iii += SUPERTILE_I;
        }
        jjj += SUPERTILE_J;
    }
}

/// Parameterized GEMM with configurable supertile dimensions.
/// 
/// Requires x86_64 with AVX-512F and AVX-512BF16 instructions.
/// 
/// supertile_i: height of supertile (must divide m and be multiple of TILE_I=4)
/// supertile_j: width of supertile (must divide n and be multiple of TILE_J=4)
#[cfg(target_arch = "x86_64")]
#[target_feature(enable = "avx512f,avx512bf16")]
pub unsafe fn gemm_bf16_with_tiling(
    m: usize,
    n: usize,
    k: usize,
    alpha: f32,
    a: &[bf16],
    lda: usize,
    b: &[bf16],
    ldb: usize,
    beta: f32,
    c: &mut [f32],
    ldc: usize,
    supertile_i: usize,
    supertile_j: usize,
) {
    assert!(k % 32 == 0, "k must be a multiple of 32");
    assert!(m % supertile_i == 0, "m must be a multiple of supertile_i");
    assert!(n % supertile_j == 0, "n must be a multiple of supertile_j");
    assert!(supertile_i % 4 == 0, "supertile_i must be a multiple of 4 (TILE_I)");
    assert!(supertile_j % 4 == 0, "supertile_j must be a multiple of 4 (TILE_J)");
    
    const TILE_I: usize = 4;
    const TILE_J: usize = 4;
    
    // Iterate over supertiles (column-major outer loop)
    let mut jjj = 0;
    while jjj < n {
        let mut iii = 0;
        while iii < m {
            // Within supertile, iterate over 4×4 tiles
            let mut jj = jjj;
            while jj < (jjj + supertile_j) {
                let mut ii = iii;
                while ii < (iii + supertile_i) {
                    gemm_bf16_kernel(ii, jj, k, alpha, a, lda, b, ldb, beta, c, ldc);
                    ii += TILE_I;
                }
                jj += TILE_J;
            }
            iii += supertile_i;
        }
        jjj += supertile_j;
    }
}


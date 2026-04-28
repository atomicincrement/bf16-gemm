#![allow(unsafe_op_in_unsafe_fn)]

use half::bf16;

/// Compute the sum of scalar * vector over all elements.
/// 
/// Assumes `vector` length is a multiple of 32 bf16 elements (64 bytes).
/// Uses AVX-512 with unaligned loads and VDPBF16PS for efficient computation.
#[cfg(target_arch = "x86_64")]
#[target_feature(enable = "avx512f,avx512bf16")]
pub unsafe fn mul_bf16(scalar: bf16, vector: &[bf16]) -> f32 {
    use std::arch::x86_64::*;
    use std::mem::transmute;

    // Broadcast scalar to all 32 BF16 slots in a ZMM register
    let scalar_bf16: __m512bh = transmute(_mm512_set1_epi16(scalar.to_bits() as i16));

    let mut accumulator = _mm512_setzero_ps();

    let mut idx = 0;
    while idx + 32 <= vector.len() {
        // Unaligned load of 32 BF16 values (64 bytes)
        let ptr = vector.as_ptr().add(idx);
        let vec_data: __m512bh = transmute(_mm512_loadu_si512(ptr as *const __m512i));

        // Dot product: accumulate scalar * vector using VDPBF16PS
        accumulator = _mm512_dpbf16_ps(accumulator, scalar_bf16, vec_data);

        idx += 32;
    }

    // Horizontal reduce to get final sum
    _mm512_reduce_add_ps(accumulator)
}

#[cfg(not(target_arch = "x86_64"))]
pub fn mul_bf16(scalar: bf16, vector: &[bf16]) -> f32 {
    let scalar_f32 = scalar.to_f32();
    vector.iter().map(|v| scalar_f32 * v.to_f32()).sum()
}

/// Compute the dot product of two BF16 vectors.
/// 
/// Assumes both vectors have length that is a multiple of 32 bf16 elements.
/// Uses AVX-512 with unaligned loads and VDPBF16PS for efficient computation.
#[cfg(target_arch = "x86_64")]
#[target_feature(enable = "avx512f,avx512bf16")]
pub unsafe fn bf16_dot_product(a: &[bf16], b: &[bf16]) -> f32 {
    use std::arch::x86_64::*;
    use std::mem::transmute;

    assert_eq!(a.len(), b.len());

    let mut accumulator = _mm512_setzero_ps();

    let mut idx = 0;
    while idx + 32 <= a.len() {
        // Unaligned load of 32 BF16 values from each vector
        let a_ptr = a.as_ptr().add(idx);
        let b_ptr = b.as_ptr().add(idx);
        
        let a_data: __m512bh = transmute(_mm512_loadu_si512(a_ptr as *const __m512i));
        let b_data: __m512bh = transmute(_mm512_loadu_si512(b_ptr as *const __m512i));

        // Dot product: accumulate a * b using VDPBF16PS
        accumulator = _mm512_dpbf16_ps(accumulator, a_data, b_data);

        idx += 32;
    }

    // Horizontal reduce to get final sum
    _mm512_reduce_add_ps(accumulator)
}

#[cfg(not(target_arch = "x86_64"))]
pub fn bf16_dot_product(a: &[bf16], b: &[bf16]) -> f32 {
    assert_eq!(a.len(), b.len());
    a.iter().zip(b.iter()).map(|(x, y)| x.to_f32() * y.to_f32()).sum()
}

/// General matrix multiply: C = alpha * A^T * B + beta * C
///
/// Currently only supports trans_a='T' and trans_b='N'.
/// 
/// Matrices are stored in column-major order:
/// - A: k×m (transposed), column-major, leading dimension lda
/// - B: k×n (untransposed), column-major, leading dimension ldb
/// - C: m×n (result), column-major, leading dimension ldc
/// 
/// m and n must be multiples of 4.
/// k must be a multiple of 32.
/// Uses 4×4 tiling for improved cache coherence.
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
    use std::arch::x86_64::*;
    use std::mem::transmute;
    
    assert!(k % 32 == 0, "k must be a multiple of 32");
    assert!(m % 4 == 0, "m must be a multiple of 4");
    assert!(n % 4 == 0, "n must be a multiple of 4");
    
    const TILE: usize = 4;
    
    // Iterate over 4×4 tiles of output matrix C in column-major order
    let mut jj = 0;
    while jj < n {
        let mut ii = 0;
        while ii < m {
            // Process 4×4 tile
            for j in jj..jj + TILE {
                // Initialize accumulators for the 4 i values in this tile
                let mut accumulators = [_mm512_setzero_ps(); 4];
                
                // Outer loop over k (in chunks of 32)
                let mut idx = 0;
                while idx + 32 <= k {
                    // Inner loop over i in the tile
                    for ii_local in 0..TILE {
                        let i = ii + ii_local;
                        
                        let a_ptr = a.as_ptr().add(i * lda + idx);
                        let b_ptr = b.as_ptr().add(j * ldb + idx);
                        
                        let a_data: __m512bh = transmute(_mm512_loadu_si512(a_ptr as *const __m512i));
                        let b_data: __m512bh = transmute(_mm512_loadu_si512(b_ptr as *const __m512i));
                        
                        accumulators[ii_local] = _mm512_dpbf16_ps(accumulators[ii_local], a_data, b_data);
                    }
                    
                    idx += 32;
                }
                
                // Write back results
                for ii_local in 0..TILE {
                    let i = ii + ii_local;
                    let dot = _mm512_reduce_add_ps(accumulators[ii_local]);
                    let c_idx = i + j * ldc;
                    c[c_idx] = alpha * dot + beta * c[c_idx];
                }
            }
            
            ii += TILE;
        }
        
        jj += TILE;
    }
}

#[cfg(not(target_arch = "x86_64"))]
pub fn gemm_bf16(
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
    assert!(m % 4 == 0, "m must be a multiple of 4");
    assert!(n % 4 == 0, "n must be a multiple of 4");
    
    const TILE: usize = 4;
    
    let mut jj = 0;
    while jj < n {
        let mut ii = 0;
        while ii < m {
            for j in jj..jj + TILE {
                // Initialize accumulators for the 4 i values in this tile
                let mut accumulators = [0.0f32; 4];
                
                // Outer loop over k
                for idx in 0..k {
                    // Inner loop over i in the tile
                    for ii_local in 0..TILE {
                        let i = ii + ii_local;
                        accumulators[ii_local] += a[i * lda + idx].to_f32() * b[j * ldb + idx].to_f32();
                    }
                }
                
                // Write back results
                for ii_local in 0..TILE {
                    let i = ii + ii_local;
                    let c_idx = i + j * ldc;
                    c[c_idx] = alpha * accumulators[ii_local] + beta * c[c_idx];
                }
            }
            
            ii += TILE;
        }
        
        jj += TILE;
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_mul_bf16_simple() {
        let scalar = bf16::from_f32(2.0);
        // Vector with 32 bf16 elements (64 bytes)
        let mut vector = vec![bf16::ZERO; 32];
        vector[0] = bf16::from_f32(1.0);
        vector[1] = bf16::from_f32(2.0);
        vector[2] = bf16::from_f32(3.0);
        vector[3] = bf16::from_f32(4.0);
        
        #[cfg(target_arch = "x86_64")]
        let result = unsafe { mul_bf16(scalar, &vector) };
        #[cfg(not(target_arch = "x86_64"))]
        let result = mul_bf16(scalar, &vector);

        // 2.0 * (1.0 + 2.0 + 3.0 + 4.0 + 0 + ... + 0) = 2.0 * 10.0 = 20.0
        assert!((result - 20.0).abs() < 0.1);
    }

    #[test]
    fn test_mul_bf162_simple() {
        let mut a = vec![bf16::ZERO; 32];
        let mut b = vec![bf16::ZERO; 32];
        
        a[0] = bf16::from_f32(1.0);
        a[1] = bf16::from_f32(2.0);
        a[2] = bf16::from_f32(3.0);
        a[3] = bf16::from_f32(4.0);
        
        b[0] = bf16::from_f32(2.0);
        b[1] = bf16::from_f32(3.0);
        b[2] = bf16::from_f32(4.0);
        b[3] = bf16::from_f32(5.0);
        
        #[cfg(target_arch = "x86_64")]
        let result = unsafe { bf16_dot_product(&a, &b) };
        #[cfg(not(target_arch = "x86_64"))]
        let result = bf16_dot_product(&a, &b);

        // 1.0*2.0 + 2.0*3.0 + 3.0*4.0 + 4.0*5.0 = 2 + 6 + 12 + 20 = 40
        assert!((result - 40.0).abs() < 0.1);
    }

    #[test]
    fn test_gemm_bf16_simple() {
        // Test C = alpha * A^T * B + beta * C
        // A: 4×4 (transposed), B: 4×4, C: 4×4
        let m = 4;
        let n = 4;
        let k = 32; // Multiple of 32
        
        let mut a = vec![bf16::ZERO; m * k];
        let mut b = vec![bf16::ZERO; n * k];
        let mut c = vec![0.0f32; m * n];
        
        // A^T in column-major: column i = [i+1, i+2, ...]
        for i in 0..m {
            for idx in 0..k {
                if idx < 2 {
                    a[i * k + idx] = bf16::from_f32((i as f32 + 1.0) * (idx as f32 + 1.0));
                }
            }
        }
        
        // B in column-major
        for j in 0..n {
            for i in 0..k {
                if i < 2 {
                    b[j * k + i] = bf16::from_f32((j as f32 + 1.0) * (i as f32 + 1.0));
                }
            }
        }
        
        #[cfg(target_arch = "x86_64")]
        unsafe {
            gemm_bf16(m, n, k, 1.0, &a, k, &b, k, 0.0, &mut c, m);
        }
        #[cfg(not(target_arch = "x86_64"))]
        gemm_bf16(m, n, k, 1.0, &a, k, &b, k, 0.0, &mut c, m);

        // C[0,0] = a_col0 · b_col0 = (1*1 + 2*2 + 0 + ...) = 5
        // C[1,0] = a_col1 · b_col0 = (2*1 + 4*2 + 0 + ...) = 10
        assert!((c[0] - 5.0).abs() < 0.1, "c[0,0]={}, expected ~5", c[0]);
        assert!((c[1] - 10.0).abs() < 0.1, "c[1,0]={}, expected ~10", c[1]);
    }
}


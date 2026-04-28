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
/// k must be a multiple of 32.
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
    assert!(k % 32 == 0, "k must be a multiple of 32");
    
    // Iterate over output matrix C in column-major order
    for j in 0..n {
        for i in 0..m {
            // Extract column i of A^T (which is column i of the transposed A matrix in column-major)
            let a_col = &a[i * lda .. i * lda + k];
            
            // Extract column j of B
            let b_col = &b[j * ldb .. j * ldb + k];
            
            // Compute dot product
            let dot = bf16_dot_product(a_col, b_col);
            
            // Update C[i, j] = alpha * dot + beta * C[i, j]
            let c_idx = i + j * ldc;
            c[c_idx] = alpha * dot + beta * c[c_idx];
        }
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
    for j in 0..n {
        for i in 0..m {
            let a_col = &a[i * lda .. i * lda + k];
            let b_col = &b[j * ldb .. j * ldb + k];
            let dot = bf16_dot_product(a_col, b_col);
            let c_idx = i + j * ldc;
            c[c_idx] = alpha * dot + beta * c[c_idx];
        }
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
        // A: 4×2 (transposed), B: 4×3, C: 2×3
        let m = 2;
        let n = 3;
        let k = 32; // Multiple of 32
        
        let mut a = vec![bf16::ZERO; m * k];
        let mut b = vec![bf16::ZERO; n * k];
        let mut c = vec![0.0f32; m * n];
        
        // A^T in column-major: column 0 = [1, 2, ...], column 1 = [3, 4, ...]
        for i in 0..k {
            a[0 * k + i] = bf16::from_f32(if i == 0 { 1.0 } else if i == 1 { 2.0 } else { 0.0 });
            a[1 * k + i] = bf16::from_f32(if i == 0 { 3.0 } else if i == 1 { 4.0 } else { 0.0 });
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
        // C[1,0] = a_col1 · b_col0 = (3*1 + 4*2 + 0 + ...) = 11
        // C[0,1] = a_col0 · b_col1 = (1*2 + 2*4 + 0 + ...) = 10
        // etc.
        assert!((c[0] - 5.0).abs() < 0.1, "c[0,0]={}, expected ~5", c[0]);
        assert!((c[1] - 11.0).abs() < 0.1, "c[1,0]={}, expected ~11", c[1]);
        assert!((c[2] - 10.0).abs() < 0.1, "c[0,1]={}, expected ~10", c[2]);
    }
}


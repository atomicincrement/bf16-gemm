use half::bf16;

// ── AVX512-BF16 assembly kernel (Option A, pre-transposed B) ─────────────────
unsafe extern "C" {
    fn gemm_avx512_bf16_opt_a(
        a: *const u16,
        b_t: *const u16,
        c: *mut f32,
        m: usize,
        n: usize,
        k: usize,
    );
}

/// Safe wrapper: transposes B then calls the AVX512 kernel.
pub fn gemm_avx512_opt_a(
    a: &[bf16],
    b: &[bf16],
    c: &mut [f32],
    m: usize,
    n: usize,
    k: usize,
) {
    assert_eq!(a.len(), m * k);
    assert_eq!(b.len(), k * n);
    assert_eq!(c.len(), m * n);

    let mut b_t = vec![bf16::ZERO; n * k];
    for p in 0..k {
        for j in 0..n {
            b_t[j * k + p] = b[p * n + j];
        }
    }

    unsafe {
        gemm_avx512_bf16_opt_a(
            a.as_ptr() as *const u16,
            b_t.as_ptr() as *const u16,
            c.as_mut_ptr(),
            m,
            n,
            k,
        );
    }
}

/// Reference BF16 GEMM: C += A * B
///
/// A: M×K row-major bf16, B: K×N row-major bf16, C: M×N row-major f32.
pub fn gemm_bf16_ref(
    a: &[bf16],
    b: &[bf16],
    c: &mut [f32],
    m: usize,
    n: usize,
    k: usize,
) {
    assert_eq!(a.len(), m * k);
    assert_eq!(b.len(), k * n);
    assert_eq!(c.len(), m * n);

    const KC: usize = 256;
    const NC: usize = 512;

    for jc in (0..n).step_by(NC) {
        let jc_end = (jc + NC).min(n);
        for pc in (0..k).step_by(KC) {
            let pc_end = (pc + KC).min(k);
            for i in 0..m {
                for j in jc..jc_end {
                    let mut acc = 0.0f32;
                    for p in pc..pc_end {
                        acc += a[i * k + p].to_f32() * b[p * n + j].to_f32();
                    }
                    c[i * n + j] += acc;
                }
            }
        }
    }
}

/// F32 GEMM reference: C += A * B
pub fn gemm_f32_ref(
    a: &[f32],
    b: &[f32],
    c: &mut [f32],
    m: usize,
    n: usize,
    k: usize,
) {
    assert_eq!(a.len(), m * k);
    assert_eq!(b.len(), k * n);
    assert_eq!(c.len(), m * n);

    for i in 0..m {
        for p in 0..k {
            let a_ip = a[i * k + p];
            for j in 0..n {
                c[i * n + j] += a_ip * b[p * n + j];
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use half::bf16;

    fn lcg(state: &mut u64) -> f32 {
        *state = state
            .wrapping_mul(6364136223846793005)
            .wrapping_add(1442695040888963407);
        let bits = (*state >> 32) as u32;
        (bits as f32 / u32::MAX as f32) * 2.0 - 1.0
    }

    fn rand_f32(n: usize, seed: u64) -> Vec<f32> {
        let mut s = seed;
        (0..n).map(|_| lcg(&mut s)).collect()
    }

    fn to_bf16(v: &[f32]) -> Vec<bf16> {
        v.iter().map(|&x| bf16::from_f32(x)).collect()
    }

    fn frobenius_rel_err(got: &[f32], expected: &[f32]) -> f32 {
        let diff_sq: f32 = got
            .iter()
            .zip(expected)
            .map(|(&a, &b)| (a - b).powi(2))
            .sum();
        let ref_sq: f32 = expected.iter().map(|&x| x.powi(2)).sum();
        (diff_sq / ref_sq.max(1e-12)).sqrt()
    }

    #[test]
    fn identity_4x4() {
        let n = 4;
        let id: Vec<bf16> = (0..n * n)
            .map(|i| bf16::from_f32(if i / n == i % n { 1.0 } else { 0.0 }))
            .collect();
        let mut c = vec![0.0f32; n * n];
        gemm_bf16_ref(&id, &id, &mut c, n, n, n);
        let expected: Vec<f32> = (0..n * n)
            .map(|i| if i / n == i % n { 1.0 } else { 0.0 })
            .collect();
        assert!(frobenius_rel_err(&c, &expected) < 1e-4, "identity failed: {c:?}");
    }

    #[test]
    fn random_small() {
        let (m, n, k) = (16, 16, 32);
        let a_f32 = rand_f32(m * k, 42);
        let b_f32 = rand_f32(k * n, 99);
        let mut c_ref = vec![0.0f32; m * n];
        gemm_f32_ref(&a_f32, &b_f32, &mut c_ref, m, n, k);
        let mut c_bf16 = vec![0.0f32; m * n];
        gemm_bf16_ref(&to_bf16(&a_f32), &to_bf16(&b_f32), &mut c_bf16, m, n, k);
        let err = frobenius_rel_err(&c_bf16, &c_ref);
        assert!(err < 0.01, "small: {err:.4} > 1%");
    }

    #[test]
    fn random_medium() {
        let (m, n, k) = (64, 64, 128);
        let a_f32 = rand_f32(m * k, 7);
        let b_f32 = rand_f32(k * n, 13);
        let mut c_ref = vec![0.0f32; m * n];
        gemm_f32_ref(&a_f32, &b_f32, &mut c_ref, m, n, k);
        let mut c_bf16 = vec![0.0f32; m * n];
        gemm_bf16_ref(&to_bf16(&a_f32), &to_bf16(&b_f32), &mut c_bf16, m, n, k);
        let err = frobenius_rel_err(&c_bf16, &c_ref);
        assert!(err < 0.01, "medium: {err:.4} > 1%");
    }

    #[test]
    fn non_square() {
        let (m, n, k) = (32, 48, 16);
        let a_f32 = rand_f32(m * k, 1234);
        let b_f32 = rand_f32(k * n, 5678);
        let mut c_ref = vec![0.0f32; m * n];
        gemm_f32_ref(&a_f32, &b_f32, &mut c_ref, m, n, k);
        let mut c_bf16 = vec![0.0f32; m * n];
        gemm_bf16_ref(&to_bf16(&a_f32), &to_bf16(&b_f32), &mut c_bf16, m, n, k);
        let err = frobenius_rel_err(&c_bf16, &c_ref);
        assert!(err < 0.01, "non-square: {err:.4} > 1%");
    }

    #[test]
    fn avx512_identity_4x4() {
        let n = 4;
        let id: Vec<bf16> = (0..n * n)
            .map(|i| bf16::from_f32(if i / n == i % n { 1.0 } else { 0.0 }))
            .collect();
        let mut c = vec![0.0f32; n * n];
        gemm_avx512_opt_a(&id, &id, &mut c, n, n, n);
        let expected: Vec<f32> = (0..n * n)
            .map(|i| if i / n == i % n { 1.0 } else { 0.0 })
            .collect();
        assert!(frobenius_rel_err(&c, &expected) < 1e-4, "avx512 identity failed: {c:?}");
    }

    #[test]
    fn avx512_random_small() {
        let (m, n, k) = (16, 16, 32);
        let a_f32 = rand_f32(m * k, 42);
        let b_f32 = rand_f32(k * n, 99);
        let mut c_ref = vec![0.0f32; m * n];
        gemm_f32_ref(&a_f32, &b_f32, &mut c_ref, m, n, k);
        let mut c_avx = vec![0.0f32; m * n];
        gemm_avx512_opt_a(&to_bf16(&a_f32), &to_bf16(&b_f32), &mut c_avx, m, n, k);
        let err = frobenius_rel_err(&c_avx, &c_ref);
        assert!(err < 0.01, "avx512 small: {err:.4} > 1%");
    }

    #[test]
    fn avx512_random_medium() {
        let (m, n, k) = (64, 64, 128);
        let a_f32 = rand_f32(m * k, 7);
        let b_f32 = rand_f32(k * n, 13);
        let mut c_ref = vec![0.0f32; m * n];
        gemm_f32_ref(&a_f32, &b_f32, &mut c_ref, m, n, k);
        let mut c_avx = vec![0.0f32; m * n];
        gemm_avx512_opt_a(&to_bf16(&a_f32), &to_bf16(&b_f32), &mut c_avx, m, n, k);
        let err = frobenius_rel_err(&c_avx, &c_ref);
        assert!(err < 0.01, "avx512 medium: {err:.4} > 1%");
    }

    #[test]
    fn avx512_non_square() {
        let (m, n, k) = (32, 48, 16);
        let a_f32 = rand_f32(m * k, 1234);
        let b_f32 = rand_f32(k * n, 5678);
        let mut c_ref = vec![0.0f32; m * n];
        gemm_f32_ref(&a_f32, &b_f32, &mut c_ref, m, n, k);
        let mut c_avx = vec![0.0f32; m * n];
        gemm_avx512_opt_a(&to_bf16(&a_f32), &to_bf16(&b_f32), &mut c_avx, m, n, k);
        let err = frobenius_rel_err(&c_avx, &c_ref);
        assert!(err < 0.01, "avx512 non-square: {err:.4} > 1%");
    }

    #[test]
    fn avx512_k_not_multiple_of_32() {
        let (m, n, k) = (8, 8, 50);
        let a_f32 = rand_f32(m * k, 999);
        let b_f32 = rand_f32(k * n, 777);
        let mut c_ref = vec![0.0f32; m * n];
        gemm_f32_ref(&a_f32, &b_f32, &mut c_ref, m, n, k);
        let mut c_avx = vec![0.0f32; m * n];
        gemm_avx512_opt_a(&to_bf16(&a_f32), &to_bf16(&b_f32), &mut c_avx, m, n, k);
        let err = frobenius_rel_err(&c_avx, &c_ref);
        assert!(err < 0.01, "avx512 k-tail: {err:.4} > 1%");
    }
}

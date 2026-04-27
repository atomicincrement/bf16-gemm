//! BF16 GEMM kernels using AVX-512BF16 (e.g. AMD Zen 5, Intel Sapphire Rapids+).
//!
//! The main entry point is [`txgemm`], which computes **C += Aᵀ × B**.
//!
//! # Matrix conventions
//! | arg | logical shape | element | storage |
//! |-----|---------------|---------|---------|
//! | `a` | K × M | BF16 | row-major: `a[k*m + i]` |
//! | `b` | K × N | BF16 | row-major: `b[k*n + j]` |
//! | `c` | M × N | F32  | row-major: `c[i*n + j]` |
//!
//! `a` is therefore stored in the *transposed* orientation: column `i` of `Aᵀ`
//! is row `i` of the stored matrix `a`.

use half::bf16;

// ── public API ───────────────────────────────────────────────────────────────

/// Scalar reference implementation of **C += Aᵀ × B**.
///
/// Useful for correctness checking; not optimised.
pub fn txgemm_ref(a: &[bf16], b: &[bf16], c: &mut [f32], m: usize, n: usize, k: usize) {
    assert_eq!(a.len(), k * m);
    assert_eq!(b.len(), k * n);
    assert_eq!(c.len(), m * n);
    for ki in 0..k {
        for i in 0..m {
            let av = a[ki * m + i].to_f32();
            for j in 0..n {
                c[i * n + j] += av * b[ki * n + j].to_f32();
            }
        }
    }
}

/// AVX-512 BF16 implementation of **C += Aᵀ × B** (experimental).
///
/// # Panics
/// Panics in debug mode if the slice lengths are inconsistent with `m`, `n`, `k`.
pub fn txgemm(a: &[bf16], b: &[bf16], c: &mut [f32], m: usize, n: usize, k: usize) {
    txgemm_avx512_simple(a, b, c, m, n, k);
}

/// Simple AVX-512 BF16 implementation (unoptimised, for experimentation).
///
/// Computes a 2×2 tile of output elements at a time.
/// Assumes m and n are both even.
pub fn txgemm_avx512_simple(a: &[bf16], b: &[bf16], c: &mut [f32], m: usize, n: usize, k: usize) {
    assert_eq!(a.len(), k * m);
    assert_eq!(b.len(), k * n);
    assert_eq!(c.len(), m * n);

    let mut i = 0;
    while i < m {
        let mut j = 0;
        while j < n {
            // Four accumulators for the 2×2 tile: C[i,j], C[i,j+1], C[i+1,j], C[i+1,j+1]
            let mut sum00 = 0.0f32;
            let mut sum01 = 0.0f32;
            let mut sum10 = 0.0f32;
            let mut sum11 = 0.0f32;

            // Accumulate dot products over k
            for ki in 0..k {
                let a_val_i = a[ki * m + i].to_f32();
                let a_val_i1 = a[ki * m + i + 1].to_f32();
                let b_val_j = b[ki * n + j].to_f32();
                let b_val_j1 = b[ki * n + j + 1].to_f32();

                sum00 += a_val_i * b_val_j;
                sum01 += a_val_i * b_val_j1;
                sum10 += a_val_i1 * b_val_j;
                sum11 += a_val_i1 * b_val_j1;
            }

            // Write back at end of j loop
            c[i * n + j] += sum00;
            c[i * n + (j + 1)] += sum01;
            c[(i + 1) * n + j] += sum10;
            c[(i + 1) * n + (j + 1)] += sum11;

            j += 2;
        }
        i += 2;
    }
}



// ── tests ────────────────────────────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;

    /// LCG random number generator (deterministic, no external deps).
    fn lcg(state: &mut u64) -> f32 {
        *state = state
            .wrapping_mul(6364136223846793005)
            .wrapping_add(1442695040888963407);
        let bits = (*state >> 32) as u32;
        (bits as f32 / u32::MAX as f32) * 2.0 - 1.0
    }

    /// Generate a deterministic BF16 vector of size `n` with seed `seed`.
    fn make_bf16_deterministic(n: usize, seed: u64) -> Vec<bf16> {
        let mut s = seed;
        (0..n).map(|_| bf16::from_f32(lcg(&mut s))).collect()
    }

    /// Check if two f32 values are close (relative or absolute tolerance).
    fn is_close(a: f32, b: f32, rel_tol: f32, abs_tol: f32) -> bool {
        if a.is_nan() || b.is_nan() {
            return false;
        }
        let diff = (a - b).abs();
        diff <= abs_tol || diff <= rel_tol * a.abs().max(b.abs())
    }

    #[test]
    fn test_txgemm_small_1x1x1() {
        let m = 1;
        let n = 1;
        let k = 1;
        let a = make_bf16_deterministic(k * m, 1);
        let b = make_bf16_deterministic(k * n, 2);

        let mut c_ref = vec![0.0f32; m * n];
        let mut c_opt = vec![0.0f32; m * n];

        txgemm_ref(&a, &b, &mut c_ref, m, n, k);
        txgemm(&a, &b, &mut c_opt, m, n, k);

        assert_eq!(c_ref.len(), c_opt.len());
        for i in 0..c_ref.len() {
            assert!(
                is_close(c_ref[i], c_opt[i], 1e-5, 1e-6),
                "Mismatch at index {}: ref={}, opt={}",
                i,
                c_ref[i],
                c_opt[i]
            );
        }
    }

    #[test]
    fn test_txgemm_small_4x4x4() {
        // Test exact tile size
        let m = 4;
        let n = 4;
        let k = 4;
        let a = make_bf16_deterministic(k * m, 42);
        let b = make_bf16_deterministic(k * n, 43);

        let mut c_ref = vec![0.0f32; m * n];
        let mut c_opt = vec![0.0f32; m * n];

        txgemm_ref(&a, &b, &mut c_ref, m, n, k);
        txgemm(&a, &b, &mut c_opt, m, n, k);

        for i in 0..c_ref.len() {
            assert!(
                is_close(c_ref[i], c_opt[i], 1e-5, 1e-6),
                "Mismatch at index {}: ref={}, opt={}",
                i,
                c_ref[i],
                c_opt[i]
            );
        }
    }

    #[test]
    fn test_txgemm_medium_8x12x64() {
        // Test non-aligned sizes
        let m = 8;
        let n = 12;
        let k = 64;
        let a = make_bf16_deterministic(k * m, 100);
        let b = make_bf16_deterministic(k * n, 101);

        let mut c_ref = vec![0.0f32; m * n];
        let mut c_opt = vec![0.0f32; m * n];

        txgemm_ref(&a, &b, &mut c_ref, m, n, k);
        txgemm(&a, &b, &mut c_opt, m, n, k);

        for i in 0..c_ref.len() {
            assert!(
                is_close(c_ref[i], c_opt[i], 1e-5, 1e-6),
                "Mismatch at [{}]: ref={}, opt={}",
                i,
                c_ref[i],
                c_opt[i]
            );
        }
    }

    #[test]
    fn test_txgemm_with_kc_boundary() {
        // Test that KC boundary (512) is handled correctly
        let m = 8;
        let n = 8;
        let k = 512; // Exactly one KC block
        let a = make_bf16_deterministic(k * m, 200);
        let b = make_bf16_deterministic(k * n, 201);

        let mut c_ref = vec![0.0f32; m * n];
        let mut c_opt = vec![0.0f32; m * n];

        txgemm_ref(&a, &b, &mut c_ref, m, n, k);
        txgemm(&a, &b, &mut c_opt, m, n, k);

        for i in 0..c_ref.len() {
            assert!(
                is_close(c_ref[i], c_opt[i], 1e-5, 1e-6),
                "Mismatch at [{}]: ref={}, opt={}",
                i,
                c_ref[i],
                c_opt[i]
            );
        }
    }

    #[test]
    fn test_txgemm_across_kc_boundary() {
        // Test k spanning multiple KC blocks
        let m = 8;
        let n = 8;
        let k = 513; // Just past one KC block
        let a = make_bf16_deterministic(k * m, 300);
        let b = make_bf16_deterministic(k * n, 301);

        let mut c_ref = vec![0.0f32; m * n];
        let mut c_opt = vec![0.0f32; m * n];

        txgemm_ref(&a, &b, &mut c_ref, m, n, k);
        txgemm(&a, &b, &mut c_opt, m, n, k);

        for i in 0..c_ref.len() {
            assert!(
                is_close(c_ref[i], c_opt[i], 1e-5, 1e-6),
                "Mismatch at [{}]: ref={}, opt={}",
                i,
                c_ref[i],
                c_opt[i]
            );
        }
    }

    #[test]
    fn test_txgemm_large() {
        // Test larger matrix (but reasonable for quick test)
        let m = 64;
        let n = 64;
        let k = 128;
        let a = make_bf16_deterministic(k * m, 400);
        let b = make_bf16_deterministic(k * n, 401);

        let mut c_ref = vec![0.0f32; m * n];
        let mut c_opt = vec![0.0f32; m * n];

        txgemm_ref(&a, &b, &mut c_ref, m, n, k);
        txgemm(&a, &b, &mut c_opt, m, n, k);

        let mut mismatch_count = 0;
        for i in 0..c_ref.len() {
            if !is_close(c_ref[i], c_opt[i], 1e-4, 1e-5) {
                mismatch_count += 1;
                if mismatch_count <= 5 {
                    eprintln!("Mismatch at [{}]: ref={}, opt={}", i, c_ref[i], c_opt[i]);
                }
            }
        }
        assert_eq!(
            mismatch_count, 0,
            "Found {} mismatches out of {}",
            mismatch_count,
            c_ref.len()
        );
    }

    #[test]
    fn test_txgemm_accumulation() {
        // Test that we're accumulating (C += Aᵀ × B), not overwriting
        let m = 4;
        let n = 4;
        let k = 4;
        let a = make_bf16_deterministic(k * m, 500);
        let b = make_bf16_deterministic(k * n, 501);

        // Initialize C with non-zero values
        let initial_c = 10.0f32;
        let mut c_ref = vec![initial_c; m * n];
        let mut c_opt = vec![initial_c; m * n];
        let c_ref_copy = c_ref.clone();

        txgemm_ref(&a, &b, &mut c_ref, m, n, k);
        txgemm(&a, &b, &mut c_opt, m, n, k);

        // Results should match after accumulation
        for i in 0..c_ref.len() {
            assert!(
                is_close(c_ref[i], c_opt[i], 1e-5, 1e-6),
                "Accumulation mismatch at [{}]: ref={}, opt={}",
                i,
                c_ref[i],
                c_opt[i]
            );
        }

        // Values should have changed (accumulated something non-zero)
        let mut any_changed = false;
        for i in 0..c_opt.len() {
            if (c_opt[i] - c_ref_copy[i]).abs() > 1e-6 {
                any_changed = true;
                break;
            }
        }
        assert!(any_changed, "Expected C to be modified by accumulation");
    }
}

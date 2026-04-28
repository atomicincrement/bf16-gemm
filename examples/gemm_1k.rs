use half::bf16;
use std::time::Instant;

fn main() {
    const M: usize = 1024;
    const N: usize = 1024;
    const K: usize = 1024;

    // Allocate matrices
    // A: K×M (transposed case)
    // B: K×N (untransposed case)
    // C: M×N (result)
    let a = vec![bf16::from_f32(1.0); K * M];
    let b = vec![bf16::from_f32(1.0); K * N];
    let mut c = vec![0.0_f32; M * N];

    println!("=== BF16 GEMM 1024x1024 Benchmark ===");
    println!("M={}, N={}, K={}", M, N, K);
    println!("Matrix A (K×M, transposed): {} elements", a.len());
    println!("Matrix B (K×N, untransposed): {} elements", b.len());
    println!("Matrix C (M×N, result): {} elements", c.len());
    println!();

    // Warm up
    unsafe {
        bf16_gemm::gemm_bf16(
            M, N, K,
            1.0,
            &a, K,
            &b, K,
            0.0,
            &mut c, M,
        );
    }

    println!("Warm-up complete. Running main benchmark...");
    println!();

    // Benchmark
    let start = Instant::now();
    unsafe {
        bf16_gemm::gemm_bf16(
            M, N, K,
            1.0,
            &a, K,
            &b, K,
            0.0,
            &mut c, M,
        );
    }
    let elapsed = start.elapsed();

    println!("Execution time: {:?}", elapsed);
    println!("Execution time: {:.3} ms", elapsed.as_secs_f64() * 1000.0);

    // Compute GFLOPs
    // GEMM requires 2*M*N*K floating point operations (2 ops per dot product)
    let total_flops = 2.0 * (M as f64) * (N as f64) * (K as f64);
    let gflops = total_flops / elapsed.as_secs_f64() / 1e9;
    println!("Performance: {:.2} GFLOPs", gflops);

    // Sanity check on result
    let sample_value = c[0];
    println!();
    println!("Sample output C[0]: {}", sample_value);
    println!("Expected (approximately): {} (K values of 1.0 summed)", K as f32);
}

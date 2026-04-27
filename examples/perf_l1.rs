//! Performance estimation for a small matrix that fits in L1 cache.
//!
//! Zen 5 L1D is 48 KB per core. This example uses a 64×64×64 matrix,
//! which fits comfortably (~32 KB total) and shows the peak compute
//! capability without cache misses.

use bf16_gemm::txgemm;
use half::bf16;
use std::time::Instant;

fn lcg(state: &mut u64) -> f32 {
    *state = state
        .wrapping_mul(6364136223846793005)
        .wrapping_add(1442695040888963407);
    let bits = (*state >> 32) as u32;
    (bits as f32 / u32::MAX as f32) * 2.0 - 1.0
}

fn make_bf16(n: usize, seed: u64) -> Vec<bf16> {
    let mut s = seed;
    (0..n).map(|_| bf16::from_f32(lcg(&mut s))).collect()
}

fn main() {
    // L1 cache: 48 KB per core.
    // 64x64x64 matrix: 2*64*64 + 2*64*64 + 4*64*64 = 32 KB
    let m = 64;
    let n = 64;
    let k = 64;

    println!("BF16 GEMM: L1-cache-friendly matrix");
    println!("===================================");
    println!("Matrix dimensions: M={}, N={}, K={}", m, n, k);

    let total_bytes = 2 * k * m + 2 * k * n + 4 * m * n;
    println!("Estimated L1 footprint: {} KB", total_bytes / 1024);

    // Generate input matrices
    let a = make_bf16(k * m, 42);
    let b = make_bf16(k * n, 43);
    let mut c = vec![0.0f32; m * n];

    // Warm-up
    txgemm(&a, &b, &mut c, m, n, k);

    // Multiple runs to stabilize timing
    let num_runs = 20;
    let mut times = Vec::new();

    for _ in 0..num_runs {
        c.fill(0.0);
        let start = Instant::now();
        txgemm(&a, &b, &mut c, m, n, k);
        let elapsed = start.elapsed();
        times.push(elapsed);
    }

    let min_time = times.iter().map(|t| t.as_secs_f64()).min_by(|a, b| a.partial_cmp(b).unwrap()).unwrap();
    let max_time = times.iter().map(|t| t.as_secs_f64()).max_by(|a, b| a.partial_cmp(b).unwrap()).unwrap();
    let mean_time = times.iter().map(|t| t.as_secs_f64()).sum::<f64>() / num_runs as f64;

    println!("\nTiming ({} runs):", num_runs);
    println!("  Min:  {:.6} s", min_time);
    println!("  Max:  {:.6} s", max_time);
    println!("  Mean: {:.6} s", mean_time);

    // FLOP count and performance
    let flops = 2u64 * m as u64 * n as u64 * k as u64;
    let gflops_min = (flops as f64 / 1e9) / min_time;
    let gflops_mean = (flops as f64 / 1e9) / mean_time;
    let tops_min = gflops_min / 1e3;
    let tops_mean = gflops_mean / 1e3;

    println!("\nPerformance:");
    println!("  Total FLOPs: {:.2e}", flops as f64);
    println!("  Peak (min): {:.2} GFLOPs/s ({:.3} TOPs/s)", gflops_min, tops_min);
    println!("  Mean: {:.2} GFLOPs/s ({:.3} TOPs/s)", gflops_mean, tops_mean);

    println!("\nNote: All data should fit in L1 cache, so this shows");
    println!("      peak compute capability with minimal cache pressure.");
}

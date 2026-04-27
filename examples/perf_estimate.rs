//! Simple performance estimation example for txgemm.
//!
//! Runs a GEMM operation and estimates single-thread throughput in TOPs.

use bf16_gemm::txgemm;
use half::bf16;
use std::time::Instant;

/// LCG random number generator (deterministic, no external deps).
fn lcg(state: &mut u64) -> f32 {
    *state = state
        .wrapping_mul(6364136223846793005)
        .wrapping_add(1442695040888963407);
    let bits = (*state >> 32) as u32;
    (bits as f32 / u32::MAX as f32) * 2.0 - 1.0
}

/// Generate a deterministic BF16 vector.
fn make_bf16(n: usize, seed: u64) -> Vec<bf16> {
    let mut s = seed;
    (0..n).map(|_| bf16::from_f32(lcg(&mut s))).collect()
}

fn main() {
    // Matrix sizes: simulate a reasonable workload
    // Modify these for different problem sizes
    let m = 512; // Rows of C (= columns of A-transposed)
    let n = 512; // Columns of C
    let k = 512; // Reduction dimension

    println!("BF16 GEMM Performance Estimation");
    println!("================================");
    println!("Matrix dimensions: M={}, N={}, K={}", m, n, k);

    let total_bf16 = k * m + k * n;
    let total_f32 = m * n;
    println!(
        "Memory: {} BF16 elements, {} F32 elements",
        total_bf16, total_f32
    );

    // Generate input matrices
    println!("\nGenerating input matrices...");
    let a = make_bf16(k * m, 42);
    let b = make_bf16(k * n, 43);
    let mut c = vec![0.0f32; m * n];

    // Warm-up run
    println!("Warm-up run...");
    txgemm(&a, &b, &mut c, m, n, k);

    // Timed runs
    let num_runs = 5;
    println!("Running {} iterations...", num_runs);
    let mut times = Vec::new();

    for _ in 0..num_runs {
        c.fill(0.0);
        let start = Instant::now();
        txgemm(&a, &b, &mut c, m, n, k);
        let elapsed = start.elapsed();
        times.push(elapsed);
    }

    // Statistics
    let min_time = times.iter().map(|t| t.as_secs_f64()).min_by(|a, b| a.partial_cmp(b).unwrap()).unwrap();
    let max_time = times.iter().map(|t| t.as_secs_f64()).max_by(|a, b| a.partial_cmp(b).unwrap()).unwrap();
    let mean_time = times.iter().map(|t| t.as_secs_f64()).sum::<f64>() / num_runs as f64;

    println!("\nTiming results:");
    println!("  Min:  {:.6} s", min_time);
    println!("  Max:  {:.6} s", max_time);
    println!("  Mean: {:.6} s", mean_time);

    // FLOP count: one multiply + one add per dot product element
    // = 2 * M * N * K
    let flops = 2u64 * m as u64 * n as u64 * k as u64;

    // Performance calculations
    let gflops_min = (flops as f64 / 1e9) / min_time;
    let gflops_mean = (flops as f64 / 1e9) / mean_time;
    let tops_min = gflops_min / 1e3;
    let tops_mean = gflops_mean / 1e3;

    println!("\nPerformance:");
    println!("  Total FLOPs: {:.2e}", flops as f64);
    println!("  Peak (min time): {:.2} GFLOPs/s ({:.3} TOPs/s)", gflops_min, tops_min);
    println!("  Average (mean time): {:.2} GFLOPs/s ({:.3} TOPs/s)", gflops_mean, tops_mean);

    // Estimate single-thread ceiling on peak FMA throughput
    // Modern CPUs: ~2-4 FMA/cycle per core (e.g. 2 x 512-bit FMA ports)
    // This GEMM uses VDPBF16PS, which retires 32 FMAs per instruction.
    // With dual FMA units @ ~3 GHz, peak is roughly 2 * 32 * 3 = 192 GFLOPs ~ 0.192 TOPs
    // But with dual FMA units and ILP, expect up to 2x that in practice.
    println!("\nNotes:");
    println!("  - Each VDPBF16PS retires 32 FMAs");
    println!("  - Zen 5 has 2x 512-bit FMA units");
    println!("  - Peak single-threaded: ~200-400 GFLOPs (0.2-0.4 TOPs) @ 3-4 GHz");
    println!("  - Measured performance: {:.1}% of theoretical peak (if peak=0.3 TOPs)",
             (tops_mean / 0.3) * 100.0);
}

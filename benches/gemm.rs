use bf16_gemm::{gemm_avx512_opt_a, gemm_bf16_ref};
use criterion::{black_box, criterion_group, criterion_main, Criterion, Throughput};
use half::bf16;

const M: usize = 1024;
const N: usize = 1024;
const K: usize = 1024;

// Minimal LCG — same as in the unit tests, no extra deps.
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

fn bench_gemm(c: &mut Criterion) {
    let a = make_bf16(M * K, 1);
    let b = make_bf16(K * N, 2);

    // 2 * M * N * K flops (one multiply + one add per element of the dot product)
    let flops = 2u64 * M as u64 * N as u64 * K as u64;

    let mut group = c.benchmark_group("gemm_1k");
    group.throughput(Throughput::Elements(flops));
    group.sample_size(10); // large matrices; keep wall time reasonable

    group.bench_function("reference", |bencher| {
        let mut c_out = vec![0.0f32; M * N];
        bencher.iter(|| {
            // Zero C each iteration so we measure a fresh GEMM, not accumulation.
            c_out.fill(0.0);
            gemm_bf16_ref(
                black_box(&a),
                black_box(&b),
                black_box(&mut c_out),
                M, N, K,
            );
        });
    });

    group.bench_function("avx512_opt_a", |bencher| {
        let mut c_out = vec![0.0f32; M * N];
        bencher.iter(|| {
            c_out.fill(0.0);
            gemm_avx512_opt_a(
                black_box(&a),
                black_box(&b),
                black_box(&mut c_out),
                M, N, K,
            );
        });
    });

    group.finish();
}

criterion_group!(benches, bench_gemm);
criterion_main!(benches);

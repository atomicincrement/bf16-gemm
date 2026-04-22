fn main() {
    cc::Build::new()
        .file("src/gemm_avx512_bf16_opt_a.s")
        // Pass the AVX512-BF16 march so the assembler accepts vdpbf16ps.
        .flag("-mavx512bf16")
        .compile("gemm_avx512_bf16_opt_a");

    println!("cargo:rerun-if-changed=src/gemm_avx512_bf16_opt_a.s");
}

fn main() {
    // Compile assembly kernel
    cc::Build::new()
        .file("src/gemm_bf16_kernel.s")
        .compile("gemm_bf16_kernel");
}


target/release/build/bf16-gemm-e7cb8420a98778de/out/55b345ab587357f8-gemm_bf16_kernel.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <gemm_bf16_kernel_asm>:
   0:	55                   	push   %rbp
   1:	48 89 e5             	mov    %rsp,%rbp
   4:	41 54                	push   %r12
   6:	41 55                	push   %r13
   8:	41 56                	push   %r14
   a:	41 57                	push   %r15
   c:	4c 8b 55 10          	mov    0x10(%rbp),%r10
  10:	4c 8b 65 18          	mov    0x18(%rbp),%r12
  14:	4c 8b 6d 20          	mov    0x20(%rbp),%r13
  18:	49 89 ce             	mov    %rcx,%r14
  1b:	4d 89 c7             	mov    %r8,%r15
  1e:	62 f1 fd 48 ef c0    	vpxorq %zmm0,%zmm0,%zmm0
  24:	62 f1 f5 48 ef c9    	vpxorq %zmm1,%zmm1,%zmm1
  2a:	62 f1 ed 48 ef d2    	vpxorq %zmm2,%zmm2,%zmm2
  30:	62 f1 e5 48 ef db    	vpxorq %zmm3,%zmm3,%zmm3
  36:	62 f1 dd 48 ef e4    	vpxorq %zmm4,%zmm4,%zmm4
  3c:	62 f1 d5 48 ef ed    	vpxorq %zmm5,%zmm5,%zmm5
  42:	62 f1 cd 48 ef f6    	vpxorq %zmm6,%zmm6,%zmm6
  48:	62 f1 c5 48 ef ff    	vpxorq %zmm7,%zmm7,%zmm7
  4e:	62 51 ad 48 ef d2    	vpxorq %zmm10,%zmm10,%zmm10
  54:	62 51 a5 48 ef db    	vpxorq %zmm11,%zmm11,%zmm11
  5a:	62 51 9d 48 ef e4    	vpxorq %zmm12,%zmm12,%zmm12
  60:	62 51 95 48 ef ed    	vpxorq %zmm13,%zmm13,%zmm13
  66:	62 51 8d 48 ef f6    	vpxorq %zmm14,%zmm14,%zmm14
  6c:	62 51 85 48 ef ff    	vpxorq %zmm15,%zmm15,%zmm15
  72:	62 a1 fd 40 ef c0    	vpxorq %zmm16,%zmm16,%zmm16
  78:	62 a1 f5 40 ef c9    	vpxorq %zmm17,%zmm17,%zmm17
  7e:	4e 8d 04 7d 00 00 00 	lea    0x0(,%r15,2),%r8
  85:	00 
  86:	4a 8d 0c 55 00 00 00 	lea    0x0(,%r10,2),%rcx
  8d:	00 
  8e:	49 89 fc             	mov    %rdi,%r12
  91:	4d 0f af e0          	imul   %r8,%r12
  95:	49 89 f5             	mov    %rsi,%r13
  98:	4c 0f af e9          	imul   %rcx,%r13
  9c:	48 31 c0             	xor    %rax,%rax
  9f:	48 39 d0             	cmp    %rdx,%rax
  a2:	0f 8d c2 00 00 00    	jge    16a <gemm_bf16_kernel_asm+0x16a>
  a8:	49 8d 1c 46          	lea    (%r14,%rax,2),%rbx
  ac:	4d 8d 1c 41          	lea    (%r9,%rax,2),%r11
  b0:	62 a1 7c 48 10 14 23 	vmovups (%rbx,%r12,1),%zmm18
  b7:	4f 8d 34 04          	lea    (%r12,%r8,1),%r14
  bb:	62 a1 7c 48 10 1c 33 	vmovups (%rbx,%r14,1),%zmm19
  c2:	4f 8d 34 06          	lea    (%r14,%r8,1),%r14
  c6:	62 a1 7c 48 10 24 33 	vmovups (%rbx,%r14,1),%zmm20
  cd:	4f 8d 34 06          	lea    (%r14,%r8,1),%r14
  d1:	62 a1 7c 48 10 2c 33 	vmovups (%rbx,%r14,1),%zmm21
  d8:	62 81 7c 48 10 34 2b 	vmovups (%r11,%r13,1),%zmm22
  df:	62 b2 6e 40 52 c6    	vdpbf16ps %zmm22,%zmm18,%zmm0
  e5:	62 b2 66 40 52 ce    	vdpbf16ps %zmm22,%zmm19,%zmm1
  eb:	62 b2 5e 40 52 d6    	vdpbf16ps %zmm22,%zmm20,%zmm2
  f1:	62 b2 56 40 52 de    	vdpbf16ps %zmm22,%zmm21,%zmm3
  f7:	4d 8d 74 0d 00       	lea    0x0(%r13,%rcx,1),%r14
  fc:	62 81 7c 48 10 34 33 	vmovups (%r11,%r14,1),%zmm22
 103:	62 b2 6e 40 52 e6    	vdpbf16ps %zmm22,%zmm18,%zmm4
 109:	62 b2 66 40 52 ee    	vdpbf16ps %zmm22,%zmm19,%zmm5
 10f:	62 b2 5e 40 52 f6    	vdpbf16ps %zmm22,%zmm20,%zmm6
 115:	62 b2 56 40 52 fe    	vdpbf16ps %zmm22,%zmm21,%zmm7
 11b:	4d 8d 34 0e          	lea    (%r14,%rcx,1),%r14
 11f:	62 81 7c 48 10 34 33 	vmovups (%r11,%r14,1),%zmm22
 126:	62 32 6e 40 52 d6    	vdpbf16ps %zmm22,%zmm18,%zmm10
 12c:	62 32 66 40 52 de    	vdpbf16ps %zmm22,%zmm19,%zmm11
 132:	62 32 5e 40 52 e6    	vdpbf16ps %zmm22,%zmm20,%zmm12
 138:	62 32 56 40 52 ee    	vdpbf16ps %zmm22,%zmm21,%zmm13
 13e:	4d 8d 34 0e          	lea    (%r14,%rcx,1),%r14
 142:	62 81 7c 48 10 34 33 	vmovups (%r11,%r14,1),%zmm22
 149:	62 32 6e 40 52 f6    	vdpbf16ps %zmm22,%zmm18,%zmm14
 14f:	62 32 66 40 52 fe    	vdpbf16ps %zmm22,%zmm19,%zmm15
 155:	62 a2 5e 40 52 c6    	vdpbf16ps %zmm22,%zmm20,%zmm16
 15b:	62 a2 56 40 52 ce    	vdpbf16ps %zmm22,%zmm21,%zmm17
 161:	48 83 c0 20          	add    $0x20,%rax
 165:	e9 35 ff ff ff       	jmp    9f <gemm_bf16_kernel_asm+0x9f>
 16a:	41 5f                	pop    %r15
 16c:	41 5e                	pop    %r14
 16e:	41 5d                	pop    %r13
 170:	41 5c                	pop    %r12
 172:	5d                   	pop    %rbp
 173:	c3                   	ret

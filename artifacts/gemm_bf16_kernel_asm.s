
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
  8e:	48 31 c0             	xor    %rax,%rax
  91:	48 39 d0             	cmp    %rdx,%rax
  94:	0f 8d f7 00 00 00    	jge    191 <gemm_bf16_kernel_asm+0x191>
  9a:	49 8d 1c 46          	lea    (%r14,%rax,2),%rbx
  9e:	4d 8d 1c 41          	lea    (%r9,%rax,2),%r11
  a2:	49 89 fc             	mov    %rdi,%r12
  a5:	4d 0f af e0          	imul   %r8,%r12
  a9:	62 a1 7c 48 10 14 23 	vmovups (%rbx,%r12,1),%zmm18
  b0:	49 89 fc             	mov    %rdi,%r12
  b3:	49 ff c4             	inc    %r12
  b6:	4d 0f af e0          	imul   %r8,%r12
  ba:	62 a1 7c 48 10 1c 23 	vmovups (%rbx,%r12,1),%zmm19
  c1:	49 89 fc             	mov    %rdi,%r12
  c4:	49 83 c4 02          	add    $0x2,%r12
  c8:	4d 0f af e0          	imul   %r8,%r12
  cc:	62 a1 7c 48 10 24 23 	vmovups (%rbx,%r12,1),%zmm20
  d3:	49 89 fc             	mov    %rdi,%r12
  d6:	49 83 c4 03          	add    $0x3,%r12
  da:	4d 0f af e0          	imul   %r8,%r12
  de:	62 a1 7c 48 10 2c 23 	vmovups (%rbx,%r12,1),%zmm21
  e5:	49 89 f4             	mov    %rsi,%r12
  e8:	4c 0f af e1          	imul   %rcx,%r12
  ec:	62 81 7c 48 10 34 23 	vmovups (%r11,%r12,1),%zmm22
  f3:	62 b2 6e 40 52 c6    	vdpbf16ps %zmm22,%zmm18,%zmm0
  f9:	62 b2 66 40 52 ce    	vdpbf16ps %zmm22,%zmm19,%zmm1
  ff:	62 b2 5e 40 52 d6    	vdpbf16ps %zmm22,%zmm20,%zmm2
 105:	62 b2 56 40 52 de    	vdpbf16ps %zmm22,%zmm21,%zmm3
 10b:	49 89 f4             	mov    %rsi,%r12
 10e:	49 ff c4             	inc    %r12
 111:	4c 0f af e1          	imul   %rcx,%r12
 115:	62 81 7c 48 10 34 23 	vmovups (%r11,%r12,1),%zmm22
 11c:	62 b2 6e 40 52 e6    	vdpbf16ps %zmm22,%zmm18,%zmm4
 122:	62 b2 66 40 52 ee    	vdpbf16ps %zmm22,%zmm19,%zmm5
 128:	62 b2 5e 40 52 f6    	vdpbf16ps %zmm22,%zmm20,%zmm6
 12e:	62 b2 56 40 52 fe    	vdpbf16ps %zmm22,%zmm21,%zmm7
 134:	49 89 f4             	mov    %rsi,%r12
 137:	49 83 c4 02          	add    $0x2,%r12
 13b:	4c 0f af e1          	imul   %rcx,%r12
 13f:	62 81 7c 48 10 34 23 	vmovups (%r11,%r12,1),%zmm22
 146:	62 32 6e 40 52 d6    	vdpbf16ps %zmm22,%zmm18,%zmm10
 14c:	62 32 66 40 52 de    	vdpbf16ps %zmm22,%zmm19,%zmm11
 152:	62 32 5e 40 52 e6    	vdpbf16ps %zmm22,%zmm20,%zmm12
 158:	62 32 56 40 52 ee    	vdpbf16ps %zmm22,%zmm21,%zmm13
 15e:	49 89 f4             	mov    %rsi,%r12
 161:	49 83 c4 03          	add    $0x3,%r12
 165:	4c 0f af e1          	imul   %rcx,%r12
 169:	62 81 7c 48 10 34 23 	vmovups (%r11,%r12,1),%zmm22
 170:	62 32 6e 40 52 f6    	vdpbf16ps %zmm22,%zmm18,%zmm14
 176:	62 32 66 40 52 fe    	vdpbf16ps %zmm22,%zmm19,%zmm15
 17c:	62 a2 5e 40 52 c6    	vdpbf16ps %zmm22,%zmm20,%zmm16
 182:	62 a2 56 40 52 ce    	vdpbf16ps %zmm22,%zmm21,%zmm17
 188:	48 83 c0 20          	add    $0x20,%rax
 18c:	e9 00 ff ff ff       	jmp    91 <gemm_bf16_kernel_asm+0x91>
 191:	41 5f                	pop    %r15
 193:	41 5e                	pop    %r14
 195:	41 5d                	pop    %r13
 197:	41 5c                	pop    %r12
 199:	5d                   	pop    %rbp
 19a:	c3                   	ret

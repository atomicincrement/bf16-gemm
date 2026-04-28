Disassembly of section .text._ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E:

0000000000000000 <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E>:
   0:	55                   	push   %rbp
   1:	41 57                	push   %r15
   3:	41 56                	push   %r14
   5:	41 55                	push   %r13
   7:	41 54                	push   %r12
   9:	53                   	push   %rbx
   a:	48 81 ec 88 01 00 00 	sub    $0x188,%rsp
  11:	48 89 4c 24 08       	mov    %rcx,0x8(%rsp)
  16:	f6 c2 1f             	test   $0x1f,%dl
  19:	0f 85 dd 08 00 00    	jne    8fc <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x8fc>
  1f:	40 f6 c7 03          	test   $0x3,%dil
  23:	0f 85 ec 08 00 00    	jne    915 <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x915>
  29:	49 89 f0             	mov    %rsi,%r8
  2c:	41 f6 c0 03          	test   $0x3,%r8b
  30:	0f 85 f8 08 00 00    	jne    92e <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x92e>
  36:	4d 85 c0             	test   %r8,%r8
  39:	0f 84 a8 08 00 00    	je     8e7 <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x8e7>
  3f:	48 85 ff             	test   %rdi,%rdi
  42:	0f 84 9f 08 00 00    	je     8e7 <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x8e7>
  48:	62 e1 7c 48 28 c1    	vmovaps %zmm1,%zmm16
  4e:	62 e1 7c 48 28 c8    	vmovaps %zmm0,%zmm17
  54:	48 8b b4 24 e0 01 00 	mov    0x1e0(%rsp),%rsi
  5b:	00 
  5c:	4c 8b 94 24 d8 01 00 	mov    0x1d8(%rsp),%r10
  63:	00 
  64:	48 8b 84 24 d0 01 00 	mov    0x1d0(%rsp),%rax
  6b:	00 
  6c:	4c 8b 9c 24 c0 01 00 	mov    0x1c0(%rsp),%r11
  73:	00 
  74:	48 89 7c 24 48       	mov    %rdi,0x48(%rsp)
  79:	48 8d 0c 40          	lea    (%rax,%rax,2),%rcx
  7d:	4d 8d 34 4b          	lea    (%r11,%rcx,2),%r14
  81:	48 8d 0c c5 00 00 00 	lea    0x0(,%rax,8),%rcx
  88:	00 
  89:	48 89 4c 24 10       	mov    %rcx,0x10(%rsp)
  8e:	4d 8d 24 83          	lea    (%r11,%rax,4),%r12
  92:	4d 8d 2c 43          	lea    (%r11,%rax,2),%r13
  96:	4b 8d 04 49          	lea    (%r9,%r9,2),%rax
  9a:	48 8b 4c 24 08       	mov    0x8(%rsp),%rcx
  9f:	48 8d 04 41          	lea    (%rcx,%rax,2),%rax
  a3:	48 89 44 24 30       	mov    %rax,0x30(%rsp)
  a8:	4a 8d 04 cd 00 00 00 	lea    0x0(,%r9,8),%rax
  af:	00 
  b0:	48 89 44 24 40       	mov    %rax,0x40(%rsp)
  b5:	4a 8d 04 89          	lea    (%rcx,%r9,4),%rax
  b9:	48 89 44 24 28       	mov    %rax,0x28(%rsp)
  be:	4a 8d 04 49          	lea    (%rcx,%r9,2),%rax
  c2:	48 89 44 24 20       	mov    %rax,0x20(%rsp)
  c7:	4c 89 d1             	mov    %r10,%rcx
  ca:	31 ff                	xor    %edi,%edi
  cc:	4c 89 44 24 18       	mov    %r8,0x18(%rsp)
  d1:	66 66 66 66 66 66 2e 	data16 data16 data16 data16 data16 cs nopw 0x0(%rax,%rax,1)
  d8:	0f 1f 84 00 00 00 00 
  df:	00 
  e0:	49 89 f8             	mov    %rdi,%r8
  e3:	49 83 c8 01          	or     $0x1,%r8
  e7:	49 89 f9             	mov    %rdi,%r9
  ea:	49 83 c9 02          	or     $0x2,%r9
  ee:	49 89 fa             	mov    %rdi,%r10
  f1:	49 83 ca 03          	or     $0x3,%r10
  f5:	48 89 7c 24 38       	mov    %rdi,0x38(%rsp)
  fa:	48 8b 84 24 e8 01 00 	mov    0x1e8(%rsp),%rax
 101:	00 
 102:	48 0f af f8          	imul   %rax,%rdi
 106:	48 89 7c 24 78       	mov    %rdi,0x78(%rsp)
 10b:	4c 0f af c0          	imul   %rax,%r8
 10f:	4c 89 44 24 70       	mov    %r8,0x70(%rsp)
 114:	4c 0f af c8          	imul   %rax,%r9
 118:	4c 89 4c 24 68       	mov    %r9,0x68(%rsp)
 11d:	4c 0f af d0          	imul   %rax,%r10
 121:	4c 89 54 24 60       	mov    %r10,0x60(%rsp)
 126:	4c 8b 7c 24 08       	mov    0x8(%rsp),%r15
 12b:	48 8b 6c 24 20       	mov    0x20(%rsp),%rbp
 130:	48 8b 7c 24 28       	mov    0x28(%rsp),%rdi
 135:	4c 8b 54 24 30       	mov    0x30(%rsp),%r10
 13a:	31 db                	xor    %ebx,%ebx
 13c:	4c 89 5c 24 58       	mov    %r11,0x58(%rsp)
 141:	4c 89 74 24 50       	mov    %r14,0x50(%rsp)
 146:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
 14d:	00 00 00 
 150:	c5 f8 57 c0          	vxorps %xmm0,%xmm0,%xmm0
 154:	c5 f0 57 c9          	vxorps %xmm1,%xmm1,%xmm1
 158:	62 f1 7c 48 11 4c 24 	vmovups %zmm1,0xc0(%rsp)
 15f:	03 
 160:	c5 c8 57 f6          	vxorps %xmm6,%xmm6,%xmm6
 164:	c4 41 28 57 d2       	vxorps %xmm10,%xmm10,%xmm10
 169:	c5 d8 57 e4          	vxorps %xmm4,%xmm4,%xmm4
 16d:	c4 41 38 57 c0       	vxorps %xmm8,%xmm8,%xmm8
 172:	c4 41 18 57 e4       	vxorps %xmm12,%xmm12,%xmm12
 177:	c5 e8 57 d2          	vxorps %xmm2,%xmm2,%xmm2
 17b:	c5 d0 57 ed          	vxorps %xmm5,%xmm5,%xmm5
 17f:	c4 41 30 57 c9       	vxorps %xmm9,%xmm9,%xmm9
 184:	c4 41 10 57 ed       	vxorps %xmm13,%xmm13,%xmm13
 189:	c5 c0 57 ff          	vxorps %xmm7,%xmm7,%xmm7
 18d:	c4 41 20 57 db       	vxorps %xmm11,%xmm11,%xmm11
 192:	c5 e0 57 db          	vxorps %xmm3,%xmm3,%xmm3
 196:	c4 41 08 57 f6       	vxorps %xmm14,%xmm14,%xmm14
 19b:	48 83 fa 20          	cmp    $0x20,%rdx
 19f:	0f 82 a0 01 00 00    	jb     345 <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x345>
 1a5:	b8 20 00 00 00       	mov    $0x20,%eax
 1aa:	62 f1 7c 48 11 4c 24 	vmovups %zmm1,0xc0(%rsp)
 1b1:	03 
 1b2:	66 66 66 66 66 2e 0f 	data16 data16 data16 data16 cs nopw 0x0(%rax,%rax,1)
 1b9:	1f 84 00 00 00 00 00 
 1c0:	62 f1 7c 48 11 44 24 	vmovups %zmm0,0x80(%rsp)
 1c7:	02 
 1c8:	62 d1 7c 48 10 44 43 	vmovups -0x40(%r11,%rax,2),%zmm0
 1cf:	ff 
 1d0:	62 c1 7c 48 10 54 47 	vmovups -0x40(%r15,%rax,2),%zmm18
 1d7:	ff 
 1d8:	62 72 6e 40 52 f0    	vdpbf16ps %zmm0,%zmm18,%zmm14
 1de:	62 e1 7c 48 10 5c 45 	vmovups -0x40(%rbp,%rax,2),%zmm19
 1e5:	ff 
 1e6:	62 72 66 40 52 e8    	vdpbf16ps %zmm0,%zmm19,%zmm13
 1ec:	62 e1 7c 48 10 64 47 	vmovups -0x40(%rdi,%rax,2),%zmm20
 1f3:	ff 
 1f4:	62 72 5e 40 52 e0    	vdpbf16ps %zmm0,%zmm20,%zmm12
 1fa:	62 c1 7c 48 10 6c 42 	vmovups -0x40(%r10,%rax,2),%zmm21
 201:	ff 
 202:	62 72 56 40 52 d0    	vdpbf16ps %zmm0,%zmm21,%zmm10
 208:	62 d1 7c 48 10 44 45 	vmovups -0x40(%r13,%rax,2),%zmm0
 20f:	ff 
 210:	62 f2 6e 40 52 d8    	vdpbf16ps %zmm0,%zmm18,%zmm3
 216:	62 72 66 40 52 c8    	vdpbf16ps %zmm0,%zmm19,%zmm9
 21c:	62 72 5e 40 52 c0    	vdpbf16ps %zmm0,%zmm20,%zmm8
 222:	62 f2 56 40 52 f0    	vdpbf16ps %zmm0,%zmm21,%zmm6
 228:	62 d1 7c 48 10 44 44 	vmovups -0x40(%r12,%rax,2),%zmm0
 22f:	ff 
 230:	62 72 6e 40 52 d8    	vdpbf16ps %zmm0,%zmm18,%zmm11
 236:	62 f2 66 40 52 e8    	vdpbf16ps %zmm0,%zmm19,%zmm5
 23c:	62 f2 5e 40 52 e0    	vdpbf16ps %zmm0,%zmm20,%zmm4
 242:	62 71 7c 48 28 fb    	vmovaps %zmm3,%zmm15
 248:	62 d1 7c 48 28 db    	vmovaps %zmm11,%zmm3
 24e:	62 71 7c 48 28 df    	vmovaps %zmm7,%zmm11
 254:	62 d1 7c 48 28 fd    	vmovaps %zmm13,%zmm7
 25a:	62 51 7c 48 28 e9    	vmovaps %zmm9,%zmm13
 260:	62 71 7c 48 28 cd    	vmovaps %zmm5,%zmm9
 266:	62 f1 7c 48 28 ea    	vmovaps %zmm2,%zmm5
 26c:	62 d1 7c 48 28 d4    	vmovaps %zmm12,%zmm2
 272:	62 51 7c 48 28 e0    	vmovaps %zmm8,%zmm12
 278:	62 71 7c 48 28 c4    	vmovaps %zmm4,%zmm8
 27e:	62 f1 7c 48 28 e1    	vmovaps %zmm1,%zmm4
 284:	62 d1 7c 48 28 ce    	vmovaps %zmm14,%zmm1
 28a:	62 51 7c 48 28 f2    	vmovaps %zmm10,%zmm14
 290:	62 71 7c 48 28 d6    	vmovaps %zmm6,%zmm10
 296:	62 f1 7c 48 10 74 24 	vmovups 0xc0(%rsp),%zmm6
 29d:	03 
 29e:	62 f2 56 40 52 f0    	vdpbf16ps %zmm0,%zmm21,%zmm6
 2a4:	62 f1 7c 48 11 74 24 	vmovups %zmm6,0xc0(%rsp)
 2ab:	03 
 2ac:	62 d1 7c 48 28 f2    	vmovaps %zmm10,%zmm6
 2b2:	62 51 7c 48 28 d6    	vmovaps %zmm14,%zmm10
 2b8:	62 71 7c 48 28 f1    	vmovaps %zmm1,%zmm14
 2be:	62 f1 7c 48 28 cc    	vmovaps %zmm4,%zmm1
 2c4:	62 d1 7c 48 28 e0    	vmovaps %zmm8,%zmm4
 2ca:	62 51 7c 48 28 c4    	vmovaps %zmm12,%zmm8
 2d0:	62 71 7c 48 28 e2    	vmovaps %zmm2,%zmm12
 2d6:	62 f1 7c 48 28 d5    	vmovaps %zmm5,%zmm2
 2dc:	62 d1 7c 48 28 e9    	vmovaps %zmm9,%zmm5
 2e2:	62 51 7c 48 28 cd    	vmovaps %zmm13,%zmm9
 2e8:	62 71 7c 48 28 ef    	vmovaps %zmm7,%zmm13
 2ee:	62 d1 7c 48 28 fb    	vmovaps %zmm11,%zmm7
 2f4:	62 71 7c 48 28 db    	vmovaps %zmm3,%zmm11
 2fa:	62 d1 7c 48 28 df    	vmovaps %zmm15,%zmm3
 300:	62 d1 7c 48 10 44 46 	vmovups -0x40(%r14,%rax,2),%zmm0
 307:	ff 
 308:	62 f2 6e 40 52 f8    	vdpbf16ps %zmm0,%zmm18,%zmm7
 30e:	62 f2 66 40 52 d0    	vdpbf16ps %zmm0,%zmm19,%zmm2
 314:	62 f2 5e 40 52 c8    	vdpbf16ps %zmm0,%zmm20,%zmm1
 31a:	62 71 7c 48 10 7c 24 	vmovups 0x80(%rsp),%zmm15
 321:	02 
 322:	62 72 56 40 52 f8    	vdpbf16ps %zmm0,%zmm21,%zmm15
 328:	62 71 7c 48 11 7c 24 	vmovups %zmm15,0x80(%rsp)
 32f:	02 
 330:	62 f1 7c 48 10 44 24 	vmovups 0x80(%rsp),%zmm0
 337:	02 
 338:	48 83 c0 20          	add    $0x20,%rax
 33c:	48 39 d0             	cmp    %rdx,%rax
 33f:	0f 86 7b fe ff ff    	jbe    1c0 <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x1c0>
 345:	62 71 7c 48 11 5c 24 	vmovups %zmm11,0x140(%rsp)
 34c:	05 
 34d:	62 f1 7c 48 11 7c 24 	vmovups %zmm7,0x100(%rsp)
 354:	04 
 355:	62 f1 7c 48 10 7c 24 	vmovups 0xc0(%rsp),%zmm7
 35c:	03 
 35d:	48 8b 44 24 78       	mov    0x78(%rsp),%rax
 362:	4c 8d 04 03          	lea    (%rbx,%rax,1),%r8
 366:	49 39 f0             	cmp    %rsi,%r8
 369:	0f 83 0a 06 00 00    	jae    979 <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x979>
 36f:	62 71 7c 48 28 fb    	vmovaps %zmm3,%zmm15
 375:	62 d1 7c 48 28 dd    	vmovaps %zmm13,%zmm3
 37b:	62 51 7c 48 28 e9    	vmovaps %zmm9,%zmm13
 381:	62 71 7c 48 28 cd    	vmovaps %zmm5,%zmm9
 387:	62 f1 7c 48 28 ea    	vmovaps %zmm2,%zmm5
 38d:	62 d1 7c 48 28 d4    	vmovaps %zmm12,%zmm2
 393:	62 51 7c 48 28 e0    	vmovaps %zmm8,%zmm12
 399:	62 71 7c 48 28 c4    	vmovaps %zmm4,%zmm8
 39f:	62 f1 7c 48 28 e1    	vmovaps %zmm1,%zmm4
 3a5:	62 f1 7c 48 11 44 24 	vmovups %zmm0,0x80(%rsp)
 3ac:	02 
 3ad:	62 73 fd 48 1b f0 01 	vextractf64x4 $0x1,%zmm14,%ymm0
 3b4:	c5 8c 58 c0          	vaddps %ymm0,%ymm14,%ymm0
 3b8:	c4 e3 7d 19 c1 01    	vextractf128 $0x1,%ymm0,%xmm1
 3be:	c5 f8 58 c1          	vaddps %xmm1,%xmm0,%xmm0
 3c2:	c5 f9 c6 c8 01       	vshufpd $0x1,%xmm0,%xmm0,%xmm1
 3c7:	c5 f8 58 c1          	vaddps %xmm1,%xmm0,%xmm0
 3cb:	c5 fa 16 c8          	vmovshdup %xmm0,%xmm1
 3cf:	c5 fa 58 c1          	vaddss %xmm1,%xmm0,%xmm0
 3d3:	62 f1 76 00 59 c0    	vmulss %xmm0,%xmm17,%xmm0
 3d9:	62 b1 7e 00 59 0c 81 	vmulss (%rcx,%r8,4),%xmm16,%xmm1
 3e0:	c5 fa 58 c1          	vaddss %xmm1,%xmm0,%xmm0
 3e4:	c4 a1 7a 11 04 81    	vmovss %xmm0,(%rcx,%r8,4)
 3ea:	4c 8d 04 03          	lea    (%rbx,%rax,1),%r8
 3ee:	49 ff c0             	inc    %r8
 3f1:	49 39 f0             	cmp    %rsi,%r8
 3f4:	0f 83 7f 05 00 00    	jae    979 <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x979>
 3fa:	62 f3 fd 48 1b d8 01 	vextractf64x4 $0x1,%zmm3,%ymm0
 401:	c5 e4 58 c0          	vaddps %ymm0,%ymm3,%ymm0
 405:	c4 e3 7d 19 c1 01    	vextractf128 $0x1,%ymm0,%xmm1
 40b:	c5 f8 58 c1          	vaddps %xmm1,%xmm0,%xmm0
 40f:	c5 f9 c6 c8 01       	vshufpd $0x1,%xmm0,%xmm0,%xmm1
 414:	c5 f8 58 c1          	vaddps %xmm1,%xmm0,%xmm0
 418:	c5 fa 16 c8          	vmovshdup %xmm0,%xmm1
 41c:	c5 fa 58 c1          	vaddss %xmm1,%xmm0,%xmm0
 420:	62 f1 76 00 59 c0    	vmulss %xmm0,%xmm17,%xmm0
 426:	62 b1 7e 00 59 0c 81 	vmulss (%rcx,%r8,4),%xmm16,%xmm1
 42d:	c5 fa 58 c1          	vaddss %xmm1,%xmm0,%xmm0
 431:	c4 a1 7a 11 04 81    	vmovss %xmm0,(%rcx,%r8,4)
 437:	4c 8d 04 03          	lea    (%rbx,%rax,1),%r8
 43b:	49 83 c0 02          	add    $0x2,%r8
 43f:	49 39 f0             	cmp    %rsi,%r8
 442:	0f 83 31 05 00 00    	jae    979 <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x979>
 448:	62 f3 fd 48 1b d0 01 	vextractf64x4 $0x1,%zmm2,%ymm0
 44f:	c5 ec 58 c0          	vaddps %ymm0,%ymm2,%ymm0
 453:	c4 e3 7d 19 c1 01    	vextractf128 $0x1,%ymm0,%xmm1
 459:	c5 f8 58 c1          	vaddps %xmm1,%xmm0,%xmm0
 45d:	c5 f9 c6 c8 01       	vshufpd $0x1,%xmm0,%xmm0,%xmm1
 462:	c5 f8 58 c1          	vaddps %xmm1,%xmm0,%xmm0
 466:	c5 fa 16 c8          	vmovshdup %xmm0,%xmm1
 46a:	c5 fa 58 c1          	vaddss %xmm1,%xmm0,%xmm0
 46e:	62 f1 76 00 59 c0    	vmulss %xmm0,%xmm17,%xmm0
 474:	62 b1 7e 00 59 0c 81 	vmulss (%rcx,%r8,4),%xmm16,%xmm1
 47b:	c5 fa 58 c1          	vaddss %xmm1,%xmm0,%xmm0
 47f:	c4 a1 7a 11 04 81    	vmovss %xmm0,(%rcx,%r8,4)
 485:	4c 8d 04 03          	lea    (%rbx,%rax,1),%r8
 489:	49 83 c0 03          	add    $0x3,%r8
 48d:	49 39 f0             	cmp    %rsi,%r8
 490:	0f 83 e3 04 00 00    	jae    979 <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x979>
 496:	62 51 7c 48 28 f2    	vmovaps %zmm10,%zmm14
 49c:	62 73 fd 48 1b d0 01 	vextractf64x4 $0x1,%zmm10,%ymm0
 4a3:	c5 8c 58 c0          	vaddps %ymm0,%ymm14,%ymm0
 4a7:	c4 e3 7d 19 c1 01    	vextractf128 $0x1,%ymm0,%xmm1
 4ad:	c5 f8 58 c1          	vaddps %xmm1,%xmm0,%xmm0
 4b1:	c5 f9 c6 c8 01       	vshufpd $0x1,%xmm0,%xmm0,%xmm1
 4b6:	c5 f8 58 c1          	vaddps %xmm1,%xmm0,%xmm0
 4ba:	c5 fa 16 c8          	vmovshdup %xmm0,%xmm1
 4be:	c5 fa 58 c1          	vaddss %xmm1,%xmm0,%xmm0
 4c2:	62 f1 76 00 59 c0    	vmulss %xmm0,%xmm17,%xmm0
 4c8:	62 b1 7e 00 59 0c 81 	vmulss (%rcx,%r8,4),%xmm16,%xmm1
 4cf:	c5 fa 58 c1          	vaddss %xmm1,%xmm0,%xmm0
 4d3:	c4 a1 7a 11 04 81    	vmovss %xmm0,(%rcx,%r8,4)
 4d9:	4c 8b 74 24 70       	mov    0x70(%rsp),%r14
 4de:	4e 8d 04 33          	lea    (%rbx,%r14,1),%r8
 4e2:	49 39 f0             	cmp    %rsi,%r8
 4e5:	0f 83 8e 04 00 00    	jae    979 <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x979>
 4eb:	49 89 d9             	mov    %rbx,%r9
 4ee:	49 83 c9 01          	or     $0x1,%r9
 4f2:	62 73 fd 48 1b f8 01 	vextractf64x4 $0x1,%zmm15,%ymm0
 4f9:	c5 84 58 c0          	vaddps %ymm0,%ymm15,%ymm0
 4fd:	c4 e3 7d 19 c1 01    	vextractf128 $0x1,%ymm0,%xmm1
 503:	c5 f8 58 c1          	vaddps %xmm1,%xmm0,%xmm0
 507:	c5 f9 c6 c8 01       	vshufpd $0x1,%xmm0,%xmm0,%xmm1
 50c:	c5 f8 58 c1          	vaddps %xmm1,%xmm0,%xmm0
 510:	c5 fa 16 c8          	vmovshdup %xmm0,%xmm1
 514:	c5 fa 58 c1          	vaddss %xmm1,%xmm0,%xmm0
 518:	62 f1 76 00 59 c0    	vmulss %xmm0,%xmm17,%xmm0
 51e:	62 b1 7e 00 59 0c 81 	vmulss (%rcx,%r8,4),%xmm16,%xmm1
 525:	c5 fa 58 c1          	vaddss %xmm1,%xmm0,%xmm0
 529:	c4 a1 7a 11 04 81    	vmovss %xmm0,(%rcx,%r8,4)
 52f:	4f 8d 04 31          	lea    (%r9,%r14,1),%r8
 533:	49 39 f0             	cmp    %rsi,%r8
 536:	0f 83 3d 04 00 00    	jae    979 <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x979>
 53c:	48 89 d8             	mov    %rbx,%rax
 53f:	48 83 c8 02          	or     $0x2,%rax
 543:	62 73 fd 48 1b e8 01 	vextractf64x4 $0x1,%zmm13,%ymm0
 54a:	c5 94 58 c0          	vaddps %ymm0,%ymm13,%ymm0
 54e:	c4 e3 7d 19 c1 01    	vextractf128 $0x1,%ymm0,%xmm1
 554:	c5 f8 58 c1          	vaddps %xmm1,%xmm0,%xmm0
 558:	c5 f9 c6 c8 01       	vshufpd $0x1,%xmm0,%xmm0,%xmm1
 55d:	c5 f8 58 c1          	vaddps %xmm1,%xmm0,%xmm0
 561:	c5 fa 16 c8          	vmovshdup %xmm0,%xmm1
 565:	c5 fa 58 c1          	vaddss %xmm1,%xmm0,%xmm0
 569:	62 f1 76 00 59 c0    	vmulss %xmm0,%xmm17,%xmm0
 56f:	62 b1 7e 00 59 0c 81 	vmulss (%rcx,%r8,4),%xmm16,%xmm1
 576:	c5 fa 58 c1          	vaddss %xmm1,%xmm0,%xmm0
 57a:	c4 a1 7a 11 04 81    	vmovss %xmm0,(%rcx,%r8,4)
 580:	4e 8d 04 30          	lea    (%rax,%r14,1),%r8
 584:	49 39 f0             	cmp    %rsi,%r8
 587:	0f 83 ec 03 00 00    	jae    979 <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x979>
 58d:	49 89 db             	mov    %rbx,%r11
 590:	49 83 cb 03          	or     $0x3,%r11
 594:	62 73 fd 48 1b e0 01 	vextractf64x4 $0x1,%zmm12,%ymm0
 59b:	c5 9c 58 c0          	vaddps %ymm0,%ymm12,%ymm0
 59f:	c4 e3 7d 19 c1 01    	vextractf128 $0x1,%ymm0,%xmm1
 5a5:	c5 f8 58 c1          	vaddps %xmm1,%xmm0,%xmm0
 5a9:	c5 f9 c6 c8 01       	vshufpd $0x1,%xmm0,%xmm0,%xmm1
 5ae:	c5 f8 58 c1          	vaddps %xmm1,%xmm0,%xmm0
 5b2:	c5 fa 16 c8          	vmovshdup %xmm0,%xmm1
 5b6:	c5 fa 58 c1          	vaddss %xmm1,%xmm0,%xmm0
 5ba:	62 f1 76 00 59 c0    	vmulss %xmm0,%xmm17,%xmm0
 5c0:	62 b1 7e 00 59 0c 81 	vmulss (%rcx,%r8,4),%xmm16,%xmm1
 5c7:	c5 fa 58 c1          	vaddss %xmm1,%xmm0,%xmm0
 5cb:	c4 a1 7a 11 04 81    	vmovss %xmm0,(%rcx,%r8,4)
 5d1:	4f 8d 04 33          	lea    (%r11,%r14,1),%r8
 5d5:	49 39 f0             	cmp    %rsi,%r8
 5d8:	0f 83 9b 03 00 00    	jae    979 <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x979>
 5de:	62 f3 fd 48 1b f0 01 	vextractf64x4 $0x1,%zmm6,%ymm0
 5e5:	c5 cc 58 c0          	vaddps %ymm0,%ymm6,%ymm0
 5e9:	c4 e3 7d 19 c1 01    	vextractf128 $0x1,%ymm0,%xmm1
 5ef:	c5 f8 58 c1          	vaddps %xmm1,%xmm0,%xmm0
 5f3:	c5 f9 c6 c8 01       	vshufpd $0x1,%xmm0,%xmm0,%xmm1
 5f8:	c5 f8 58 c1          	vaddps %xmm1,%xmm0,%xmm0
 5fc:	c5 fa 16 c8          	vmovshdup %xmm0,%xmm1
 600:	c5 fa 58 c1          	vaddss %xmm1,%xmm0,%xmm0
 604:	62 f1 76 00 59 c0    	vmulss %xmm0,%xmm17,%xmm0
 60a:	62 b1 7e 00 59 0c 81 	vmulss (%rcx,%r8,4),%xmm16,%xmm1
 611:	c5 fa 58 c1          	vaddss %xmm1,%xmm0,%xmm0
 615:	c4 a1 7a 11 04 81    	vmovss %xmm0,(%rcx,%r8,4)
 61b:	4c 8b 74 24 68       	mov    0x68(%rsp),%r14
 620:	4e 8d 04 33          	lea    (%rbx,%r14,1),%r8
 624:	49 39 f0             	cmp    %rsi,%r8
 627:	0f 83 4c 03 00 00    	jae    979 <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x979>
 62d:	62 f1 7c 48 10 4c 24 	vmovups 0x140(%rsp),%zmm1
 634:	05 
 635:	62 f3 fd 48 1b c8 01 	vextractf64x4 $0x1,%zmm1,%ymm0
 63c:	c5 f4 58 c0          	vaddps %ymm0,%ymm1,%ymm0
 640:	c4 e3 7d 19 c1 01    	vextractf128 $0x1,%ymm0,%xmm1
 646:	c5 f8 58 c1          	vaddps %xmm1,%xmm0,%xmm0
 64a:	c5 f9 c6 c8 01       	vshufpd $0x1,%xmm0,%xmm0,%xmm1
 64f:	c5 f8 58 c1          	vaddps %xmm1,%xmm0,%xmm0
 653:	c5 fa 16 c8          	vmovshdup %xmm0,%xmm1
 657:	c5 fa 58 c1          	vaddss %xmm1,%xmm0,%xmm0
 65b:	62 f1 76 00 59 c0    	vmulss %xmm0,%xmm17,%xmm0
 661:	62 b1 7e 00 59 0c 81 	vmulss (%rcx,%r8,4),%xmm16,%xmm1
 668:	c5 fa 58 c1          	vaddss %xmm1,%xmm0,%xmm0
 66c:	c4 a1 7a 11 04 81    	vmovss %xmm0,(%rcx,%r8,4)
 672:	4f 8d 04 31          	lea    (%r9,%r14,1),%r8
 676:	49 39 f0             	cmp    %rsi,%r8
 679:	0f 83 fa 02 00 00    	jae    979 <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x979>
 67f:	62 73 fd 48 1b c8 01 	vextractf64x4 $0x1,%zmm9,%ymm0
 686:	c5 b4 58 c0          	vaddps %ymm0,%ymm9,%ymm0
 68a:	c4 e3 7d 19 c1 01    	vextractf128 $0x1,%ymm0,%xmm1
 690:	c5 f8 58 c1          	vaddps %xmm1,%xmm0,%xmm0
 694:	c5 f9 c6 c8 01       	vshufpd $0x1,%xmm0,%xmm0,%xmm1
 699:	c5 f8 58 c1          	vaddps %xmm1,%xmm0,%xmm0
 69d:	c5 fa 16 c8          	vmovshdup %xmm0,%xmm1
 6a1:	c5 fa 58 c1          	vaddss %xmm1,%xmm0,%xmm0
 6a5:	62 f1 76 00 59 c0    	vmulss %xmm0,%xmm17,%xmm0
 6ab:	62 b1 7e 00 59 0c 81 	vmulss (%rcx,%r8,4),%xmm16,%xmm1
 6b2:	c5 fa 58 c1          	vaddss %xmm1,%xmm0,%xmm0
 6b6:	c4 a1 7a 11 04 81    	vmovss %xmm0,(%rcx,%r8,4)
 6bc:	4e 8d 04 30          	lea    (%rax,%r14,1),%r8
 6c0:	49 39 f0             	cmp    %rsi,%r8
 6c3:	0f 83 b0 02 00 00    	jae    979 <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x979>
 6c9:	62 73 fd 48 1b c0 01 	vextractf64x4 $0x1,%zmm8,%ymm0
 6d0:	c5 bc 58 c0          	vaddps %ymm0,%ymm8,%ymm0
 6d4:	c4 e3 7d 19 c1 01    	vextractf128 $0x1,%ymm0,%xmm1
 6da:	c5 f8 58 c1          	vaddps %xmm1,%xmm0,%xmm0
 6de:	c5 f9 c6 c8 01       	vshufpd $0x1,%xmm0,%xmm0,%xmm1
 6e3:	c5 f8 58 c1          	vaddps %xmm1,%xmm0,%xmm0
 6e7:	c5 fa 16 c8          	vmovshdup %xmm0,%xmm1
 6eb:	c5 fa 58 c1          	vaddss %xmm1,%xmm0,%xmm0
 6ef:	62 f1 76 00 59 c0    	vmulss %xmm0,%xmm17,%xmm0
 6f5:	62 b1 7e 00 59 0c 81 	vmulss (%rcx,%r8,4),%xmm16,%xmm1
 6fc:	c5 fa 58 c1          	vaddss %xmm1,%xmm0,%xmm0
 700:	c4 a1 7a 11 04 81    	vmovss %xmm0,(%rcx,%r8,4)
 706:	4f 8d 04 33          	lea    (%r11,%r14,1),%r8
 70a:	49 39 f0             	cmp    %rsi,%r8
 70d:	0f 83 66 02 00 00    	jae    979 <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x979>
 713:	62 f3 fd 48 1b f8 01 	vextractf64x4 $0x1,%zmm7,%ymm0
 71a:	c5 c4 58 c0          	vaddps %ymm0,%ymm7,%ymm0
 71e:	c4 e3 7d 19 c1 01    	vextractf128 $0x1,%ymm0,%xmm1
 724:	c5 f8 58 c1          	vaddps %xmm1,%xmm0,%xmm0
 728:	c5 f9 c6 c8 01       	vshufpd $0x1,%xmm0,%xmm0,%xmm1
 72d:	c5 f8 58 c1          	vaddps %xmm1,%xmm0,%xmm0
 731:	c5 fa 16 c8          	vmovshdup %xmm0,%xmm1
 735:	c5 fa 58 c1          	vaddss %xmm1,%xmm0,%xmm0
 739:	62 f1 76 00 59 c0    	vmulss %xmm0,%xmm17,%xmm0
 73f:	62 b1 7e 00 59 0c 81 	vmulss (%rcx,%r8,4),%xmm16,%xmm1
 746:	c5 fa 58 c1          	vaddss %xmm1,%xmm0,%xmm0
 74a:	c4 a1 7a 11 04 81    	vmovss %xmm0,(%rcx,%r8,4)
 750:	4c 8b 74 24 60       	mov    0x60(%rsp),%r14
 755:	4e 8d 04 33          	lea    (%rbx,%r14,1),%r8
 759:	49 39 f0             	cmp    %rsi,%r8
 75c:	0f 83 17 02 00 00    	jae    979 <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x979>
 762:	62 f1 7c 48 10 4c 24 	vmovups 0x100(%rsp),%zmm1
 769:	04 
 76a:	62 f3 fd 48 1b c8 01 	vextractf64x4 $0x1,%zmm1,%ymm0
 771:	c5 f4 58 c0          	vaddps %ymm0,%ymm1,%ymm0
 775:	c4 e3 7d 19 c1 01    	vextractf128 $0x1,%ymm0,%xmm1
 77b:	c5 f8 58 c1          	vaddps %xmm1,%xmm0,%xmm0
 77f:	c5 f9 c6 c8 01       	vshufpd $0x1,%xmm0,%xmm0,%xmm1
 784:	c5 f8 58 c1          	vaddps %xmm1,%xmm0,%xmm0
 788:	c5 fa 16 c8          	vmovshdup %xmm0,%xmm1
 78c:	c5 fa 58 c1          	vaddss %xmm1,%xmm0,%xmm0
 790:	62 f1 76 00 59 c0    	vmulss %xmm0,%xmm17,%xmm0
 796:	62 b1 7e 00 59 0c 81 	vmulss (%rcx,%r8,4),%xmm16,%xmm1
 79d:	c5 fa 58 c1          	vaddss %xmm1,%xmm0,%xmm0
 7a1:	c4 a1 7a 11 04 81    	vmovss %xmm0,(%rcx,%r8,4)
 7a7:	4d 01 f1             	add    %r14,%r9
 7aa:	49 39 f1             	cmp    %rsi,%r9
 7ad:	0f 83 ad 01 00 00    	jae    960 <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x960>
 7b3:	62 f3 fd 48 1b e8 01 	vextractf64x4 $0x1,%zmm5,%ymm0
 7ba:	c5 d4 58 c0          	vaddps %ymm0,%ymm5,%ymm0
 7be:	c4 e3 7d 19 c1 01    	vextractf128 $0x1,%ymm0,%xmm1
 7c4:	c5 f8 58 c1          	vaddps %xmm1,%xmm0,%xmm0
 7c8:	c5 f9 c6 c8 01       	vshufpd $0x1,%xmm0,%xmm0,%xmm1
 7cd:	c5 f8 58 c1          	vaddps %xmm1,%xmm0,%xmm0
 7d1:	c5 fa 16 c8          	vmovshdup %xmm0,%xmm1
 7d5:	c5 fa 58 c1          	vaddss %xmm1,%xmm0,%xmm0
 7d9:	62 f1 76 00 59 c0    	vmulss %xmm0,%xmm17,%xmm0
 7df:	62 b1 7e 00 59 0c 89 	vmulss (%rcx,%r9,4),%xmm16,%xmm1
 7e6:	c5 fa 58 c1          	vaddss %xmm1,%xmm0,%xmm0
 7ea:	c4 a1 7a 11 04 89    	vmovss %xmm0,(%rcx,%r9,4)
 7f0:	4c 01 f0             	add    %r14,%rax
 7f3:	48 39 f0             	cmp    %rsi,%rax
 7f6:	0f 83 7a 01 00 00    	jae    976 <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x976>
 7fc:	62 f1 7c 48 28 dc    	vmovaps %zmm4,%zmm3
 802:	62 f3 fd 48 1b e0 01 	vextractf64x4 $0x1,%zmm4,%ymm0
 809:	c5 e4 58 c0          	vaddps %ymm0,%ymm3,%ymm0
 80d:	c4 e3 7d 19 c1 01    	vextractf128 $0x1,%ymm0,%xmm1
 813:	c5 f8 58 c1          	vaddps %xmm1,%xmm0,%xmm0
 817:	c5 f9 c6 c8 01       	vshufpd $0x1,%xmm0,%xmm0,%xmm1
 81c:	c5 f8 58 c1          	vaddps %xmm1,%xmm0,%xmm0
 820:	c5 fa 16 c8          	vmovshdup %xmm0,%xmm1
 824:	c5 fa 58 c1          	vaddss %xmm1,%xmm0,%xmm0
 828:	62 f1 76 00 59 c0    	vmulss %xmm0,%xmm17,%xmm0
 82e:	62 f1 7e 00 59 0c 81 	vmulss (%rcx,%rax,4),%xmm16,%xmm1
 835:	c5 fa 58 c1          	vaddss %xmm1,%xmm0,%xmm0
 839:	c5 fa 11 04 81       	vmovss %xmm0,(%rcx,%rax,4)
 83e:	4d 01 f3             	add    %r14,%r11
 841:	48 89 f0             	mov    %rsi,%rax
 844:	49 39 f3             	cmp    %rsi,%r11
 847:	0f 83 fa 00 00 00    	jae    947 <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x947>
 84d:	62 f1 7c 48 10 4c 24 	vmovups 0x80(%rsp),%zmm1
 854:	02 
 855:	62 f3 fd 48 1b c8 01 	vextractf64x4 $0x1,%zmm1,%ymm0
 85c:	c5 f4 58 c0          	vaddps %ymm0,%ymm1,%ymm0
 860:	c4 e3 7d 19 c1 01    	vextractf128 $0x1,%ymm0,%xmm1
 866:	c5 f8 58 c1          	vaddps %xmm1,%xmm0,%xmm0
 86a:	c5 f9 c6 c8 01       	vshufpd $0x1,%xmm0,%xmm0,%xmm1
 86f:	c5 f8 58 c1          	vaddps %xmm1,%xmm0,%xmm0
 873:	c5 fa 16 c8          	vmovshdup %xmm0,%xmm1
 877:	c5 fa 58 c1          	vaddss %xmm1,%xmm0,%xmm0
 87b:	62 f1 76 00 59 c0    	vmulss %xmm0,%xmm17,%xmm0
 881:	62 b1 7e 00 59 0c 99 	vmulss (%rcx,%r11,4),%xmm16,%xmm1
 888:	c5 fa 58 c1          	vaddss %xmm1,%xmm0,%xmm0
 88c:	c4 a1 7a 11 04 99    	vmovss %xmm0,(%rcx,%r11,4)
 892:	48 83 c3 04          	add    $0x4,%rbx
 896:	48 8b 74 24 40       	mov    0x40(%rsp),%rsi
 89b:	49 01 f2             	add    %rsi,%r10
 89e:	48 01 f7             	add    %rsi,%rdi
 8a1:	48 01 f5             	add    %rsi,%rbp
 8a4:	49 01 f7             	add    %rsi,%r15
 8a7:	48 3b 5c 24 48       	cmp    0x48(%rsp),%rbx
 8ac:	48 89 c6             	mov    %rax,%rsi
 8af:	4c 8b 5c 24 58       	mov    0x58(%rsp),%r11
 8b4:	4c 8b 74 24 50       	mov    0x50(%rsp),%r14
 8b9:	0f 82 91 f8 ff ff    	jb     150 <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x150>
 8bf:	48 8b 7c 24 38       	mov    0x38(%rsp),%rdi
 8c4:	48 83 c7 04          	add    $0x4,%rdi
 8c8:	48 8b 44 24 10       	mov    0x10(%rsp),%rax
 8cd:	49 01 c6             	add    %rax,%r14
 8d0:	49 01 c4             	add    %rax,%r12
 8d3:	49 01 c5             	add    %rax,%r13
 8d6:	49 01 c3             	add    %rax,%r11
 8d9:	4c 8b 44 24 18       	mov    0x18(%rsp),%r8
 8de:	4c 39 c7             	cmp    %r8,%rdi
 8e1:	0f 82 f9 f7 ff ff    	jb     e0 <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0xe0>
 8e7:	48 81 c4 88 01 00 00 	add    $0x188,%rsp
 8ee:	5b                   	pop    %rbx
 8ef:	41 5c                	pop    %r12
 8f1:	41 5d                	pop    %r13
 8f3:	41 5e                	pop    %r14
 8f5:	41 5f                	pop    %r15
 8f7:	5d                   	pop    %rbp
 8f8:	c5 f8 77             	vzeroupper
 8fb:	c3                   	ret
 8fc:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 903 <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x903>
 903:	48 8d 15 00 00 00 00 	lea    0x0(%rip),%rdx        # 90a <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x90a>
 90a:	be 35 00 00 00       	mov    $0x35,%esi
 90f:	ff 15 00 00 00 00    	call   *0x0(%rip)        # 915 <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x915>
 915:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 91c <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x91c>
 91c:	48 8d 15 00 00 00 00 	lea    0x0(%rip),%rdx        # 923 <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x923>
 923:	be 33 00 00 00       	mov    $0x33,%esi
 928:	ff 15 00 00 00 00    	call   *0x0(%rip)        # 92e <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x92e>
 92e:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 935 <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x935>
 935:	48 8d 15 00 00 00 00 	lea    0x0(%rip),%rdx        # 93c <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x93c>
 93c:	be 33 00 00 00       	mov    $0x33,%esi
 941:	ff 15 00 00 00 00    	call   *0x0(%rip)        # 947 <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x947>
 947:	4d 89 d8             	mov    %r11,%r8
 94a:	48 89 c6             	mov    %rax,%rsi
 94d:	48 8d 15 00 00 00 00 	lea    0x0(%rip),%rdx        # 954 <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x954>
 954:	4c 89 c7             	mov    %r8,%rdi
 957:	c5 f8 77             	vzeroupper
 95a:	ff 15 00 00 00 00    	call   *0x0(%rip)        # 960 <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x960>
 960:	4d 89 c8             	mov    %r9,%r8
 963:	48 8d 15 00 00 00 00 	lea    0x0(%rip),%rdx        # 96a <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x96a>
 96a:	4c 89 c7             	mov    %r8,%rdi
 96d:	c5 f8 77             	vzeroupper
 970:	ff 15 00 00 00 00    	call   *0x0(%rip)        # 976 <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x976>
 976:	49 89 c0             	mov    %rax,%r8
 979:	48 8d 15 00 00 00 00 	lea    0x0(%rip),%rdx        # 980 <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x980>
 980:	4c 89 c7             	mov    %r8,%rdi
 983:	c5 f8 77             	vzeroupper
 986:	ff 15 00 00 00 00    	call   *0x0(%rip)        # 98c <_ZN9bf16_gemm9gemm_bf1617h071c3c4b8f7e1983E+0x98c>

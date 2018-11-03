; c_power_intel.s
; Copyright (C) 2012, 2017, 2018 Eric Herman <eric@freesa.org>
;
; This library is free software; you can redistribute it and/or
; modify it under the terms of the GNU Lesser General Public
; License as published by the Free Software Foundation; either
; version 2.1 of the License, or (at your option) any later version.
;
; This library is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
; Lesser General Public License for more details.
;
;	https://www.gnu.org/licenses/lgpl-2.1.txt

	.file	"c_power.c"
	.intel_syntax noprefix
	.text
	.globl	power
	.type	power, @function
power:
.LFB0:
	.cfi_startproc
	push	ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	mov	ebp, esp
	.cfi_def_cfa_register 5
	sub	esp, 16
	mov	DWORD PTR [ebp-4], 1
	mov	DWORD PTR [ebp-8], 0
	jmp	.L2
.L3:
	mov	eax, DWORD PTR [ebp-4]
	imul	eax, DWORD PTR [ebp+8]
	mov	DWORD PTR [ebp-4], eax
	add	DWORD PTR [ebp-8], 1
.L2:
	mov	eax, DWORD PTR [ebp-8]
	cmp	eax, DWORD PTR [ebp+12]
	jl	.L3
	mov	eax, DWORD PTR [ebp-4]
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE0:
	.size	power, .-power
	.ident	"GCC: (GNU) 6.2.0"
	.section	.note.GNU-stack,"",@progbits

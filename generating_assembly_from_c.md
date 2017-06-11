# Generating Assembly from C by Example

Copyright (c) 2012,2017 Eric Herman

Licensed under the terms of the GNU Lesser General Public License (LGPL)
version 2.1 or at your option any later version.

This _how to_ page is the result of a mental side-track I took as I was
reading the excellent on-line book [ Programming from the Ground
Up](http://programminggroundup.blogspot.com/) ([or
pdf](http://savannah.nongnu.org/projects/pgubook/)) as an introduction
to x86 assembly programming.

## Simple C code

Let us start with a trivial C library with a single function:

* * *
	/* c_power.c */
	int power(int base, int exponent)
	{
		int result= 1;
		int i;
		for(i= 0; i < exponent; i++) {
			result*= base;
		}
		return result;
	}
* * *

(It won't take a particularly astute reader to see that the function
will not work with negative powers. That's okay, this is just a trivial
example.)

## Generating Assembly from C

Sometimes it can be instructive, or perhaps otherwise useful, to see how
a C program translates to assembly. Fortunately, gcc makes this easy:


	gcc -S c_power.c


creates a file "c_power.s" with the following:

### Generated on x86

* * *
		.file	"c_power.c"
		.text
	.globl power
		.type	power, @function
	power:
		pushl	%ebp
		movl	%esp, %ebp
		subl	$16, %esp
		movl	$1, -8(%ebp)
		movl	$0, -4(%ebp)
		jmp	.L2
	.L3:
		movl	-8(%ebp), %eax
		imull	8(%ebp), %eax
		movl	%eax, -8(%ebp)
		incl	-4(%ebp)
	.L2:
		movl	-4(%ebp), %eax
		cmpl	12(%ebp), %eax
		jl	.L3
		movl	-8(%ebp), %eax
		leave
		ret
		.size	power, .-power
		.ident	"GCC: (GNU) 4.1.2 20061115 (prerelease) (Debian 4.1.1-21)"
		.section	.note.GNU-stack,"",@progbits
* * *

Generated assembly may serve as a useful reference or starting point if
we wish to try reimplementing a function in assembly. However generated
assembly may have confusing uses of registers, not to mention the poor
labels and total lack of comments.

### Generated on MIPS

For comparison, here is the same C function on MIPS (endian little)

* * *
	eric:~/src$ uname -a
	Linux 192.168.23.3 2.6.23.16ekh_freesa_3 #3 Sat Jul 26 14:24:58 CEST 2008 mips Broadcom BCM3302 V0.6 Broadcom BCM47xx GNU/Linux
	eric:~/src$ gcc -S c_power.c
	eric:~/src$ cat c_power.s
		.file	1 "c_power.c"
		.section .mdebug.abi32
		.previous
		.gnu_attribute 4, 1
		.abicalls
		.text
		.align	2
		.globl	power
		.ent	power
		.type	power, @function
	power:
		.set	nomips16
		.frame	$fp,24,$31		# vars= 8, regs= 1/0, args= 0, gp= 8
		.mask	0x40000000,-4
		.fmask	0x00000000,0
		.set	noreorder
		.set	nomacro

		addiu	$sp,$sp,-24
		sw	$fp,20($sp)
		move	$fp,$sp
		.cprestore	0
		sw	$4,24($fp)
		sw	$5,28($fp)
		li	$2,1			# 0x1
		sw	$2,12($fp)
		sw	$0,8($fp)
		b	$L2
		nop

	$L3:
		lw	$3,12($fp)
		lw	$2,24($fp)
		nop
		mult	$3,$2
		mflo	$2
		sw	$2,12($fp)
		lw	$2,8($fp)
		nop
		addiu	$2,$2,1
		sw	$2,8($fp)
	$L2:
		lw	$2,8($fp)
		lw	$3,28($fp)
		nop
		slt	$2,$2,$3
		bne	$2,$0,$L3
		nop

		lw	$2,12($fp)
		move	$sp,$fp
		lw	$fp,20($sp)
		addiu	$sp,$sp,24
		j	$31
		nop

		.set	macro
		.set	reorder
		.end	power
		.ident	"GCC: (GNU) 4.3.0"
	eric:~/src$
* * *

The conversion to assembly from C may be quite straightforward for any
given architecture, perhaps even _every_ architecture. This comparison
highlights for me that C is an abstraction above assembly; seemingly at
a good level of abstraction, if one were to trying to construct a
"portable assembly". Perhaps if one were _really_ to have "portable
assembly" as a goal, one might construct something which looks very
different from C, I don't yet know enough to guess.

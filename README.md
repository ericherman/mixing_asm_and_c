# Mixing Assembly and C by Example

Copyright (c) 2012,2017 Eric Herman

Licensed under the terms of the GNU Lesser General Public License (LGPL)
version 2.1 or at your option any later version.

This _how to_ page is the result of a mental side-track I took as I was
reading the excellent on-line book [ Programming from the Ground Up][1]
([or pdf][2]) as an introduction to x86 assembly programming. While I
was able to find some very good examples of using [in-line assembly in
C][3] programs, I didn't see a good example of how to replace a module
written in C with a pure assembly module. This page is a slightly
cleaned up version of my notes from working it out. ## Simple C Let's
start with a trivial program in C consisting of a "main" program, and a
library with a single function:

* * *
	/* c_power_test.c */
	#include "c_power.h"

	int main(void) {
		int result;
		result= power(2, 3);
		result+= power(5, 2);
		printf("%dn", result);
		return result != 33;
	}
* * *
	/* c_power.h */
	#ifndef C_POWER_H_
	#define C_POWER_H_
	int power(int base, int exponent);
	#endif /* C_POWER_H_ */
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

Normally, I'd build a trivial program like this using some gcc shortcuts
like:

	gcc c_power.c c_power_test.c -o c_power_test

which does the compile for each of the source files and then performs
the link operation to create a single executable -- all in one step.
However, since this is an illustration, I'm going to take smaller steps.
First compile the c\_power.c library into the c\_power.o object file:


	gcc -c c_power.c -o c_power.o


Next, compile the c\_power\_test.c into the c\_power\_test.o object
file:


	gcc -c c_power_test.c -o c_power_test.o


Next we link the object files together into an execuable:


	gcc c_power_test.o c_power.o -o c_power_test


And lastly, we run the result:


	$ ./c_power_test
	33


Perfect. "33" just as we expected.

### Generating Assembly from C

Sometimes it can be instructive, or perhaps otherwise useful, to see how
a C program translates to assembly. See: [Generating Assembly from C by
Example][4]

In our case, we're going to focus on x86 assembly which was written by
hand, which (unlike generated assembly) should have good comments and
sensible label names.

## Simple Assembly

Now let's do more-or-less the same "power test" program using assembly.
One big difference is that we will not print to the screen, instead we
will simply return an exit code which we will read from the shell.

The code is an only slightly modified transcription of an exercise in  [
Programming from the Ground Up: A Function Example][5].

* * *
	# asm_power_test.s
	#
	#PURPOSE:  Program to illustrate how functions work
	#		  This program will compute the value of
	#		  2^3 + 5^2
	#

	#Everything in the main program is stored in registers,
	#so the data section doesn't have anything.
	.section .data

	.section .text

	.global _start

	_start:
	 pushl	$3			# push second argument (exponent)
	 pushl	$2			# push first argument (base)
	 call	power			# call the 'power' function
	 addl	$8, %esp		# move the stack pointer back

	 pushl	%eax			# save the first answer before
					# calling th enext function

	 pushl	$2			# push exponent
	 pushl	$5			# push base
	 call	power			# call the 'power' function
	 addl	$8, %esp		# move the stack pointer back

	 popl	%ebx			# The second answer is already
					# in %eax. We saved the
					# first answer onto the stack,
					# so now we can just pop it
					# out into %ebx

	 addl	%eax, %ebx		# add the values
					#  (result in %ebx)

	 movl	$1, %eax		# exit (%ebx is returned)
	 int	$0x80			# kernel interrupt

	# EOF
* * *
	#asm_power.s
	#
	#Everything in the main program is stored in registers,
	#so the data section doesn't have anything.
	.section .data

	.section .text

	.global power
	#PURPOSE:   This function is used to compute
	#		   the value of a number raised to
	#		   a power.
	#
	#INPUT:	 First argument - the base number
	#		   Second argument - the power to
	#							 raise it to
	#
	#OUTPUT:	Will give the result as a return value (%eax)
	#
	#NOTES:	 The power must be 1 or greater
	#
	#VARIABLES:
	#		   %ebx - holds the base number
	#		   %ecx - holds the power
	#
	#		   -4(%ebp) - holds the current result
	#
	#		   %eax is used for temporary storage
	#

	.type power, @function
	power:
	 pushl	%ebp			# save old base pointer
	 movl	%esp, %ebp		# copy stack pointer to base pointer
	 subl	$4, %esp		# make spot for local variable

	 movl	8(%ebp), %ebx		# put first argument in %ebx (base)
	 movl	12(%ebp), %ecx		# put second argument in %ecx (exponent)

	# check for power of 0
	 movl   $1, -4(%ebp)		# store current result
	 cmpl   $0, %ecx		# if the power is 0, we are done
	 je	 end_power

	# init regular loop
	 movl	%ebx, -4(%ebp)		# store current result

	power_loop_start:
	 cmpl	$1, %ecx		# if the power is 1, we are done
	 je	end_power
	 movl	-4(%ebp), %eax		# move the current result into %eax
	 imull	%ebx, %eax		# multiply current result by base
					#  (imull result lands in %eax)
	 movl	%eax, -4(%ebp)		# store the current result

	 decl	%ecx			# decrease the power
	 jmp	power_loop_start	# loop!

	end_power:
	 movl	-4(%ebp), %eax		# put current value in %eax for return
	 movl	%ebp, %esp		# restore the stack pointer
	 popl	%ebp			# restore the base pointer
	 ret

	# EOF
* * *

First, we assemble the test program:


	as asm_power_test.s -o asm_power_test.o


Next, we assemble the library function:


	as asm_power.s -o asm_power.o


Then, we link them together into an executable:


	ld asm_power_test.o asm_power.o -o asm_power_test


And finally, we execute the program and check the return code using "echo $?":


	$ ./asm_power_test; echo $?
	33


33! Okay, so that shows us that we can do the same sorts of things using
C and assembly. Additionally, since the assembly program was written to
use the _C calling convention_, we should be able to mix-and-match, and
we've demonstrated enough of how to use the compiler, assembler and
linker that it should be straight-forward.

We're finally ready to mix them, so let's start by calling the Assembly
library from C:

## Calling Assembly from C

First clean up:


	rm *.o


Now, assemble the assembly library:


	as asm_power.s -o asm_power.o


Next, compile the main C program which will call the library


	gcc -c c_power_test.c -o c_power_test.o


Lastly, link them together into a single executable. (We will use gcc
instead of ld to do the linking because we don't want to deal with
linking 'printf' from the standard C library.)


	gcc asm_power.o c_power_test.o -o c_to_asm_power_test


Now here's the moment of truth:


	$ ./c_to_asm_power_test
	33


W00T! It works.

Now can we go the other direction?

## Calling C from Assembly

First, we clean up


	rm *.o


Next, compile the C library:


	gcc -c c_power.c -o c_power.o


Next, we assemble the assembly "main" program


	as asm_power_test.s -o asm_power_test.o


Then we link them together into an executable


	ld asm_power_test.o c_power.o -o asm_to_c_power_test


And does it run?


	./asm_to_c_power_test; echo $?
	33


Sure enough! How about _that?_

* * *

Please send contributions and commentary to Eric Herman: eric@[freesa.org]

[0]: (http://tiedyedfreaks.org/eric/mixing_asm_and_c.html "Mixing C & Assembly")
[1]: http://programminggroundup.blogspot.com/
[2]: http://savannah.nongnu.org/projects/pgubook/
[3]: http://asm.sourceforge.net/articles/linasm.html
[4]: http://tiedyedfreaks.org/generating_asm_from_c.html
[5]: http://programminggroundup.blogspot.com/2007/01/chapter-4-all-about-functions.html#ch04lev1sec4
[6]: http://freesa.org
[7]: http://www.w3.org/Icons/valid-html401-blue



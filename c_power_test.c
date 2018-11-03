/* c_power_test.c
   Copyright (C) 2012, 2017, 2018 Eric Herman <eric@freesa.org>

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

	https://www.gnu.org/licenses/lgpl-2.1.txt
 */
#include "c_power.h"
#include <stdio.h>

int main(void) {
	int result;
	result= power(2, 3);
	result+= power(5, 2);
	printf("%dn", result);
	return result != 33;
}

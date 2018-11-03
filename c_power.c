/* c_power.c
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
int power(int base, int exponent)
{
	int result= 1;
	int i;
	for(i= 0; i < exponent; i++) {
		result*= base;
	}
	return result;
}

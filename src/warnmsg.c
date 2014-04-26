/* Warning handling.

Copyright (C) 2000-2011 Eduardo A. Robsy Petrus
Copyright (C) 2014 Adrian Oboroc

This file is part of asmsx project <https://github.com/asmsx/asmsx/>.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

#include <stdio.h>
#include <string.h>

void warning_message(int code, int _pass, char *_source, int _lines, int *warnings)
{
	if (2 != _pass)
		return;

	printf("%s, line %d: Warning: ", strtok(_source, "\042"), _lines);
	switch (code)
	{
	case 1:
		printf("16-bit overflow\n");
		break;
	case 2:
		printf("8-bit overflow\n");
		break;
	case 3:
		printf("3-bit overflow\n");
		break;
	case 4:
		printf("output cannot be converted to CAS\n");
		break;
	case 5:
		printf("not official Zilog syntax\n");
		break;
	case 6:
		printf("undocumented Zilog instruction\n");
		break;
	}
	(*warnings)++;	/* ??? run this through debugger to confirm it works as hoped ??? */
}

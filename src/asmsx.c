/* Top level entry point of asmsx.

 Copyright (C) 2000-2011 Eduardo A. Robsy Petrus
 Copyright (C) 2014 Adrian Oboroc
 
 This file is part of as-ng, rewrite of asmsx.
 
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


#include "core.c"
#include "lex.c"

int main(int argc, char *argv[])
{
	int i;

	printf(" asmsx %s MSX cross assembler [%s]\n", VERSION, __DATE__);
	if (2 != argc)
	{
        	printf("Syntax: asmsx [file.asm]\n");
		exit(0);
	}
	clock();
	initialize_system();
	assembler = (unsigned char *)malloc(0x100);
	source = (unsigned char *)malloc(0x100);
	original = (unsigned char *)malloc(0x100);
	binary = (char *)malloc(0x100);
	symbols = (char *)malloc(0x100);
	outputfname = (char *)malloc(0x100);
	filename = (char *)malloc(0x100);
	strcpy(filename, argv[1]);
	strcpy(assembler, filename);
	for (i = strlen(filename) - 1; (filename[i] != '.') && i; i--);
	if (i)
		filename[i]=0;
	else
		strcat(assembler, ".asm");
	preprocessor1(assembler);
	preprocessor3();
	sprintf(original, "~tmppre.%i", preprocessor2());
	printf("Assembling source file %s\n", assembler);
	conditional[0] = 1;
	foriginal = fopen(original, "r");
	yyin = foriginal;
	yyparse();
	remove("~tmppre.?");
	return 0;
}

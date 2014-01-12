/* Top level entry point of asmsx plus some temporarily homeless code.

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
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

#include "compat_s.h"	/* https://github.com/oboroc/compat_s/ */
#include "asmsx.h"
#include "wav.h"
#include "parser1.h"
#include "parser2.h"
#include "parser3.h"


/* Global variables */
/* TODO: reduce the number of global variables */

char *source, *intname, *binary, *filename, *original, *outputfname, *symbols, *assembler;
unsigned char *memory;
int zilog = 0, pass = 1, size = 0, bios = 0, type = 0;
int conditional[MAX_INCLUDE_LEVEL], conditional_level = 0, cassette = 0;
int lastpage, parity;
int ePC = 0, PC = 0, subpage, pagesize, usedpage[256], mapper, pageinit, addr_start = 0xffff, addr_end = 0x0000, start = 0, warnings = 0, lines;
int maxpage[4] = {32, 64, 256, 256};

int maximum = 0, last_global = 0;
FILE *foriginal, *fmessages, *foutput;

#define MAX_ID 32000

struct
{
	char *name;
	int value;
	char type;
	int page;
} id_list[MAX_ID];

/* TODO: compartmentalize all functions that got moved from core.y into their own units */

/* Register standard BIOS routines */
void msx_bios(void)
{
	bios = 1;

	/* BIOS routines */
	register_symbol("CHKRAM", 0x0000, 0);
	register_symbol("SYNCHR", 0x0008, 0);
	register_symbol("RDSLT", 0x000c, 0);
	register_symbol("CHRGTR", 0x0010, 0);
	register_symbol("WRSLT", 0x0014, 0);
	register_symbol("OUTDO", 0x0018, 0);
	register_symbol("CALSLT", 0x001c, 0);
	register_symbol("DCOMPR", 0x0020, 0);
	register_symbol("ENASLT", 0x0024, 0);
	register_symbol("GETYPR", 0x0028, 0);
	register_symbol("CALLF", 0x0030, 0);
	register_symbol("KEYINT", 0x0038, 0);
	register_symbol("INITIO", 0x003b, 0);
	register_symbol("INIFNK", 0x003e, 0);
	register_symbol("DISSCR", 0x0041, 0);
	register_symbol("ENASCR", 0x0044, 0);
	register_symbol("WRTVDP", 0x0047, 0);
	register_symbol("RDVRM", 0x004a, 0);
	register_symbol("WRTVRM", 0x004d, 0);
	register_symbol("SETRD", 0x0050, 0);
	register_symbol("SETWRT", 0x0053, 0);
	register_symbol("FILVRM", 0x0056, 0);
	register_symbol("LDIRMV", 0x0059, 0);
	register_symbol("LDIRVM", 0x005c, 0);
	register_symbol("CHGMOD", 0x005f, 0);
	register_symbol("CHGCLR", 0x0062, 0);
	register_symbol("NMI", 0x0066, 0);
	register_symbol("CLRSPR", 0x0069, 0);
	register_symbol("INITXT", 0x006c, 0);
	register_symbol("INIT32", 0x006f, 0);
	register_symbol("INIGRP", 0x0072, 0);
	register_symbol("INIMLT", 0x0075, 0);
	register_symbol("SETTXT", 0x0078, 0);
	register_symbol("SETT32", 0x007b, 0);
	register_symbol("SETGRP", 0x007e, 0);
	register_symbol("SETMLT", 0x0081, 0);
	register_symbol("CALPAT", 0x0084, 0);
	register_symbol("CALATR", 0x0087, 0);
	register_symbol("GSPSIZ", 0x008a, 0);
	register_symbol("GRPPRT", 0x008d, 0);
	register_symbol("GICINI", 0x0090, 0);
	register_symbol("WRTPSG", 0x0093, 0);
	register_symbol("RDPSG", 0x0096, 0);
	register_symbol("STRTMS", 0x0099, 0);
	register_symbol("CHSNS", 0x009c, 0);
	register_symbol("CHGET", 0x009f, 0);
	register_symbol("CHPUT", 0x00a2, 0);
	register_symbol("LPTOUT", 0x00a5, 0);
	register_symbol("LPTSTT", 0x00a8, 0);
	register_symbol("CNVCHR", 0x00ab, 0);
	register_symbol("PINLIN", 0x00ae, 0);
	register_symbol("INLIN", 0x00b1, 0);
	register_symbol("QINLIN", 0x00b4, 0);
	register_symbol("BREAKX", 0x00b7, 0);
	register_symbol("ISCNTC", 0x00ba, 0);
	register_symbol("CKCNTC", 0x00bd, 0);
	register_symbol("BEEP", 0x00c0, 0);
	register_symbol("CLS", 0x00c3, 0);
	register_symbol("POSIT", 0x00c6, 0);
	register_symbol("FNKSB", 0x00c9, 0);
	register_symbol("ERAFNK", 0x00cc, 0);
	register_symbol("DSPFNK", 0x00cf, 0);
	register_symbol("TOTEXT", 0x00d2, 0);
	register_symbol("GTSTCK", 0x00d5, 0);
	register_symbol("GTTRIG", 0x00d8, 0);
	register_symbol("GTPAD", 0x00db, 0);
	register_symbol("GTPDL", 0x00de, 0);
	register_symbol("TAPION", 0x00e1, 0);
	register_symbol("TAPIN", 0x00e4, 0);
	register_symbol("TAPIOF", 0x00e7, 0);
	register_symbol("TAPOON", 0x00ea, 0);
	register_symbol("TAPOUT", 0x00ed, 0);
	register_symbol("TAPOOF", 0x00f0, 0);
	register_symbol("STMOTR", 0x00f3, 0);
	register_symbol("LFTQ", 0x00f6, 0);
	register_symbol("PUTQ", 0x00f9, 0);
	register_symbol("RIGHTC", 0x00fc, 0);
	register_symbol("LEFTC", 0x00ff, 0);
	register_symbol("UPC", 0x0102, 0);
	register_symbol("TUPC", 0x0105, 0);
	register_symbol("DOWNC", 0x0108, 0);
	register_symbol("TDOWNC", 0x010b, 0);
	register_symbol("SCALXY", 0x010e, 0);
	register_symbol("MAPXYC", 0x0111, 0);
	register_symbol("FETCHC", 0x0114, 0);
	register_symbol("STOREC", 0x0117, 0);
	register_symbol("SETATR", 0x011a, 0);
	register_symbol("READC", 0x011d, 0);
	register_symbol("SETC", 0x0120, 0);
	register_symbol("NSETCX", 0x0123, 0);
	register_symbol("GTASPC", 0x0126, 0);
	register_symbol("PNTINI", 0x0129, 0);
	register_symbol("SCANR", 0x012c, 0);
	register_symbol("SCANL", 0x012f, 0);
	register_symbol("CHGCAP", 0x0132, 0);
	register_symbol("CHGSND", 0x0135, 0);
	register_symbol("RSLREG", 0x0138, 0);
	register_symbol("WSLREG", 0x013b, 0);
	register_symbol("RDVDP", 0x013e, 0);
	register_symbol("SNSMAT", 0x0141, 0);
	register_symbol("PHYDIO", 0x0144, 0);
	register_symbol("FORMAT", 0x0147, 0);
	register_symbol("ISFLIO", 0x014a, 0);
	register_symbol("OUTDLP", 0x014d, 0);
	register_symbol("GETVCP", 0x0150, 0);
	register_symbol("GETVC2", 0x0153, 0);
	register_symbol("KILBUF", 0x0156, 0);
	register_symbol("CALBAS", 0x0159, 0);
	register_symbol("SUBROM", 0x015c, 0);
	register_symbol("EXTROM", 0x015f, 0);
	register_symbol("CHKSLZ", 0x0162, 0);
	register_symbol("CHKNEW", 0x0165, 0);
	register_symbol("EOL", 0x0168, 0);
	register_symbol("BIGFIL", 0x016b, 0);
	register_symbol("NSETRD", 0x016e, 0);
	register_symbol("NSTWRT", 0x0171, 0);
	register_symbol("NRDVRM", 0x0174, 0);
	register_symbol("NWRVRM", 0x0177, 0);
	register_symbol("RDBTST", 0x017a, 0);
	register_symbol("WRBTST", 0x017d, 0);
	register_symbol("CHGCPU", 0x0180, 0);
	register_symbol("GETCPU", 0x0183, 0);
	register_symbol("PCMPLY", 0x0186, 0);
	register_symbol("PCMREC", 0x0189, 0);
}


void error_message(int code)
{
	#ifndef COMPAT_S
	char *next_token = NULL;
	#endif /*  COMPAT_S */

	printf_s("%s, line %d: ", strtok_s(source, "\042", &next_token), lines);
	switch (code)
	{
		case 0:
			printf_s("syntax error\n");
			break;
		case 1:
			printf_s("memory overflow\n");
			break;
		case 2:
			printf_s("wrong register combination\n");
			break;
		case 3:
			printf_s("wrong interruption mode\n");
			break;
		case 4:
			printf_s("destination register should be A\n");
			break;
		case 5:
			printf_s("source register should be A\n");
			break;
		case 6:
			printf_s("value should be 0\n");
			break;
		case 7:
			printf_s("missing condition\n");
			break;
		case 8:
			printf_s("unreachable address\n");
			break;
		case 9:
			printf_s("wrong condition\n");
			break;
		case 10:
			printf_s("wrong restart address\n");
			break;
		case 11:
			printf_s("symbol table overflow\n");
			break;
		case 12:
			printf_s("undefined identifier\n");
			break;
		case 13:
			printf_s("undefined local label\n");
			break;
		case 14:
			printf_s("symbol redefinition\n");
			break;
		case 15:
			printf_s("size redefinition\n");
			break;
		case 16:
			printf_s("reserved word used as identifier\n");
			break;
		case 17:
			printf_s("code size overflow\n");
			break;
		case 18:
			printf_s("binary file not found\n");
			break;
		case 19:
			printf_s("ROM directive should preceed any code\n");
			break;
		case 20:
			printf_s("previously defined type\n");
			break;
		case 21:
			printf_s("BASIC directive should preceed any code\n");
			break;
		case 22:
			printf_s("page out of range\n");
			break;
		case 23:
			printf_s("MSXDOS directive should preceed any code\n");
			break;
		case 24:
			printf_s("no code in the whole file\n");
			break;
		case 25:
			printf_s("only available for MSXDOS\n");
			break;
		case 26:
			printf_s("machine not defined\n");
			break;
		case 27:
			printf_s("MegaROM directive should preceed any code\n");
			break;
		case 28:
			printf_s("cannot write ROM code/data to page 3\n");
			break;
		case 29:
			printf_s("included binary shorter than expected\n");
			break;
		case 30:
			printf_s("wrong number of bytes to skip/include\n");
			break;
		case 31:
			printf_s("megaROM subpage overflow\n");
			break;
		case 32:
			printf_s("subpage 0 can only be defined by megaROM directive\n");
			break;
		case 33:
			printf_s("unsupported mapper type\n");
			break;
		case 34:
			printf_s("megaROM code should be between 4000h and BFFFh\n");
			break;
		case 35:
			printf_s("code/data without subpage\n");
			break;
		case 36:
			printf_s("megaROM mapper subpage out of range\n");
			break;
		case 37:
			printf_s("megaROM subpage already defined\n");
			break;
		case 38:
			printf_s("Konami megaROM forces page 0 at 4000h\n");
			break;
		case 39:
			printf_s("megaROM subpage not defined\n");
			break;
		case 40:
			printf_s("megaROM-only macro used\n");
			break;
		case 41:
			printf_s("only for ROMs and megaROMs\n");
			break;
		case 42:
			printf_s("ELSE without IF\n");
			break;
		case 43:
			printf_s("ENDIF without IF\n");
			break;
		case 44:
			printf_s("Cannot nest more IFs\n");
			break;
		case 45:
			printf_s("IF not closed\n");
			break;
		case 46:
			printf_s("Sinclair directive should preceed any code\n");
			break;
	}

	remove("~tmppre.?");
	exit(0);
}


void warning_message(int code)
{
	#ifndef COMPAT_S
	char *next_token = NULL;
	#endif /*  COMPAT_S */

	if (2 != pass)
		return;

	printf_s("%s, line %d: Warning: ", strtok_s(source, "\042", &next_token), lines);
	switch (code)
	{
		case 1:
			printf_s("16-bit overflow\n");
			break;
		case 2:
			printf_s("8-bit overflow\n");
			break;
		case 3:
			printf_s("3-bit overflow\n");
			break;
		case 4:
			printf_s("output cannot be converted to CAS\n");
			break;
		case 5:
			printf_s("not official Zilog syntax\n");
			break;
		case 6:
			printf_s("undocumented Zilog instruction\n");
			break;
	}
	warnings++;
}


void write_byte(const int b)
{
	if ((!conditional_level) || (conditional[conditional_level]))
	if (type != MEGAROM)
	{
		if (PC >= 0x10000)
			error_message(1);
		if ((type == ROM) && (PC >= 0xC000))
			error_message(28);
		if (addr_start > PC)
			addr_start = PC;
		if (addr_end < PC)
			addr_end = PC;
		if ((size) && (PC >= addr_start + size * 1024) && (pass == 2))
			error_message(17);
		if ((size) && (addr_start + size * 1024 > 65536) && (pass == 2))
			error_message(1);
		memory[PC++] = (unsigned char)b;
		ePC++;
	}

	if (type == MEGAROM)
	{
		if (subpage == ASMSX_MAX_PATH)
			error_message(35);
		if (PC >= pageinit + 1024 * pagesize)
			error_message(31);
		memory[subpage * pagesize * 1024 + PC - pageinit] = (unsigned char)b;
		PC++;
		ePC++;
	}
}


void write_text(const char *text)
{
	size_t i;
	for (i = 0; i < strlen(text); i++)
		write_byte(text[i]);
}


void write_word(const int w)
{
	write_byte((char)(w & 0xff));		/* TODO: check if it works for negative values */
	write_byte((char)((w >> 8) & 0xff));
}


void conditional_jump(const int address)
{
	int jump;
	jump = address - ePC - 1;
	if ((jump > 127) || (jump <- 128))
		error_message(8);
	write_byte((char)(address - ePC - 1));
}


void register_label(const char *name)
{
	int i;
	size_t name_len;

	if (pass == 2)
		for (i = 0; i < maximum; i++)
			if (!strcmp(name, id_list[i].name))
			{
				last_global = i;
				return;
			}

	for (i = 0; i < maximum; i++)
		if (!strcmp(name, id_list[i].name))
			error_message(14);

	if (++maximum == MAX_ID)
		error_message(11);

	name_len = strlen(name) + 4;
	id_list[maximum - 1].name = (char*)malloc(name_len);
	strcpy_s(id_list[maximum - 1].name, name_len, name);
	id_list[maximum - 1].value = ePC;
	id_list[maximum - 1].type = 1;
	id_list[maximum - 1].page = subpage;
	last_global = maximum - 1;
}


void register_local(const char *name)
{
	int i;
	size_t name_len;

	if (pass == 2)
		return;

	for (i = last_global; i < maximum; i++)
		if (!strcmp(name, id_list[i].name))
			error_message(14);

	if (++maximum == MAX_ID)
		error_message(11);

	name_len = strlen(name) + 4;
	id_list[maximum - 1].name = (char*)malloc(name_len);
	strcpy_s(id_list[maximum - 1].name, name_len, name);
	id_list[maximum - 1].value = ePC;
	id_list[maximum - 1].type = 1;
	id_list[maximum - 1].page = subpage;
}


void register_symbol(const char *name, int value, char type)
{
	#ifndef COMPAT_S
	char *next_token = NULL;
	#endif /*  COMPAT_S */

	int i;
	size_t name_len;
	char *tmpstr;

	if (2 == pass)
		return;
	for (i = 0; i < maximum; i++)
		if (!strcmp(name, id_list[i].name))
		{
			error_message(14);
			return;
		}

	if (++maximum == MAX_ID)
		error_message(11);

	name_len = strlen(name) + 1;
	id_list[maximum - 1].name = (char*)malloc(name_len);

	tmpstr = _strdup(name);
	strcpy_s(id_list[maximum - 1].name, name_len, strtok_s(tmpstr, " ", &next_token));
	id_list[maximum - 1].value = value;
	id_list[maximum - 1].type = type;
}


void register_variable(const char *name, int value)
{
	#ifndef COMPAT_S
	char *next_token = NULL;
	#endif /*  COMPAT_S */

	int i;
	size_t name_len;

	for (i = 0; i < maximum; i++)
		if ((!strcmp(name, id_list[i].name)) && (id_list[i].type == 3))
		{
			id_list[i].value = value;
			return;
		}

	if (++maximum == MAX_ID)
		error_message(11);

	name_len = strlen(name) + 1;
	id_list[maximum - 1].name = (char*)malloc(name_len);
	strcpy_s(id_list[maximum - 1].name, name_len, strtok_s((char *)name, " ", &next_token));
	id_list[maximum - 1].value = value;
	id_list[maximum - 1].type = 3;
}


int read_label(const char *name)
{
	int i;

	for (i = 0; i < maximum; i++)
		if (!strcmp(name, id_list[i].name))
			return id_list[i].value;

	if ((pass == 1) && (i == maximum))
		return ePC;

	error_message(12);
	return 0;	/* suppress compiler warning "not all control paths return a value" */
}


int read_local(const char *name)
{
	int i;

	if (pass==1)
		return ePC;

	for (i = last_global; i < maximum; i++)
		if (!strcmp(name, id_list[i].name))
			return id_list[i].value;

	error_message(13);
	return 0;	/* suppress compiler warning "not all control paths return a value" */
}


void output_text(void)
{
	strcpy_s(outputfname, ASMSX_MAX_PATH, filename);	/* Get output file name */
	strcat_s(outputfname, ASMSX_MAX_PATH, ".txt");

	if (0 != fopen_s(&fmessages, outputfname, "wt"))
		return;		/* TODO: validate if this is ok */

	fprintf_s(fmessages, "; Output text file from %s\n", assembler);
	fprintf_s(fmessages, "; generated by asmsx %s\n\n", ASMSX_VERSION);
	printf_s("Output text file %s saved\n", outputfname);
}


void save_symbols(void)
{
	int i, j;
	FILE *f;

	j = 0;
	for (i = 0; i < maximum; i++)
		j += id_list[i].type;

	if (j > 0)
	{
		if (0 != fopen_s(&f, symbols, "wt"))
			error_message(0);

		fprintf_s(f, "; Symbol table from %s\n", assembler);
		fprintf_s(f, "; generated by asmsx %s\n\n", ASMSX_VERSION);

		j = 0;
		for (i = 0; i < maximum; i++)
			if ((id_list[i].type) == 1)
				j++;

		if (j > 0)
		{
			fprintf_s(f, "; global and local labels\n");
			for (i = 0; i < maximum; i++)
				if ((id_list[i].type) == 1)
				{
					if (type != MEGAROM)
						fprintf_s(f, "%4.4Xh %s\n", id_list[i].value, id_list[i].name);
					else
						fprintf_s(f, "%2.2Xh:%4.4Xh %s\n", id_list[i].page & 0xff, id_list[i].value, id_list[i].name);
				}
		}

		j = 0;
		for (i = 0; i < maximum; i++)
			if (id_list[i].type == 2)
				j++;

		if (j > 0)
		{
			fprintf_s(f, "; other identifiers\n");
			for (i = 0; i < maximum; i++)
				if (id_list[i].type == 2)
					fprintf_s(f, "%4.4Xh %s\n", id_list[i].value, id_list[i].name);
		}

		j = 0;
		for (i = 0; i < maximum; i++)
			if (id_list[i].type == 3)
				j++;

		if (j > 0)
		{
			fprintf_s(f, "; variables - value on exit\n");
			for (i = 0; i < maximum; i++)
			if (id_list[i].type == 3)
				fprintf_s(f, "%4.4Xh %s\n", id_list[i].value, id_list[i].name);
		}

		fclose(f);
		printf_s("Symbol file %s saved\n", symbols);
	}
}


void include_binary(const char* name, int skip, int n)
{
	FILE *file;
	int i;
	char k;

	if (0 != fopen_s(&file, name, "rb"))
		error_message(18);

	if (pass == 1)
		printf_s("Including binary file %s", name);

	if ((pass == 1) && (skip))
		printf_s(", skipping %i bytes", skip);

	if ((pass == 1) && (n))
		printf_s(", saving %i bytes", n);

	if (pass == 1)
		printf_s("\n");

	if (skip)
		for (i = 0; (!feof(file)) && (i < skip); i++)
			k = (char)fgetc(file);

	if (skip && feof(file))
		error_message(29);

	if (n)
	{
		for (i = 0; (i < n) && (!feof(file));)
		{
			k = (char)fgetc(file);
			if (!feof(file))
			{
				write_byte(k);
				i++;
			}
		}
		if (i < n)
			error_message(29);
	}
	else
		for (i = 0; !feof(file); i++)	/* TODO: check if this works as expected - originally i wasn't initialized */
		{
			k = (char)fgetc(file);
			if (!feof(file))
				write_byte(k);
		}

	fclose(file);
}


void write_zx_byte(const int b)	/* TODO: move to zx specific unit */
{
	fputc(b, foutput);
	parity ^= b;
}


void write_zx_word(int w)	/* TODO: move to zx specific unit */
{
	write_zx_byte((char)(w & 0xff));
	write_zx_byte((char)((w >> 8) & 0xff));
}


void write_zx_number(int i)	/* TODO: move to zx specific unit */
{
	int c;
	c = i / 10000;
	i -= c * 10000;
	write_zx_byte((char)(c + 48));
	c = i / 1000;
	i -= c * 1000;
	write_zx_byte((char)(c + 48));
	c = i / 100;
	i -= c * 100;
	write_zx_byte((char)(c + 48));
	c = i / 10;
	write_zx_byte((char)(c + 48));
	i %= 10;
	write_zx_byte((char)(c + 48));
}


void write_binary(void)
{
	int i, j;

	if ((addr_start > addr_end) && (type != MEGAROM))
		error_message(24);

	if (type == Z80)
		strcat_s(binary, ASMSX_MAX_PATH, ".z80");

	if (type == ROM)
	{
		strcat_s(binary, ASMSX_MAX_PATH, ".rom");
		PC = addr_start + 2;
		write_word(start);
		if (!size)
			size = 8 * ((addr_end - addr_start + 8191) / 8192);
	}

	if (type == BASIC)
		strcat_s(binary, ASMSX_MAX_PATH, ".bin");

	if (type == MSXDOS)
		strcat_s(binary, ASMSX_MAX_PATH, ".com");

	if (type == SINCLAIR)
		strcat_s(binary, ASMSX_MAX_PATH, ".tap");

	if (type == MEGAROM)
	{
		strcat_s(binary, ASMSX_MAX_PATH, ".rom");
		PC = 0x4002;
		subpage = 0x00;
		pageinit = 0x4000;
		write_word(start);

		for (i = 1, j = 0; i <= lastpage; i++)	/* TODO: wow, can you really do that? "i = 1, j = 0" */
			j += usedpage[i];
		j >>= 1;
		if (j < lastpage)
			printf_s("Warning: %i out of %i megaROM pages are not defined\n", lastpage - j, lastpage);
	}

	printf_s("Binary file %s saved\n", binary);
	if (0 != fopen_s(&foutput, binary, "wb"))
		return;	/* TODO: print some error??? */

	if (type == BASIC)
	{
		fputc(0xfe, foutput);
		fputc(addr_start & 0xff, foutput);
		fputc((addr_start >> 8) & 0xff, foutput);
		fputc(addr_end & 0xff, foutput);
		fputc((addr_end >> 8) & 0xff, foutput);
		if (!start)
			start = addr_start;
		fputc(start & 0xff, foutput);
		fputc((start >> 8) & 0xff, foutput);
	}

	if (type == SINCLAIR)
	{
		if (start)
		{
			fputc(0x13, foutput);
			fputc(0, foutput);
			fputc(0, foutput);
			parity = 0x20;
			write_zx_byte(0);

			for (i = 0; i < 10; i++) 
				if (i < (int)strlen(filename))
					write_zx_byte(filename[i]);
				else
					write_zx_byte(32);	/* pad name on tape with spaces */

			write_zx_byte(0x1e);	/* line length */
			write_zx_byte(0);
			write_zx_byte(0x0a);	/* 10 */
			write_zx_byte(0);
			write_zx_byte(0x1e);	/* line length */
			write_zx_byte(0);
			write_zx_byte(0x1b);
			write_zx_byte(0x20);
			write_zx_byte(0);
			write_zx_byte(0xff);
			write_zx_byte(0);
			write_zx_byte(0x0a);
			write_zx_byte(0x1a);
			write_zx_byte(0);
			write_zx_byte(0xfd);	/* CLEAR */
			write_zx_byte(0xb0);	/* VAL */
			write_zx_byte('\"');	/* TODO: why escape? Isn't '"' the same? */
			write_zx_number(addr_start - 1);
			write_zx_byte('\"');
			write_zx_byte(':');
			write_zx_byte(0xef);	/* LOAD */
			write_zx_byte('\"');
			write_zx_byte('\"');
			write_zx_byte(0xaf);	/* CODE */
			write_zx_byte(':');
			write_zx_byte(0xf9);	/* RANDOMIZE */
			write_zx_byte(0xc0);	/* USR */
			write_zx_byte(0xb0);	/* VAL */
			write_zx_byte('\"');
			write_zx_number(start);
			write_zx_byte('\"');
			write_zx_byte(0x0d);
			write_zx_byte(parity);
		}

		fputc(19, foutput);	/* Header len */
		fputc(0, foutput);	/* MSB of len */
		fputc(0, foutput);	/* Header is 0 */
		parity = 0;

		write_zx_byte(3);	/* Filetype (Code) */

		for (i = 0; i < 10; i++) 

		if (i < (int)strlen(filename))
			write_zx_byte(filename[i]);
		else
			write_zx_byte(32);	/* pad name on tape with spaces */

		write_zx_word(addr_end - addr_start + 1);
		write_zx_word(addr_start);	/* load address */
		write_zx_word(0);		/* offset */
		write_zx_byte(parity);

		write_zx_word(addr_end - addr_start + 3);	/* Length of next block */
		parity = 0;
		write_zx_byte(255);		/* Data... */

		for (i = addr_start; i <= addr_end; i++)
			write_zx_byte(memory[i]);
		write_zx_byte(parity);
	}

	if (type != SINCLAIR)
	{
		if (!size)
		{
			if (type != MEGAROM)
				for (i = addr_start; i <= addr_end; i++)
					fputc(memory[i], foutput);
			else
				for (i = 0; i < (lastpage + 1) * pagesize * 1024; i++)
					fputc(memory[i], foutput);
		}
		else
			if (type != MEGAROM)
				for (i=addr_start; i < addr_start + size * 1024; i++)
					fputc(memory[i], foutput);
			else
				for (i = 0; i < size * 1024; i++)
					fputc(memory[i], foutput);
	}

	fclose(foutput);
}


void finalize(void)
{
	/* Get name of binary output file */
	strcpy_s(binary, ASMSX_MAX_PATH, filename);

	/* Get symbols file name */
	strcpy_s(symbols, ASMSX_MAX_PATH, filename);
	strcat_s(symbols, ASMSX_MAX_PATH, ".sym");

	write_binary();

	if (cassette & 1)
		cas_write_file();

	if (cassette & 2)
		wav_write_file(binary, intname, type, addr_start, addr_end, start, memory);

	if (maximum > 0)
		save_symbols();

	printf_s("Completed in %.2f seconds", (float)clock() / (float)CLOCKS_PER_SEC);

	if (warnings > 1)
		printf_s(", %i warnings\n", warnings);
	else
		if (warnings == 1)
			printf_s(", 1 warning\n");
		else
			printf_s("\n");
	remove("~tmppre.*");
	exit(0);
}


void initialize_memory(void)
{
	int i;
	memory = (unsigned char*)malloc(MEMORY_MAX);
	for (i = 0; i < MEMORY_MAX; i++)
		memory[i] = 0;
}


void initialize_system(void)
{
	initialize_memory();
	intname = malloc(ASMSX_MAX_PATH);
	intname[0] = 0;
	register_symbol("Eduardo_A_Robsy_Petrus_2007", 0, 0);	/* TODO: check if this is used anywhere */
}


void type_sinclair(void)
{
	if ((type) && (type != SINCLAIR))
		error_message(46);
	type = SINCLAIR;
	if (!addr_start)
	{
		PC = 0x8000;
		ePC = PC;
	}
}


void type_rom(void)
{
	if ((pass == 1) && (!addr_start))
		error_message(19);
	if ((type) && (type != ROM))
		error_message(20);
	type = ROM;
	write_byte(65);
	write_byte(66);
	PC += 14;
	ePC += 14;
	if (!start)
		start = ePC;
}


void type_megarom(int n)
{
	int i;

	if (pass == 1)
		for (i = 0; i < 256; i++)
			usedpage[i] = 0;

	if ((pass == 1) && (!addr_start))
		error_message(19);

	/* if ((pass==1) && ((!PC) || (!ePC)))
		error_message(19); */

	if ((type) && (type != MEGAROM))
		error_message(20);

	if ((n < 0) || (n > 3))
		error_message(33);

	type = MEGAROM;
	usedpage[0] = 1;
	subpage = 0;
	pageinit = 0x4000;
	lastpage = 0;

	if ((n == 0) || (n == 1) || (n == 2))
		pagesize = 8;
	else
		pagesize = 16;

	mapper = n;
	PC = 0x4000;
	ePC = 0x4000;
	write_byte(65);
	write_byte(66);
	PC += 14;
	ePC += 14;

	if (!start)
		start = ePC;
}


void type_basic(void)
{
	if ((pass == 1) && (!addr_start))
		error_message(21);

	if ((type) && (type != BASIC))
		error_message(20);

	type = BASIC;
}


void type_msxdos(void)
{
	if ((pass == 1) && (!addr_start))
		error_message(23);

	if ((type) && (type != MSXDOS))
		error_message(20);

	type = MSXDOS;
	PC = 0x0100;
	ePC = 0x0100;
}


void set_subpage(int n, int addr)
{
	if (n > lastpage)
		lastpage = n;

	if (!n)
		error_message(32);

	if (usedpage[n] == pass)
		error_message(37);
	else
		usedpage[n] = pass;

	if ((addr < 0x4000) || (addr > 0xbfff))
		error_message(35);

	if (n > maxpage[mapper])
		error_message(36);

	subpage = n;
	pageinit = (addr / pagesize) * pagesize;
	PC = pageinit;
	ePC = PC;
}


void locate_32k(void)
{
	int i;

	/* TODO: this is probably Z80 binary code, need to figure out what is it */
	unsigned char locate32[31] =
	{
		0xCD, 0x38, 0x01, 0x0F, 0x0F, 0xE6, 0x03, 0x4F,
		0x21, 0xC1, 0xFC, 0x85, 0x6F, 0x7E, 0xE6, 0x80,
		0xB1, 0x4F, 0x2C, 0x2C, 0x2C, 0x2C, 0x7E, 0xE6,
		0x0C, 0xB1, 0x26, 0x80, 0xCD, 0x24, 0x00
	};

	for (i = 0; i < 31; i++)
		write_byte(locate32[i]);
}


int selector(int addr)
{
	addr = (addr / pagesize) * pagesize;

	if ((mapper == KONAMI) && (addr == 0x4000))
		error_message(38);

	if (mapper == KONAMISCC)
		addr += 0x1000;

	if (mapper == ASCII8)
		addr = 0x6000 + (addr - 0x4000) / 4;

	if (mapper == ASCII16)
	{
		if (addr == 0x4000)
			addr = 0x6000;
		else
			addr = 0x7000;
	}

	return addr;
}


void select_page_direct(int n, int addr)
{
	int sel;

	sel = selector(addr);

	if ((pass == 2) && (!usedpage[n]))
		error_message(39);

	write_byte(0xf5);
	write_byte(0x3e);
	write_byte((char)n);
	write_byte(0x32);
	write_word(sel);
	write_byte(0xf1);
}


void select_page_register(int r, int addr)
{
	int sel;

	sel = selector(addr);

	if (r != 7)
	{
		write_byte(0xf5);				/* PUSH AF */
		write_byte((char)(0x40 | (7 << 3) | r));	/* LD A,r */
	}

	write_byte(0x32);
	write_word(sel);
	if (r != 7)
		write_byte(0xf1);				/* POP AF */
}


void cas_write_file(void)
{
	FILE *f;
	int i;
	unsigned char cas[8] = {0x1F, 0xA6, 0xDE, 0xBA, 0xCC, 0x13, 0x7D, 0x74};

	if ((type == MEGAROM) || ((type == ROM) && (addr_start < 0x8000)))
	{
		warning_message(0);
		return;
	}

	binary[strlen(binary) - 3] = 0;
	strcat_s(binary, ASMSX_MAX_PATH, "cas");

	if (0 != fopen_s(&f, binary, "wb"))
		return;	/* TODO: print some error ??? */

	for (i = 0; i < 8; i++)
		fputc(cas[i], f);

	if ((type == BASIC) || (type == ROM))
	{
		for (i = 0; i < 10; i++)
			fputc(0xd0, f);

		if (strlen(intname) < 6)
			for (i = (int)strlen(intname); i < 6; i++)
				intname[i] = 32;

		for (i = 0; i < 6; i++)
			fputc(intname[i], f);

		for (i = 0; i < 8; i++)
			fputc(cas[i], f);

		fputc(addr_start & 0xff, f);
		fputc((addr_start >> 8) & 0xff, f);
		fputc(addr_end & 0xff, f);
		fputc((addr_end >> 8) & 0xff, f);
		fputc(start & 0xff, f);
		fputc((start >> 8) & 0xff, f);
	}

	for (i = addr_start; i <= addr_end; i++)
		fputc(memory[i], f);

	fclose(f);

	printf_s("Cassette file %s saved\n", binary);
}


int defined_symbol(const char *name)
{
	int i;

	for (i = 0; i < maximum; i++)
		if (!strcmp(name, id_list[i].name))
			return 1;

	return 0;
}


int main(int argc, char *argv[])
{
	size_t strpos;

	printf_s("asmsx %s MSX cross assembler https://github.com/asmsx/asmsx/ (%s)\n", ASMSX_VERSION, __DATE__);

	if (2 != argc)
	{
        	printf_s("Syntax: asmsx [file.asm]\n");
		exit(0);
	}

	clock();
	initialize_system();
	assembler = (char *)malloc(ASMSX_MAX_PATH);
	source = (char *)malloc(ASMSX_MAX_PATH);
	original = (char *)malloc(ASMSX_MAX_PATH);
	binary = (char *)malloc(ASMSX_MAX_PATH);
	symbols = (char *)malloc(ASMSX_MAX_PATH);
	outputfname = (char *)malloc(ASMSX_MAX_PATH);
	filename = (char *)malloc(ASMSX_MAX_PATH);

	strcpy_s(filename, ASMSX_MAX_PATH, argv[1]);
	strcpy_s(assembler, ASMSX_MAX_PATH, filename);

	strpos = strlen(filename);
	do
		strpos--;
	while ((strpos != 0u) && (filename[strpos] != '.'));

	if (strpos != 0)
		filename[strpos]=0;	/* if there is a file extension, remove it */
	else
		strcat_s(assembler, ASMSX_MAX_PATH, ".asm");	/* file name supplied without extensions, add it */

	preprocessor1(assembler);
	preprocessor3();
	sprintf_s(original, ASMSX_MAX_PATH, "~tmppre.%i", preprocessor2());
	printf_s("Assembling source file %s\n", assembler);
	conditional[0] = 1;
	if (0 != fopen_s(&foriginal, original, "r"))
		return 1;	/* TODO: print some error ??? */
	yyin = foriginal;
	yyparse();
	remove("~tmppre.?");
	return 0;
}

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


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

#include "asmsx.h"
#include "wav.h"
#include "core.c"	/* TODO: change this somehow, C is not supposed to be included */
#include "lex.c"	/* TODO: it should be compiled and linked together instead */

/* Global variables */
/* TODO: reduce the number of global variables */

unsigned char *memory, zilog = 0, pass = 1, size = 0, bios = 0, type = 0, parity;
int conditional[16], conditional_level = 0;
unsigned char *assembler, cassette = 0;
char *source, *intname, *binary, *filename, *original, *outputfname, *symbols;
unsigned int ePC = 0, PC = 0, subpage, pagesize, usedpage[256], lastpage, mapper, pageinit, addr_start = 0xffff, addr_end = 0x0000, start = 0, warnings = 0, lines;
unsigned int maxpage[4] = {32, 64, 256, 256};

int maximum = 0, last_global = 0;
FILE *foriginal, *fmessages, *foutput;

#define MAX_ID 32000

struct
{
	char *name;
	unsigned int value;
	unsigned char type;
	unsigned int page;
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
	printf("%s, line %d: ", strtok(source, "\042"), lines);
	switch (code)
	{
		case 0:
			printf("syntax error\n");
			break;
		case 1:
			printf("memory overflow\n");
			break;
		case 2:
			printf("wrong register combination\n");
			break;
		case 3:
			printf("wrong interruption mode\n");
			break;
		case 4:
			printf("destination register should be A\n");
			break;
		case 5:
			printf("source register should be A\n");
			break;
		case 6:
			printf("value should be 0\n");
			break;
		case 7:
			printf("missing condition\n");
			break;
		case 8:
			printf("unreachable address\n");
			break;
		case 9:
			printf("wrong condition\n");
			break;
		case 10:
			printf("wrong restart address\n");
			break;
		case 11:
			printf("symbol table overflow\n");
			break;
		case 12:
			printf("undefined identifier\n");
			break;
		case 13:
			printf("undefined local label\n");
			break;
		case 14:
			printf("symbol redefinition\n");
			break;
		case 15:
			printf("size redefinition\n");
			break;
		case 16:
			printf("reserved word used as identifier\n");
			break;
		case 17:
			printf("code size overflow\n");
			break;
		case 18:
			printf("binary file not found\n");
			break;
		case 19:
			printf("ROM directive should preceed any code\n");
			break;
		case 20:
			printf("previously defined type\n");
			break;
		case 21:
			printf("BASIC directive should preceed any code\n");
			break;
		case 22:
			printf("page out of range\n");
			break;
		case 23:
			printf("MSXDOS directive should preceed any code\n");
			break;
		case 24:
			printf("no code in the whole file\n");
			break;
		case 25:
			printf("only available for MSXDOS\n");
			break;
		case 26:
			printf("machine not defined\n");
			break;
		case 27:
			printf("MegaROM directive should preceed any code\n");
			break;
		case 28:
			printf("cannot write ROM code/data to page 3\n");
			break;
		case 29:
			printf("included binary shorter than expected\n");
			break;
		case 30:
			printf("wrong number of bytes to skip/include\n");
			break;
		case 31:
			printf("megaROM subpage overflow\n");
			break;
		case 32:
			printf("subpage 0 can only be defined by megaROM directive\n");
			break;
		case 33:
			printf("unsupported mapper type\n");
			break;
		case 34:
			printf("megaROM code should be between 4000h and BFFFh\n");
			break;
		case 35:
			printf("code/data without subpage\n");
			break;
		case 36:
			printf("megaROM mapper subpage out of range\n");
			break;
		case 37:
			printf("megaROM subpage already defined\n");
			break;
		case 38:
			printf("Konami megaROM forces page 0 at 4000h\n");
			break;
		case 39:
			printf("megaROM subpage not defined\n");
			break;
		case 40:
			printf("megaROM-only macro used\n");
			break;
		case 41:
			printf("only for ROMs and megaROMs\n");
			break;
		case 42:
			printf("ELSE without IF\n");
			break;
		case 43:
			printf("ENDIF without IF\n");
			break;
		case 44:
			printf("Cannot nest more IFs\n");
			break;
		case 45:
			printf("IF not closed\n");
			break;
		case 46:
			printf("Sinclair directive should preceed any code\n");
			break;
	}

	remove("~tmppre.?");
	exit(0);
}


void warning_message(int code)
{
	if (2 != pass)
		return;

	printf("%s, line %d: Warning: ", strtok(source, "\042"), lines);
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
	warnings++;
}


void write_byte(int b)
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
		memory[PC++] = b;
		ePC++;
	}

	if (type == MEGAROM)
	{
		if (subpage == ASMSX_MAX_PATH)
			error_message(35);
		if (PC >= pageinit + 1024 * pagesize)
			error_message(31);
		memory[subpage * pagesize * 1024 + PC - pageinit] = b;
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
	write_byte(w & 0xff);
	write_byte((w >> 8) & 0xff);
}


void conditional_jump(const int address)
{
	int jump;
	jump = address - ePC - 1;
	if ((jump > 127) || (jump <- 128))
		error_message(8);
	write_byte(address - ePC - 1);
}


void register_label(const char *name)
{
	int i;

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

	id_list[maximum - 1].name = (char*)malloc(strlen(name) + 4);
	strcpy(id_list[maximum-1].name, name);
	id_list[maximum - 1].value = ePC;
	id_list[maximum - 1].type = 1;
	id_list[maximum - 1].page = subpage;
	last_global = maximum - 1;
}


void register_local(const char *name)
{
	int i;

	if (pass == 2)
		return;

	for (i = last_global; i < maximum; i++)
		if (!strcmp(name, id_list[i].name))
			error_message(14);

	if (++maximum == MAX_ID)
		error_message(11);

	id_list[maximum - 1].name = (char*)malloc(strlen(name) + 4);
	strcpy(id_list[maximum - 1].name, name);
	id_list[maximum - 1].value = ePC;
	id_list[maximum - 1].type = 1;
	id_list[maximum - 1].page = subpage;
}


void register_symbol(const char *name,int number,int type)
{
	unsigned int i;
	char *tmpstr;

	if (pass == 2)
		return;
	for (i=0; i < maximum; i++)
		if (!strcmp(name, id_list[i].name))
		{
			error_message(14);
			return;
		}

	if (++maximum == MAX_ID)
		error_message(11);

	id_list[maximum - 1].name = (char*)malloc(strlen(name) + 1);

	tmpstr = strdup(name);
	strcpy(id_list[maximum - 1].name, strtok(tmpstr, " "));
	id_list[maximum - 1].value = number;
	id_list[maximum - 1].type = type;
}


void register_variable(const char *name,int number)
{
 unsigned int i;
 for (i=0;i<maximum;i++) if ((!strcmp(name,id_list[i].name))&&(id_list[i].type==3)) {id_list[i].value=number;return;}
 if (++maximum==MAX_ID) error_message(11);
 id_list[maximum-1].name=(char*)malloc(strlen(name)+1);
 strcpy(id_list[maximum-1].name,strtok((char *)name," "));
 id_list[maximum-1].value=number;
 id_list[maximum-1].type=3;
}


unsigned int read_label(const char *name)
{
	unsigned int i;
	for (i = 0; i < maximum; i++)
	if (!strcmp(name, id_list[i].name))
		return id_list[i].value;
	if ((pass == 1) && (i == maximum))
		return ePC;
	error_message(12);
	return 0;	/* suppress compiler warning "not all control paths return a value" */
}


unsigned int read_local(const char *name)
{
	unsigned int i;
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
	strcpy(outputfname,filename);	/* Get output file name */
	outputfname = strcat(outputfname, ".txt");

	fmessages = fopen(outputfname, "wt");

	if (fmessages == NULL)
		return;		/* TODO: validate if this is ok */

	fprintf(fmessages, "; Output text file from %s\n", assembler);
	fprintf(fmessages, "; generated by asmsx %s\n\n", ASMSX_VERSION);
	printf("Output text file %s saved\n", outputfname);
}


void save_symbols(void)
{
	unsigned int i, j;
	FILE *f;

	j = 0;
	for (i = 0; i < maximum; i++)
		j += id_list[i].type;

	if (j > 0)
	{
		if ((f = fopen(symbols, "wt")) == NULL)
			error_message(0);
		fprintf(f, "; Symbol table from %s\n", assembler);
		fprintf(f, "; generated by asmsx %s\n\n", ASMSX_VERSION);

		j = 0;
		for (i = 0; i < maximum; i++)
			if (1 == (id_list[i].type))
				j++;

		if (j > 0)
		{
			fprintf(f, "; global and local labels\n");
			for (i = 0; i < maximum; i++)
				if (1 == (id_list[i].type))
					if (type != MEGAROM)
						fprintf(f, "%4.4Xh %s\n", id_list[i].value, id_list[i].name);
					else
						fprintf(f, "%2.2Xh:%4.4Xh %s\n", id_list[i].page & 0xff, id_list[i].value, id_list[i].name);
		}

		j = 0;
		for (i = 0; i < maximum; i++)
			if (id_list[i].type == 2)
				j++;

		if (j > 0)
		{
			fprintf(f, "; other identifiers\n");
			for (i = 0; i < maximum; i++)
				if (id_list[i].type == 2)
					fprintf(f, "%4.4Xh %s\n", id_list[i].value, id_list[i].name);
		}

		j = 0;
		for (i=0; i < maximum; i++)
			if (id_list[i].type == 3)
				j++;

		if (j > 0)
		{
			fprintf(f, "; variables - value on exit\n");
			for (i = 0; i < maximum; i++)
			if (id_list[i].type == 3)
				fprintf(f, "%4.4Xh %s\n", id_list[i].value, id_list[i].name);
		}

		fclose(f);
		printf("Symbol file %s saved\n", symbols);
	}
}


int yywrap(void)	/* TODO: move back to core.y? */
{
	return 1;
}


void yyerror(const char *s)	/* TODO: move back to core.y? */
{
	error_message(0);
}


void include_binary(const char* name,unsigned int skip,unsigned int n)
{
	FILE *file;
	char k;
	unsigned int i;

	if ((file = fopen(name, "rb")) == NULL)
		error_message(18);

	if (pass == 1)
		printf("Including binary file %s", name);

	if ((pass == 1) && (skip))
		printf(", skipping %i bytes", skip);

	if ((pass == 1) && (n))
		printf(", saving %i bytes", n);

	if (pass == 1)
		printf("\n");

	if (skip)
		for (i = 0; (!feof(file)) && (i < skip); i++)
			k = fgetc(file);

	if (skip && feof(file))
		error_message(29);

	if (n)
	{
		for (i = 0; (i < n) && (!feof(file));)
		{
			k = fgetc(file);
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
		for (; !feof(file); i++)
		{
			k = fgetc(file);
			if (!feof(file))
				write_byte(k);
		}

	fclose(file);
}


void write_zx_byte(unsigned char c)	/* TODO: move to zx specific unit */
{
	putc(c, foutput);
	parity ^= c;
}


void write_zx_word(unsigned int c)	/* TODO: move to zx specific unit */
{
	write_zx_byte(c & 0xff);
	write_zx_byte((c >> 8) & 0xff);
}


void write_zx_number(unsigned int i)	/* TODO: move to zx specific unit */
{
	int c;
	c = i / 10000;
	i -= c * 10000;
	write_zx_byte(c + 48);
	c = i / 1000;
	i -= c * 1000;
	write_zx_byte(c + 48);
	c = i / 100;
	i -= c * 100;
	write_zx_byte(c + 48);
	c = i / 10;
	write_zx_byte(c + 48);
	i %= 10;
	write_zx_byte(i + 48);
}


void write_binary(void)
{
	unsigned int i, j;

	if ((addr_start > addr_end) && (type != MEGAROM))
		error_message(24);

	if (type == Z80)
		binary = strcat(binary, ".z80");

	if (type == ROM)
	{
		binary = strcat(binary, ".rom");
		PC = addr_start + 2;
		write_word(start);
		if (!size)
			size = 8 * ((addr_end - addr_start + 8191) / 8192);
	}

	if (type == BASIC)
		binary = strcat(binary, ".bin");

	if (type == MSXDOS)
		binary = strcat(binary, ".com");

	if (type == SINCLAIR)
		binary = strcat(binary, ".tap");

	if (type == MEGAROM)
	{
		binary = strcat(binary, ".rom");
		PC = 0x4002;
		subpage = 0x00;
		pageinit = 0x4000;
		write_word(start);

		for (i = 1, j = 0; i <= lastpage; i++)	/* TODO: wow, can you really do that? "i = 1, j = 0" */
			j += usedpage[i];
		j >>= 1;
		if (j < lastpage)
			printf("Warning: %i out of %i megaROM pages are not defined\n", lastpage - j, lastpage);
	}

	printf("Binary file %s saved\n", binary);
	foutput = fopen(binary, "wb");

	if (type == BASIC)
	{
		putc(0xfe, foutput);
		putc(addr_start & 0xff, foutput);
		putc((addr_start >> 8) & 0xff, foutput);
		putc(addr_end & 0xff, foutput);
		putc((addr_end >> 8) & 0xff, foutput);
		if (!start)
			start = addr_start;
		putc(start & 0xff, foutput);
		putc((start >> 8) & 0xff, foutput);
	}

	if (type == SINCLAIR)
	{
		if (start)
		{
			putc(0x13, foutput);
			putc(0, foutput);
			putc(0, foutput);
			parity = 0x20;
			write_zx_byte(0);

			for (i = 0; i < 10; i++) 
				if (i < strlen(filename))
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

		putc(19, foutput);	/* Header len */
		putc(0, foutput);	/* MSB of len */
		putc(0, foutput);	/* Header is 0 */
		parity = 0;

		write_zx_byte(3);	/* Filetype (Code) */

		for (i = 0; i < 10; i++) 

		if (i < strlen(filename))
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
		if (!size)
		{
			if (type != MEGAROM)
				for (i = addr_start; i <= addr_end; i++)
					putc(memory[i], foutput);
			else
				for (i = 0; i < (lastpage + 1) * pagesize * 1024; i++)
					putc(memory[i], foutput);
		}
		else
			if (type != MEGAROM)
				for (i=addr_start; i < addr_start + size * 1024; i++)
					putc(memory[i], foutput);
			else
				for (i = 0; i < size * 1024; i++)
					putc(memory[i], foutput);

	fclose(foutput);
}


void finalize(void)
{
	unsigned int i;
 
	/* Get name of binary output file */
	strcpy(binary, filename);

	/* Get symbols file name */
	strcpy(symbols, filename);
	symbols = strcat(symbols, ".sym");

	write_binary();

	if (cassette & 1)
		generate_cassette();

	if (cassette & 2)
		wav_write_file(binary, intname, type, addr_start, addr_end, start, memory);

	if (maximum > 0)
		save_symbols();

	printf("Completed in %.2f seconds", (float)clock() / (float)CLOCKS_PER_SEC);

	if (warnings > 1)
		printf(", %i warnings\n", warnings);
	else
		if (warnings == 1)
			printf(", 1 warning\n");
		else
			printf("\n");
	remove("~tmppre.*");
	exit(0);
}


void initialize_memory(void)
{
 unsigned int i;
 memory=(unsigned char*)malloc(0x1000000);

 for (i=0;i<0x1000000;i++) memory[i]=0;

}


void initialize_system(void)
{

 initialize_memory();

 intname=malloc(ASMSX_MAX_PATH);
 intname[0]=0;

 register_symbol("Eduardo_A_Robsy_Petrus_2007",0,0);

}


void type_sinclair(void)
{
 if ((type) && (type!=SINCLAIR)) error_message(46);
 type=SINCLAIR;
 if (!addr_start) {PC=0x8000;ePC=PC;}
}


void type_rom(void)
{
 if ((pass==1) && (!addr_start)) error_message(19);
 if ((type) && (type!=ROM)) error_message(20);
 type=ROM;
 write_byte(65);
 write_byte(66);
 PC+=14;
 ePC+=14;
 if (!start) start=ePC;
}


void type_megarom(int n)
{
 unsigned int i;

 if (pass==1) for (i=0;i<256;i++) usedpage[i]=0;

 if ((pass==1) && (!addr_start)) error_message(19);
/* if ((pass==1) && ((!PC) || (!ePC))) error_message(19); */
 if ((type) && (type!=MEGAROM)) error_message(20);
 if ((n<0)||(n>3)) error_message(33);
 type=MEGAROM;
 usedpage[0]=1;
 subpage=0;
 pageinit=0x4000;
 lastpage=0;
 if ((n==0)||(n==1)||(n==2)) pagesize=8; else pagesize=16;
 mapper=n;
 PC=0x4000;
 ePC=0x4000;
 write_byte(65);
 write_byte(66);
 PC+=14;
 ePC+=14;
 if (!start) start=ePC;
}


void type_basic(void)
{
 if ((pass==1) && (!addr_start)) error_message(21);
 if ((type) && (type!=BASIC)) error_message(20);
 type=BASIC;
}


void type_msxdos(void)
{
 if ((pass==1) && (!addr_start)) error_message(23);
 if ((type) && (type!=MSXDOS)) error_message(20);
 type=MSXDOS;
 PC=0x0100;
 ePC=0x0100;
}


void set_subpage(int n, int addr)
{
 if (n>lastpage) lastpage=n;
 if (!n) error_message(32);
 if (usedpage[n]==pass) error_message(37); else usedpage[n]=pass;
 if ((addr<0x4000) || (addr>0xbfff)) error_message(35);
 if (n>maxpage[mapper]) error_message(36);
 subpage=n;
 pageinit=(addr/pagesize)*pagesize;
 PC=pageinit;
 ePC=PC;
}


void locate_32k(void)
{
	unsigned int i;
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


unsigned int selector(unsigned int addr)
{
 addr=(addr/pagesize)*pagesize;
 if ((mapper==KONAMI) && (addr==0x4000)) error_message(38);
 if (mapper==KONAMISCC) addr+=0x1000; else
  if (mapper==ASCII8) addr=0x6000+(addr-0x4000)/4; else
   if (mapper==ASCII16) if (addr==0x4000) addr=0x6000; else addr=0x7000;
 return addr;
}


void select_page_direct(unsigned int n,unsigned int addr)
{
 unsigned int sel;

 sel=selector(addr);

 if ((pass==2)&&(!usedpage[n])) error_message(39);
 write_byte(0xf5);
 write_byte(0x3e);
 write_byte(n);
 write_byte(0x32);
 write_word(sel);
 write_byte(0xf1);
}


void select_page_register(unsigned int r, unsigned int addr)
{
 unsigned int sel;

 sel=selector(addr);

 if (r!=7)
 {
  write_byte(0xf5); /* PUSH AF */
  write_byte(0x40|(7<<3)|r); /* LD A,r */
 }
 write_byte(0x32);
 write_word(sel);
 if (r!=7) write_byte(0xf1); /* POP AF */
}


void generate_cassette(void)
{

 unsigned char cas[8]={0x1F,0xA6,0xDE,0xBA,0xCC,0x13,0x7D,0x74};

 FILE *fcas;
 unsigned int i;

 if ((type==MEGAROM)||((type=ROM)&&(addr_start<0x8000)))
 {
  warning_message(0);
  return;
 }

 binary[strlen(binary)-3]=0;
 binary=strcat(binary,"cas");

 fcas=fopen(binary,"wb");

 for (i=0;i<8;i++) fputc(cas[i],fcas);

 if ((type==BASIC)||(type==ROM))
 {
  for (i=0;i<10;i++) fputc(0xd0,fcas);

  if (strlen(intname)<6)
   for (i=strlen(intname);i<6;i++) intname[i]=32;

  for (i=0;i<6;i++) fputc(intname[i],fcas);

	for (i=0;i<8;i++)
		fputc(cas[i],fcas);


  putc(addr_start & 0xff,fcas);
  putc((addr_start>>8) & 0xff,fcas);
  putc(addr_end & 0xff,fcas);
  putc((addr_end>>8) & 0xff,fcas);
  putc(start & 0xff,fcas);
  putc((start>>8) & 0xff,fcas);
 }

 for (i=addr_start;i<=addr_end;i++)
   putc(memory[i],fcas);
 fclose(fcas);

 printf("Cassette file %s saved\n",binary);
}


int defined_symbol(const char *name)
{
 unsigned int i;
 for (i=0;i<maximum;i++) if (!strcmp(name,id_list[i].name)) return 1;
 return 0;
}


int main(int argc, char *argv[])
{
	int i;

	printf("asmsx %s - MSX cross assembler %s\n", ASMSX_VERSION, __DATE__);
	if (2 != argc)
	{
        	printf("Syntax: asmsx [file.asm]\n");
		exit(0);
	}
	clock();
	initialize_system();
	assembler = (unsigned char *)malloc(ASMSX_MAX_PATH);
	source = (unsigned char *)malloc(ASMSX_MAX_PATH);
	original = (unsigned char *)malloc(ASMSX_MAX_PATH);
	binary = (char *)malloc(ASMSX_MAX_PATH);
	symbols = (char *)malloc(ASMSX_MAX_PATH);
	outputfname = (char *)malloc(ASMSX_MAX_PATH);
	filename = (char *)malloc(ASMSX_MAX_PATH);
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

/* Main asmsx declaration file.

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


#ifndef ASMSX_ASMSX_H
#define ASMSX_ASMSX_H

#define ASMSX_VERSION "0.16.1"

#ifdef _MSC_VER
#define YY_NO_UNISTD_H 1
#endif

#define YY_NO_INPUT 1

#define Z80 0
#define ROM 1
#define BASIC 2
#define MSXDOS 3
#define MEGAROM 4
#define SINCLAIR 5

#define KONAMI 0
#define KONAMISCC 1
#define ASCII8 2
#define ASCII16 3

#define ASMSX_MAX_PATH	0x100
#define MEMORY_MAX	0x1000000	/* 16 megabytes - a bit too rich */

#define MAX_INCLUDE_LEVEL 16


/* variables */

extern char *assembler;
extern char *source;
extern char *intname;
extern char *binary;
extern char *filename;
extern char *original;
extern char *outputfname;
extern char *symbols;

extern unsigned char *memory;

extern int parity;
extern int zilog;
extern int pass;
extern int size;
extern int bios;
extern int type;
extern int conditional[16];
extern int conditional_level;
extern int cassette;
extern int ePC;
extern int PC;
extern int subpage;
extern int pagesize;
extern int usedpage[256];
extern int mapper;
extern int pageinit;
extern int addr_start;
extern int addr_end;
extern int start;
extern int warnings;
extern int lines;
extern int maxpage[4];
extern int last_global;

extern FILE *foriginal;
extern FILE *fmessages;
extern FILE *foutput;

/* Function prototypes */
extern void error_message(const int, const char *, const int);
extern void msx_bios(void);
extern void register_label(const char *);
extern void register_local(const char *);
extern void register_symbol(const char *, int, char);
extern void register_variable(const char *, int);
extern void output_text(void);
extern void cas_write_file(void);
extern void write_byte(const int);
extern void write_text(const char *);
extern void write_word(const int);
extern void conditional_jump(const int);
extern int read_label(const char *);
extern int read_local(const char *);
extern void include_binary(const char *, int, int);
extern void finalize(void);
extern void type_sinclair(void);
extern void type_rom(void);
extern void type_megarom(int);
extern void type_basic(void);
extern void type_msxdos(void);
extern void set_subpage(int, int);
extern void locate_32k(void);
extern void select_page_direct(int, int);
extern void select_page_register(int, int);
extern int defined_symbol(const char *);

/* bison / flex */
extern FILE *yyin, *yyout;

extern int yylex(void);
extern int yyparse(void);
extern void yyerror(const char *);

#endif	/* ASMSX_ASMSX_H */

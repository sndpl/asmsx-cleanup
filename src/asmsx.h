/* Main asmsx declaration file.

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


#ifndef ASMSX_ASMSX_H
#define ASMSX_ASMSX_H

#define ASMSX_VERSION "0.16.1 WIP"

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

#define ASMSX_MAX_PATH	(0x100)

/* variables */

extern unsigned char *memory;
extern unsigned char zilog;
extern unsigned char pass;
extern unsigned char size;
extern unsigned char bios;
extern unsigned char type;
extern unsigned char parity;

extern int conditional[16];
extern int conditional_level;
extern int cassette;
extern char *assembler;
extern char *source;
extern char *intname;
extern char *binary;
extern char *filename;
extern char *original;
extern char *outputfname;
extern char *symbols;

extern unsigned int ePC;
extern unsigned int PC;
extern unsigned int subpage;
extern unsigned int pagesize;
extern unsigned int usedpage[256];
extern unsigned int lastpage;
extern unsigned int mapper;
extern unsigned int pageinit;
extern unsigned int addr_start;
extern unsigned int addr_end;
extern unsigned int start;
extern unsigned int warnings;
extern unsigned int lines;

extern unsigned int maxpage[4];

extern int maximum;
extern int last_global;

extern FILE *foriginal;
extern FILE *fmessages;
extern FILE *foutput;


/* function prototypes */
extern int yylex(void);
extern void warning_message(int);
extern void error_message(int);
extern void msx_bios(void);
extern void register_label(const char *);
extern void register_local(const char *);
extern void register_symbol(const char *, int, int);
extern void register_variable(const char *, int);
extern void output_text(void);
extern void cas_write_file(void);
extern void write_byte(int);
extern void write_text(const char *);
extern void write_word(const int);
extern void conditional_jump(const int);
extern unsigned int read_label(const char *);
extern unsigned int read_local(const char *);
extern void yyerror(const char *);
extern void include_binary(const char *, unsigned int, unsigned int);
extern void finalize(void);
extern void type_sinclair(void);
extern void type_rom(void);
extern void type_megarom(int);
extern void type_basic(void);
extern void type_msxdos(void);
extern void set_subpage(int, int);
extern void locate_32k(void);
extern void select_page_direct(unsigned int, unsigned int);
extern void select_page_register(unsigned int, unsigned int);
extern int defined_symbol(const char *);

#endif	/* ASMSX_ASMSX_H */

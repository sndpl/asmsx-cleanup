/* Look for ZILOG macro, if present, swap parentheses and square
 brackets. This affects syntax for mathematical expressions and
 instructions with indirect addressing.

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


%option noyywrap yylineno nounput warn

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "asmsx.h"

#define P3TEXT_MAX	0x1000

FILE *p3fout;
char *p3text;
%}

%s line
%s zilog

%%

<INITIAL>"#"line[ \t]*[0-9]+\n	{
					strcat(p3text, yytext);
					BEGIN(line);
				}

<INITIAL>\n			{
					fprintf(p3fout, "%s%s", p3text, yytext);
					p3text[0] = 0;
				}

<INITIAL>.			strcat(p3text, yytext);

<line>.?zilog[ \t]*\n		{
					strcat(p3text, yytext);
					BEGIN(zilog);
				}

<line>.				{
					strcat(p3text, yytext);
					BEGIN(INITIAL);
				}

<zilog>\"[^\"\n]+\"		strcat(p3text, yytext);
<zilog>"("			strcat(p3text, "[");
<zilog>")"			strcat(p3text, "]");
<zilog>"["			strcat(p3text, "(");
<zilog>"]"			strcat(p3text, ")");
<zilog>.			strcat(p3text, yytext);

<zilog>\n			{
					fprintf(p3fout, "%s%s", p3text, yytext);
					p3text[0] = 0;
				}
%%

int preprocessor3(void)
{
	FILE *input;

	p3text = (char*)malloc(P3TEXT_MAX);
	if (!p3text)
	{
		error_message(1);
		exit(1);
	}

	p3text[0] = 0;

	input = fopen("~tmppre.0", "r");
	if (!input)
	{
		printf("Fatal: cannot process file\n");
		exit(1);
	}

	yyin = input;
 
	p3fout = fopen("~tmppre.1", "w");
	if (!p3fout)
	{
		printf("Fatal: cannot create temporary file in preprocessor3()\n");
		exit(1);
	}

	yylex();

	fclose(input);
	fclose(p3fout);

	free(p3text);
 
	return 0;
}

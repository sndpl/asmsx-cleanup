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

/* anything between %{ and %} is included as-is. See http://flex.sourceforge.net/manual/Rules-Section.html */
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "asmsx.h"

#define P3TEXT_MAX	0x1000	/* 4 Kilobytes */

FILE *p3fout;
char *p3text;
%}

/* %s defines inclusive state? Need to look it up */
%s line
%s zilog

%%

<INITIAL>"#"line[ \t]*[0-9]+\n	{	/* line starts with #line ("#"line), then some white space ([ \t]*), then one or more decimal digits and ends with new line */
					strcat(p3text, yytext);	/* copy input line to output */
					BEGIN(line);		/* switch to "line" state */
				}

<INITIAL>\n			{	/* new line is the first character of input line - empty line? */
					fprintf(p3fout, "%s%s", p3text, yytext);	/* flush buffer to output file */
					p3text[0] = 0;					/* empty output buffer */
				}


<INITIAL>.			strcat(p3text, yytext);	/* line starts with any character except new line ('.'), copy it as is */

<line>.?zilog[ \t]*\n		{	/* conditional on "line" state, any character but new line (.?), then 'zilog', then zero or more white space and a new line */
					strcat(p3text, yytext);	/* copy to output as is */
					BEGIN(zilog);		/* switch to "zilog" state */
				}

<line>.				{	/* conditional on "line" state, look for any character except new line ('.') */
					strcat(p3text, yytext);	/* copy to output as is */
					BEGIN(INITIAL);		/* reset state to default */
				}

<zilog>\"[^\"\n]+\"		strcat(p3text, yytext);	/* starts with '"' (\"), then one or more characters that are not quotes or new lines ([^\"\n]+), ends with another '"' - copy as is */
<zilog>"("			strcat(p3text, "[");	/* replace '(' with '[' */
<zilog>")"			strcat(p3text, "]");	/* replace ')' with ']' */
<zilog>"["			strcat(p3text, "(");	/* replace '[' with '(' */
<zilog>"]"			strcat(p3text, ")");	/* replace ']' with ')' */
<zilog>.			strcat(p3text, yytext);	/* any other character, copy as is */

<zilog>\n			{	/* new line while in zilog state */
					fprintf(p3fout, "%s%s", p3text, yytext);	/* flush buffer to output file */
					p3text[0] = 0;					/* empty output buffer */
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

	yylex();	/* read from ~tmppre.0, process with yylex() and output to ~tmppre.1 */

	fclose(input);
	fclose(p3fout);

	free(p3text);
 
	return 0;
}

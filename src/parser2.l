/* Process REPT / ENDR macros.

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

#define P2TEXT_MAX	0x1000
#define P2BUF_MAX	0x4000

FILE *p2output;
char *p2text, *p2buf;
char p2nested = 0, p2level;
unsigned int p2no, p2lines, i;
extern void prompt_error2(int);
%}

%s rept
%s repnum
%s line
%s final

%%

<INITIAL>"#"line[ \t]*[0-9]+\n	{
					strcat(p2text, yytext);
					p2lines = atoi(&yytext[5]);
					BEGIN(line);
				}

<line>.?rept[ \t]+		BEGIN(repnum);

<line>.				{
					strcat(p2text, yytext);
					BEGIN(INITIAL);
				}

<repnum>[0-9]+[ \t]*		{
					p2no = atoi(yytext);
					p2buf[0] = 0;
					p2text[0] = 0;
					BEGIN(rept);
				}

<rept>.?rept[ \t]+[0-9]+[ \t]*	{
					strcat(p2buf, yytext);
					p2nested++;
					p2level++;
				}

<rept>"#"line[ \t]*[0-9]+\n[ \t]*.?endr[ \t]*\n	{
					if (p2nested)
					{
						p2nested--;
						strcat(p2buf, yytext);
					}
					else
					{
						for (i = 0; i < p2no; i++)
						fprintf(p2output, "%s", p2buf);
						p2buf[0] = 0;
						BEGIN(INITIAL);
					}
				}

<rept>.				strcat(p2text, yytext);	/* TODO: investigate! This was p2buf=strcat(p2text,yytext) in original */
<rept>\n			strcat(p2buf, yytext);
<rept><<EOF>>			{
					error_message(2);
					exit(2);
				}
<repnum>.			prompt_error2(1);

<INITIAL>\n			{
					fprintf(p2output, "%s%s", p2text, yytext);
					p2text[0] = 0;
				}

<INITIAL>.			strcat(p2text, yytext);

%%

void prompt_error2(int c)
{
	printf(", line %d: ", p2lines);
	switch (c)
	{
		case 1:
			printf("number expected in REPT");
			break;
		case 2:
			printf("REPT without ENDR");
			break;
	}
	fclose(p2output);
	exit(c);
}

int preprocessor2(void)
{
	FILE *input;
	char *filename, loop = 0;

	filename = (char*)malloc(ASMSX_MAX_PATH);
	if (!filename)
	{
		error_message(1);
		exit(1);
	}

	p2text = (char*)malloc(P2TEXT_MAX);
	if (!p2text)
	{
		error_message(1);
		exit(1);
	}

	p2buf = (char*)malloc(P2BUF_MAX);
	if (!p2buf)
	{
		error_message(1);
		exit(1);
	}

	p2text[0] = 0;

	printf("Expanding system macros\n");
	do
	{
		sprintf(filename, "~tmppre.%i", loop + 1);

		input = fopen(filename, "r");
		if (!input)
		{
			printf("Fatal: cannot process file\n");
			exit(1);
		}

		yyin = input;
		loop++;

		sprintf(filename, "~tmppre.%i", loop + 1);

		p2output = fopen(filename, "w");
		if (!p2output)
		{
			printf("Fatal: cannot create file %s\n", filename);
			exit(1);
		}
	
		p2level = 0;
		p2nested = 0;
		yylex();

		fclose(input);
		fclose(p2output);

	}
	while (p2level);

/*	free(filename);
	free(p2text);
	free(p2buf);*/

	return loop + 1;
}

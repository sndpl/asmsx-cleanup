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

/* anything between %{ and %} is included as-is */
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "asmsx.h"

#define P2TEXT_MAX	0x1000	/* 4 Kilobytes */
#define P2BUF_MAX	0x4000	/* 16 Kilobytes */

FILE *p2output;
char *p2text, *p2buf;
char p2nested = 0, p2level;
unsigned int p2no, p2lines, i;
extern void prompt_error2(int);
%}

/* %s defines inclusive state */
%s rept
%s repnum
%s line
%s final

%%

<INITIAL>"#"line[ \t]*[0-9]+\n	{	/* line starts with #line ("#"line), then some white space ([ \t]*), then one or more decimal digits and ends with new line */
					strcat(p2text, yytext);		/* add input to output buffer */
					p2lines = atoi(&yytext[5]);	/* what is &yytext[5]? */
					BEGIN(line);			/* start "line" state */
				}

<line>.?rept[ \t]+		BEGIN(repnum);	/* while in "line" state, encounter 0 or more of any character other then new line, "rept" verbatim, followed with white space */

<line>.				{	/* while in "line" state, any character other then new line */
					strcat(p2text, yytext);	/* is copied to output buffer */
					BEGIN(INITIAL);		/* then reset state to default */
				}

<repnum>[0-9]+[ \t]*		{	/* while in "repnum" state, any one or more digit, followed by optional white space */
					p2no = atoi(yytext);	/* convert string number to unsigned integer value */
					p2buf[0] = 0;		/* empty output buffer */
					p2text[0] = 0;		/* empty the other buffer */
					BEGIN(rept);		/* switch to "rept" state */
				}

<rept>.?rept[ \t]+[0-9]+[ \t]*	{
					strcat(p2buf, yytext);
					p2nested++;
					p2level++;
				}

<rept>"#"line[ \t]*[0-9]+\n[ \t]*.?endr[ \t]*\n	{
				/* line starts with #line ("#"line), followed by white space, followed by one or more digits, followed by new line
				followed by zero or one of any character other then new line, followed by endr, followed by zero or more white space,
				followed by new line */
					if (p2nested)	/* level of nesting, 1 to 15 */
					{
						p2nested--;		/* decrease nesting level */
						strcat(p2buf, yytext);	/* copy input to buffer */
					}
					else
					{	/* nesting level is 0 */
						for (i = 0; i < p2no; i++)
							fprintf(p2output, "%s", p2buf);	/* repeat p2buf content 'p2no' times */

						p2buf[0] = 0;	/* empty output buffer */
						BEGIN(INITIAL);	/* reset to default state */
					}
				}

<rept>.				{	/* any character in "rept" state */
					strcat(p2buf, yytext);	/* TODO: investigate! This was p2buf = strcat(p2text, yytext) in original */
				}

<rept>\n			{	/* new line while in "rept" state */
					strcat(p2buf, yytext);	/* copy verbatim */
				}

<rept><<EOF>>			{	/* reach end of file while "rept" block is unfinished */
					error_message(2);
					exit(2);
				}

<repnum>.			{	/* any character here means not a number after "repnum", numbers would be caught above */
					prompt_error2(1);
				}

<INITIAL>\n			{	/* new line in default state */
					fprintf(p2output, "%s%s", p2text, yytext);	/* flush buffer to output file */
					p2text[0] = 0;					/* reset buffer */
				}

<INITIAL>.			{	/* any character other then new line while in default state */
					strcat(p2text, yytext);	/* copy verbatim */
				}

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

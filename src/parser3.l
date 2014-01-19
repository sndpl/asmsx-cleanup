/*
	PARSER-3
	(c) Eduardo Robsy Petrus, 2010

	Functions:
		1. Identify ZILOG macro
		2. Set accordingly indirection and mathematical style 

*/

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

<zilog>\42[^\42\n]+\42		strcat(p3text, yytext);
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

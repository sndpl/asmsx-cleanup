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

#include "compat_s.h"	/* https://github.com/oboroc/compat_s/ */
#include "asmsx.h"

#define YY_NO_INPUT 1

#if ((_MSC_VER) || (__DMC__))
#define YY_NO_UNISTD_H 1
#endif

#define P3TEXT_MAX	0x1000

FILE *p3fout;
char *p3text;
%}

%s line
%s zilog

%%

<INITIAL>"#"line[ \t]*[0-9]+\n	strcat_s(p3text, P3TEXT_MAX, yytext); BEGIN(line);
<INITIAL>\n			fprintf_s(p3fout, "%s%s", p3text, yytext); p3text[0] = 0;
<INITIAL>.			strcat_s(p3text, P3TEXT_MAX, yytext);
<line>.?zilog[ \t]*\n		strcat_s(p3text, P3TEXT_MAX, yytext); BEGIN(zilog);
<line>.				strcat_s(p3text, P3TEXT_MAX, yytext); BEGIN(INITIAL);
<zilog>\42[^\42\n]+\42		strcat_s(p3text, P3TEXT_MAX, yytext);
<zilog>"("			strcat_s(p3text, P3TEXT_MAX, "[");
<zilog>")"			strcat_s(p3text, P3TEXT_MAX, "]");
<zilog>"["			strcat_s(p3text, P3TEXT_MAX, "(");
<zilog>"]"			strcat_s(p3text, P3TEXT_MAX, ")");
<zilog>.			strcat_s(p3text, P3TEXT_MAX, yytext);
<zilog>\n			fprintf_s(p3fout, "%s%s", p3text, yytext); p3text[0] = 0;

%%

int preprocessor3(void)
{
	FILE *input;

	p3text = (char*)malloc(P3TEXT_MAX);
	p3text[0] = 0;

	if (0 != fopen_s(&input, "~tmppre.0", "r"))
	{
		printf_s("Fatal: cannot process file\n");
		exit(1);
	}

	yyin = input;
 
	if (0 != fopen_s(&p3fout, "~tmppre.1", "w"))
	{
		printf_s("Fatal: cannot create temporary file in preprocessor3()\n");
		exit(1);
	}

	yylex();

	fclose(input);
	fclose(p3fout);

	free(p3text);
 
	return 0;
}

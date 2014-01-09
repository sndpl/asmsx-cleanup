/*
	PARSER-3
	(c) Eduardo Robsy Petrus, 2010

	Functions:
		1.-Identify ZILOG macro
		2.-Set accordingly indirection and mathematical style 
		
*/

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "compat.h"
#include "asmsx.h"

#define YY_NO_INPUT 1
#ifdef _MSC_VER
#define YY_NO_UNISTD_H 1
#endif


FILE *output;
char *text;
%}

%option yylineno
%option nounput

%s line
%s zilog

%%

<INITIAL>"#"line[ \t]*[0-9]+\n strcat(text,yytext);BEGIN(line);
<INITIAL>\n   fprintf_s(output,"%s%s",text,yytext);text[0]=0;
<INITIAL>.    strcat(text,yytext);
<line>.?zilog[ \t]*\n strcat(text,yytext);BEGIN(zilog);
<line>. strcat(text,yytext);BEGIN(INITIAL);
<zilog>\42[^\42\n]+\42 strcat(text,yytext);
<zilog>"(" strcat(text,"[");
<zilog>")" strcat(text,"]");
<zilog>"[" strcat(text,"(");
<zilog>"]" strcat(text,")");
<zilog>. strcat(text,yytext);
<zilog>\n fprintf_s(output,"%s%s",text,yytext);text[0]=0;

%%

int yywrap(void)
{
 return 1;
}

int preprocessor3(void)
{
 FILE *input;

 text=(char*)malloc(0x1000);
 text[0]=0;

 if ((input=fopen("~tmppre.0","r"))==NULL)
 {
  printf_s("Fatal: cannot process file");
  exit(1);
 }

 yyin=input;
 
 output=fopen("~tmppre.1","w");

 yylex();

 fclose(input);
 fclose(output);

 free(text);
 
 return 0;
}


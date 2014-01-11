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

FILE *p3fout;
char *p3text;
%}

%option yylineno
%option nounput

%s line
%s zilog

%%

<INITIAL>"#"line[ \t]*[0-9]+\n strcat(p3text,yytext);BEGIN(line);
<INITIAL>\n   fprintf_s(p3fout,"%s%s",p3text,yytext);p3text[0]=0;
<INITIAL>.    strcat(p3text,yytext);
<line>.?zilog[ \t]*\n strcat(p3text,yytext);BEGIN(zilog);
<line>. strcat(p3text,yytext);BEGIN(INITIAL);
<zilog>\42[^\42\n]+\42 strcat(p3text,yytext);
<zilog>"(" strcat(p3text,"[");
<zilog>")" strcat(p3text,"]");
<zilog>"[" strcat(p3text,"(");
<zilog>"]" strcat(p3text,")");
<zilog>. strcat(p3text,yytext);
<zilog>\n fprintf_s(p3fout,"%s%s",p3text,yytext);p3text[0]=0;

%%

int yywrap(void)
{
 return 1;
}

int preprocessor3(void)
{
 FILE *input;

 p3text=(char*)malloc(0x1000);
 p3text[0]=0;

 if ((input=fopen("~tmppre.0","r"))==NULL)
 {
  printf_s("Fatal: cannot process file");
  exit(1);
 }

 yyin=input;
 
 p3fout=fopen("~tmppre.1","w");

 yylex();

 fclose(input);
 fclose(p3fout);

 free(p3text);
 
 return 0;
}

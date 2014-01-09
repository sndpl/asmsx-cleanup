/*
	PARSER-2
	(c) Eduardo Robsy Petrus, 2000-2010

	Functions:
		1.-Unroll REPT/ENDR macro
		2.-Manage nested REPT/ENDR
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

FILE *p2output;
char *p2text, *p2buf, p2nested = 0, p2lvl;
unsigned int p2number, p2lines, i;
extern int prompt_error2(char);
%}

%option yylineno
%option nounput

%s rept
%s repnum
%s line
%s final

%%

<INITIAL>"#"line[ \t]*[0-9]+\n strcat(p2text,yytext);p2lines=atoi(&yytext[5]);BEGIN(line);
<line>.?rept[ \t]+ BEGIN(repnum);
<line>. strcat(p2text,yytext);BEGIN(INITIAL);
<repnum>[0-9]+[ \t]* {
             p2number=atoi(yytext);
             p2buf[0]=0;
             p2text[0]=0;
             BEGIN(rept); }
<rept>.?rept[ \t]+[0-9]+[ \t]* p2buf=strcat(p2buf,yytext);p2nested++;p2lvl++;
<rept>"#"line[ \t]*[0-9]+\n[ \t]*.?endr[ \t]*\n {
              if (p2nested)
               {
                p2nested--;
                p2buf=strcat(p2buf,yytext);
               } else
              {
               for (i=0;i<p2number;i++)
                fprintf_s(p2output,"%s",p2buf);
               p2buf[0]=0;
               BEGIN(INITIAL);
              }
             }
<rept>. p2buf=strcat(p2text,yytext);
<rept>\n   p2buf=strcat(p2buf,yytext);
<rept><<EOF>> error_message(2);
<repnum>.     prompt_error2(1);
<INITIAL>\n   fprintf_s(p2output,"%s%s",p2text,yytext);p2text[0]=0;
<INITIAL>.    strcat(p2text,yytext);

%%

int prompt_error2(char c)
{
 printf_s(", line %d: ", p2lines);
 switch (c)
 {
  case 1:printf_s("number expected in REPT");break;
  case 2:printf_s("REPT without ENDR");break;
 }
 fclose(p2output);
 exit(c);
 return 0;
}

int yywrap(void)
{
 return 1;
}

int preprocessor2(void)
{
 FILE *input;
 char *filename,loop=0;

 filename=(char*)malloc(ASMSX_MAX_PATH);
 p2text=(char*)malloc(0x1000);
 p2buf=(char*)malloc(0x4000);
 p2text[0]=0;

 printf_s("Expanding system macros\n");
 do
{
 sprintf_s(filename,"~tmppre.%i",loop+1);

 if ((input=fopen(filename,"r"))==NULL)
 {
  printf_s("Fatal: cannot process file");
  exit(1);
 }

 yyin=input;
 
 loop++;

 sprintf_s(filename,"~tmppre.%i",loop+1);

 p2output=fopen(filename,"w");
 p2lvl=0;
 p2nested=0;
 yylex();

 fclose(input);
 fclose(p2output);

} while (p2lvl);

// free(filename);
// free(p2text);
// free(p2buf);

 return loop+1;
}


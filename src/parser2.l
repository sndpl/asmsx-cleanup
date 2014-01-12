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

#include "compat_s.h"	/* https://github.com/oboroc/compat_s/ */
#include "asmsx.h"

#define YY_NO_INPUT 1
#ifdef _MSC_VER
#define YY_NO_UNISTD_H 1
#endif

#define P2TEXT_MAX	0x1000
#define P2BUF_MAX	0x4000

FILE *p2output;
char *p2text, *p2buf, p2nested = 0, p2level;
unsigned int p2no, p2lines, i;
extern int prompt_error2(int);
%}

%option yylineno
%option nounput

%s rept
%s repnum
%s line
%s final

%%

<INITIAL>"#"line[ \t]*[0-9]+\n strcat_s(p2text, P2TEXT_MAX, yytext);p2lines=atoi(&yytext[5]);BEGIN(line);
<line>.?rept[ \t]+ BEGIN(repnum);
<line>. strcat_s(p2text, P2TEXT_MAX, yytext);BEGIN(INITIAL);
<repnum>[0-9]+[ \t]* {
             p2no=atoi(yytext);
             p2buf[0]=0;
             p2text[0]=0;
             BEGIN(rept); }
<rept>.?rept[ \t]+[0-9]+[ \t]* strcat_s(p2buf, P2BUF_MAX, yytext);p2nested++;p2level++;
<rept>"#"line[ \t]*[0-9]+\n[ \t]*.?endr[ \t]*\n {
              if (p2nested)
               {
                p2nested--;
                strcat_s(p2buf, P2BUF_MAX, yytext);
               } else
              {
               for (i=0;i<p2no;i++)
                fprintf_s(p2output,"%s",p2buf);
               p2buf[0]=0;
               BEGIN(INITIAL);
              }
             }
<rept>. strcat_s(p2text, P2TEXT_MAX, yytext);/* TODO: investigate! This was p2buf=strcat(p2text,yytext) in original */
<rept>\n   strcat_s(p2buf, P2BUF_MAX, yytext);
<rept><<EOF>> error_message(2);
<repnum>.     prompt_error2(1);
<INITIAL>\n   fprintf_s(p2output,"%s%s",p2text,yytext);p2text[0]=0;
<INITIAL>.    strcat_s(p2text, P2TEXT_MAX, yytext);

%%

int prompt_error2(int c)
{
 printf_s(", line %d: ", p2lines);
 switch (c)
 {
  case 1:printf_s("number expected in REPT");break;
  case 2:printf_s("REPT without ENDR");break;
 }
 fclose(p2output);
 exit(c);
 return c;
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
 p2text=(char*)malloc(P2TEXT_MAX);
 p2buf=(char*)malloc(P2BUF_MAX);
 p2text[0]=0;

 printf_s("Expanding system macros\n");
 do
{
 sprintf_s(filename, ASMSX_MAX_PATH, "~tmppre.%i", loop + 1);

 if (0 != fopen_s(&input, filename, "r"))
 {
  printf_s("Fatal: cannot process file\n");
  exit(1);
 }

 yyin=input;
 
 loop++;

 sprintf_s(filename, ASMSX_MAX_PATH, "~tmppre.%i", loop + 1);

 if (0 != fopen_s(&p2output, filename, "w"))
 {
  printf_s("Fatal: cannot create file %s\n", filename);
  exit(1);
 }
	
 p2level=0;
 p2nested=0;
 yylex();

 fclose(input);
 fclose(p2output);

} while (p2level);

// free(filename);
// free(p2text);
// free(p2buf);

 return loop+1;
}


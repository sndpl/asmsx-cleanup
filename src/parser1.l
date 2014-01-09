/*
	PARSER-1
	(c) Eduardo Robsy Petrus, 2000-2010

	Functions:
		1.-Eliminate all comments
		2.-Eliminate blank lines
		3.-Eliminate duplicated spaces and tabulators
		4.-Include source file name and line numbers
		5.-Manage INCLUDE files nested up to 16 levels
		6.-Supports MS-DOS, Windows, Linux and Mac text source files
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
#define MAX_INCLUDE_LEVEL 16

char *p1text,*tmpstr,*p1name;
int p1i,p1incl_idx=0;
FILE *p1output_file,*input_file;
struct
{
	YY_BUFFER_STATE buffer;
	unsigned int line;
	char *name;
} include_stack[MAX_INCLUDE_LEVEL];

extern int prompt_error1(char);
%}

%option yylineno
%option nounput

%s comment
%s pascal_comment
%s chain
%s inclusion

%%

<INITIAL>\42[^\42]*\42 strcat(p1text,yytext);
<INITIAL>.?include/[ \042\t]+ tmpstr=NULL;BEGIN(inclusion);
<inclusion>[ \t]*      /* strip spaces */
<inclusion>[^ \t\n]+   tmpstr=strtok(yytext,"\42");
<inclusion>\n {
	if (tmpstr==NULL) prompt_error1(5);
	if (tmpstr[strlen(tmpstr)-1]<=32) prompt_error1(1);
	if (p1incl_idx>=MAX_INCLUDE_LEVEL) prompt_error1(2);
	for (p1i=0;p1i<p1incl_idx;p1i++)
		if (!strcmp(tmpstr,include_stack[p1i].name))
			prompt_error1(4);
	include_stack[p1incl_idx].name=(char*)malloc(ASMSX_MAX_PATH);
	strcpy(include_stack[p1incl_idx].name,p1name);
	include_stack[p1incl_idx].line=yylineno;
	include_stack[p1incl_idx++].buffer=YY_CURRENT_BUFFER;
	yyin=fopen(tmpstr,"r");
	if (!yyin) prompt_error1(3);
	printf_s("Including file %s\n",tmpstr);
	yylineno=1;
	strcpy(p1name,tmpstr);
	fprintf_s(p1output_file,"#file \042%s\042\n",p1name);
	yy_switch_to_buffer(yy_create_buffer(yyin,YY_BUF_SIZE));
	BEGIN(INITIAL);
	}

<<EOF>> {
	fclose(yyin);
	if (--p1incl_idx>=0)
	{
		yy_delete_buffer(YY_CURRENT_BUFFER);
		yy_switch_to_buffer(include_stack[p1incl_idx].buffer);
		yylineno=include_stack[p1incl_idx].line;
		strcpy(p1name,include_stack[p1incl_idx].name);
		fprintf_s(p1output_file,"#file \042%s\042\n",p1name);
		free(include_stack[p1incl_idx].name);
	}
	else
        {
		if (strlen(p1text)>0) fprintf_s(p1output_file,"#line %d\n%s\n",yylineno,p1text);
		fprintf_s(p1output_file,"%s",yytext);
		return 0;
	}
	}


<INITIAL>";"[^\n]*  /* Skip assembler-style comments */
<INITIAL>"//"[^\n]* /* Skip C/C++ single line comments */
<INITIAL>"--"[^\n]* /* Skip ADA-style comments */
<INITIAL>\15 /* Skip line feeds */

<INITIAL>"/*" BEGIN(comment); /* Skip C/C++ multiple line comments */
<comment>[^"*/"]* /* Skip all within */
<comment>"*/" BEGIN(INITIAL);

<INITIAL>"{" BEGIN(pascal_comment); /* Skip Pascal multiple line comments */
<pascal_comment>[^}]* /* Skip all within */
<pascal_comment>"}" BEGIN(INITIAL);

<INITIAL>\42 strcat(p1text,yytext);BEGIN(chain);
<chain>\42 strcat(p1text,yytext);BEGIN(INITIAL);
<chain>\n prompt_error1(1);
<chain>[^\42\n] strcat(p1text,yytext);

<INITIAL>[ \t]+ if (strlen(p1text)>0) strcat(p1text," "); // Should be 0 for Windows
<INITIAL>\n     { if (strlen(p1text)>0) fprintf_s(p1output_file,"#line %d\n%s\n",yylineno-1,p1text);  // Should be 0 for Windows?
         p1text[0]=0;
       }
<INITIAL>.      strcat(p1text,yytext);

%%
#define VERSION 

int prompt_error1(char c)
{
 printf_s("%s, line %d: ",p1name,yylineno-1);
 switch (c)
 {
  case 1:printf_s("Unterminated string");break;
  case 2:printf_s("Nested include level overflow");break;
  case 3:printf_s("Include file not found");break;
  case 4:printf_s("Recursive include");break;
  case 5:printf_s("Wrong file name");break;
 }
 fclose(p1output_file);
 exit(c);
 return 0;
}

int yywrap(void)
{
 return 1;
}

int preprocessor1(char *input_name)
{
// Memory allocation for strings
 char *tmpstr_;
 p1text=(char*)malloc(256);
 p1name=(char*)malloc(256);
 tmpstr=(char*)malloc(256);
 tmpstr_=tmpstr;

// Strings initialization
 p1text[0]=0;

// Get source code name
 strcpy(p1name,input_name);

// Open original source file
 if ((input_file=fopen(p1name,"r"))==NULL)
 {
  printf_s("Fatal: cannot open %s",input_name);
  exit(1);
 }

// Print parsing message
 printf_s("Parsing file %s\n",input_name);

// Create p1output_file file
 p1output_file=fopen("~tmppre.0","w");
 fprintf_s(p1output_file,"#file \042%s\042\n",p1name);
 
// Start lexical scanner
 yyin=input_file;
 yylex();
 
// Close p1output_file file
 fclose(p1output_file);

// Free string pointers
 free(p1text);
 free(p1name);
 free(tmpstr_);

// Done
 return 0;
}


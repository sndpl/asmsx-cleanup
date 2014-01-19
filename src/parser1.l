/*
	PARSER-1
	(c) Eduardo Robsy Petrus, 2000-2010

	Functions:
		1. Eliminate all comments
		2. Eliminate blank lines
		3. Eliminate duplicated spaces and tabulators
		4. Include source file name and line numbers
		5. Manage INCLUDE files nested up to 16 levels
		6. Supports MS-DOS, Windows, Linux and Mac text source files
*/

%option noyywrap yylineno nounput warn

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "asmsx.h"

char *p1text, *p1tmp, *p1name;
int p1i, p1incidx = 0;
FILE *p1fout, *p1fin;

struct
{
	YY_BUFFER_STATE buffer;
	unsigned int line;
	char *name;
} p1inc_stack[MAX_INCLUDE_LEVEL];

extern void prompt_error1(int);
%}

%s comment
%s pascal_comment
%s chain
%s inclusion

%%

<INITIAL>\42[^\42]*\42		strcat(p1text, yytext);
<INITIAL>.?include/[ \042\t]+	p1tmp = NULL; BEGIN(inclusion);
<inclusion>[ \t]*		/* strip spaces */
<inclusion>[^ \t\n]+		p1tmp = strtok(yytext, "\42");
<inclusion>\n			{
					if (NULL == p1tmp)
						prompt_error1(5);

					if (32 >= p1tmp[strlen(p1tmp) - 1])
						prompt_error1(1);

					if (MAX_INCLUDE_LEVEL <= p1incidx)
						prompt_error1(2);

					for (p1i = 0; p1i < p1incidx; p1i++)
						if (!strcmp(p1tmp, p1inc_stack[p1i].name))
							prompt_error1(4);

					p1inc_stack[p1incidx].name = (char*)malloc(ASMSX_MAX_PATH);
					strcpy(p1inc_stack[p1incidx].name, p1name);
					p1inc_stack[p1incidx].line = yylineno;
					p1inc_stack[p1incidx++].buffer = YY_CURRENT_BUFFER;

					yyin = fopen(p1tmp, "r");
					if (!yyin)
						prompt_error1(3);

					printf("Including file %s\n", p1tmp);
					yylineno = 1;
					strcpy(p1name, p1tmp);
					fprintf(p1fout, "#file \042%s\042\n", p1name);
					yy_switch_to_buffer(yy_create_buffer(yyin, YY_BUF_SIZE));
					BEGIN(INITIAL);
				}

<<EOF>>				{
					fclose(yyin);
					if (0 <= --p1incidx)
					{
						yy_delete_buffer(YY_CURRENT_BUFFER);
						yy_switch_to_buffer(p1inc_stack[p1incidx].buffer);
						yylineno = p1inc_stack[p1incidx].line;
						strcpy(p1name, p1inc_stack[p1incidx].name);
						fprintf(p1fout, "#file \042%s\042\n", p1name);
						free(p1inc_stack[p1incidx].name);
					}
					else
					{
						if (0 < strlen(p1text))
							fprintf(p1fout, "#line %d\n%s\n", yylineno, p1text);
						fprintf(p1fout, "%s", yytext);
						return 0;
					}
				}

<INITIAL>";"[^\n]*		/* Skip assembler-style comments */
<INITIAL>"//"[^\n]*		/* Skip C/C++ single line comments */
<INITIAL>"--"[^\n]*		/* Skip ADA-style comments */
<INITIAL>\15			/* Skip line feeds */

<INITIAL>"/*"			BEGIN(comment);	/* Skip C/C++ multiple line comments */
<comment>[^"*/"]*		/* Skip all within */
<comment>"*/"			BEGIN(INITIAL);

<INITIAL>"{"			BEGIN(pascal_comment); /* Skip Pascal multiple line comments */
<pascal_comment>[^}]*		/* Skip all within */
<pascal_comment>"}"		BEGIN(INITIAL);

<INITIAL>\42			strcat(p1text, yytext); BEGIN(chain);
<chain>\42			strcat(p1text, yytext); BEGIN(INITIAL);
<chain>\n			prompt_error1(1);
<chain>[^\42\n]			strcat(p1text, yytext);

<INITIAL>[ \t]+			{
					if (0 < strlen(p1text))
						strcat(p1text, " ");	/* Should be 0 for Windows */
				}
<INITIAL>\n			{
					if (0 < strlen(p1text))
						fprintf(p1fout, "#line %d\n%s\n", yylineno - 1, p1text);	/* Should be 0 for Windows? */
					p1text[0] = 0;
				}
<INITIAL>.			strcat(p1text, yytext);

%%

#define VERSION 

void prompt_error1(int c)
{
	printf("%s, line %d: ", p1name, yylineno - 1);
	switch (c)
	{
		case 1:
			printf("Unterminated string");
			break;
		case 2:
			printf("Nested include level overflow");
			break;
		case 3:
			printf("Include file not found");
			break;
		case 4:
			printf("Recursive include");
			break;
		case 5:
			printf("Wrong file name");
			break;
	}
	fclose(p1fout);
	exit(c);
}

int preprocessor1(char *input_name)
{
	/* Memory allocation for strings */
	p1text = (char*)malloc(ASMSX_MAX_PATH);
	p1name = (char*)malloc(ASMSX_MAX_PATH);
	p1tmp = (char*)malloc(ASMSX_MAX_PATH);

	/* Strings initialization */
	p1text[0] = 0;

	/* Get source code name */
	strcpy(p1name, input_name);

	/* Open original source file */
	p1fin = fopen(p1name, "r");
	if (!p1fin)
	{
		printf("Fatal: cannot open %s\n", input_name);
		exit(1);
	}

	/* Print parsing message */
	printf("Parsing file %s\n", input_name);

	/* Create p1fout file */
	p1fout = fopen("~tmppre.0", "w");
	if (!p1fout)
	{
		printf("Fatal: cannot create temp file in preprocessor1()\n");
		exit(1);
	}
	
	fprintf(p1fout, "#file \042%s\042\n", p1name);
 
	/* Start lexical scanner */
	yyin = p1fin;
	yylex();
 
	/* Close p1fout file */
	fclose(p1fout);

	/* Free string pointers */
	free(p1text);
	free(p1name);
	free(p1tmp);

	return 0;
}

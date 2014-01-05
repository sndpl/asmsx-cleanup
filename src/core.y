%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

#include "asmsx.h"
#include "wav.h"

#define MAX_ID 32000

unsigned char *memory, zilog = 0, pass = 1, size = 0, bios = 0, type = 0, parity;
int conditional[16], conditional_level = 0;
unsigned char *filename, *assembler, *binary, *symbols, *outputfname, *source, *original, cassette = 0, *intname;
unsigned int ePC = 0, PC = 0, subpage, pagesize, usedpage[256], lastpage, mapper, pageinit, addr_start = 0xffff, addr_end = 0x0000, start = 0, warnings = 0, lines;
unsigned int maxpage[4] = {32, 64, 256, 256};

unsigned char locate32[31] =
{
	0xCD, 0x38, 0x01, 0x0F, 0x0F, 0xE6, 0x03, 0x4F,
	0x21, 0xC1, 0xFC, 0x85, 0x6F, 0x7E, 0xE6, 0x80,
	0xB1, 0x4F, 0x2C, 0x2C, 0x2C, 0x2C, 0x7E, 0xE6,
	0x0C, 0xB1, 0x26, 0x80, 0xCD, 0x24, 0x00
};

int maximum = 0, last_global = 0;
FILE *foriginal, *fmessages, *foutput;

struct
{
	char *name;
	unsigned int value;
	unsigned char type;
	unsigned int page;
} id_list[MAX_ID];
%}

%union
{
	unsigned int val;
	double real;
	char *tex;
}

/* Main elements */

%left '+' '-' OP_OR OP_XOR
%left SHIFT_L SHIFT_R
%left '*' '/' '%' '&'
%left OP_OR_LOG OP_AND_LOG
%left NEGATIVE
%left NEGATION OP_NEG_LOG
%left OP_EQUAL OP_MINOR_EQUAL OP_MINOR OP_MAJOR OP_MAJOR_EQUAL OP_NON_EQUAL

%token <tex> APOSTROPHE
%token <tex> TEXT
%token <tex> IDENTIFICATOR
%token <tex> LOCAL_IDENTIFICATOR

%token <val> PREPRO_LINE
%token <val> PREPRO_FILE

%token <val> PSEUDO_CALLDOS
%token <val> PSEUDO_CALLBIOS
%token <val> PSEUDO_MSXDOS
%token <val> PSEUDO_PAGE
%token <val> PSEUDO_BASIC
%token <val> PSEUDO_ROM
%token <val> PSEUDO_MEGAROM
%token <val> PSEUDO_SINCLAIR
%token <val> PSEUDO_BIOS
%token <val> PSEUDO_ORG
%token <val> PSEUDO_START
%token <val> PSEUDO_END
%token <val> PSEUDO_DB
%token <val> PSEUDO_DW
%token <val> PSEUDO_DS
%token <val> PSEUDO_EQU
%token <val> PSEUDO_ASSIGN
%token <val> PSEUDO_INCBIN
%token <val> PSEUDO_SKIP
%token <val> PSEUDO_DEBUG
%token <val> PSEUDO_BREAK
%token <val> PSEUDO_PRINT
%token <val> PSEUDO_PRINTTEXT
%token <val> PSEUDO_PRINTHEX
%token <val> PSEUDO_PRINTFIX
%token <val> PSEUDO_SIZE
%token <val> PSEUDO_BYTE
%token <val> PSEUDO_WORD
%token <val> PSEUDO_RANDOM
%token <val> PSEUDO_PHASE
%token <val> PSEUDO_DEPHASE
%token <val> PSEUDO_SUBPAGE
%token <val> PSEUDO_SELECT
%token <val> PSEUDO_SEARCH
%token <val> PSEUDO_AT
%token <val> PSEUDO_ZILOG
%token <val> PSEUDO_FILENAME

%token <val> PSEUDO_FIXMUL
%token <val> PSEUDO_FIXDIV
%token <val> PSEUDO_INT
%token <val> PSEUDO_FIX
%token <val> PSEUDO_SIN
%token <val> PSEUDO_COS
%token <val> PSEUDO_TAN
%token <val> PSEUDO_SQRT
%token <val> PSEUDO_SQR
%token <real> PSEUDO_PI
%token <val> PSEUDO_ABS
%token <val> PSEUDO_ACOS
%token <val> PSEUDO_ASIN
%token <val> PSEUDO_ATAN
%token <val> PSEUDO_EXP
%token <val> PSEUDO_LOG
%token <val> PSEUDO_LN
%token <val> PSEUDO_POW

%token <val> PSEUDO_IF
%token <val> PSEUDO_IFDEF
%token <val> PSEUDO_ELSE
%token <val> PSEUDO_ENDIF

%token <val> PSEUDO_CASSETTE

%token <val> MNEMO_LD
%token <val> MNEMO_LD_SP
%token <val> MNEMO_PUSH
%token <val> MNEMO_POP
%token <val> MNEMO_EX
%token <val> MNEMO_EXX
%token <val> MNEMO_LDI 
%token <val> MNEMO_LDIR
%token <val> MNEMO_LDD 
%token <val> MNEMO_LDDR
%token <val> MNEMO_CPI 
%token <val> MNEMO_CPIR
%token <val> MNEMO_CPD 
%token <val> MNEMO_CPDR
%token <val> MNEMO_ADD
%token <val> MNEMO_ADC
%token <val> MNEMO_SUB
%token <val> MNEMO_SBC
%token <val> MNEMO_AND
%token <val> MNEMO_OR
%token <val> MNEMO_XOR
%token <val> MNEMO_CP
%token <val> MNEMO_INC
%token <val> MNEMO_DEC
%token <val> MNEMO_DAA
%token <val> MNEMO_CPL
%token <val> MNEMO_NEG
%token <val> MNEMO_CCF
%token <val> MNEMO_SCF
%token <val> MNEMO_NOP
%token <val> MNEMO_HALT
%token <val> MNEMO_DI
%token <val> MNEMO_EI
%token <val> MNEMO_IM
%token <val> MNEMO_RLCA
%token <val> MNEMO_RLA
%token <val> MNEMO_RRCA
%token <val> MNEMO_RRA
%token <val> MNEMO_RLC
%token <val> MNEMO_RL
%token <val> MNEMO_RRC
%token <val> MNEMO_RR
%token <val> MNEMO_SLA
%token <val> MNEMO_SLL
%token <val> MNEMO_SRA
%token <val> MNEMO_SRL
%token <val> MNEMO_RLD
%token <val> MNEMO_RRD
%token <val> MNEMO_BIT
%token <val> MNEMO_SET
%token <val> MNEMO_RES
%token <val> MNEMO_IN
%token <val> MNEMO_INI
%token <val> MNEMO_INIR
%token <val> MNEMO_IND
%token <val> MNEMO_INDR
%token <val> MNEMO_OUT
%token <val> MNEMO_OUTI
%token <val> MNEMO_OTIR
%token <val> MNEMO_OUTD
%token <val> MNEMO_OTDR
%token <val> MNEMO_JP
%token <val> MNEMO_JR
%token <val> MNEMO_DJNZ
%token <val> MNEMO_CALL
%token <val> MNEMO_RET
%token <val> MNEMO_RETI
%token <val> MNEMO_RETN
%token <val> MNEMO_RST
       
%token <val> REGISTER
%token <val> REGISTER_IX
%token <val> REGISTER_IY
%token <val> REGISTER_R
%token <val> REGISTER_I
%token <val> REGISTER_F
%token <val> REGISTER_AF
%token <val> REGISTER_IND_BC
%token <val> REGISTER_IND_DE
%token <val> REGISTER_IND_HL
%token <val> REGISTER_IND_SP
%token <val> REGISTER_16_IX
%token <val> REGISTER_16_IY
%token <val> REGISTER_PAR
%token <val> MULTI_MODE
%token <val> CONDITION

%token <val> NUMBER
%token <val> EOL

%token <real> REAL

%type <real> value_real
%type <val> value
%type <val> value_3bits
%type <val> value_8bits
%type <val> value_16bits
%type <val> rel_IX
%type <val> rel_IY

/* Grammar rules */

%%

entry: /*empty*/
	| entry line
;

line:	pseudo_instruction EOL
	| mnemo_load8bit EOL
	| mnemo_load16bit EOL
	| mnemo_exchange EOL
	| mnemo_arithm16bit EOL
	| mnemo_arithm8bit EOL
	| mnemo_general EOL
	| mnemo_rotate EOL
	| mnemo_bits EOL
	| mnemo_io EOL
	| mnemo_jump EOL
	| mnemo_call EOL
	| PREPRO_FILE TEXT EOL
	{
		strcpy(source, $2);
	}
	| PREPRO_LINE value EOL
	{
		lines=$2;
	}
	| label line
	| label EOL
;

label:	IDENTIFICATOR ':'
	{
		register_label(strtok($1, ":"));
	}
	| LOCAL_IDENTIFICATOR ':'
	{
		register_local(strtok($1, ":"));
	}
;

pseudo_instruction: PSEUDO_ORG value
	{
		if (conditional[conditional_level])
		{
			PC = $2;
			ePC=PC;
		}
	}
	| PSEUDO_PHASE value
	{
		if (conditional[conditional_level])
		{
			ePC=$2;
		}
	}
	| PSEUDO_DEPHASE
	{
		if (conditional[conditional_level])
			{
				ePC=PC;
			}
	}
	| PSEUDO_ROM
	{
		if (conditional[conditional_level])
		{
			type_rom();
		}
	}
	| PSEUDO_MEGAROM
	{
		if (conditional[conditional_level])
		{
			type_megarom(0);
		}
	}
	| PSEUDO_MEGAROM value
	{
		if (conditional[conditional_level])
		{
			type_megarom($2);
		}
	}
	| PSEUDO_BASIC
	{
		if (conditional[conditional_level])
		{
			type_basic();
		}
	}
	| PSEUDO_MSXDOS
	{
		if (conditional[conditional_level])
		{
			type_msxdos();
		}
	}
	| PSEUDO_SINCLAIR
	{
		if (conditional[conditional_level])
		{
			type_sinclair();
		}
	}
	| PSEUDO_BIOS
	{
		if (conditional[conditional_level])
		{
			if (!bios)
				msx_bios();
		}
	}
	| PSEUDO_PAGE value
	{
		if (conditional[conditional_level])
		{
			subpage = ASMSX_MAX_PATH;
			if ($2 > 3)
				error_message(22);
			else
			{
				PC = 0x4000 * $2;
				ePC = PC;
			}
		}
	}
	| PSEUDO_SEARCH
	{
		if (conditional[conditional_level])
		{
			if ((type != MEGAROM) && (type != ROM))
				error_message(41);
			locate_32k();
		}
	}
	| PSEUDO_SUBPAGE value PSEUDO_AT value
	{
		if (conditional[conditional_level])
		{
			if (type != MEGAROM)
				error_message(40);
			set_subpage($2, $4);
		}
	}
	| PSEUDO_SELECT value PSEUDO_AT value
	{
		if (conditional[conditional_level])
		{
			if (type != MEGAROM)
				error_message(40);
			select_page_direct($2, $4);
		}
	}
	| PSEUDO_SELECT REGISTER PSEUDO_AT value
	{
		if (conditional[conditional_level])
		{
			if (type != MEGAROM)
				error_message(40);
			select_page_register($2, $4);
		}
	}
	| PSEUDO_START value
	{
		if (conditional[conditional_level])
		{
			start=$2;
		}
	}
	| PSEUDO_CALLBIOS value
	{
		if (conditional[conditional_level])
		{
			write_byte(0xfd);
			write_byte(0x2a);
			write_word(0xfcc0);
			write_byte(0xdd);
			write_byte(0x21);
			write_word($2);
			write_byte(0xcd);
			write_word(0x001c);
		}
	}
	| PSEUDO_CALLDOS value
	{
		if (conditional[conditional_level])
		{
			if (type != MSXDOS)
				error_message(25);
			write_byte(0x0e);
			write_byte($2);
			write_byte(0xcd);
			write_word(0x0005);
		}
	}
	| PSEUDO_DB listing_8bits
	{
		;
	}
	| PSEUDO_DW listing_16bits
	{
		;
	}
	| PSEUDO_DS value_16bits
	{
		if (conditional[conditional_level])
		{
			if (addr_start > PC)
				addr_start = PC;
			PC += $2;
			ePC += $2;
			if (PC > 0xffff)
				error_message(1);
		}
	}
	| PSEUDO_BYTE
	{
		if (conditional[conditional_level])
		{
			PC++;
			ePC++;
		}
	}
	| PSEUDO_WORD
	{
		if (conditional[conditional_level])
		{
			PC+=2;
			ePC+=2;
		}
	}
	| IDENTIFICATOR PSEUDO_EQU value
	{
		if (conditional[conditional_level])
		{
			register_symbol(strtok($1, "="), $3, 2);
		}
	}
	| IDENTIFICATOR PSEUDO_ASSIGN value
	{
		if (conditional[conditional_level])
		{
			register_variable(strtok($1, "="), $3);
		}
	}
	| PSEUDO_INCBIN TEXT
	{
		if (conditional[conditional_level])
		{
			include_binary($2, 0, 0);
		}
	}
	| PSEUDO_INCBIN TEXT PSEUDO_SKIP value
	{
		if (conditional[conditional_level])
		{
			if ($4 <= 0)
				error_message(30);
			include_binary($2, $4, 0);
		}
	}
	| PSEUDO_INCBIN TEXT PSEUDO_SIZE value
	{
		if (conditional[conditional_level])
		{
			if ($4 <= 0)
				error_message(30);
			include_binary($2, 0, $4);
		}
	}
	| PSEUDO_INCBIN TEXT PSEUDO_SKIP value PSEUDO_SIZE value
	{
		if (conditional[conditional_level])
		{
			if (($4 <= 0) || ($6 <= 0))
				error_message(30);
			include_binary($2, $4, $6);
		}
	}
	| PSEUDO_INCBIN TEXT PSEUDO_SIZE value PSEUDO_SKIP value
	{
		if (conditional[conditional_level])
		{
			if (($4 <= 0) || ($6 <= 0))
				error_message(30);
			include_binary($2, $6, $4);
		}
	}
	| PSEUDO_END
	{
		if (pass == 3)
			finalize();
		PC = 0;
		ePC = 0;
		last_global = 0;
		type = 0;
		zilog = 0;
		if (conditional_level)
			error_message(45);
	}
	| PSEUDO_DEBUG TEXT
	{
		if (conditional[conditional_level])
		{
			write_byte(0x52);
			write_byte(0x18);
			write_byte(strlen($2) + 4);
			write_text($2);
		}
	}
	| PSEUDO_BREAK
	{
		if (conditional[conditional_level])
		{
			write_byte(0x40);
			write_byte(0x18);
			write_byte(0x00);
		}
	}
	| PSEUDO_BREAK value
	{
		if (conditional[conditional_level])
		{
			write_byte(0x40);
			write_byte(0x18);
			write_byte(0x02);
			write_word($2);
		}
	}
	| PSEUDO_PRINTTEXT TEXT
	{
		if (conditional[conditional_level])
		{
			if (pass == 2)
			{
				if (fmessages == NULL)
					output_text();
				fprintf(fmessages, "%s\n", $2);
			}
		}
	}
	| PSEUDO_PRINT value
	{
		if (conditional[conditional_level])
		{
			if (pass == 2)
			{
				if (fmessages == NULL)
					output_text();
				fprintf(fmessages, "%d\n", (short)$2 & 0xffff);
			}
		}
	}
	| PSEUDO_PRINT value_real
	{
		if (conditional[conditional_level])
		{
			if (pass == 2)
			{
				if (fmessages==NULL)
					output_text();
				fprintf(fmessages, "%.4f\n", $2);
			}
		}
	}
	| PSEUDO_PRINTHEX value
	{
		if (conditional[conditional_level])
		{
			if (pass == 2)
			{
				if (fmessages == NULL)
					output_text();
				fprintf(fmessages, "$%4.4x\n", (short)$2 & 0xffff);
			}
		}
	}
	| PSEUDO_PRINTFIX value
	{
		if (conditional[conditional_level])
		{
			if (pass == 2)
			{
				if (fmessages == NULL)
					output_text();
				fprintf(fmessages, "%.4f\n", ((float)($2 & 0xffff)) / 256);
			}
		}
	}
	| PSEUDO_SIZE value
	{
		if (conditional[conditional_level])
		{
			if (pass == 2)
			{
				if (size > 0)
					error_message(15);
				else
					size = $2;
			}
		}
	}
	| PSEUDO_IF value
	{
		if (conditional_level == 15)
			error_message(44);
		conditional_level++;
		if ($2)
			conditional[conditional_level] = 1 & conditional[conditional_level - 1];
		else
			conditional[conditional_level] = 0;
	}
	| PSEUDO_IFDEF IDENTIFICATOR
	{
		if (conditional_level == 15)
			error_message(44);
		conditional_level++;
		if (defined_symbol($2))
			conditional[conditional_level] = 1 & conditional[conditional_level - 1];
		else
			conditional[conditional_level] = 0;
	}
	| PSEUDO_ELSE
	{
		if (!conditional_level)
			error_message(42);
		conditional[conditional_level] = (conditional[conditional_level] ^ 1) & conditional[conditional_level - 1];
	}
	| PSEUDO_ENDIF
	{
		if (!conditional_level)
			error_message(43);
		conditional_level--;
	}
	| PSEUDO_CASSETTE TEXT
	{
		if (conditional[conditional_level])
		{
			if (!intname[0])
				strcpy(intname, $2);
			cassette |= $1;
		}
	}
	| PSEUDO_CASSETTE
	{
		if (conditional[conditional_level])
		{
			if (!intname[0])
			{
				strcpy(intname, binary);
				intname[strlen(intname) - 1] = 0;
			}
			cassette |= $1;
		}
	}
	| PSEUDO_ZILOG
	{
		zilog = 1;
	}
	| PSEUDO_FILENAME TEXT
	{
		strcpy(filename, $2);
	}
;

rel_IX: '[' REGISTER_16_IX ']'
	{
		$$ = 0;
	}
	| '[' REGISTER_16_IX '+' value_8bits ']'
	{
		$$ = $4;
	}
	| '[' REGISTER_16_IX '-' value_8bits ']'
	{
		$$ = -$4;
	}
;
	
rel_IY: '[' REGISTER_16_IY ']'
	{
		$$ = 0;
	}
	| '[' REGISTER_16_IY '+' value_8bits ']'
	{
		$$ = $4;
	}
	| '[' REGISTER_16_IY '-' value_8bits ']'
	{
		$$ = -$4;
	}
;
	
mnemo_load8bit: MNEMO_LD REGISTER ',' REGISTER {write_byte(0x40|($2<<3)|$4);}
              | MNEMO_LD REGISTER ',' REGISTER_IX {if (($2>3)&&($2!=7)) error_message(2);write_byte(0xdd);write_byte(0x40|($2<<3)|$4);}
              | MNEMO_LD REGISTER_IX ',' REGISTER {if (($4>3)&&($4!=7)) error_message(2);write_byte(0xdd);write_byte(0x40|($2<<3)|$4);}
              | MNEMO_LD REGISTER_IX ',' REGISTER_IX {write_byte(0xdd);write_byte(0x40|($2<<3)|$4);}
              | MNEMO_LD REGISTER ',' REGISTER_IY {if (($2>3)&&($2!=7)) error_message(2);write_byte(0xfd);write_byte(0x40|($2<<3)|$4);}
              | MNEMO_LD REGISTER_IY ',' REGISTER {if (($4>3)&&($4!=7)) error_message(2);write_byte(0xfd);write_byte(0x40|($2<<3)|$4);}
              | MNEMO_LD REGISTER_IY ',' REGISTER_IY {write_byte(0xfd);write_byte(0x40|($2<<3)|$4);}
              | MNEMO_LD REGISTER ',' value_8bits {write_byte(0x06|($2<<3));write_byte($4);}               
              | MNEMO_LD REGISTER_IX ',' value_8bits {write_byte(0xdd);write_byte(0x06|($2<<3));write_byte($4);}
              | MNEMO_LD REGISTER_IY ',' value_8bits {write_byte(0xfd);write_byte(0x06|($2<<3));write_byte($4);}
              | MNEMO_LD REGISTER ',' REGISTER_IND_HL {write_byte(0x46|($2<<3));}
              | MNEMO_LD REGISTER ',' rel_IX {write_byte(0xdd);write_byte(0x46|($2<<3));write_byte($4);}
              | MNEMO_LD REGISTER ',' rel_IY {write_byte(0xfd);write_byte(0x46|($2<<3));write_byte($4);}
              | MNEMO_LD REGISTER_IND_HL ',' REGISTER {write_byte(0x70|$4);}
              | MNEMO_LD rel_IX ',' REGISTER {write_byte(0xdd);write_byte(0x70|$4);write_byte($2);}
              | MNEMO_LD rel_IY ',' REGISTER {write_byte(0xfd);write_byte(0x70|$4);write_byte($2);}
              | MNEMO_LD REGISTER_IND_HL ',' value_8bits {write_byte(0x36);write_byte($4);}
              | MNEMO_LD rel_IX ',' value_8bits {write_byte(0xdd);write_byte(0x36);write_byte($2);write_byte($4);}
              | MNEMO_LD rel_IY ',' value_8bits {write_byte(0xfd);write_byte(0x36);write_byte($2);write_byte($4);}
              | MNEMO_LD REGISTER ',' REGISTER_IND_BC {if ($2!=7) error_message(4);write_byte(0x0a);}
              | MNEMO_LD REGISTER ',' REGISTER_IND_DE {if ($2!=7) error_message(4);write_byte(0x1a);}
              | MNEMO_LD REGISTER ',' '[' value_16bits ']' {if ($2!=7) error_message(4);write_byte(0x3a);write_word($5);}
              | MNEMO_LD REGISTER_IND_BC ',' REGISTER {if ($4!=7) error_message(5);write_byte(0x02);}
              | MNEMO_LD REGISTER_IND_DE ',' REGISTER {if ($4!=7) error_message(5);write_byte(0x12);}
              | MNEMO_LD '[' value_16bits ']' ',' REGISTER {if ($6!=7) error_message(5);write_byte(0x32);write_word($3);}
              | MNEMO_LD REGISTER ',' REGISTER_I {if ($2!=7) error_message(4);write_byte(0xed);write_byte(0x57);}
              | MNEMO_LD REGISTER ',' REGISTER_R {if ($2!=7) error_message(4);write_byte(0xed);write_byte(0x5f);}
              | MNEMO_LD REGISTER_I ',' REGISTER {if ($4!=7) error_message(5);write_byte(0xed);write_byte(0x47);}
              | MNEMO_LD REGISTER_R ',' REGISTER {if ($4!=7) error_message(5);write_byte(0xed);write_byte(0x4f);}
;

mnemo_load16bit: MNEMO_LD REGISTER_PAR ',' value_16bits {write_byte(0x01|($2<<4));write_word($4);}
               | MNEMO_LD REGISTER_16_IX ',' value_16bits {write_byte(0xdd);write_byte(0x21);write_word($4);}
               | MNEMO_LD REGISTER_16_IY ',' value_16bits {write_byte(0xfd);write_byte(0x21);write_word($4);}
               | MNEMO_LD REGISTER_PAR ',' '[' value_16bits ']' {if ($2!=2) {write_byte(0xed);write_byte(0x4b|($2<<4));} else write_byte(0x2a);write_word($5);}
               | MNEMO_LD REGISTER_16_IX ',' '[' value_16bits ']' {write_byte(0xdd);write_byte(0x2a);write_word($5);}
               | MNEMO_LD REGISTER_16_IY ',' '[' value_16bits ']' {write_byte(0xfd);write_byte(0x2a);write_word($5);}
               | MNEMO_LD '[' value_16bits ']' ',' REGISTER_PAR {if ($6!=2) {write_byte(0xed);write_byte(0x43|($6<<4));} else write_byte(0x22);write_word($3);}
               | MNEMO_LD '[' value_16bits ']' ',' REGISTER_16_IX {write_byte(0xdd);write_byte(0x22);write_word($3);}
               | MNEMO_LD '[' value_16bits ']' ',' REGISTER_16_IY {write_byte(0xfd);write_byte(0x22);write_word($3);}
               | MNEMO_LD_SP ',' '[' value_16bits ']' {write_byte(0xed);write_byte(0x7b);write_word($4);}
               | MNEMO_LD_SP ',' value_16bits {write_byte(0x31);write_word($3);}
               | MNEMO_LD_SP ',' REGISTER_PAR {if ($3!=2) error_message(2);write_byte(0xf9);}
               | MNEMO_LD_SP ',' REGISTER_16_IX {write_byte(0xdd);write_byte(0xf9);}
               | MNEMO_LD_SP ',' REGISTER_16_IY {write_byte(0xfd);write_byte(0xf9);}
               | MNEMO_PUSH REGISTER_PAR {if ($2==3) error_message(2);write_byte(0xc5|($2<<4));}
               | MNEMO_PUSH REGISTER_AF {write_byte(0xf5);}
               | MNEMO_PUSH REGISTER_16_IX {write_byte(0xdd);write_byte(0xe5);}
               | MNEMO_PUSH REGISTER_16_IY {write_byte(0xfd);write_byte(0xe5);}
               | MNEMO_POP REGISTER_PAR {if ($2==3) error_message(2);write_byte(0xc1|($2<<4));}
               | MNEMO_POP REGISTER_AF {write_byte(0xf1);}
               | MNEMO_POP REGISTER_16_IX {write_byte(0xdd);write_byte(0xe1);}
               | MNEMO_POP REGISTER_16_IY {write_byte(0xfd);write_byte(0xe1);}
;

mnemo_exchange: MNEMO_EX REGISTER_PAR ',' REGISTER_PAR {if ((($2!=1)||($4!=2))&&(($2!=2)||($4!=1))) error_message(2);if ((zilog)&&($2!=1)) warning_message(5);write_byte(0xeb);}
              | MNEMO_EX REGISTER_AF ',' REGISTER_AF APOSTROPHE {write_byte(0x08);}
              | MNEMO_EXX {write_byte(0xd9);}
              | MNEMO_EX REGISTER_IND_SP ',' REGISTER_PAR {if ($4!=2) error_message(2);write_byte(0xe3);}
              | MNEMO_EX REGISTER_IND_SP ',' REGISTER_16_IX {write_byte(0xdd);write_byte(0xe3);}
              | MNEMO_EX REGISTER_IND_SP ',' REGISTER_16_IY {write_byte(0xfd);write_byte(0xe3);}
              | MNEMO_LDI {write_byte(0xed);write_byte(0xa0);}
              | MNEMO_LDIR {write_byte(0xed);write_byte(0xb0);}
              | MNEMO_LDD {write_byte(0xed);write_byte(0xa8);}
              | MNEMO_LDDR {write_byte(0xed);write_byte(0xb8);}
              | MNEMO_CPI {write_byte(0xed);write_byte(0xa1);}
              | MNEMO_CPIR {write_byte(0xed);write_byte(0xb1);}
              | MNEMO_CPD {write_byte(0xed);write_byte(0xa9);}
              | MNEMO_CPDR {write_byte(0xed);write_byte(0xb9);}
;

mnemo_arithm8bit: MNEMO_ADD REGISTER ',' REGISTER {if ($2!=7) error_message(4);write_byte(0x80|$4);}
              | MNEMO_ADD REGISTER ',' REGISTER_IX {if ($2!=7) error_message(4);write_byte(0xdd);write_byte(0x80|$4);}
              | MNEMO_ADD REGISTER ',' REGISTER_IY {if ($2!=7) error_message(4);write_byte(0xfd);write_byte(0x80|$4);}
              | MNEMO_ADD REGISTER ',' value_8bits {if ($2!=7) error_message(4);write_byte(0xc6);write_byte($4);}
              | MNEMO_ADD REGISTER ',' REGISTER_IND_HL {if ($2!=7) error_message(4);write_byte(0x86);}
              | MNEMO_ADD REGISTER ',' rel_IX {if ($2!=7) error_message(4);write_byte(0xdd);write_byte(0x86);write_byte($4);}
              | MNEMO_ADD REGISTER ',' rel_IY {if ($2!=7) error_message(4);write_byte(0xfd);write_byte(0x86);write_byte($4);}
              | MNEMO_ADC REGISTER ',' REGISTER {if ($2!=7) error_message(4);write_byte(0x88|$4);}
              | MNEMO_ADC REGISTER ',' REGISTER_IX {if ($2!=7) error_message(4);write_byte(0xdd);write_byte(0x88|$4);}
              | MNEMO_ADC REGISTER ',' REGISTER_IY {if ($2!=7) error_message(4);write_byte(0xfd);write_byte(0x88|$4);}
              | MNEMO_ADC REGISTER ',' value_8bits {if ($2!=7) error_message(4);write_byte(0xce);write_byte($4);}
              | MNEMO_ADC REGISTER ',' REGISTER_IND_HL {if ($2!=7) error_message(4);write_byte(0x8e);}
              | MNEMO_ADC REGISTER ',' rel_IX {if ($2!=7) error_message(4);write_byte(0xdd);write_byte(0x8e);write_byte($4);}
              | MNEMO_ADC REGISTER ',' rel_IY {if ($2!=7) error_message(4);write_byte(0xfd);write_byte(0x8e);write_byte($4);}
              | MNEMO_SUB REGISTER ',' REGISTER {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0x90|$4);}
              | MNEMO_SUB REGISTER ',' REGISTER_IX {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0xdd);write_byte(0x90|$4);}
              | MNEMO_SUB REGISTER ',' REGISTER_IY {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0xfd);write_byte(0x90|$4);}
              | MNEMO_SUB REGISTER ',' value_8bits {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0xd6);write_byte($4);}
              | MNEMO_SUB REGISTER ',' REGISTER_IND_HL {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0x96);}
              | MNEMO_SUB REGISTER ',' rel_IX {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0xdd);write_byte(0x96);write_byte($4);}
              | MNEMO_SUB REGISTER ',' rel_IY {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0xfd);write_byte(0x96);write_byte($4);}
              | MNEMO_SBC REGISTER ',' REGISTER {if ($2!=7) error_message(4);write_byte(0x98|$4);}
              | MNEMO_SBC REGISTER ',' REGISTER_IX {if ($2!=7) error_message(4);write_byte(0xdd);write_byte(0x98|$4);}
              | MNEMO_SBC REGISTER ',' REGISTER_IY {if ($2!=7) error_message(4);write_byte(0xfd);write_byte(0x98|$4);}
              | MNEMO_SBC REGISTER ',' value_8bits {if ($2!=7) error_message(4);write_byte(0xde);write_byte($4);}
              | MNEMO_SBC REGISTER ',' REGISTER_IND_HL {if ($2!=7) error_message(4);write_byte(0x9e);}
              | MNEMO_SBC REGISTER ',' rel_IX {if ($2!=7) error_message(4);write_byte(0xdd);write_byte(0x9e);write_byte($4);}
              | MNEMO_SBC REGISTER ',' rel_IY {if ($2!=7) error_message(4);write_byte(0xfd);write_byte(0x9e);write_byte($4);}
              | MNEMO_AND REGISTER ',' REGISTER {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0xa0|$4);}
              | MNEMO_AND REGISTER ',' REGISTER_IX {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0xdd);write_byte(0xa0|$4);}
              | MNEMO_AND REGISTER ',' REGISTER_IY {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0xfd);write_byte(0xa0|$4);}
              | MNEMO_AND REGISTER ',' value_8bits {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0xe6);write_byte($4);}
              | MNEMO_AND REGISTER ',' REGISTER_IND_HL {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0xa6);}
              | MNEMO_AND REGISTER ',' rel_IX {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0xdd);write_byte(0xa6);write_byte($4);}
              | MNEMO_AND REGISTER ',' rel_IY {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0xfd);write_byte(0xa6);write_byte($4);}
              | MNEMO_OR REGISTER ',' REGISTER {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0xb0|$4);}
              | MNEMO_OR REGISTER ',' REGISTER_IX {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0xdd);write_byte(0xb0|$4);}
              | MNEMO_OR REGISTER ',' REGISTER_IY {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0xfd);write_byte(0xb0|$4);}
              | MNEMO_OR REGISTER ',' value_8bits {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0xf6);write_byte($4);}
              | MNEMO_OR REGISTER ',' REGISTER_IND_HL {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0xb6);}
              | MNEMO_OR REGISTER ',' rel_IX {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0xdd);write_byte(0xb6);write_byte($4);}
              | MNEMO_OR REGISTER ',' rel_IY {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0xfd);write_byte(0xb6);write_byte($4);}
              | MNEMO_XOR REGISTER ',' REGISTER {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0xa8|$4);}
              | MNEMO_XOR REGISTER ',' REGISTER_IX {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0xdd);write_byte(0xa8|$4);}
              | MNEMO_XOR REGISTER ',' REGISTER_IY {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0xfd);write_byte(0xa8|$4);}
              | MNEMO_XOR REGISTER ',' value_8bits {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0xee);write_byte($4);}
              | MNEMO_XOR REGISTER ',' REGISTER_IND_HL {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0xae);}
              | MNEMO_XOR REGISTER ',' rel_IX {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0xdd);write_byte(0xae);write_byte($4);}
              | MNEMO_XOR REGISTER ',' rel_IY {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0xfd);write_byte(0xae);write_byte($4);}
              | MNEMO_CP REGISTER ',' REGISTER {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0xb8|$4);}
              | MNEMO_CP REGISTER ',' REGISTER_IX {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0xdd);write_byte(0xb8|$4);}
              | MNEMO_CP REGISTER ',' REGISTER_IY {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0xfd);write_byte(0xb8|$4);}
              | MNEMO_CP REGISTER ',' value_8bits {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0xfe);write_byte($4);}
              | MNEMO_CP REGISTER ',' REGISTER_IND_HL {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0xbe);}
              | MNEMO_CP REGISTER ',' rel_IX {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0xdd);write_byte(0xbe);write_byte($4);}
              | MNEMO_CP REGISTER ',' rel_IY {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0xfd);write_byte(0xbe);write_byte($4);}
              | MNEMO_ADD REGISTER {if (zilog) warning_message(5);write_byte(0x80|$2);}
              | MNEMO_ADD REGISTER_IX {if (zilog) warning_message(5);write_byte(0xdd);write_byte(0x80|$2);}
              | MNEMO_ADD REGISTER_IY {if (zilog) warning_message(5);write_byte(0xfd);write_byte(0x80|$2);}
              | MNEMO_ADD value_8bits {if (zilog) warning_message(5);write_byte(0xc6);write_byte($2);}
              | MNEMO_ADD REGISTER_IND_HL {if (zilog) warning_message(5);write_byte(0x86);}
              | MNEMO_ADD rel_IX {if (zilog) warning_message(5);write_byte(0xdd);write_byte(0x86);write_byte($2);}
              | MNEMO_ADD rel_IY {if (zilog) warning_message(5);write_byte(0xfd);write_byte(0x86);write_byte($2);}
              | MNEMO_ADC REGISTER {if (zilog) warning_message(5);write_byte(0x88|$2);}
              | MNEMO_ADC REGISTER_IX {if (zilog) warning_message(5);write_byte(0xdd);write_byte(0x88|$2);}
              | MNEMO_ADC REGISTER_IY {if (zilog) warning_message(5);write_byte(0xfd);write_byte(0x88|$2);}
              | MNEMO_ADC value_8bits {if (zilog) warning_message(5);write_byte(0xce);write_byte($2);}
              | MNEMO_ADC REGISTER_IND_HL {if (zilog) warning_message(5);write_byte(0x8e);}
              | MNEMO_ADC rel_IX {if (zilog) warning_message(5);write_byte(0xdd);write_byte(0x8e);write_byte($2);}
              | MNEMO_ADC rel_IY {if (zilog) warning_message(5);write_byte(0xfd);write_byte(0x8e);write_byte($2);}
              | MNEMO_SUB REGISTER {write_byte(0x90|$2);}
              | MNEMO_SUB REGISTER_IX {write_byte(0xdd);write_byte(0x90|$2);}
              | MNEMO_SUB REGISTER_IY {write_byte(0xfd);write_byte(0x90|$2);}
              | MNEMO_SUB value_8bits {write_byte(0xd6);write_byte($2);}
              | MNEMO_SUB REGISTER_IND_HL {write_byte(0x96);}
              | MNEMO_SUB rel_IX {write_byte(0xdd);write_byte(0x96);write_byte($2);}
              | MNEMO_SUB rel_IY {write_byte(0xfd);write_byte(0x96);write_byte($2);}
              | MNEMO_SBC REGISTER {if (zilog) warning_message(5);write_byte(0x98|$2);}
              | MNEMO_SBC REGISTER_IX {if (zilog) warning_message(5);write_byte(0xdd);write_byte(0x98|$2);}
              | MNEMO_SBC REGISTER_IY {if (zilog) warning_message(5);write_byte(0xfd);write_byte(0x98|$2);}
              | MNEMO_SBC value_8bits {if (zilog) warning_message(5);write_byte(0xde);write_byte($2);}
              | MNEMO_SBC REGISTER_IND_HL {if (zilog) warning_message(5);write_byte(0x9e);}
              | MNEMO_SBC rel_IX {if (zilog) warning_message(5);write_byte(0xdd);write_byte(0x9e);write_byte($2);}
              | MNEMO_SBC rel_IY {if (zilog) warning_message(5);write_byte(0xfd);write_byte(0x9e);write_byte($2);}
              | MNEMO_AND REGISTER {write_byte(0xa0|$2);}
              | MNEMO_AND REGISTER_IX {write_byte(0xdd);write_byte(0xa0|$2);}
              | MNEMO_AND REGISTER_IY {write_byte(0xfd);write_byte(0xa0|$2);}
              | MNEMO_AND value_8bits {write_byte(0xe6);write_byte($2);}
              | MNEMO_AND REGISTER_IND_HL {write_byte(0xa6);}
              | MNEMO_AND rel_IX {write_byte(0xdd);write_byte(0xa6);write_byte($2);}
              | MNEMO_AND rel_IY {write_byte(0xfd);write_byte(0xa6);write_byte($2);}
              | MNEMO_OR REGISTER {write_byte(0xb0|$2);}
              | MNEMO_OR REGISTER_IX {write_byte(0xdd);write_byte(0xb0|$2);}
              | MNEMO_OR REGISTER_IY {write_byte(0xfd);write_byte(0xb0|$2);}
              | MNEMO_OR value_8bits {write_byte(0xf6);write_byte($2);}
              | MNEMO_OR REGISTER_IND_HL {write_byte(0xb6);}
              | MNEMO_OR rel_IX {write_byte(0xdd);write_byte(0xb6);write_byte($2);}
              | MNEMO_OR rel_IY {write_byte(0xfd);write_byte(0xb6);write_byte($2);}
              | MNEMO_XOR REGISTER {write_byte(0xa8|$2);}
              | MNEMO_XOR REGISTER_IX {write_byte(0xdd);write_byte(0xa8|$2);}
              | MNEMO_XOR REGISTER_IY {write_byte(0xfd);write_byte(0xa8|$2);}
              | MNEMO_XOR value_8bits {write_byte(0xee);write_byte($2);}
              | MNEMO_XOR REGISTER_IND_HL {write_byte(0xae);}
              | MNEMO_XOR rel_IX {write_byte(0xdd);write_byte(0xae);write_byte($2);}
              | MNEMO_XOR rel_IY {write_byte(0xfd);write_byte(0xae);write_byte($2);}
              | MNEMO_CP REGISTER {write_byte(0xb8|$2);}
              | MNEMO_CP REGISTER_IX {write_byte(0xdd);write_byte(0xb8|$2);}
              | MNEMO_CP REGISTER_IY {write_byte(0xfd);write_byte(0xb8|$2);}
              | MNEMO_CP value_8bits {write_byte(0xfe);write_byte($2);}
              | MNEMO_CP REGISTER_IND_HL {write_byte(0xbe);}
              | MNEMO_CP rel_IX {write_byte(0xdd);write_byte(0xbe);write_byte($2);}
              | MNEMO_CP rel_IY {write_byte(0xfd);write_byte(0xbe);write_byte($2);}
              | MNEMO_INC REGISTER {write_byte(0x04|($2<<3));}
              | MNEMO_INC REGISTER_IX {write_byte(0xdd);write_byte(0x04|($2<<3));}
              | MNEMO_INC REGISTER_IY {write_byte(0xfd);write_byte(0x04|($2<<3));}
              | MNEMO_INC REGISTER_IND_HL {write_byte(0x34);}
              | MNEMO_INC rel_IX {write_byte(0xdd);write_byte(0x34);write_byte($2);}
              | MNEMO_INC rel_IY {write_byte(0xfd);write_byte(0x34);write_byte($2);}
              | MNEMO_DEC REGISTER {write_byte(0x05|($2<<3));}
              | MNEMO_DEC REGISTER_IX {write_byte(0xdd);write_byte(0x05|($2<<3));}
              | MNEMO_DEC REGISTER_IY {write_byte(0xfd);write_byte(0x05|($2<<3));}
              | MNEMO_DEC REGISTER_IND_HL {write_byte(0x35);}
              | MNEMO_DEC rel_IX {write_byte(0xdd);write_byte(0x35);write_byte($2);}
              | MNEMO_DEC rel_IY {write_byte(0xfd);write_byte(0x35);write_byte($2);}
;

mnemo_arithm16bit: MNEMO_ADD REGISTER_PAR ',' REGISTER_PAR {if ($2!=2) error_message(2);write_byte(0x09|($4<<4));}
               | MNEMO_ADC REGISTER_PAR ',' REGISTER_PAR {if ($2!=2) error_message(2);write_byte(0xed);write_byte(0x4a|($4<<4));}
               | MNEMO_SBC REGISTER_PAR ',' REGISTER_PAR {if ($2!=2) error_message(2);write_byte(0xed);write_byte(0x42|($4<<4));}
               | MNEMO_ADD REGISTER_16_IX ',' REGISTER_PAR {if ($4==2) error_message(2);write_byte(0xdd);write_byte(0x09|($4<<4));}
               | MNEMO_ADD REGISTER_16_IX ',' REGISTER_16_IX {write_byte(0xdd);write_byte(0x29);}
               | MNEMO_ADD REGISTER_16_IY ',' REGISTER_PAR {if ($4==2) error_message(2);write_byte(0xfd);write_byte(0x09|($4<<4));}
               | MNEMO_ADD REGISTER_16_IY ',' REGISTER_16_IY {write_byte(0xfd);write_byte(0x29);}
               | MNEMO_INC REGISTER_PAR {write_byte(0x03|($2<<4));}
               | MNEMO_INC REGISTER_16_IX {write_byte(0xdd);write_byte(0x23);}
               | MNEMO_INC REGISTER_16_IY {write_byte(0xfd);write_byte(0x23);}
               | MNEMO_DEC REGISTER_PAR {write_byte(0x0b|($2<<4));}
               | MNEMO_DEC REGISTER_16_IX {write_byte(0xdd);write_byte(0x2b);}
               | MNEMO_DEC REGISTER_16_IY {write_byte(0xfd);write_byte(0x2b);}
;

mnemo_general: MNEMO_DAA {write_byte(0x27);}
             | MNEMO_CPL {write_byte(0x2f);}
             | MNEMO_NEG {write_byte(0xed);write_byte(0x44);}
             | MNEMO_CCF {write_byte(0x3f);}
             | MNEMO_SCF {write_byte(0x37);}
             | MNEMO_NOP {write_byte(0x00);}
             | MNEMO_HALT {write_byte(0x76);}
             | MNEMO_DI {write_byte(0xf3);}
             | MNEMO_EI {write_byte(0xfb);}
             | MNEMO_IM value_8bits {if (($2<0)||($2>2)) error_message(3); write_byte(0xed); if ($2==0) write_byte(0x46); else if ($2==1) write_byte(0x56); else write_byte(0x5e);}
;

mnemo_rotate: MNEMO_RLCA {write_byte(0x07);}
            | MNEMO_RLA {write_byte(0x17);}
            | MNEMO_RRCA {write_byte(0x0f);}
            | MNEMO_RRA {write_byte(0x1f);}
            | MNEMO_RLC REGISTER {write_byte(0xcb);write_byte($2);}
            | MNEMO_RLC REGISTER_IND_HL {write_byte(0xcb);write_byte(0x06);}

            | MNEMO_RLC rel_IX ',' REGISTER {if ($4==6) error_message(2);write_byte(0xdd);write_byte(0xcb);write_byte($2);write_byte($4);}
            | MNEMO_RLC rel_IY ',' REGISTER {if ($4==6) error_message(2);write_byte(0xfd);write_byte(0xcb);write_byte($2);write_byte($4);}
            | MNEMO_RLC rel_IX {write_byte(0xdd);write_byte(0xcb);write_byte($2);write_byte(0x06);}
            | MNEMO_RLC rel_IY {write_byte(0xfd);write_byte(0xcb);write_byte($2);write_byte(0x06);}
            | MNEMO_LD REGISTER ',' MNEMO_RLC rel_IX {write_byte(0xdd);write_byte(0xcb);write_byte($5);write_byte($2);}
            | MNEMO_LD REGISTER ',' MNEMO_RLC rel_IY {write_byte(0xfd);write_byte(0xcb);write_byte($5);write_byte($2);}
            | MNEMO_RL REGISTER {write_byte(0xcb);write_byte(0x10|$2);}
            | MNEMO_RL REGISTER_IND_HL {write_byte(0xcb);write_byte(0x16);}

            | MNEMO_RL rel_IX ',' REGISTER {if ($4==6) error_message(2);write_byte(0xdd);write_byte(0xcb);write_byte($2);write_byte($4 | 0x10);}
            | MNEMO_RL rel_IY ',' REGISTER {if ($4==6) error_message(2);write_byte(0xfd);write_byte(0xcb);write_byte($2);write_byte($4 | 0x10);}

            | MNEMO_RL rel_IX {write_byte(0xdd);write_byte(0xcb);write_byte($2);write_byte(0x16);}
            | MNEMO_RL rel_IY {write_byte(0xfd);write_byte(0xcb);write_byte($2);write_byte(0x16);}

            | MNEMO_LD REGISTER ',' MNEMO_RL rel_IX {write_byte(0xdd);write_byte(0xcb);write_byte($5);write_byte(0x10|$2);}
            | MNEMO_LD REGISTER ',' MNEMO_RL rel_IY {write_byte(0xfd);write_byte(0xcb);write_byte($5);write_byte(0x10|$2);}

            | MNEMO_RRC REGISTER {write_byte(0xcb);write_byte(0x08|$2);}
            | MNEMO_RRC REGISTER_IND_HL {write_byte(0xcb);write_byte(0x0e);}

            | MNEMO_RRC rel_IX ',' REGISTER {if ($4==6) error_message(2);write_byte(0xdd);write_byte(0xcb);write_byte($2);write_byte($4 | 0x08);}
            | MNEMO_RRC rel_IY ',' REGISTER {if ($4==6) error_message(2);write_byte(0xfd);write_byte(0xcb);write_byte($2);write_byte($4 | 0x08);}

            | MNEMO_RRC rel_IX {write_byte(0xdd);write_byte(0xcb);write_byte($2);write_byte(0x0e);}
            | MNEMO_RRC rel_IY {write_byte(0xfd);write_byte(0xcb);write_byte($2);write_byte(0x0e);}

            | MNEMO_LD REGISTER ',' MNEMO_RRC rel_IX {write_byte(0xdd);write_byte(0xcb);write_byte($5);write_byte(0x08|$2);}
            | MNEMO_LD REGISTER ',' MNEMO_RRC rel_IY {write_byte(0xfd);write_byte(0xcb);write_byte($5);write_byte(0x08|$2);}

            | MNEMO_RR REGISTER {write_byte(0xcb);write_byte(0x18|$2);}
            | MNEMO_RR REGISTER_IND_HL {write_byte(0xcb);write_byte(0x1e);}

            | MNEMO_RR rel_IX ',' REGISTER {if ($4==6) error_message(2);write_byte(0xdd);write_byte(0xcb);write_byte($2);write_byte($4 | 0x18);}
            | MNEMO_RR rel_IY ',' REGISTER {if ($4==6) error_message(2);write_byte(0xfd);write_byte(0xcb);write_byte($2);write_byte($4 | 0x18);}

            | MNEMO_RR rel_IX {write_byte(0xdd);write_byte(0xcb);write_byte($2);write_byte(0x1e);}
            | MNEMO_RR rel_IY {write_byte(0xfd);write_byte(0xcb);write_byte($2);write_byte(0x1e);}

            | MNEMO_LD REGISTER ',' MNEMO_RR rel_IX {write_byte(0xdd);write_byte(0xcb);write_byte($5);write_byte(0x18|$2);}
            | MNEMO_LD REGISTER ',' MNEMO_RR rel_IY {write_byte(0xfd);write_byte(0xcb);write_byte($5);write_byte(0x18|$2);}

            | MNEMO_SLA REGISTER {write_byte(0xcb);write_byte(0x20|$2);}
            | MNEMO_SLA REGISTER_IND_HL {write_byte(0xcb);write_byte(0x26);}

            | MNEMO_SLA rel_IX ',' REGISTER {if ($4==6) error_message(2);write_byte(0xdd);write_byte(0xcb);write_byte($2);write_byte($4 | 0x20);}
            | MNEMO_SLA rel_IY ',' REGISTER {if ($4==6) error_message(2);write_byte(0xfd);write_byte(0xcb);write_byte($2);write_byte($4 | 0x20);}

            | MNEMO_SLA rel_IX {write_byte(0xdd);write_byte(0xcb);write_byte($2);write_byte(0x26);}
            | MNEMO_SLA rel_IY {write_byte(0xfd);write_byte(0xcb);write_byte($2);write_byte(0x26);}

            | MNEMO_LD REGISTER ',' MNEMO_SLA rel_IX {write_byte(0xdd);write_byte(0xcb);write_byte($5);write_byte(0x20|$2);}
            | MNEMO_LD REGISTER ',' MNEMO_SLA rel_IY {write_byte(0xfd);write_byte(0xcb);write_byte($5);write_byte(0x20|$2);}

            | MNEMO_SLL REGISTER {write_byte(0xcb);write_byte(0x30|$2);}
            | MNEMO_SLL REGISTER_IND_HL {write_byte(0xcb);write_byte(0x36);}

            | MNEMO_SLL rel_IX ',' REGISTER {if ($4==6) error_message(2);write_byte(0xdd);write_byte(0xcb);write_byte($2);write_byte($4 | 0x30);}
            | MNEMO_SLL rel_IY ',' REGISTER {if ($4==6) error_message(2);write_byte(0xfd);write_byte(0xcb);write_byte($2);write_byte($4 | 0x30);}

            | MNEMO_SLL rel_IX {write_byte(0xdd);write_byte(0xcb);write_byte($2);write_byte(0x36);}
            | MNEMO_SLL rel_IY {write_byte(0xfd);write_byte(0xcb);write_byte($2);write_byte(0x36);}

            | MNEMO_LD REGISTER ',' MNEMO_SLL rel_IX {write_byte(0xdd);write_byte(0xcb);write_byte($5);write_byte(0x30|$2);}
            | MNEMO_LD REGISTER ',' MNEMO_SLL rel_IY {write_byte(0xfd);write_byte(0xcb);write_byte($5);write_byte(0x30|$2);}

            | MNEMO_SRA REGISTER {write_byte(0xcb);write_byte(0x28|$2);}
            | MNEMO_SRA REGISTER_IND_HL {write_byte(0xcb);write_byte(0x2e);}

            | MNEMO_SRA rel_IX ',' REGISTER {if ($4==6) error_message(2);write_byte(0xdd);write_byte(0xcb);write_byte($2);write_byte($4 | 0x28);}
            | MNEMO_SRA rel_IY ',' REGISTER {if ($4==6) error_message(2);write_byte(0xfd);write_byte(0xcb);write_byte($2);write_byte($4 | 0x28);}

            | MNEMO_SRA rel_IX {write_byte(0xdd);write_byte(0xcb);write_byte($2);write_byte(0x2e);}
            | MNEMO_SRA rel_IY {write_byte(0xfd);write_byte(0xcb);write_byte($2);write_byte(0x2e);}

            | MNEMO_LD REGISTER ',' MNEMO_SRA rel_IX {write_byte(0xdd);write_byte(0xcb);write_byte($5);write_byte(0x28|$2);}
            | MNEMO_LD REGISTER ',' MNEMO_SRA rel_IY {write_byte(0xfd);write_byte(0xcb);write_byte($5);write_byte(0x28|$2);}

            | MNEMO_SRL REGISTER {write_byte(0xcb);write_byte(0x38|$2);}
            | MNEMO_SRL REGISTER_IND_HL {write_byte(0xcb);write_byte(0x3e);}

            | MNEMO_SRL rel_IX ',' REGISTER {if ($4==6) error_message(2);write_byte(0xdd);write_byte(0xcb);write_byte($2);write_byte($4 | 0x38);}
            | MNEMO_SRL rel_IY ',' REGISTER {if ($4==6) error_message(2);write_byte(0xfd);write_byte(0xcb);write_byte($2);write_byte($4 | 0x38);}

            | MNEMO_SRL rel_IX {write_byte(0xdd);write_byte(0xcb);write_byte($2);write_byte(0x3e);}
            | MNEMO_SRL rel_IY {write_byte(0xfd);write_byte(0xcb);write_byte($2);write_byte(0x3e);}

            | MNEMO_LD REGISTER ',' MNEMO_SRL rel_IX {write_byte(0xdd);write_byte(0xcb);write_byte($5);write_byte(0x38|$2);}
            | MNEMO_LD REGISTER ',' MNEMO_SRL rel_IY {write_byte(0xfd);write_byte(0xcb);write_byte($5);write_byte(0x38|$2);}

            | MNEMO_RLD {write_byte(0xed);write_byte(0x6f);}
            | MNEMO_RRD {write_byte(0xed);write_byte(0x67);}
;

mnemo_bits: MNEMO_BIT value_3bits ',' REGISTER {write_byte(0xcb);write_byte(0x40|($2<<3)|($4));}
          | MNEMO_BIT value_3bits ',' REGISTER_IND_HL {write_byte(0xcb);write_byte(0x46|($2<<3));}
          | MNEMO_BIT value_3bits ',' rel_IX {write_byte(0xdd);write_byte(0xcb);write_byte($4);write_byte(0x46|($2<<3));}
          | MNEMO_BIT value_3bits ',' rel_IY {write_byte(0xfd);write_byte(0xcb);write_byte($4);write_byte(0x46|($2<<3));}

          | MNEMO_SET value_3bits ',' REGISTER {write_byte(0xcb);write_byte(0xc0|($2<<3)|($4));}
          | MNEMO_SET value_3bits ',' REGISTER_IND_HL {write_byte(0xcb);write_byte(0xc6|($2<<3));}
          | MNEMO_SET value_3bits ',' rel_IX {write_byte(0xdd);write_byte(0xcb);write_byte($4);write_byte(0xc6|($2<<3));}
          | MNEMO_SET value_3bits ',' rel_IY {write_byte(0xfd);write_byte(0xcb);write_byte($4);write_byte(0xc6|($2<<3));}

          | MNEMO_SET value_3bits ',' rel_IX ',' REGISTER {if ($6==6) error_message(2);write_byte(0xdd);write_byte(0xcb);write_byte($4);write_byte(0xc0|($2<<3)|$6);}
          | MNEMO_SET value_3bits ',' rel_IY ',' REGISTER {if ($6==6) error_message(2);write_byte(0xfd);write_byte(0xcb);write_byte($4);write_byte(0xc0|($2<<3)|$6);}

          | MNEMO_LD REGISTER ',' MNEMO_SET value_3bits ',' rel_IX {write_byte(0xdd);write_byte(0xcb);write_byte($7);write_byte(0xc0|($5<<3)|$2);}
          | MNEMO_LD REGISTER ',' MNEMO_SET value_3bits ',' rel_IY {write_byte(0xfd);write_byte(0xcb);write_byte($7);write_byte(0xc0|($5<<3)|$2);}

          | MNEMO_RES value_3bits ',' REGISTER {write_byte(0xcb);write_byte(0x80|($2<<3)|($4));}
          | MNEMO_RES value_3bits ',' REGISTER_IND_HL {write_byte(0xcb);write_byte(0x86|($2<<3));}
          | MNEMO_RES value_3bits ',' rel_IX {write_byte(0xdd);write_byte(0xcb);write_byte($4);write_byte(0x86|($2<<3));}
          | MNEMO_RES value_3bits ',' rel_IY {write_byte(0xfd);write_byte(0xcb);write_byte($4);write_byte(0x86|($2<<3));}

          | MNEMO_RES value_3bits ',' rel_IX ',' REGISTER {if ($6==6) error_message(2);write_byte(0xdd);write_byte(0xcb);write_byte($4);write_byte(0x80|($2<<3)|$6);}
          | MNEMO_RES value_3bits ',' rel_IY ',' REGISTER {if ($6==6) error_message(2);write_byte(0xfd);write_byte(0xcb);write_byte($4);write_byte(0x80|($2<<3)|$6);}

          | MNEMO_LD REGISTER ',' MNEMO_RES value_3bits ',' rel_IX {write_byte(0xdd);write_byte(0xcb);write_byte($7);write_byte(0x80|($5<<3)|$2);}
          | MNEMO_LD REGISTER ',' MNEMO_RES value_3bits ',' rel_IY {write_byte(0xfd);write_byte(0xcb);write_byte($7);write_byte(0x80|($5<<3)|$2);}
;

mnemo_io: MNEMO_IN REGISTER ',' '[' value_8bits ']' {if ($2!=7) error_message(4);write_byte(0xdb);write_byte($5);}
        | MNEMO_IN REGISTER ',' value_8bits {if ($2!=7) error_message(4);if (zilog) warning_message(5);write_byte(0xdb);write_byte($4);}
        | MNEMO_IN REGISTER ',' '[' REGISTER ']' {if ($5!=1) error_message(2);write_byte(0xed);write_byte(0x40|($2<<3));}
        | MNEMO_IN '[' REGISTER ']'{if ($3!=1) error_message(2);if (zilog) warning_message(5);write_byte(0xed);write_byte(0x70);}
        | MNEMO_IN REGISTER_F ',' '[' REGISTER ']' {if ($5!=1) error_message(2);write_byte(0xed);write_byte(0x70);}
        | MNEMO_INI {write_byte(0xed);write_byte(0xa2);}
        | MNEMO_INIR {write_byte(0xed);write_byte(0xb2);}
        | MNEMO_IND {write_byte(0xed);write_byte(0xaa);}
        | MNEMO_INDR {write_byte(0xed);write_byte(0xba);}
        | MNEMO_OUT '[' value_8bits ']' ',' REGISTER {if ($6!=7) error_message(5);write_byte(0xd3);write_byte($3);}
        | MNEMO_OUT value_8bits ',' REGISTER {if ($4!=7) error_message(5);if (zilog) warning_message(5);write_byte(0xd3);write_byte($2);}
        | MNEMO_OUT '[' REGISTER ']' ',' REGISTER {if ($3!=1) error_message(2);write_byte(0xed);write_byte(0x41|($6<<3));}
        | MNEMO_OUT '[' REGISTER ']' ',' value_8bits {if ($3!=1) error_message(2);if ($6!=0) error_message(6);write_byte(0xed);write_byte(0x71);}
        | MNEMO_OUTI {write_byte(0xed);write_byte(0xa3);}
        | MNEMO_OTIR {write_byte(0xed);write_byte(0xb3);}
        | MNEMO_OUTD {write_byte(0xed);write_byte(0xab);}
        | MNEMO_OTDR {write_byte(0xed);write_byte(0xbb);}
        | MNEMO_IN '[' value_8bits ']' {if (zilog) warning_message(5);write_byte(0xdb);write_byte($3);}
        | MNEMO_IN value_8bits {if (zilog) warning_message(5);write_byte(0xdb);write_byte($2);}
        | MNEMO_OUT '[' value_8bits ']' {if (zilog) warning_message(5);write_byte(0xd3);write_byte($3);}
        | MNEMO_OUT value_8bits {if (zilog) warning_message(5);write_byte(0xd3);write_byte($2);}
;

mnemo_jump: MNEMO_JP value_16bits {write_byte(0xc3);write_word($2);}
          | MNEMO_JP CONDITION ',' value_16bits {write_byte(0xc2|($2<<3));write_word($4);}
          | MNEMO_JP REGISTER ',' value_16bits {if ($2!=1) error_message(7);write_byte(0xda);write_word($4);}
          | MNEMO_JR value_16bits {write_byte(0x18);conditional_jump($2);}
          | MNEMO_JR REGISTER ',' value_16bits {if ($2!=1) error_message(7);write_byte(0x38);conditional_jump($4);}
          | MNEMO_JR CONDITION ',' value_16bits {if ($2==2) write_byte(0x30); else if ($2==1) write_byte(0x28); else if ($2==0) write_byte(0x20); else error_message(9);conditional_jump($4);}
          | MNEMO_JP REGISTER_PAR {if ($2!=2) error_message(2);write_byte(0xe9);}
          | MNEMO_JP REGISTER_IND_HL {write_byte(0xe9);}
          | MNEMO_JP REGISTER_16_IX {write_byte(0xdd);write_byte(0xe9);}
          | MNEMO_JP REGISTER_16_IY {write_byte(0xfd);write_byte(0xe9);}
          | MNEMO_JP '[' REGISTER_16_IX ']' {write_byte(0xdd);write_byte(0xe9);}
          | MNEMO_JP '[' REGISTER_16_IY ']' {write_byte(0xfd);write_byte(0xe9);}
          | MNEMO_DJNZ value_16bits {write_byte(0x10);conditional_jump($2);}
;

mnemo_call: MNEMO_CALL value_16bits {write_byte(0xcd);write_word($2);}
          | MNEMO_CALL CONDITION ',' value_16bits {write_byte(0xc4|($2<<3));write_word($4);}
          | MNEMO_CALL REGISTER ',' value_16bits {if ($2!=1) error_message(7);write_byte(0xdc);write_word($4);}
          | MNEMO_RET {write_byte(0xc9);}
          | MNEMO_RET CONDITION {write_byte(0xc0|($2<<3));}
          | MNEMO_RET REGISTER {if ($2!=1) error_message(7);write_byte(0xd8);}
          | MNEMO_RETI {write_byte(0xed);write_byte(0x4d);}
          | MNEMO_RETN {write_byte(0xed);write_byte(0x45);}
          | MNEMO_RST value_8bits {if (($2%8!=0)||($2/8>7)||($2/8<0)) error_message(10);write_byte(0xc7|(($2/8)<<3));}
;

value: NUMBER {$$=$1;}
     | IDENTIFICATOR {$$=read_label($1);}
     | LOCAL_IDENTIFICATOR {$$=read_local($1);}
     | '-' value %prec NEGATIVE {$$=-$2;}
     | value OP_EQUAL value {$$=($1==$3);}
     | value OP_MINOR_EQUAL value {$$=($1<=$3);}
     | value OP_MINOR value {$$=($1<$3);}
     | value OP_MAJOR_EQUAL value {$$=($1>=$3);}
     | value OP_MAJOR value {$$=($1>$3);}
     | value OP_NON_EQUAL value {$$=($1!=$3);}
     | value OP_OR_LOG value {$$=($1||$3);}
     | value OP_AND_LOG value {$$=($1&&$3);}
     | value '+' value {$$=$1+$3;}
     | value '-' value {$$=$1-$3;}
     | value '*' value {$$=$1*$3;}
     | value '/' value {if (!$3) error_message(1); else $$=$1/$3;}
     | value '%' value {if (!$3) error_message(1); else $$=$1%$3;}
     | '(' value ')' {$$=$2;}
     | '~' value %prec NEGATION {$$=~$2;}
     | '!' value %prec OP_NEG_LOG {$$=!$2;}
     | value '&' value {$$=$1&$3;}
     | value OP_OR value {$$=$1|$3;}
     | value OP_XOR value {$$=$1^$3;}
     | value SHIFT_L value {$$=$1<<$3;}
     | value SHIFT_R value {$$=$1>>$3;}
     | PSEUDO_RANDOM '(' value ')' {for (;($$=rand()&0xff)>=$3;);}
     | PSEUDO_INT '(' value_real ')' {$$=(int)$3;}
     | PSEUDO_FIX '(' value_real ')' {$$=(int)($3*256);}
     | PSEUDO_FIXMUL '(' value ',' value ')' {$$=(int)((((float)$3/256)*((float)$5/256))*256);}
     | PSEUDO_FIXDIV '(' value ',' value ')' {$$=(int)((((float)$3/256)/((float)$5/256))*256);}
;

value_real: REAL {$$=$1;}
     | '-' value_real {$$=-$2;}
     | value_real '+' value_real {$$=$1+$3;}
     | value_real '-' value_real {$$=$1-$3;}
     | value_real '*' value_real {$$=$1*$3;}
     | value_real '/' value_real {if (!$3) error_message(1); else $$=$1/$3;}
     | value '+' value_real {$$=(double)$1+$3;}
     | value '-' value_real {$$=(double)$1-$3;}
     | value '*' value_real {$$=(double)$1*$3;}
     | value '/' value_real {if ($3<1e-6) error_message(1); else $$=(double)$1/$3;}
     | value_real '+' value {$$=$1+(double)$3;}
     | value_real '-' value {$$=$1-(double)$3;}
     | value_real '*' value {$$=$1*(double)$3;}
     | value_real '/' value {if (!$3) error_message(1); else $$=$1/(double)$3;}
     | PSEUDO_SIN '(' value_real ')' {$$=sin($3);}
     | PSEUDO_COS '(' value_real ')' {$$=cos($3);}
     | PSEUDO_TAN '(' value_real ')' {$$=tan($3);}
     | PSEUDO_SQR '(' value_real ')' {$$=$3*$3;}
     | PSEUDO_SQRT '(' value_real ')' {$$=sqrt($3);}
     | PSEUDO_PI {$$=asin(1)*2;}
     | PSEUDO_ABS '(' value_real ')' {$$=abs($3);}
     | PSEUDO_ACOS '(' value_real ')' {$$=acos($3);}
     | PSEUDO_ASIN '(' value_real ')' {$$=asin($3);}
     | PSEUDO_ATAN '(' value_real ')' {$$=atan($3);}
     | PSEUDO_EXP '(' value_real ')' {$$=exp($3);}
     | PSEUDO_LOG '(' value_real ')' {$$=log10($3);}
     | PSEUDO_LN '(' value_real ')' {$$=log($3);}
     | PSEUDO_POW '(' value_real ',' value_real ')' {$$=pow($3,$5);}
     | '(' value_real ')' {$$=$2;}
;

value_3bits: value {if (((int)$1<0)||((int)$1>7)) warning_message(3);$$=$1&0x07;}
;

value_8bits: value {if (((int)$1>255)||((int)$1<-128)) warning_message(2);$$=$1&0xff;}
;

value_16bits: value {if (((int)$1>65535)||((int)$1<-32768)) warning_message(1);$$=$1&0xffff;}
;

listing_8bits : value_8bits {write_byte($1);}
              | TEXT {write_text($1);}
              | listing_8bits ',' value_8bits {write_byte($3);}
              | listing_8bits ',' TEXT {write_text($3);}
;

listing_16bits : value_16bits {write_word($1);}
               | TEXT {write_text($1);}
               | listing_16bits ',' value_16bits {write_word($3);}
               | listing_16bits ',' TEXT {write_text($3);}
;

%%

/* Additional C functions */
void msx_bios(void)
{
 bios=1;
/* BIOS routines */
 register_symbol("CHKRAM",0x0000,0);
 register_symbol("SYNCHR",0x0008,0);
 register_symbol("RDSLT",0x000c,0);
 register_symbol("CHRGTR",0x0010,0);
 register_symbol("WRSLT",0x0014,0);
 register_symbol("OUTDO",0x0018,0);
 register_symbol("CALSLT",0x001c,0);
 register_symbol("DCOMPR",0x0020,0);
 register_symbol("ENASLT",0x0024,0);
 register_symbol("GETYPR",0x0028,0);
 register_symbol("CALLF",0x0030,0);
 register_symbol("KEYINT",0x0038,0);
 register_symbol("INITIO",0x003b,0);
 register_symbol("INIFNK",0x003e,0);
 register_symbol("DISSCR",0x0041,0);
 register_symbol("ENASCR",0x0044,0);
 register_symbol("WRTVDP",0x0047,0);
 register_symbol("RDVRM",0x004a,0);
 register_symbol("WRTVRM",0x004d,0);
 register_symbol("SETRD",0x0050,0);
 register_symbol("SETWRT",0x0053,0);
 register_symbol("FILVRM",0x0056,0);
 register_symbol("LDIRMV",0x0059,0);
 register_symbol("LDIRVM",0x005c,0);
 register_symbol("CHGMOD",0x005f,0);
 register_symbol("CHGCLR",0x0062,0);
 register_symbol("NMI",0x0066,0);
 register_symbol("CLRSPR",0x0069,0);
 register_symbol("INITXT",0x006c,0);
 register_symbol("INIT32",0x006f,0);
 register_symbol("INIGRP",0x0072,0);
 register_symbol("INIMLT",0x0075,0);
 register_symbol("SETTXT",0x0078,0);
 register_symbol("SETT32",0x007b,0);
 register_symbol("SETGRP",0x007e,0);
 register_symbol("SETMLT",0x0081,0);
 register_symbol("CALPAT",0x0084,0);
 register_symbol("CALATR",0x0087,0);
 register_symbol("GSPSIZ",0x008a,0);
 register_symbol("GRPPRT",0x008d,0);
 register_symbol("GICINI",0x0090,0);
 register_symbol("WRTPSG",0x0093,0);
 register_symbol("RDPSG",0x0096,0);
 register_symbol("STRTMS",0x0099,0);
 register_symbol("CHSNS",0x009c,0);
 register_symbol("CHGET",0x009f,0);
 register_symbol("CHPUT",0x00a2,0);
 register_symbol("LPTOUT",0x00a5,0);
 register_symbol("LPTSTT",0x00a8,0);
 register_symbol("CNVCHR",0x00ab,0);
 register_symbol("PINLIN",0x00ae,0);
 register_symbol("INLIN",0x00b1,0);
 register_symbol("QINLIN",0x00b4,0);
 register_symbol("BREAKX",0x00b7,0);
 register_symbol("ISCNTC",0x00ba,0);
 register_symbol("CKCNTC",0x00bd,0);
 register_symbol("BEEP",0x00c0,0);
 register_symbol("CLS",0x00c3,0);
 register_symbol("POSIT",0x00c6,0);
 register_symbol("FNKSB",0x00c9,0);
 register_symbol("ERAFNK",0x00cc,0);
 register_symbol("DSPFNK",0x00cf,0);
 register_symbol("TOTEXT",0x00d2,0);
 register_symbol("GTSTCK",0x00d5,0);
 register_symbol("GTTRIG",0x00d8,0);
 register_symbol("GTPAD",0x00db,0);
 register_symbol("GTPDL",0x00de,0);
 register_symbol("TAPION",0x00e1,0);
 register_symbol("TAPIN",0x00e4,0);
 register_symbol("TAPIOF",0x00e7,0);
 register_symbol("TAPOON",0x00ea,0);
 register_symbol("TAPOUT",0x00ed,0);
 register_symbol("TAPOOF",0x00f0,0);
 register_symbol("STMOTR",0x00f3,0);
 register_symbol("LFTQ",0x00f6,0);
 register_symbol("PUTQ",0x00f9,0);
 register_symbol("RIGHTC",0x00fc,0);
 register_symbol("LEFTC",0x00ff,0);
 register_symbol("UPC",0x0102,0);
 register_symbol("TUPC",0x0105,0);
 register_symbol("DOWNC",0x0108,0);
 register_symbol("TDOWNC",0x010b,0);
 register_symbol("SCALXY",0x010e,0);
 register_symbol("MAPXYC",0x0111,0);
 register_symbol("FETCHC",0x0114,0);
 register_symbol("STOREC",0x0117,0);
 register_symbol("SETATR",0x011a,0);
 register_symbol("READC",0x011d,0);
 register_symbol("SETC",0x0120,0);
 register_symbol("NSETCX",0x0123,0);
 register_symbol("GTASPC",0x0126,0);
 register_symbol("PNTINI",0x0129,0);
 register_symbol("SCANR",0x012c,0);
 register_symbol("SCANL",0x012f,0);
 register_symbol("CHGCAP",0x0132,0);
 register_symbol("CHGSND",0x0135,0);
 register_symbol("RSLREG",0x0138,0);
 register_symbol("WSLREG",0x013b,0);
 register_symbol("RDVDP",0x013e,0);
 register_symbol("SNSMAT",0x0141,0);
 register_symbol("PHYDIO",0x0144,0);
 register_symbol("FORMAT",0x0147,0);
 register_symbol("ISFLIO",0x014a,0);
 register_symbol("OUTDLP",0x014d,0);
 register_symbol("GETVCP",0x0150,0);
 register_symbol("GETVC2",0x0153,0);
 register_symbol("KILBUF",0x0156,0);
 register_symbol("CALBAS",0x0159,0);
 register_symbol("SUBROM",0x015c,0);
 register_symbol("EXTROM",0x015f,0);
 register_symbol("CHKSLZ",0x0162,0);
 register_symbol("CHKNEW",0x0165,0);
 register_symbol("EOL",0x0168,0);
 register_symbol("BIGFIL",0x016b,0);
 register_symbol("NSETRD",0x016e,0);
 register_symbol("NSTWRT",0x0171,0);
 register_symbol("NRDVRM",0x0174,0);
 register_symbol("NWRVRM",0x0177,0);
 register_symbol("RDBTST",0x017a,0);
 register_symbol("WRBTST",0x017d,0);
 register_symbol("CHGCPU",0x0180,0);
 register_symbol("GETCPU",0x0183,0);
 register_symbol("PCMPLY",0x0186,0);
 register_symbol("PCMREC",0x0189,0);
}

void error_message(int code)
{
 printf("%s, line %d: ",strtok(source,"\042"),lines);
 switch (code)
 {
  case 0: printf("syntax error\n");break;
  case 1: printf("memory overflow\n");break;
  case 2: printf("wrong register combination\n");break;
  case 3: printf("wrong interruption mode\n");break;
  case 4: printf("destination register should be A\n");break;
  case 5: printf("source register should be A\n");break;
  case 6: printf("value should be 0\n");break;
  case 7: printf("missing condition\n");break;
  case 8: printf("unreachable address\n");break;
  case 9: printf("wrong condition\n");break;
  case 10: printf("wrong restart address\n");break;
  case 11: printf("symbol table overflow\n");break;
  case 12: printf("undefined identifier\n");break;
  case 13: printf("undefined local label\n");break;
  case 14: printf("symbol redefinition\n");break;
  case 15: printf("size redefinition\n");break;
  case 16: printf("reserved word used as identifier\n");break;
  case 17: printf("code size overflow\n");break;
  case 18: printf("binary file not found\n");break;
  case 19: printf("ROM directive should preceed any code\n");break;
  case 20: printf("previously defined type\n");break;
  case 21: printf("BASIC directive should preceed any code\n");break;
  case 22: printf("page out of range\n");break;
  case 23: printf("MSXDOS directive should preceed any code\n");break;
  case 24: printf("no code in the whole file\n");break;
  case 25: printf("only available for MSXDOS\n");break;
  case 26: printf("machine not defined\n");break;
  case 27: printf("MegaROM directive should preceed any code\n");break;
  case 28: printf("cannot write ROM code/data to page 3\n");break;
  case 29: printf("included binary shorter than expected\n");break;
  case 30: printf("wrong number of bytes to skip/include\n");break;
  case 31: printf("megaROM subpage overflow\n");break;
  case 32: printf("subpage 0 can only be defined by megaROM directive\n");break;
  case 33: printf("unsupported mapper type\n");break;
  case 34: printf("megaROM code should be between 4000h and BFFFh\n");break;
  case 35: printf("code/data without subpage\n");break;
  case 36: printf("megaROM mapper subpage out of range\n");break;
  case 37: printf("megaROM subpage already defined\n");break;
  case 38: printf("Konami megaROM forces page 0 at 4000h\n");break;
  case 39: printf("megaROM subpage not defined\n");break;
  case 40: printf("megaROM-only macro used\n");break;
  case 41: printf("only for ROMs and megaROMs\n");break;
  case 42: printf("ELSE without IF\n");break;
  case 43: printf("ENDIF without IF\n");break;
  case 44: printf("Cannot nest more IFs\n");break;
  case 45: printf("IF not closed\n");break;
  case 46: printf("Sinclair directive should preceed any code\n");break;
 }

 remove("~tmppre.?");

 exit(0);
}

void warning_message(int code)
{
 if (pass==2) {
 printf("%s, line %d: Warning: ",strtok(source,"\042"),lines);
 switch (code)
 {
  case 1: printf("16-bit overflow\n");break;
  case 2: printf("8-bit overflow\n");break;
  case 3: printf("3-bit overflow\n");break;
  case 4: printf("output cannot be converted to CAS\n");break;
  case 5: printf("non official Zilog syntax\n");break;
  case 6: printf("undocumented Zilog instruction\n");break;
 }
 warnings++;
 }
}

void write_byte(int b)
{
if ((!conditional_level)||(conditional[conditional_level]))
if (type!=MEGAROM)
{
 if (PC>=0x10000) error_message(1);
 if ((type==ROM) && (PC>=0xC000)) error_message(28);
 if (addr_start>PC) addr_start=PC;
 if (addr_end<PC) addr_end=PC;
 if ((size)&&(PC>=addr_start+size*1024)&&(pass==2)) error_message(17);
 if ((size)&&(addr_start+size*1024>65536)&&(pass==2)) error_message(1);
 memory[PC++]=b;
 ePC++;
}
if (type==MEGAROM)
{
 if (subpage==ASMSX_MAX_PATH) error_message(35);
 if (PC>=pageinit+1024*pagesize) error_message(31);
 memory[subpage*pagesize*1024+PC-pageinit]=b;
 PC++;
 ePC++;
}
}

void write_text(const char *text)
{
	size_t i;
	for (i = 0; i < strlen(text); i++)
		write_byte(text[i]);
}

void write_word(int w)
{
 write_byte(w&0xff);
 write_byte((w>>8)&0xff);
}

void conditional_jump(int address)
{
 int jump;

 jump=address-ePC-1;
 if ((jump>127)||(jump<-128)) error_message(8);
 write_byte(address-ePC-1);

}

void register_label(const char *name)
{
 int i;
 if (pass==2)
   for (i=0;i<maximum;i++) if (!strcmp(name,id_list[i].name)) {last_global=i;return;}
 for (i=0;i<maximum;i++) if (!strcmp(name,id_list[i].name)) error_message(14);
 if (++maximum==MAX_ID) error_message(11);
 id_list[maximum-1].name=(char*)malloc(strlen(name)+4);
 strcpy(id_list[maximum-1].name,name);
 id_list[maximum-1].value=ePC;
 id_list[maximum-1].type=1;
 id_list[maximum-1].page=subpage;

 last_global=maximum-1;
}

void register_local(const char *name)
{
 int i;
 if (pass==2) return;
 for (i=last_global;i<maximum;i++) if (!strcmp(name,id_list[i].name)) error_message(14);
 if (++maximum==MAX_ID) error_message(11);
 id_list[maximum-1].name=(char*)malloc(strlen(name)+4);
 strcpy(id_list[maximum-1].name,name);
 id_list[maximum-1].value=ePC;
 id_list[maximum-1].type=1;
 id_list[maximum-1].page=subpage;
}

void register_symbol(const char *name,int number,int type)
{
 unsigned int i;
 char *tmpstr;

 if (pass==2) return;
 for (i=0;i<maximum;i++) if (!strcmp(name,id_list[i].name)) {error_message(14);return;}
 if (++maximum==MAX_ID) error_message(11);
 id_list[maximum-1].name=(char*)malloc(strlen(name)+1);

 tmpstr=strdup(name);
 strcpy(id_list[maximum-1].name,strtok(tmpstr," "));
 id_list[maximum-1].value=number;
 id_list[maximum-1].type=type;
}

void register_variable(const char *name,int number)
{
 unsigned int i;
 for (i=0;i<maximum;i++) if ((!strcmp(name,id_list[i].name))&&(id_list[i].type==3)) {id_list[i].value=number;return;}
 if (++maximum==MAX_ID) error_message(11);
 id_list[maximum-1].name=(char*)malloc(strlen(name)+1);
 strcpy(id_list[maximum-1].name,strtok((char *)name," "));
 id_list[maximum-1].value=number;
 id_list[maximum-1].type=3;
}


unsigned int read_label(const char *name)
{
 unsigned int i;
 for (i=0;i<maximum;i++) if (!strcmp(name,id_list[i].name)) return id_list[i].value;
 if ((pass==1)&&(i==maximum)) return ePC;
 error_message(12);
}

unsigned int read_local(const char *name)
{
 unsigned int i;
 if (pass==1) return ePC;
 for (i=last_global;i<maximum;i++)
   if (!strcmp(name,id_list[i].name)) return id_list[i].value;
 error_message(13);
}

void output_text(void)
{
 // Get output file name
 strcpy(outputfname,filename);
 outputfname=strcat(outputfname,".txt");

 fmessages=fopen(outputfname,"wt");
 if (fmessages==NULL) return;
 fprintf(fmessages,"; Output text file from %s\n",assembler);
 fprintf(fmessages,"; generated by asmsx v.%s\n\n", ASMSX_VERSION);
 printf("Output text file %s saved\n",outputfname);
}

void save_symbols(void)
{
 unsigned int i,j;
 FILE *file;
 j=0;
 for (i=0;i<maximum;i++) j+=id_list[i].type;
 if (j>0)
 {
 if ((file=fopen(symbols,"wt"))==NULL) error_message(0);
 fprintf(file,"; Symbol table from %s\n",assembler);
 fprintf(file,"; generated by asmsx v.%s\n\n", ASMSX_VERSION);
 j=0;
 for (i=0;i<maximum;i++) if (id_list[i].type==1) j++;
 if (j>0)
 {
 fprintf(file,"; global and local labels\n");
 for (i=0;i<maximum;i++)
  if (id_list[i].type==1)
   if (type!=MEGAROM) fprintf(file,"%4.4Xh %s\n",id_list[i].value,id_list[i].name);
    else
     fprintf(file,"%2.2Xh:%4.4Xh %s\n",id_list[i].page&0xff,id_list[i].value,id_list[i].name);
 }
 j=0;
 for (i=0;i<maximum;i++) if (id_list[i].type==2) j++;
 if (j>0)
 {
 fprintf(file,"; other identifiers\n");
 for (i=0;i<maximum;i++)
  if (id_list[i].type==2)
   fprintf(file,"%4.4Xh %s\n",id_list[i].value,id_list[i].name);
 }
 j=0;
 for (i=0;i<maximum;i++) if (id_list[i].type==3) j++;
 if (j>0)
 {
 fprintf(file,"; variables - value on exit\n");
 for (i=0;i<maximum;i++)
  if (id_list[i].type==3)
   fprintf(file,"%4.4Xh %s\n",id_list[i].value,id_list[i].name);
 }

 fclose(file);
 printf("Symbol file %s saved\n",symbols);
 }
}

int yywrap(void)
{
 return 1;
}

void yyerror(const char *s)
{
 error_message(0);
}

void include_binary(const char* name,unsigned int skip,unsigned int n)
{
 FILE *file;
 char k;
 unsigned int i;
 if ((file=fopen(name,"rb"))==NULL) error_message(18);

 if (pass==1) printf("Including binary file %s",name);
 if ((pass==1)&&(skip)) printf(", skipping %i bytes",skip);
 if ((pass==1)&&(n)) printf(", saving %i bytes",n);
 if (pass==1) printf("\n");

 if (skip) for (i=0;(!feof(file))&&(i<skip);i++) k=fgetc(file);

 if (skip && feof(file)) error_message(29);

 if (n)
 {
  for (i=0;(i<n)&&(!feof(file));)
  {
   k=fgetc(file);
   if (!feof(file))
   {
    write_byte(k);
    i++;
   }
  }
  if (i<n) error_message(29);
 } else

  for (;!feof(file);i++)
  {
   k=fgetc(file);
   if (!feof(file)) write_byte(k);
  }

 fclose(file);
}


void write_zx_byte(unsigned char c)
{
 putc(c,foutput);
 parity^=c;
}

void write_zx_word(unsigned int c)
{
 write_zx_byte(c&0xff);
 write_zx_byte((c>>8)&0xff);
}

void write_zx_number(unsigned int i)
{
        int c;
        c=i/10000;
        i-=c*10000;
        write_zx_byte(c+48);
        c=i/1000;
        i-=c*1000;
        write_zx_byte(c+48);
        c=i/100;
        i-=c*100;
        write_zx_byte(c+48);
        c=i/10;
        write_zx_byte(c+48);
        i%=10;
        write_zx_byte(i+48);
}

void write_binary(void)
{
  unsigned int i,j;

  if ((addr_start>addr_end)&&(type!=MEGAROM)) error_message(24);

  if (type==Z80) binary=strcat(binary,".z80");
   else if (type==ROM)
    {
     binary=strcat(binary,".rom");
     PC=addr_start+2;
     write_word(start);
     if (!size) size=8*((addr_end-addr_start+8191)/8192);
    } else if (type==BASIC) binary=strcat(binary,".bin");
     else if (type==MSXDOS) binary=strcat(binary,".com");
       else if (type==MEGAROM)
       {
        binary=strcat(binary,".rom");
        PC=0x4002;
        subpage=0x00;
        pageinit=0x4000;
        write_word(start);
       }
	else if (type==SINCLAIR)
	{
	 binary=strcat(binary,".tap");
	}

  if (type==MEGAROM)
  {
   for (i=1,j=0;i<=lastpage;i++) j+=usedpage[i];
   j>>=1;
   if (j<lastpage)
     printf("Warning: %i out of %i megaROM pages are not defined\n",lastpage-j,lastpage);
  }

  printf("Binary file %s saved\n",binary);
  foutput=fopen(binary,"wb");
  if (type==BASIC)
  {
   putc(0xfe,foutput);
   putc(addr_start & 0xff,foutput);
   putc((addr_start>>8) & 0xff,foutput);
   putc(addr_end & 0xff,foutput);
   putc((addr_end>>8) & 0xff,foutput);
   if (!start) start=addr_start;
   putc(start & 0xff,foutput);
   putc((start>>8) & 0xff,foutput);
  } else
   if (type==SINCLAIR)
   {

	if (start)
   {

        putc(0x13,foutput);
        putc(0,foutput);
        putc(0,foutput);
        parity=0x20;
        write_zx_byte(0);

	for (i=0;i<10;i++) 
		if (i<strlen(filename)) write_zx_byte(filename[i]); else write_zx_byte(0x20);

        write_zx_byte(0x1e);      /* line length */
        write_zx_byte(0);
        write_zx_byte(0x0a);      /* 10 */
        write_zx_byte(0);
        write_zx_byte(0x1e);      /* line length */
        write_zx_byte(0);
        write_zx_byte(0x1b);
        write_zx_byte(0x20);
        write_zx_byte(0);
        write_zx_byte(0xff);
        write_zx_byte(0);
        write_zx_byte(0x0a);
        write_zx_byte(0x1a);
        write_zx_byte(0);
        write_zx_byte(0xfd);      /* CLEAR */
        write_zx_byte(0xb0);      /* VAL */
        write_zx_byte('\"');
        write_zx_number(addr_start-1);
        write_zx_byte('\"');
        write_zx_byte(':');
        write_zx_byte(0xef);      /* LOAD */
        write_zx_byte('\"');
        write_zx_byte('\"');
        write_zx_byte(0xaf);      /* CODE */
        write_zx_byte(':');
        write_zx_byte(0xf9);      /* RANDOMIZE */
        write_zx_byte(0xc0);      /* USR */
        write_zx_byte(0xb0);      /* VAL */
        write_zx_byte('\"');
        write_zx_number(start);
        write_zx_byte('\"');
        write_zx_byte(0x0d);
        write_zx_byte(parity);
	}


	putc(19,foutput);	/* Header len */
	putc(0,foutput);		/* MSB of len */
	putc(0,foutput);		/* Header is 0 */
	parity=0;
	
	write_zx_byte(3);	/* Filetype (Code) */

	for (i=0;i<10;i++) 
		if (i<strlen(filename)) write_zx_byte(filename[i]); else write_zx_byte(0x20);

	write_zx_word(addr_end-addr_start+1);
        write_zx_word(addr_start); /* load address */
	write_zx_word(0);	/* offset */
	write_zx_byte(parity);
	
	write_zx_word(addr_end-addr_start+3);	/* Length of next block */
	parity=0;
	write_zx_byte(255);	/* Data... */
	for (i=addr_start; i<=addr_end;i++) {
		write_zx_byte(memory[i]);
	}
	write_zx_byte(parity);
	
	
   }

  if (type!=SINCLAIR) if (!size)
  {
   if (type!=MEGAROM) for (i=addr_start;i<=addr_end;i++) putc(memory[i],foutput);
    else for (i=0;i<(lastpage+1)*pagesize*1024;i++) putc(memory[i],foutput);
  } else if (type!=MEGAROM) for (i=addr_start;i<addr_start+size*1024;i++) putc(memory[i],foutput);
    else for (i=0;i<size*1024;i++) putc(memory[i],foutput);

  fclose(foutput);


}

void finalize(void)
{
 unsigned int i;
 
 // Get name of binary output file
 strcpy(binary,filename);

 // Get symbols file name
 strcpy(symbols,filename);
 symbols=strcat(symbols,".sym");

 write_binary();
 if (cassette&1) generate_cassette();
 if (cassette&2)
	wav_write_file((const char *)binary, (const char *)intname, type, addr_start, addr_end, start, memory);
 if (maximum>0) save_symbols();
 printf("Completed in %.2f seconds",(float)clock()/(float)CLOCKS_PER_SEC);
 if (warnings>1) printf(", %i warnings\n",warnings);
  else if (warnings==1) printf(", 1 warning\n");
   else printf("\n");
 remove("~tmppre.*");
 exit(0);
}

void initialize_memory(void)
{
 unsigned int i;
 memory=(unsigned char*)malloc(0x1000000);

 for (i=0;i<0x1000000;i++) memory[i]=0;

}

void initialize_system(void)
{

 initialize_memory();

 intname=malloc(ASMSX_MAX_PATH);
 intname[0]=0;

 register_symbol("Eduardo_A_Robsy_Petrus_2007",0,0);

}

void type_sinclair(void)
{
 if ((type) && (type!=SINCLAIR)) error_message(46);
 type=SINCLAIR;
 if (!addr_start) {PC=0x8000;ePC=PC;}
}

void type_rom(void)
{
 if ((pass==1) && (!addr_start)) error_message(19);
 if ((type) && (type!=ROM)) error_message(20);
 type=ROM;
 write_byte(65);
 write_byte(66);
 PC+=14;
 ePC+=14;
 if (!start) start=ePC;
}

void type_megarom(int n)
{
 unsigned int i;

 if (pass==1) for (i=0;i<256;i++) usedpage[i]=0;

 if ((pass==1) && (!addr_start)) error_message(19);
/* if ((pass==1) && ((!PC) || (!ePC))) error_message(19); */
 if ((type) && (type!=MEGAROM)) error_message(20);
 if ((n<0)||(n>3)) error_message(33);
 type=MEGAROM;
 usedpage[0]=1;
 subpage=0;
 pageinit=0x4000;
 lastpage=0;
 if ((n==0)||(n==1)||(n==2)) pagesize=8; else pagesize=16;
 mapper=n;
 PC=0x4000;
 ePC=0x4000;
 write_byte(65);
 write_byte(66);
 PC+=14;
 ePC+=14;
 if (!start) start=ePC;
}


void type_basic(void)
{
 if ((pass==1) && (!addr_start)) error_message(21);
 if ((type) && (type!=BASIC)) error_message(20);
 type=BASIC;
}

void type_msxdos(void)
{
 if ((pass==1) && (!addr_start)) error_message(23);
 if ((type) && (type!=MSXDOS)) error_message(20);
 type=MSXDOS;
 PC=0x0100;
 ePC=0x0100;
}

void set_subpage(int n, int addr)
{
 if (n>lastpage) lastpage=n;
 if (!n) error_message(32);
 if (usedpage[n]==pass) error_message(37); else usedpage[n]=pass;
 if ((addr<0x4000) || (addr>0xbfff)) error_message(35);
 if (n>maxpage[mapper]) error_message(36);
 subpage=n;
 pageinit=(addr/pagesize)*pagesize;
 PC=pageinit;
 ePC=PC;
}

void locate_32k(void)
{
 unsigned int i;
 for (i=0;i<31;i++) write_byte(locate32[i]);
}

unsigned int selector(unsigned int addr)
{
 addr=(addr/pagesize)*pagesize;
 if ((mapper==KONAMI) && (addr==0x4000)) error_message(38);
 if (mapper==KONAMISCC) addr+=0x1000; else
  if (mapper==ASCII8) addr=0x6000+(addr-0x4000)/4; else
   if (mapper==ASCII16) if (addr==0x4000) addr=0x6000; else addr=0x7000;
 return addr;
}

void select_page_direct(unsigned int n,unsigned int addr)
{
 unsigned int sel;

 sel=selector(addr);

 if ((pass==2)&&(!usedpage[n])) error_message(39);
 write_byte(0xf5);
 write_byte(0x3e);
 write_byte(n);
 write_byte(0x32);
 write_word(sel);
 write_byte(0xf1);
}

void select_page_register(unsigned int r, unsigned int addr)
{
 unsigned int sel;

 sel=selector(addr);

 if (r!=7)
 {
  write_byte(0xf5); /* PUSH AF */
  write_byte(0x40|(7<<3)|r); /* LD A,r */
 }
 write_byte(0x32);
 write_word(sel);
 if (r!=7) write_byte(0xf1); /* POP AF */
}

void generate_cassette(void)
{

 unsigned char cas[8]={0x1F,0xA6,0xDE,0xBA,0xCC,0x13,0x7D,0x74};

 FILE *fcas;
 unsigned int i;

 if ((type==MEGAROM)||((type=ROM)&&(addr_start<0x8000)))
 {
  warning_message(0);
  return;
 }

 binary[strlen(binary)-3]=0;
 binary=strcat(binary,"cas");

 fcas=fopen(binary,"wb");

 for (i=0;i<8;i++) fputc(cas[i],fcas);

 if ((type==BASIC)||(type==ROM))
 {
  for (i=0;i<10;i++) fputc(0xd0,fcas);

  if (strlen(intname)<6)
   for (i=strlen(intname);i<6;i++) intname[i]=32;

  for (i=0;i<6;i++) fputc(intname[i],fcas);

	for (i=0;i<8;i++)
		fputc(cas[i],fcas);


  putc(addr_start & 0xff,fcas);
  putc((addr_start>>8) & 0xff,fcas);
  putc(addr_end & 0xff,fcas);
  putc((addr_end>>8) & 0xff,fcas);
  putc(start & 0xff,fcas);
  putc((start>>8) & 0xff,fcas);
 }

 for (i=addr_start;i<=addr_end;i++)
   putc(memory[i],fcas);
 fclose(fcas);

 printf("Cassette file %s saved\n",binary);
}

int defined_symbol(const char *name)
{
 unsigned int i;
 for (i=0;i<maximum;i++) if (!strcmp(name,id_list[i].name)) return 1;
 return 0;
}

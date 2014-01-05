%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

#include "asmsx.h"
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
	
mnemo_load8bit: MNEMO_LD REGISTER ',' REGISTER
	{
		write_byte(0x40 | ($2 << 3) | $4);
	}
	| MNEMO_LD REGISTER ',' REGISTER_IX
	{
		if (($2 > 3) && ($2 != 7))
			error_message(2);
		write_byte(0xdd);
		write_byte(0x40 | ($2 << 3) | $4);
	}
	| MNEMO_LD REGISTER_IX ',' REGISTER
	{
		if (($4 > 3) && ($4 != 7))
			error_message(2);
		write_byte(0xdd);
		write_byte(0x40 | ($2 << 3) | $4);
	}
	| MNEMO_LD REGISTER_IX ',' REGISTER_IX
	{
		write_byte(0xdd);
		write_byte(0x40 | ($2 << 3) | $4);
	}
	| MNEMO_LD REGISTER ',' REGISTER_IY
	{
		if (($2 > 3) && ($2 != 7))
			error_message(2);
		write_byte(0xfd);
		write_byte(0x40 | ($2 << 3) | $4);
	}
	| MNEMO_LD REGISTER_IY ',' REGISTER
	{
		if (($4 > 3) && ($4 != 7))
			error_message(2);
		write_byte(0xfd);
		write_byte(0x40 | ($2 << 3) | $4);
	}
	| MNEMO_LD REGISTER_IY ',' REGISTER_IY
	{
		write_byte(0xfd);
		write_byte(0x40 | ($2 << 3) | $4);
	}
	| MNEMO_LD REGISTER ',' value_8bits
	{
		write_byte(0x06 | ($2 << 3));
		write_byte($4);
	}
	| MNEMO_LD REGISTER_IX ',' value_8bits
	{
		write_byte(0xdd);
		write_byte(0x06 | ($2 << 3));
		write_byte($4);
	}
	| MNEMO_LD REGISTER_IY ',' value_8bits
	{
		write_byte(0xfd);
		write_byte(0x06 | ($2 << 3));
		write_byte($4);
	}
	| MNEMO_LD REGISTER ',' REGISTER_IND_HL
	{
		write_byte(0x46 | ($2 << 3));
	}
	| MNEMO_LD REGISTER ',' rel_IX
	{
		write_byte(0xdd);
		write_byte(0x46 | ($2 << 3));
		write_byte($4);
	}
	| MNEMO_LD REGISTER ',' rel_IY
	{
		write_byte(0xfd);
		write_byte(0x46 | ($2 << 3));
		write_byte($4);
	}
	| MNEMO_LD REGISTER_IND_HL ',' REGISTER
	{
		write_byte(0x70 | $4);
	}
	| MNEMO_LD rel_IX ',' REGISTER
	{
		write_byte(0xdd);
		write_byte(0x70 | $4);
		write_byte($2);
	}
	| MNEMO_LD rel_IY ',' REGISTER
	{
		write_byte(0xfd);
		write_byte(0x70 | $4);
		write_byte($2);
	}
	| MNEMO_LD REGISTER_IND_HL ',' value_8bits
	{
		write_byte(0x36);
		write_byte($4);
	}
	| MNEMO_LD rel_IX ',' value_8bits
	{
		write_byte(0xdd);
		write_byte(0x36);
		write_byte($2);
		write_byte($4);
	}
	| MNEMO_LD rel_IY ',' value_8bits
	{
		write_byte(0xfd);
		write_byte(0x36);
		write_byte($2);
		write_byte($4);
	}
	| MNEMO_LD REGISTER ',' REGISTER_IND_BC
	{
		if ($2 != 7)
			error_message(4);
		write_byte(0x0a);
	}
	| MNEMO_LD REGISTER ',' REGISTER_IND_DE
	{
		if ($2 != 7)
			error_message(4);
		write_byte(0x1a);
	}
	| MNEMO_LD REGISTER ',' '[' value_16bits ']'
	{
		if ($2 != 7)
			error_message(4);
		write_byte(0x3a);
		write_word($5);
	}
	| MNEMO_LD REGISTER_IND_BC ',' REGISTER
	{
		if ($4 != 7)
			error_message(5);
		write_byte(0x02);
	}
	| MNEMO_LD REGISTER_IND_DE ',' REGISTER
	{
		if ($4 != 7)
			error_message(5);
		write_byte(0x12);
	}
	| MNEMO_LD '[' value_16bits ']' ',' REGISTER
	{
		if ($6 != 7)
			error_message(5);
		write_byte(0x32);
		write_word($3);
	}
	| MNEMO_LD REGISTER ',' REGISTER_I
	{
		if ($2 != 7)
			error_message(4);
		write_byte(0xed);
		write_byte(0x57);
	}
	| MNEMO_LD REGISTER ',' REGISTER_R
	{
		if ($2 != 7)
			error_message(4);
		write_byte(0xed);
		write_byte(0x5f);
	}
	| MNEMO_LD REGISTER_I ',' REGISTER
	{
		if ($4 != 7)
			error_message(5);
		write_byte(0xed);
		write_byte(0x47);
	}
	| MNEMO_LD REGISTER_R ',' REGISTER
	{
		if ($4 != 7)
			error_message(5);
		write_byte(0xed);
		write_byte(0x4f);
	}
;

mnemo_load16bit: MNEMO_LD REGISTER_PAR ',' value_16bits
	{
		write_byte(0x01 | ($2 << 4));
		write_word($4);
	}
	| MNEMO_LD REGISTER_16_IX ',' value_16bits
	{
		write_byte(0xdd);
		write_byte(0x21);
		write_word($4);
	}
	| MNEMO_LD REGISTER_16_IY ',' value_16bits
	{
		write_byte(0xfd);
		write_byte(0x21);
		write_word($4);
	}
	| MNEMO_LD REGISTER_PAR ',' '[' value_16bits ']'
	{
		if ($2 != 2)
		{
			write_byte(0xed);
			write_byte(0x4b | ($2 << 4));
		}
		else
			write_byte(0x2a);
		write_word($5);
	}
	| MNEMO_LD REGISTER_16_IX ',' '[' value_16bits ']'
	{
		write_byte(0xdd);
		write_byte(0x2a);
		write_word($5);
	}
	| MNEMO_LD REGISTER_16_IY ',' '[' value_16bits ']'
	{
		write_byte(0xfd);
		write_byte(0x2a);
		write_word($5);
	}
	| MNEMO_LD '[' value_16bits ']' ',' REGISTER_PAR
	{
		if ($6 != 2)
		{
			write_byte(0xed);
			write_byte(0x43 | ($6 << 4));
		}
		else
			write_byte(0x22);
		write_word($3);
	}
	| MNEMO_LD '[' value_16bits ']' ',' REGISTER_16_IX
	{
		write_byte(0xdd);
		write_byte(0x22);
		write_word($3);
	}
	| MNEMO_LD '[' value_16bits ']' ',' REGISTER_16_IY
	{
		write_byte(0xfd);
		write_byte(0x22);
		write_word($3);
	}
	| MNEMO_LD_SP ',' '[' value_16bits ']'
	{
		write_byte(0xed);
		write_byte(0x7b);
		write_word($4);
	}
	| MNEMO_LD_SP ',' value_16bits
	{
		write_byte(0x31);
		write_word($3);
	}
	| MNEMO_LD_SP ',' REGISTER_PAR
	{
		if ($3 != 2)
			error_message(2);
		write_byte(0xf9);
	}
	| MNEMO_LD_SP ',' REGISTER_16_IX
	{
		write_byte(0xdd);
		write_byte(0xf9);
	}
	| MNEMO_LD_SP ',' REGISTER_16_IY
	{
		write_byte(0xfd);
		write_byte(0xf9);
	}
	| MNEMO_PUSH REGISTER_PAR
	{
		if ($2 == 3)
			error_message(2);
		write_byte(0xc5 | ($2 << 4));
	}
	| MNEMO_PUSH REGISTER_AF
	{
		write_byte(0xf5);
	}
	| MNEMO_PUSH REGISTER_16_IX
	{
		write_byte(0xdd);
		write_byte(0xe5);
	}
	| MNEMO_PUSH REGISTER_16_IY
	{
		write_byte(0xfd);
		write_byte(0xe5);
	}
	| MNEMO_POP REGISTER_PAR
	{
		if ($2 == 3)
			error_message(2);
		write_byte(0xc1 | ($2 << 4));
	}
	| MNEMO_POP REGISTER_AF
	{
		write_byte(0xf1);
	}
	| MNEMO_POP REGISTER_16_IX
	{
		write_byte(0xdd);
		write_byte(0xe1);
	}
	| MNEMO_POP REGISTER_16_IY
	{
		write_byte(0xfd);
		write_byte(0xe1);
	}
;

mnemo_exchange: MNEMO_EX REGISTER_PAR ',' REGISTER_PAR
	{
		if ((($2 != 1) || ($4 != 2)) && (($2 != 2) || ($4 != 1)))
			error_message(2);
		if ((zilog) && ($2 != 1))
			warning_message(5);
		write_byte(0xeb);
	}
	| MNEMO_EX REGISTER_AF ',' REGISTER_AF APOSTROPHE
	{
		write_byte(0x08);
	}
	| MNEMO_EXX
	{
		write_byte(0xd9);
	}
	| MNEMO_EX REGISTER_IND_SP ',' REGISTER_PAR
	{
		if ($4 != 2)
			error_message(2);
		write_byte(0xe3);
	}
	| MNEMO_EX REGISTER_IND_SP ',' REGISTER_16_IX
	{
		write_byte(0xdd);
		write_byte(0xe3);
	}
	| MNEMO_EX REGISTER_IND_SP ',' REGISTER_16_IY
	{
		write_byte(0xfd);
		write_byte(0xe3);
	}
	| MNEMO_LDI
	{
		write_byte(0xed);
		write_byte(0xa0);
	}
	| MNEMO_LDIR
	{
		write_byte(0xed);
		write_byte(0xb0);
	}
	| MNEMO_LDD
	{
		write_byte(0xed);
		write_byte(0xa8);
	}
	| MNEMO_LDDR
	{
		write_byte(0xed);
		write_byte(0xb8);
	}
	| MNEMO_CPI
	{
		write_byte(0xed);
		write_byte(0xa1);
	}
	| MNEMO_CPIR
	{
		write_byte(0xed);
		write_byte(0xb1);
	}
	| MNEMO_CPD
	{
		write_byte(0xed);
		write_byte(0xa9);
	}
	| MNEMO_CPDR
	{
		write_byte(0xed);
		write_byte(0xb9);
	}
;

mnemo_arithm8bit: MNEMO_ADD REGISTER ',' REGISTER
	{
		if ($2 != 7)
			error_message(4);
		write_byte(0x80 | $4);
	}
	| MNEMO_ADD REGISTER ',' REGISTER_IX
	{
		if ($2 != 7)
			error_message(4);
		write_byte(0xdd);
		write_byte(0x80 | $4);
	}
	| MNEMO_ADD REGISTER ',' REGISTER_IY
	{
		if ($2 != 7)
			error_message(4);
		write_byte(0xfd);
		write_byte(0x80 | $4);
	}
	| MNEMO_ADD REGISTER ',' value_8bits
	{
		if ($2 != 7)
			error_message(4);
		write_byte(0xc6);
		write_byte($4);
	}
	| MNEMO_ADD REGISTER ',' REGISTER_IND_HL
	{
		if ($2 != 7)
			error_message(4);
		write_byte(0x86);
	}
	| MNEMO_ADD REGISTER ',' rel_IX
	{
		if ($2 != 7)
			error_message(4);
		write_byte(0xdd);
		write_byte(0x86);
		write_byte($4);
	}
	| MNEMO_ADD REGISTER ',' rel_IY
	{
		if ($2 != 7)
			error_message(4);
		write_byte(0xfd);
		write_byte(0x86);
		write_byte($4);
	}
	| MNEMO_ADC REGISTER ',' REGISTER
	{
		if ($2 != 7)
			error_message(4);
		write_byte(0x88 | $4);
	}
	| MNEMO_ADC REGISTER ',' REGISTER_IX
	{
		if ($2 != 7)
			error_message(4);
		write_byte(0xdd);
		write_byte(0x88 | $4);
	}
	| MNEMO_ADC REGISTER ',' REGISTER_IY
	{
		if ($2 != 7)
			error_message(4);
		write_byte(0xfd);
		write_byte(0x88 | $4);
	}
	| MNEMO_ADC REGISTER ',' value_8bits
	{
		if ($2 != 7)
			error_message(4);
		write_byte(0xce);
		write_byte($4);
	}
	| MNEMO_ADC REGISTER ',' REGISTER_IND_HL
	{
		if ($2 != 7)
			error_message(4);
		write_byte(0x8e);
	}
	| MNEMO_ADC REGISTER ',' rel_IX
	{
		if ($2 != 7)
			error_message(4);
		write_byte(0xdd);
		write_byte(0x8e);
		write_byte($4);
	}
	| MNEMO_ADC REGISTER ',' rel_IY
	{
		if ($2 != 7)
			error_message(4);
		write_byte(0xfd);
		write_byte(0x8e);
		write_byte($4);
	}
	| MNEMO_SUB REGISTER ',' REGISTER
	{
		if ($2 != 7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0x90 | $4);
	}
	| MNEMO_SUB REGISTER ',' REGISTER_IX
	{
		if ($2 != 7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0xdd);
		write_byte(0x90 | $4);
	}
	| MNEMO_SUB REGISTER ',' REGISTER_IY
	{
		if ($2 != 7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0xfd);
		write_byte(0x90 | $4);
	}
	| MNEMO_SUB REGISTER ',' value_8bits
	{
		if ($2 != 7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0xd6);
		write_byte($4);
	}
	| MNEMO_SUB REGISTER ',' REGISTER_IND_HL
	{
		if ($2 != 7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0x96);
	}
	| MNEMO_SUB REGISTER ',' rel_IX
	{
		if ($2 != 7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0xdd);
		write_byte(0x96);
		write_byte($4);
	}
	| MNEMO_SUB REGISTER ',' rel_IY
	{
		if ($2 != 7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0xfd);
		write_byte(0x96);
		write_byte($4);
	}
	| MNEMO_SBC REGISTER ',' REGISTER
	{
		if ($2 != 7)
			error_message(4);
		write_byte(0x98 | $4);
	}
	| MNEMO_SBC REGISTER ',' REGISTER_IX
	{
		if ($2 != 7)
			error_message(4);
		write_byte(0xdd);
		write_byte(0x98 | $4);
	}
	| MNEMO_SBC REGISTER ',' REGISTER_IY
	{
		if ($2 != 7)
			error_message(4);
		write_byte(0xfd);
		write_byte(0x98 | $4);
	}
	| MNEMO_SBC REGISTER ',' value_8bits
	{
		if ($2 != 7)
			error_message(4);
		write_byte(0xde);
		write_byte($4);
	}
	| MNEMO_SBC REGISTER ',' REGISTER_IND_HL
	{
		if ($2 != 7)
			error_message(4);
		write_byte(0x9e);
	}
	| MNEMO_SBC REGISTER ',' rel_IX
	{
		if ($2 != 7)
			error_message(4);
		write_byte(0xdd);
		write_byte(0x9e);
		write_byte($4);
	}
	| MNEMO_SBC REGISTER ',' rel_IY
	{
		if ($2 != 7)
			error_message(4);
		write_byte(0xfd);
		write_byte(0x9e);
		write_byte($4);
	}
	| MNEMO_AND REGISTER ',' REGISTER
	{
		if ($2 != 7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0xa0 | $4);
	}
	| MNEMO_AND REGISTER ',' REGISTER_IX
	{
		if ($2 != 7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0xdd);
		write_byte(0xa0 | $4);
	}
	| MNEMO_AND REGISTER ',' REGISTER_IY
	{
		if ($2 != 7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0xfd);
		write_byte(0xa0 | $4);
	}
	| MNEMO_AND REGISTER ',' value_8bits
	{
		if ($2 != 7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0xe6);
		write_byte($4);
	}
	| MNEMO_AND REGISTER ',' REGISTER_IND_HL
	{
		if ($2 != 7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0xa6);
	}
	| MNEMO_AND REGISTER ',' rel_IX
	{
		if ($2 != 7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0xdd);
		write_byte(0xa6);
		write_byte($4);
	}
	| MNEMO_AND REGISTER ',' rel_IY
	{
		if ($2 != 7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0xfd);
		write_byte(0xa6);
		write_byte($4);
	}
	| MNEMO_OR REGISTER ',' REGISTER
	{
		if ($2 != 7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0xb0 | $4);
	}
	| MNEMO_OR REGISTER ',' REGISTER_IX
	{
		if ($2 != 7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0xdd);
		write_byte(0xb0 | $4);
	}
	| MNEMO_OR REGISTER ',' REGISTER_IY
	{
		if ($2 != 7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0xfd);
		write_byte(0xb0 | $4);
	}
	| MNEMO_OR REGISTER ',' value_8bits
	{
		if ($2!=7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0xf6);
		write_byte($4);
	}
	| MNEMO_OR REGISTER ',' REGISTER_IND_HL
	{
		if ($2 != 7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0xb6);
	}
	| MNEMO_OR REGISTER ',' rel_IX
	{
		if ($2!=7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0xdd);
		write_byte(0xb6);
		write_byte($4);
	}
	| MNEMO_OR REGISTER ',' rel_IY
	{
		if ($2 != 7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0xfd);
		write_byte(0xb6);
		write_byte($4);
	}
	| MNEMO_XOR REGISTER ',' REGISTER
	{
		if ($2 != 7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0xa8 | $4);
	}
	| MNEMO_XOR REGISTER ',' REGISTER_IX
	{
		if ($2 != 7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0xdd);
		write_byte(0xa8 | $4);
	}
	| MNEMO_XOR REGISTER ',' REGISTER_IY
	{
		if ($2 != 7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0xfd);
		write_byte(0xa8 | $4);
	}
	| MNEMO_XOR REGISTER ',' value_8bits
	{
		if ($2 != 7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0xee);
		write_byte($4);
	}
	| MNEMO_XOR REGISTER ',' REGISTER_IND_HL
	{
		if ($2 != 7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0xae);
	}
	| MNEMO_XOR REGISTER ',' rel_IX
	{
		if ($2 != 7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0xdd);
		write_byte(0xae);
		write_byte($4);
	}
	| MNEMO_XOR REGISTER ',' rel_IY
	{
		if ($2 != 7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0xfd);
		write_byte(0xae);
		write_byte($4);
	}
	| MNEMO_CP REGISTER ',' REGISTER
	{
		if ($2 != 7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0xb8 | $4);
	}
	| MNEMO_CP REGISTER ',' REGISTER_IX
	{
		if ($2 != 7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0xdd);
		write_byte(0xb8 | $4);
	}
	| MNEMO_CP REGISTER ',' REGISTER_IY
	{
		if ($2 != 7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0xfd);
		write_byte(0xb8 | $4);
	}
	| MNEMO_CP REGISTER ',' value_8bits
	{
		if ($2 != 7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0xfe);
		write_byte($4);
	}
	| MNEMO_CP REGISTER ',' REGISTER_IND_HL
	{
		if ($2 != 7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0xbe);
	}
	| MNEMO_CP REGISTER ',' rel_IX
	{
		if ($2 != 7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0xdd);
		write_byte(0xbe);
		write_byte($4);
	}
	| MNEMO_CP REGISTER ',' rel_IY
	{
		if ($2 != 7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0xfd);
		write_byte(0xbe);
		write_byte($4);
	}
	| MNEMO_ADD REGISTER
	{
		if (zilog)
			warning_message(5);
		write_byte(0x80 | $2);
	}
	| MNEMO_ADD REGISTER_IX
	{
		if (zilog)
			warning_message(5);
		write_byte(0xdd);
		write_byte(0x80 | $2);
	}
	| MNEMO_ADD REGISTER_IY
	{
		if (zilog)
			warning_message(5);
		write_byte(0xfd);
		write_byte(0x80 | $2);
	}
	| MNEMO_ADD value_8bits
	{
		if (zilog)
			warning_message(5);
		write_byte(0xc6);
		write_byte($2);
	}
	| MNEMO_ADD REGISTER_IND_HL
	{
		if (zilog)
			warning_message(5);
		write_byte(0x86);
	}
	| MNEMO_ADD rel_IX
	{
		if (zilog)
			warning_message(5);
		write_byte(0xdd);
		write_byte(0x86);
		write_byte($2);
	}
	| MNEMO_ADD rel_IY
	{
		if (zilog)
			warning_message(5);
		write_byte(0xfd);
		write_byte(0x86);
		write_byte($2);
	}
	| MNEMO_ADC REGISTER
	{
		if (zilog)
			warning_message(5);
		write_byte(0x88 | $2);
	}
	| MNEMO_ADC REGISTER_IX
	{
		if (zilog)
			warning_message(5);
		write_byte(0xdd);
		write_byte(0x88 | $2);
	}
	| MNEMO_ADC REGISTER_IY
	{
		if (zilog)
			warning_message(5);
		write_byte(0xfd);
		write_byte(0x88 | $2);
	}
	| MNEMO_ADC value_8bits
	{
		if (zilog)
			warning_message(5);
		write_byte(0xce);
		write_byte($2);
	}
	| MNEMO_ADC REGISTER_IND_HL
	{
		if (zilog)
			warning_message(5);
		write_byte(0x8e);
	}
	| MNEMO_ADC rel_IX
	{
		if (zilog)
			warning_message(5);
		write_byte(0xdd);
		write_byte(0x8e);
		write_byte($2);
	}
	| MNEMO_ADC rel_IY
	{
		if (zilog)
			warning_message(5);
		write_byte(0xfd);
		write_byte(0x8e);
		write_byte($2);
	}
	| MNEMO_SUB REGISTER
	{
		write_byte(0x90 | $2);
	}
	| MNEMO_SUB REGISTER_IX
	{
		write_byte(0xdd);
		write_byte(0x90 | $2);
	}
	| MNEMO_SUB REGISTER_IY
	{
		write_byte(0xfd);
		write_byte(0x90 | $2);
	}
	| MNEMO_SUB value_8bits
	{
		write_byte(0xd6);
		write_byte($2);
	}
	| MNEMO_SUB REGISTER_IND_HL
	{
		write_byte(0x96);
	}
	| MNEMO_SUB rel_IX
	{
		write_byte(0xdd);
		write_byte(0x96);
		write_byte($2);
	}
	| MNEMO_SUB rel_IY
	{
		write_byte(0xfd);
		write_byte(0x96);
		write_byte($2);
	}
	| MNEMO_SBC REGISTER
	{
		if (zilog)
			warning_message(5);
		write_byte(0x98 | $2);
	}
	| MNEMO_SBC REGISTER_IX
	{
		if (zilog)
			warning_message(5);
		write_byte(0xdd);
		write_byte(0x98 | $2);
	}
	| MNEMO_SBC REGISTER_IY
	{
		if (zilog)
			warning_message(5);
		write_byte(0xfd);
		write_byte(0x98 | $2);
	}
	| MNEMO_SBC value_8bits
	{
		if (zilog)
			warning_message(5);
		write_byte(0xde);
		write_byte($2);
	}
	| MNEMO_SBC REGISTER_IND_HL
	{
		if (zilog)
			warning_message(5);
		write_byte(0x9e);
	}
	| MNEMO_SBC rel_IX
	{
		if (zilog)
			warning_message(5);
		write_byte(0xdd);
		write_byte(0x9e);
		write_byte($2);
	}
	| MNEMO_SBC rel_IY
	{
		if (zilog)
			warning_message(5);
		write_byte(0xfd);
		write_byte(0x9e);
		write_byte($2);
	}
	| MNEMO_AND REGISTER
	{
		write_byte(0xa0 | $2);
	}
	| MNEMO_AND REGISTER_IX
	{
		write_byte(0xdd);
		write_byte(0xa0 | $2);
	}
	| MNEMO_AND REGISTER_IY
	{
		write_byte(0xfd);
		write_byte(0xa0 | $2);
	}
	| MNEMO_AND value_8bits
	{
		write_byte(0xe6);
		write_byte($2);
	}
	| MNEMO_AND REGISTER_IND_HL
	{
		write_byte(0xa6);
	}
	| MNEMO_AND rel_IX
	{
		write_byte(0xdd);
		write_byte(0xa6);
		write_byte($2);
	}
	| MNEMO_AND rel_IY
	{
		write_byte(0xfd);
		write_byte(0xa6);
		write_byte($2);
	}
	| MNEMO_OR REGISTER
	{
		write_byte(0xb0 | $2);
	}
	| MNEMO_OR REGISTER_IX
	{
		write_byte(0xdd);
		write_byte(0xb0 | $2);
	}
	| MNEMO_OR REGISTER_IY
	{
		write_byte(0xfd);
		write_byte(0xb0 | $2);
	}
	| MNEMO_OR value_8bits
	{
		write_byte(0xf6);
		write_byte($2);
	}
	| MNEMO_OR REGISTER_IND_HL
	{
		write_byte(0xb6);
	}
	| MNEMO_OR rel_IX
	{
		write_byte(0xdd);
		write_byte(0xb6);
		write_byte($2);
	}
	| MNEMO_OR rel_IY
	{
		write_byte(0xfd);
		write_byte(0xb6);
		write_byte($2);
	}
	| MNEMO_XOR REGISTER
	{
		write_byte(0xa8 | $2);
	}
	| MNEMO_XOR REGISTER_IX
	{
		write_byte(0xdd);
		write_byte(0xa8 | $2);
	}
	| MNEMO_XOR REGISTER_IY
	{
		write_byte(0xfd);
		write_byte(0xa8 | $2);
	}
	| MNEMO_XOR value_8bits
	{
		write_byte(0xee);
		write_byte($2);
	}
	| MNEMO_XOR REGISTER_IND_HL
	{
		write_byte(0xae);
	}
	| MNEMO_XOR rel_IX
	{
		write_byte(0xdd);
		write_byte(0xae);
		write_byte($2);
	}
	| MNEMO_XOR rel_IY
	{
		write_byte(0xfd);
		write_byte(0xae);
		write_byte($2);
	}
	| MNEMO_CP REGISTER
	{
		write_byte(0xb8 | $2);
	}
	| MNEMO_CP REGISTER_IX
	{
		write_byte(0xdd);
		write_byte(0xb8 | $2);
	}
	| MNEMO_CP REGISTER_IY
	{
		write_byte(0xfd);
		write_byte(0xb8 | $2);
	}
	| MNEMO_CP value_8bits
	{
		write_byte(0xfe);
		write_byte($2);
	}
	| MNEMO_CP REGISTER_IND_HL
	{
		write_byte(0xbe);
	}
	| MNEMO_CP rel_IX
	{
		write_byte(0xdd);
		write_byte(0xbe);
		write_byte($2);
	}
	| MNEMO_CP rel_IY
	{
		write_byte(0xfd);
		write_byte(0xbe);
		write_byte($2);
	}
	| MNEMO_INC REGISTER
	{
		write_byte(0x04 | ($2 << 3));
	}
	| MNEMO_INC REGISTER_IX
	{
		write_byte(0xdd);
		write_byte(0x04 | ($2 << 3));
	}
	| MNEMO_INC REGISTER_IY
	{
		write_byte(0xfd);
		write_byte(0x04 | ($2 << 3));
	}
	| MNEMO_INC REGISTER_IND_HL
	{
		write_byte(0x34);
	}
	| MNEMO_INC rel_IX
	{
		write_byte(0xdd);
		write_byte(0x34);
		write_byte($2);
	}
	| MNEMO_INC rel_IY
	{
		write_byte(0xfd);
		write_byte(0x34);
		write_byte($2);
	}
	| MNEMO_DEC REGISTER
	{
		write_byte(0x05 | ($2 << 3));
	}
	| MNEMO_DEC REGISTER_IX
	{
		write_byte(0xdd);
		write_byte(0x05 | ($2 << 3));
	}
	| MNEMO_DEC REGISTER_IY
	{
		write_byte(0xfd);
		write_byte(0x05 | ($2 << 3));
	}
	| MNEMO_DEC REGISTER_IND_HL
	{
		write_byte(0x35);
	}
	| MNEMO_DEC rel_IX
	{
		write_byte(0xdd);
		write_byte(0x35);
		write_byte($2);
	}
	| MNEMO_DEC rel_IY
	{
		write_byte(0xfd);
		write_byte(0x35);
		write_byte($2);
	}
;

mnemo_arithm16bit: MNEMO_ADD REGISTER_PAR ',' REGISTER_PAR
	{
		if ($2 != 2)
			error_message(2);
		write_byte(0x09 | ($4 << 4));
	}
	| MNEMO_ADC REGISTER_PAR ',' REGISTER_PAR
	{
		if ($2!=2)
			error_message(2);
		write_byte(0xed);
		write_byte(0x4a | ($4 << 4));
	}
	| MNEMO_SBC REGISTER_PAR ',' REGISTER_PAR
	{
		if ($2!=2)
			error_message(2);
		write_byte(0xed);
		write_byte(0x42 | ($4 << 4));
	}
	| MNEMO_ADD REGISTER_16_IX ',' REGISTER_PAR
	{
		if ($4 == 2)
			error_message(2);
		write_byte(0xdd);
		write_byte(0x09 | ($4 << 4));
	}
	| MNEMO_ADD REGISTER_16_IX ',' REGISTER_16_IX
	{
		write_byte(0xdd);
		write_byte(0x29);
	}
	| MNEMO_ADD REGISTER_16_IY ',' REGISTER_PAR
	{
		if ($4 == 2)
			error_message(2);
		write_byte(0xfd);
		write_byte(0x09 | ($4 << 4));
	}
	| MNEMO_ADD REGISTER_16_IY ',' REGISTER_16_IY
	{
		write_byte(0xfd);
		write_byte(0x29);
	}
	| MNEMO_INC REGISTER_PAR
	{
		write_byte(0x03 | ($2 << 4));
	}
	| MNEMO_INC REGISTER_16_IX
	{
		write_byte(0xdd);
		write_byte(0x23);
	}
	| MNEMO_INC REGISTER_16_IY
	{
		write_byte(0xfd);
		write_byte(0x23);
	}
	| MNEMO_DEC REGISTER_PAR
	{
		write_byte(0x0b | ($2 << 4));
	}
	| MNEMO_DEC REGISTER_16_IX
	{
		write_byte(0xdd);
		write_byte(0x2b);
	}
	| MNEMO_DEC REGISTER_16_IY
	{
		write_byte(0xfd);
		write_byte(0x2b);
	}
;

mnemo_general: MNEMO_DAA
	{
		write_byte(0x27);
	}
	| MNEMO_CPL
	{
		write_byte(0x2f);
	}
	| MNEMO_NEG
	{
		write_byte(0xed);
		write_byte(0x44);
	}
	| MNEMO_CCF
	{
		write_byte(0x3f);
	}
	| MNEMO_SCF
	{
		write_byte(0x37);
	}
	| MNEMO_NOP
	{
		write_byte(0x00);
	}
	| MNEMO_HALT
	{
		write_byte(0x76);
	}
	| MNEMO_DI
	{
		write_byte(0xf3);
	}
	| MNEMO_EI
	{
		write_byte(0xfb);
	}
	| MNEMO_IM value_8bits
	{
		if (($2 < 0) || ($2 > 2))
			error_message(3);
		write_byte(0xed);
		if ($2 == 0)
			write_byte(0x46);
		else
			if ($2 == 1)
				write_byte(0x56);
			else
				write_byte(0x5e);
	}
;

mnemo_rotate: MNEMO_RLCA
	{
		write_byte(0x07);
	}
	| MNEMO_RLA
	{
		write_byte(0x17);
	}
	| MNEMO_RRCA
	{
		write_byte(0x0f);
	}
	| MNEMO_RRA
	{
		write_byte(0x1f);
	}
	| MNEMO_RLC REGISTER
	{
		write_byte(0xcb);
		write_byte($2);
	}
	| MNEMO_RLC REGISTER_IND_HL
	{
		write_byte(0xcb);
		write_byte(0x06);
	}
	| MNEMO_RLC rel_IX ',' REGISTER
	{
		if ($4 == 6)
			error_message(2);
		write_byte(0xdd);
		write_byte(0xcb);
		write_byte($2);
		write_byte($4);
	}
	| MNEMO_RLC rel_IY ',' REGISTER
	{
		if ($4 == 6)
			error_message(2);
		write_byte(0xfd);
		write_byte(0xcb);
		write_byte($2);
		write_byte($4);
	}
	| MNEMO_RLC rel_IX
	{
		write_byte(0xdd);
		write_byte(0xcb);
		write_byte($2);
		write_byte(0x06);
	}
	| MNEMO_RLC rel_IY
	{
		write_byte(0xfd);
		write_byte(0xcb);
		write_byte($2);
		write_byte(0x06);
	}
	| MNEMO_LD REGISTER ',' MNEMO_RLC rel_IX
	{
		write_byte(0xdd);
		write_byte(0xcb);
		write_byte($5);
		write_byte($2);
	}
	| MNEMO_LD REGISTER ',' MNEMO_RLC rel_IY
	{
		write_byte(0xfd);
		write_byte(0xcb);
		write_byte($5);
		write_byte($2);
	}
	| MNEMO_RL REGISTER
	{
		write_byte(0xcb);
		write_byte(0x10 | $2);
	}
	| MNEMO_RL REGISTER_IND_HL
	{
		write_byte(0xcb);
		write_byte(0x16);
	}
	| MNEMO_RL rel_IX ',' REGISTER
	{
		if ($4 == 6)
			error_message(2);
		write_byte(0xdd);
		write_byte(0xcb);
		write_byte($2);
		write_byte($4 | 0x10);
	}
	| MNEMO_RL rel_IY ',' REGISTER
	{
		if ($4 == 6)
			error_message(2);
		write_byte(0xfd);
		write_byte(0xcb);
		write_byte($2);
		write_byte($4 | 0x10);
	}
	| MNEMO_RL rel_IX
	{
		write_byte(0xdd);
		write_byte(0xcb);
		write_byte($2);
		write_byte(0x16);
	}
	| MNEMO_RL rel_IY
	{
		write_byte(0xfd);
		write_byte(0xcb);
		write_byte($2);
		write_byte(0x16);
	}
	| MNEMO_LD REGISTER ',' MNEMO_RL rel_IX
	{
		write_byte(0xdd);
		write_byte(0xcb);
		write_byte($5);
		write_byte(0x10 | $2);
	}
	| MNEMO_LD REGISTER ',' MNEMO_RL rel_IY
	{
		write_byte(0xfd);
		write_byte(0xcb);
		write_byte($5);
		write_byte(0x10 | $2);
	}
	| MNEMO_RRC REGISTER
	{
		write_byte(0xcb);
		write_byte(0x08 | $2);
	}
	| MNEMO_RRC REGISTER_IND_HL
	{
		write_byte(0xcb);
		write_byte(0x0e);
	}
	| MNEMO_RRC rel_IX ',' REGISTER
	{
		if ($4 == 6)
			error_message(2);
		write_byte(0xdd);
		write_byte(0xcb);
		write_byte($2);
		write_byte($4 | 0x08);
	}
	| MNEMO_RRC rel_IY ',' REGISTER
	{
		if ($4 == 6)
			error_message(2);
		write_byte(0xfd);
		write_byte(0xcb);
		write_byte($2);
		write_byte($4 | 0x08);
	}
	| MNEMO_RRC rel_IX
	{
		write_byte(0xdd);
		write_byte(0xcb);
		write_byte($2);
		write_byte(0x0e);
	}
	| MNEMO_RRC rel_IY
	{
		write_byte(0xfd);
		write_byte(0xcb);
		write_byte($2);
		write_byte(0x0e);
	}
	| MNEMO_LD REGISTER ',' MNEMO_RRC rel_IX
	{
		write_byte(0xdd);
		write_byte(0xcb);
		write_byte($5);
		write_byte(0x08 | $2);
	}
	| MNEMO_LD REGISTER ',' MNEMO_RRC rel_IY
	{
		write_byte(0xfd);
		write_byte(0xcb);
		write_byte($5);
		write_byte(0x08 | $2);
	}
	| MNEMO_RR REGISTER
	{
		write_byte(0xcb);
		write_byte(0x18 | $2);
	}
	| MNEMO_RR REGISTER_IND_HL
	{
		write_byte(0xcb);
		write_byte(0x1e);
	}
	| MNEMO_RR rel_IX ',' REGISTER
	{
		if ($4 == 6)
			error_message(2);
		write_byte(0xdd);
		write_byte(0xcb);
		write_byte($2);
		write_byte($4 | 0x18);
	}
	| MNEMO_RR rel_IY ',' REGISTER
	{
		if ($4 == 6)
			error_message(2);
		write_byte(0xfd);
		write_byte(0xcb);
		write_byte($2);
		write_byte($4 | 0x18);
	}
	| MNEMO_RR rel_IX
	{
		write_byte(0xdd);
		write_byte(0xcb);
		write_byte($2);
		write_byte(0x1e);
	}
	| MNEMO_RR rel_IY
	{
		write_byte(0xfd);
		write_byte(0xcb);
		write_byte($2);
		write_byte(0x1e);
	}
	| MNEMO_LD REGISTER ',' MNEMO_RR rel_IX
	{
		write_byte(0xdd);
		write_byte(0xcb);
		write_byte($5);
		write_byte($2 | 0x18);
	}
	| MNEMO_LD REGISTER ',' MNEMO_RR rel_IY
	{
		write_byte(0xfd);
		write_byte(0xcb);
		write_byte($5);
		write_byte($2 | 0x18);
	}
	| MNEMO_SLA REGISTER
	{
		write_byte(0xcb);
		write_byte($2 | 0x20);
	}
	| MNEMO_SLA REGISTER_IND_HL
	{
		write_byte(0xcb);
		write_byte(0x26);
	}
	| MNEMO_SLA rel_IX ',' REGISTER
	{
		if ($4 == 6)
			error_message(2);
		write_byte(0xdd);
		write_byte(0xcb);
		write_byte($2);
		write_byte($4 | 0x20);
	}
	| MNEMO_SLA rel_IY ',' REGISTER
	{
		if ($4 == 6)
			error_message(2);
		write_byte(0xfd);
		write_byte(0xcb);
		write_byte($2);
		write_byte($4 | 0x20);
	}
	| MNEMO_SLA rel_IX
	{
		write_byte(0xdd);
		write_byte(0xcb);
		write_byte($2);
		write_byte(0x26);
	}
	| MNEMO_SLA rel_IY
	{
		write_byte(0xfd);
		write_byte(0xcb);
		write_byte($2);
		write_byte(0x26);
	}
	| MNEMO_LD REGISTER ',' MNEMO_SLA rel_IX
	{
		write_byte(0xdd);
		write_byte(0xcb);
		write_byte($5);
		write_byte($2 | 0x20);
	}
	| MNEMO_LD REGISTER ',' MNEMO_SLA rel_IY
	{
		write_byte(0xfd);
		write_byte(0xcb);
		write_byte($5);
		write_byte($2 | 0x20);
	}
	| MNEMO_SLL REGISTER
	{
		write_byte(0xcb);
		write_byte($2 | 0x30);
	}
	| MNEMO_SLL REGISTER_IND_HL
	{
		write_byte(0xcb);
		write_byte(0x36);
	}
	| MNEMO_SLL rel_IX ',' REGISTER
	{
		if ($4 == 6)
			error_message(2);
		write_byte(0xdd);
		write_byte(0xcb);
		write_byte($2);
		write_byte($4 | 0x30);
	}
	| MNEMO_SLL rel_IY ',' REGISTER
	{
		if ($4 == 6)
			error_message(2);
		write_byte(0xfd);
		write_byte(0xcb);
		write_byte($2);
		write_byte($4 | 0x30);
	}
	| MNEMO_SLL rel_IX
	{
		write_byte(0xdd);
		write_byte(0xcb);
		write_byte($2);
		write_byte(0x36);
	}
	| MNEMO_SLL rel_IY
	{
		write_byte(0xfd);
		write_byte(0xcb);
		write_byte($2);
		write_byte(0x36);
	}
	| MNEMO_LD REGISTER ',' MNEMO_SLL rel_IX
	{
		write_byte(0xdd);
		write_byte(0xcb);
		write_byte($5);
		write_byte($2 | 0x30);
	}
	| MNEMO_LD REGISTER ',' MNEMO_SLL rel_IY
	{
		write_byte(0xfd);
		write_byte(0xcb);
		write_byte($5);
		write_byte($2 | 0x30);
	}
	| MNEMO_SRA REGISTER
	{
		write_byte(0xcb);
		write_byte($2 | 0x28);
	}
	| MNEMO_SRA REGISTER_IND_HL
	{
		write_byte(0xcb);
		write_byte(0x2e);
	}
	| MNEMO_SRA rel_IX ',' REGISTER
	{
		if ($4 == 6)
			error_message(2);
		write_byte(0xdd);
		write_byte(0xcb);
		write_byte($2);
		write_byte($4 | 0x28);
	}
	| MNEMO_SRA rel_IY ',' REGISTER
	{
		if ($4 == 6)
			error_message(2);
		write_byte(0xfd);
		write_byte(0xcb);
		write_byte($2);
		write_byte($4 | 0x28);
	}
	| MNEMO_SRA rel_IX
	{
		write_byte(0xdd);
		write_byte(0xcb);
		write_byte($2);
		write_byte(0x2e);
	}
	| MNEMO_SRA rel_IY
	{
		write_byte(0xfd);
		write_byte(0xcb);
		write_byte($2);
		write_byte(0x2e);
	}
	| MNEMO_LD REGISTER ',' MNEMO_SRA rel_IX
	{
		write_byte(0xdd);
		write_byte(0xcb);
		write_byte($5);
		write_byte($2 | 0x28);
	}
	| MNEMO_LD REGISTER ',' MNEMO_SRA rel_IY
	{
		write_byte(0xfd);
		write_byte(0xcb);
		write_byte($5);
		write_byte($2 | 0x28);
	}
	| MNEMO_SRL REGISTER
	{
		write_byte(0xcb);
		write_byte($2 | 0x38);
	}
	| MNEMO_SRL REGISTER_IND_HL
	{
		write_byte(0xcb);
		write_byte(0x3e);
	}
	| MNEMO_SRL rel_IX ',' REGISTER
	{
		if ($4 == 6)
			error_message(2);
		write_byte(0xdd);
		write_byte(0xcb);
		write_byte($2);
		write_byte($4 | 0x38);
	}
	| MNEMO_SRL rel_IY ',' REGISTER
	{
		if ($4 == 6)
			error_message(2);
		write_byte(0xfd);
		write_byte(0xcb);
		write_byte($2);
		write_byte($4 | 0x38);
	}
	| MNEMO_SRL rel_IX
	{
		write_byte(0xdd);
		write_byte(0xcb);
		write_byte($2);
		write_byte(0x3e);
	}
	| MNEMO_SRL rel_IY
	{
		write_byte(0xfd);
		write_byte(0xcb);
		write_byte($2);
		write_byte(0x3e);
	}
	| MNEMO_LD REGISTER ',' MNEMO_SRL rel_IX
	{
		write_byte(0xdd);
		write_byte(0xcb);
		write_byte($5);
		write_byte($2 | 0x38);
	}
	| MNEMO_LD REGISTER ',' MNEMO_SRL rel_IY
	{
		write_byte(0xfd);
		write_byte(0xcb);
		write_byte($5);
		write_byte($2 | 0x38);
	}
	| MNEMO_RLD
	{
		write_byte(0xed);
		write_byte(0x6f);
	}
	| MNEMO_RRD
	{
		write_byte(0xed);
		write_byte(0x67);
	}
;

mnemo_bits: MNEMO_BIT value_3bits ',' REGISTER
	{
		write_byte(0xcb);
		write_byte(0x40 | ($2 << 3) | ($4));
	}
	| MNEMO_BIT value_3bits ',' REGISTER_IND_HL
	{
		write_byte(0xcb);
		write_byte(0x46 | ($2 << 3));
	}
	| MNEMO_BIT value_3bits ',' rel_IX
	{
		write_byte(0xdd);
		write_byte(0xcb);
		write_byte($4);
		write_byte(0x46 | ($2 << 3));
	}
	| MNEMO_BIT value_3bits ',' rel_IY
	{
		write_byte(0xfd);
		write_byte(0xcb);
		write_byte($4);
		write_byte(0x46 | ($2 << 3));
	}
	| MNEMO_SET value_3bits ',' REGISTER
	{
		write_byte(0xcb);
		write_byte(0xc0 | ($2 << 3) | ($4));
	}
	| MNEMO_SET value_3bits ',' REGISTER_IND_HL
	{
		write_byte(0xcb);
		write_byte(0xc6 | ($2 << 3));
	}
	| MNEMO_SET value_3bits ',' rel_IX
	{
		write_byte(0xdd);
		write_byte(0xcb);
		write_byte($4);
		write_byte(0xc6 | ($2 << 3));
	}
	| MNEMO_SET value_3bits ',' rel_IY
	{
		write_byte(0xfd);
		write_byte(0xcb);
		write_byte($4);
		write_byte(0xc6 | ($2 << 3));
	}
	| MNEMO_SET value_3bits ',' rel_IX ',' REGISTER
	{
		if ($6 == 6)
			error_message(2);
		write_byte(0xdd);
		write_byte(0xcb);
		write_byte($4);
		write_byte(0xc0 | ($2 << 3) | $6);
	}
	| MNEMO_SET value_3bits ',' rel_IY ',' REGISTER
	{
		if ($6 == 6)
			error_message(2);
		write_byte(0xfd);
		write_byte(0xcb);
		write_byte($4);
		write_byte(0xc0 | ($2 << 3) | $6);
	}
	| MNEMO_LD REGISTER ',' MNEMO_SET value_3bits ',' rel_IX
	{
		write_byte(0xdd);
		write_byte(0xcb);
		write_byte($7);
		write_byte(0xc0 | ($5 << 3) | $2);
	}
	| MNEMO_LD REGISTER ',' MNEMO_SET value_3bits ',' rel_IY
	{
		write_byte(0xfd);
		write_byte(0xcb);
		write_byte($7);
		write_byte(0xc0 | ($5 << 3) | $2);
	}
	| MNEMO_RES value_3bits ',' REGISTER
	{
		write_byte(0xcb);
		write_byte(0x80 | ($2 << 3) | ($4));
	}
	| MNEMO_RES value_3bits ',' REGISTER_IND_HL
	{
		write_byte(0xcb);
		write_byte(0x86 | ($2 << 3));
	}
	| MNEMO_RES value_3bits ',' rel_IX
	{
		write_byte(0xdd);
		write_byte(0xcb);
		write_byte($4);
		write_byte(0x86 | ($2 << 3));
	}
	| MNEMO_RES value_3bits ',' rel_IY
	{
		write_byte(0xfd);
		write_byte(0xcb);
		write_byte($4);
		write_byte(0x86 | ($2 << 3));
	}
	| MNEMO_RES value_3bits ',' rel_IX ',' REGISTER
	{
		if ($6 == 6)
			error_message(2);
		write_byte(0xdd);
		write_byte(0xcb);
		write_byte($4);
		write_byte(0x80 | ($2<<3) | $6);
	}
	| MNEMO_RES value_3bits ',' rel_IY ',' REGISTER
	{
		if ($6 == 6)
			error_message(2);
		write_byte(0xfd);
		write_byte(0xcb);
		write_byte($4);
		write_byte(0x80 | ($2 << 3) | $6);
	}
	| MNEMO_LD REGISTER ',' MNEMO_RES value_3bits ',' rel_IX
	{
		write_byte(0xdd);
		write_byte(0xcb);
		write_byte($7);
		write_byte(0x80 | ($5 << 3) | $2);
	}
	| MNEMO_LD REGISTER ',' MNEMO_RES value_3bits ',' rel_IY
	{
		write_byte(0xfd);
		write_byte(0xcb);
		write_byte($7);
		write_byte(0x80 | ($5 << 3) | $2);
	}
;

mnemo_io: MNEMO_IN REGISTER ',' '[' value_8bits ']'
	{
		if ($2 != 7)
			error_message(4);
		write_byte(0xdb);
		write_byte($5);
	}
        | MNEMO_IN REGISTER ',' value_8bits
	{
		if ($2 != 7)
			error_message(4);
		if (zilog)
			warning_message(5);
		write_byte(0xdb);
		write_byte($4);
	}
        | MNEMO_IN REGISTER ',' '[' REGISTER ']'
	{
		if ($5!=1)
			error_message(2);
		write_byte(0xed);
		write_byte(0x40 | ($2 << 3));
	}
        | MNEMO_IN '[' REGISTER ']'
	{
		if ($3 != 1)
			error_message(2);
		if (zilog)
			warning_message(5);
		write_byte(0xed);
		write_byte(0x70);
	}
        | MNEMO_IN REGISTER_F ',' '[' REGISTER ']'
	{
		if ($5 != 1)
			error_message(2);
		write_byte(0xed);
		write_byte(0x70);
	}
        | MNEMO_INI
	{
		write_byte(0xed);
		write_byte(0xa2);
	}
        | MNEMO_INIR
	{
		write_byte(0xed);
		write_byte(0xb2);
	}
        | MNEMO_IND
	{
		write_byte(0xed);
		write_byte(0xaa);
	}
        | MNEMO_INDR
	{
		write_byte(0xed);
		write_byte(0xba);
	}
        | MNEMO_OUT '[' value_8bits ']' ',' REGISTER
	{
		if ($6 != 7)
			error_message(5);
		write_byte(0xd3);
		write_byte($3);
	}
        | MNEMO_OUT value_8bits ',' REGISTER
	{
		if ($4 != 7)
			error_message(5);
		if (zilog)
			warning_message(5);
		write_byte(0xd3);
		write_byte($2);
	}
        | MNEMO_OUT '[' REGISTER ']' ',' REGISTER
	{
		if ($3 != 1)
			error_message(2);
		write_byte(0xed);
		write_byte(0x41 | ($6 << 3));
	}
        | MNEMO_OUT '[' REGISTER ']' ',' value_8bits
	{
		if ($3 != 1)
			error_message(2);
		if ($6 != 0)
			error_message(6);
		write_byte(0xed);
		write_byte(0x71);
	}
        | MNEMO_OUTI
	{
		write_byte(0xed);
		write_byte(0xa3);
	}
        | MNEMO_OTIR
	{	write_byte(0xed);
		write_byte(0xb3);
	}
        | MNEMO_OUTD
	{
		write_byte(0xed);
		write_byte(0xab);
	}
        | MNEMO_OTDR
	{
		write_byte(0xed);
		write_byte(0xbb);
	}
        | MNEMO_IN '[' value_8bits ']'
	{
		if (zilog)
			warning_message(5);
		write_byte(0xdb);
		write_byte($3);
	}
        | MNEMO_IN value_8bits
	{
		if (zilog)
			warning_message(5);
		write_byte(0xdb);
		write_byte($2);
	}
        | MNEMO_OUT '[' value_8bits ']'
	{
		if (zilog)
			warning_message(5);
		write_byte(0xd3);
		write_byte($3);
	}
        | MNEMO_OUT value_8bits
	{
		if (zilog)
			warning_message(5);
		write_byte(0xd3);
		write_byte($2);
	}
;

mnemo_jump: MNEMO_JP value_16bits
	{
		write_byte(0xc3);
		write_word($2);
	}
	| MNEMO_JP CONDITION ',' value_16bits
	{
		write_byte(0xc2 | ($2 << 3));
		write_word($4);
	}
	| MNEMO_JP REGISTER ',' value_16bits
	{
		if ($2 != 1)
			error_message(7);
		write_byte(0xda);
		write_word($4);
	}
	| MNEMO_JR value_16bits
	{
		write_byte(0x18);
		conditional_jump($2);
	}
	| MNEMO_JR REGISTER ',' value_16bits
	{
		if ($2 != 1)
			error_message(7);
		write_byte(0x38);
		conditional_jump($4);
	}
	| MNEMO_JR CONDITION ',' value_16bits
	{
		if ($2 == 2)
			write_byte(0x30);
		else
			if ($2 == 1)
				write_byte(0x28);
			else
				if ($2 == 0)
					write_byte(0x20);
				else
					error_message(9);
		conditional_jump($4);
	}
	| MNEMO_JP REGISTER_PAR
	{
		if ($2 != 2)
			error_message(2);
		write_byte(0xe9);
	}
	| MNEMO_JP REGISTER_IND_HL
	{
		write_byte(0xe9);
	}
	| MNEMO_JP REGISTER_16_IX
	{
		write_byte(0xdd);
		write_byte(0xe9);
	}
	| MNEMO_JP REGISTER_16_IY
	{
		write_byte(0xfd);
		write_byte(0xe9);
	}
	| MNEMO_JP '[' REGISTER_16_IX ']'
	{
		write_byte(0xdd);
		write_byte(0xe9);
	}
	| MNEMO_JP '[' REGISTER_16_IY ']'
	{
		write_byte(0xfd);
		write_byte(0xe9);
	}
	| MNEMO_DJNZ value_16bits
	{
		write_byte(0x10);
		conditional_jump($2);
	}
;

mnemo_call: MNEMO_CALL value_16bits
	{
		write_byte(0xcd);
		write_word($2);
	}
	| MNEMO_CALL CONDITION ',' value_16bits
	{
		write_byte(0xc4 | ($2 << 3));
		write_word($4);
	}
	| MNEMO_CALL REGISTER ',' value_16bits
	{
		if ($2 != 1)
			error_message(7);
		write_byte(0xdc);
		write_word($4);
	}
	| MNEMO_RET
	{
		write_byte(0xc9);
	}
	| MNEMO_RET CONDITION
	{
		write_byte(0xc0 | ($2 << 3));
	}
	| MNEMO_RET REGISTER
	{
		if ($2 != 1)
			error_message(7);
		write_byte(0xd8);
	}
	| MNEMO_RETI
	{
		write_byte(0xed);
		write_byte(0x4d);
	}
	| MNEMO_RETN
	{
		write_byte(0xed);
		write_byte(0x45);
	}
	| MNEMO_RST value_8bits
	{
		if (($2 % 8 != 0) || ($2 / 8 > 7) || ($2 / 8 < 0))
			error_message(10);
		write_byte(0xc7 | (($2 / 8) << 3));
	}
;

value:	NUMBER
	{
		$$ = $1;
	}
	| IDENTIFICATOR
	{
		$$ = read_label($1);
	}
	| LOCAL_IDENTIFICATOR
	{
		$$ = read_local($1);
	}
	| '-' value %prec NEGATIVE
	{
		$$ = -$2;
	}
	| value OP_EQUAL value
	{
		$$ = ($1 == $3);
	}
	| value OP_MINOR_EQUAL value
	{
		$$ = ($1 <= $3);
	}
	| value OP_MINOR value
	{
		$$ = ($1 < $3);
	}
	| value OP_MAJOR_EQUAL value
	{
		$$ = ($1 >= $3);
	}
	| value OP_MAJOR value
	{
		$$ = ($1 > $3);
	}
	| value OP_NON_EQUAL value
	{
		$$ = ($1 != $3);
	}
	| value OP_OR_LOG value
	{
		$$ = ($1 || $3);
	}
	| value OP_AND_LOG value
	{
		$$ = ($1 && $3);
	}
	| value '+' value
	{
		$$ = $1 + $3;
	}
	| value '-' value
	{
		$$ = $1 - $3;
	}
	| value '*' value
	{
		$$ = $1 * $3;
	}
	| value '/' value
	{
		if (!$3)
			error_message(1);
		else
			$$ = $1 / $3;
	}
	| value '%' value
	{
		if (!$3)
			error_message(1);
		else $$ = $1 % $3;
	}
	| '(' value ')'
	{
		$$ = $2;
	}
	| '~' value %prec NEGATION
	{
		$$ = ~$2;
	}
	| '!' value %prec OP_NEG_LOG
	{
		$$ = !$2;
	}
	| value '&' value
	{
		$$ = $1 & $3;
	}
	| value OP_OR value
	{
		$$ = $1 | $3;
	}
	| value OP_XOR value
	{
		$$ = $1 ^ $3;
	}
	| value SHIFT_L value
	{
		$$ = $1 << $3;
	}
	| value SHIFT_R value
	{
		$$ = $1 >> $3;
	}
	| PSEUDO_RANDOM '(' value ')'
	{
		for (; ($$ = rand() & 0xff) >= $3;)
			;
	}
	| PSEUDO_INT '(' value_real ')'
	{
		$$ = (int)$3;
	}
	| PSEUDO_FIX '(' value_real ')'
	{
		$$ = (int)($3 * 256);
	}
	| PSEUDO_FIXMUL '(' value ',' value ')'
	{
		$$ = (int)((((float)$3 / 256) * ((float)$5 / 256)) * 256);
	}
	| PSEUDO_FIXDIV '(' value ',' value ')'
	{
		$$ = (int)((((float)$3 / 256) / ((float)$5 / 256)) * 256);
	}
;

value_real: REAL
	{
		$$ = $1;
	}
	| '-' value_real
	{
		$$ = -$2;
	}
	| value_real '+' value_real
	{
		$$ = $1 + $3;
	}
	| value_real '-' value_real
	{
		$$ = $1 - $3;
	}
	| value_real '*' value_real
	{
		$$ = $1 * $3;
	}
	| value_real '/' value_real
	{
		if (!$3)
			error_message(1);
		else $$ = $1 / $3;
	}
	| value '+' value_real
	{
		$$ = (double)$1 + $3;
	}
	| value '-' value_real
	{
		$$ = (double)$1 - $3;
	}
	| value '*' value_real
	{
		$$ = (double)$1 * $3;
	}
	| value '/' value_real
	{
		if ($3 < 1e-6)
			error_message(1);
		else
			$$ = (double)$1 / $3;
	}
	| value_real '+' value
	{
		$$ = $1 + (double)$3;
	}
	| value_real '-' value
	{
		$$ = $1 - (double)$3;
	}
	| value_real '*' value
	{
		$$ = $1 * (double)$3;
	}
	| value_real '/' value
	{
		if (!$3)
			error_message(1);
		else
			$$ = $1 / (double)$3;
	}
	| PSEUDO_SIN '(' value_real ')'
	{
		$$ = sin($3);
	}
	| PSEUDO_COS '(' value_real ')'
	{
		$$ = cos($3);
	}
	| PSEUDO_TAN '(' value_real ')'
	{
		$$ = tan($3);
	}
	| PSEUDO_SQR '(' value_real ')'
	{
		$$ = $3 * $3;
	}
	| PSEUDO_SQRT '(' value_real ')'
	{
		$$ = sqrt($3);
	}
	| PSEUDO_PI
	{
		$$ = asin(1) * 2;
	}
	| PSEUDO_ABS '(' value_real ')'
	{
		$$ = abs($3);
	}
	| PSEUDO_ACOS '(' value_real ')'
	{
		$$ = acos($3);
	}
	| PSEUDO_ASIN '(' value_real ')'
	{
		$$ = asin($3);
	}
	| PSEUDO_ATAN '(' value_real ')'
	{
		$$ = atan($3);
	}
	| PSEUDO_EXP '(' value_real ')'
	{
		$$ = exp($3);
	}
	| PSEUDO_LOG '(' value_real ')'
	{
		$$ = log10($3);
	}
	| PSEUDO_LN '(' value_real ')'
	{
		$$ = log($3);
	}
	| PSEUDO_POW '(' value_real ',' value_real ')'
	{
		$$ = pow($3, $5);
	}
	| '(' value_real ')'
	{
		$$ = $2;
	}
;

value_3bits: value
	{
		if (((int)$1 < 0) || ((int)$1 > 7))
			warning_message(3);
		$$ = $1 & 0x07;
	}
;

value_8bits: value
	{
		if (((int)$1 > 255) || ((int) $1 < -128))
			warning_message(2);
		$$ = $1 & 0xff;
	}
;

value_16bits: value
	{
		if (((int)$1 > 65535) || ((int)$1 < -32768))
			warning_message(1);
		$$ = $1 & 0xffff;
	}
;

listing_8bits: value_8bits
	{
		write_byte($1);
	}
	| TEXT
	{
		write_text($1);
	}
	| listing_8bits ',' value_8bits
	{
		write_byte($3);
	}
	| listing_8bits ',' TEXT
	{
		write_text($3);
	}
;

listing_16bits : value_16bits
	{
		write_word($1);
	}
	| TEXT
	{
		write_text($1);
	}
	| listing_16bits ',' value_16bits
	{
		write_word($3);
	}
	| listing_16bits ',' TEXT
	{
		write_text($3);
	}
;

%%

int yywrap(void)
{
	return 1;
}


void yyerror(const char *s)
{
	error_message(0);
}

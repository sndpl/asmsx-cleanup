/* Wav writer implementation file.

 Copyright (C) 2000-2011 Eduardo A. Robsy Petrus
 Copyright (C) 2014 Adrian Oboroc
 
 This file is part of asmsx project <https://github.com/asmsx/asmsx/>.
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

#include <stdio.h>
#include <string.h>

#include "asmsx.h"
#include "warnmsg.h"


#define FREQ_HI 0x7FFF
#define FREQ_LO 0x8000
#define SILENCE 0x0000


void wav_store_word(const unsigned int value, FILE *f)
{
	fputc((int)(value & 0xff), f);		/* write lower byte of the word first */
	fputc((int)((value >> 8) & 0xff), f);	/* write higher byte of the word */
}


/* Write one (high-state) */
void wav_write_one(FILE *f)
{
	unsigned int l;
	for (l = 0; l < 5 * 2; l++)
		wav_store_word(FREQ_LO, f);
	for (l = 0; l < 5 * 2; l++)
		wav_store_word(FREQ_HI, f);
	for (l = 0; l < 5 * 2; l++)
		wav_store_word(FREQ_LO, f);
	for (l = 0; l < 5 * 2; l++)
		wav_store_word(FREQ_HI, f);
}


/* Write zero (low-state) */
void wav_write_zero(FILE *f)
{
	unsigned int l;
	for (l = 0; l < 10 * 2; l++)
		wav_store_word(FREQ_LO, f);
	for (l = 0; l < 10 * 2; l++)
		wav_store_word(FREQ_HI, f);
}


void wav_write_nothing(FILE *f)
{
	unsigned int l;
	for (l = 0; l < 18 * 2; l++)
		wav_store_word(SILENCE, f);
}


/* Write full byte */
void wav_write_byte(const unsigned char b, FILE *f)
{
	int l;
	unsigned char m;

	m = b;
	wav_write_zero(f);
	for (l = 0; l < 8; l++) 
	{
		if (m & 1)
			wav_write_one(f);
		else
			wav_write_zero(f);
		m = (unsigned char)(m >> 1);
	}
	wav_write_one(f);
	wav_write_one(f);
}


/* Main WAV writer funtion */
/* TODO: pack parameters into a struct to keep it compact */
/* TODO: memory is passed unprotected, this function has opportunity to mess it up. Not sure how to deal with it */
void wav_write_file(const char *bin_filename, const char *bin_intname, const int type, const int addr_start, const int addr_end, const int start, const unsigned char *memory)
{
	char wav_filename[ASMSX_MAX_PATH];
	FILE *f;
	int i, wav_size = 0;

	int wav_header[44] =
	{
		0x52, 0x49, 0x46, 0x46, 0x44, 0x00, 0x00, 0x00, 0x57, 0x41, 0x56,
		0x45, 0x66, 0x6D, 0x74, 0x20, 0x10, 0x00, 0x00, 0x00, 0x01, 0x00,
		0x02, 0x00, 0x44, 0xAC, 0x00, 0x00, 0x10, 0xB1, 0x02, 0x00, 0x04,
		0x00, 0x10, 0x00, 0x64, 0x61, 0x74, 0x61, 0x20, 0x00, 0x00, 0x00
	};

	if ((MEGAROM == type) || ((ROM == type) && (0x8000 > addr_start)))
	{
	//	warning_message(0);	/* TODO: replace this with return code and have warning printed by caller */
		warning_message(0, pass, source, lines, &warnings);
		return;
	}

	strcpy(wav_filename, bin_filename);
	wav_filename[strlen(wav_filename) - 3] = 0;	/* drop supplied extension */
	strcat(wav_filename, "wav");	/* make "wav" new extension */

	f = fopen(wav_filename, "wb");
	if (!f)
	{
	//	warning_message(0);	/* TODO: figure out if 0 is ok */
		warning_message(0, pass, source, lines, &warnings);
		return;
	}

	if ((BASIC == type) || (ROM == type))
	{
		char wav_intname[ASMSX_MAX_PATH];	/* TODO: max valid size is 7, could reduce size from ASMSX_MAX_PATH with some sanity checks */

		wav_size = (3968 * 2 + 1500 * 2 + 11 * (10 + 6 + 6 + addr_end - addr_start + 1)) * 40;
		wav_size = wav_size << 1;

		wav_header[4] = (wav_size + 36) & 0xff;
		wav_header[5] = ((wav_size + 36) >> 8) & 0xff;
		wav_header[6] = ((wav_size + 36) >> 16) & 0xff;
		wav_header[7] = ((wav_size + 36) >> 24) & 0xff;
		wav_header[40] = wav_size & 0xff;
		wav_header[41] = (wav_size >> 8) & 0xff;
		wav_header[42] = (wav_size >> 16) & 0xff;
		wav_header[43] = (wav_size >> 24) & 0xff;

		/* Write WAV header */
		for (i = 0; i < 44; i++)
			fputc(wav_header[i], f);
        
		/* Write long header */
		for (i = 0; i < 3968; i++)
			wav_write_one(f);
        
		/* Write file identifier */
		for (i = 0; i < 10; i++)
			wav_write_byte(0xd0, f);

		/* Make a local copy of internal tape name of the program */
		strcpy(wav_intname, bin_intname);

		/* Pad MSX name with spaces at the end until it is 6 characters long */
		if (6 > strlen(wav_intname))
			for (i = (int)strlen(wav_intname); i < 6; i++)	/* TODO: check if this actualy pads 6th character, it is possible that condition shold be "i <= 6" */
				wav_intname[i] = 32;
        
		/* Write MSX name */
		for (i = 0; i < 6; i++)
			wav_write_byte((unsigned char)wav_intname[i], f);
        
		/* Write blank */
		for (i = 0; i < 1500; i++)
			wav_write_nothing(f);
        
		/* Write short header */
		for (i = 0; i < 3968; i++)
			wav_write_one(f);
        
		/* Write start, end and init addresses */
		wav_write_byte((unsigned char)(addr_start & 0xff), f);
		wav_write_byte((unsigned char)((addr_start >> 8) & 0xff), f);
		wav_write_byte((unsigned char)(addr_end & 0xff), f);
		wav_write_byte((unsigned char)((addr_end >> 8) & 0xff), f);
		wav_write_byte((unsigned char)(start & 0xff), f);
		wav_write_byte((unsigned char)((start >> 8) & 0xff), f);
        
		/* Write data */
		for (i = addr_start; i <= addr_end; i++)
			wav_write_byte(memory[i], f);
	}


	if (Z80 == type)
	{
		wav_size = (3968 * 1 + 1500 * 1 + 11 * (addr_end - addr_start + 1)) * 36;
		wav_size = wav_size << 1;

		wav_header[4] = (wav_size + 36) & 0xff;
		wav_header[5] = ((wav_size + 36) >> 8) & 0xff;
		wav_header[6] = ((wav_size + 36) >> 16) & 0xff;
		wav_header[7] = ((wav_size + 36) >> 24) & 0xff;
		wav_header[40] = wav_size & 0xff;
		wav_header[41] = (wav_size >> 8) & 0xff;
		wav_header[42] = (wav_size >> 16) & 0xff;
		wav_header[43] = (wav_size >> 24) & 0xff;

		/* Write WAV header */
		for (i = 0; i < 44; i++)
			fputc(wav_header[i], f);

		/* Write long header */
		for (i = 0; i < 3968; i++)
			wav_write_one(f);

		/* Write data */
		for (i = addr_start; i <= addr_end; i++)
			wav_write_byte(memory[i], f);
	}

	/* Write blank */
	for (i = 0; i < 1500; i++)
		wav_write_nothing(f);

	/* Close file */
	fclose(f);

	printf("Audio file %s saved [%2.2f sec]\n", wav_filename, (float) wav_size / 176400);	/* TODO: try to externalize logging to caller */
}

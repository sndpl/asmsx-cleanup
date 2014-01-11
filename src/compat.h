/* Backwards compatibility macros for outdated compilers.

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


#ifndef COMPAT_H
#define COMPAT_H

#if ((_MSC_VER && (_MSC_VER < 1400)) || (__WATCOMC__))	/* Check if compiler is Visual C++ version is below 2005 or any version of Watcom C/C++ */

#define COMPAT_S	1

#define fopen_s(FPP, FNAME, FMODE)	((int)((void *)(NULL) == (void *)((*FPP = fopen(FNAME, FMODE)))))

#define strcpy_s(DESTSTR, MAXLEN, SRCSTR)	(strcpy(DESTSTR, SRCSTR))

#define strncpy_s(DESTSTR, MAXLEN, SRCSTR, NUM)	(strncpy(DESTSTR, SRCSTR, NUM))

#define strcat_s(DESTSTR, MAXLEN, SRCSTR)	(strcat(DESTSTR, SRCSTR))

#define fprintf_s	fprintf
#define printf_s	printf
#define sprintf_s	sprintf

#define strtok_s(TOK, DELIM, NEXT)	(strtok(TOK, DELIM))

#endif	/* ((_MSC_VER < 1400) || (__WATCOMC__)) */

#endif	/* COMPAT_H */

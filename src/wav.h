/* Wav writer declaration file.

 Copyright (C) 2000-2011 Eduardo A. Robsy Petrus
 Copyright (C) 2014 Adrian Oboroc
 
 This file is part of as-ng, rewrite of asmsx.
 
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


#ifndef ASMSX_WAV_H
#define ASMSX_WAV_H


extern void wav_write_file(const char *bin_filename, const char *bin_intname, const int type, const unsigned int addr_start, const unsigned int addr_end, const unsigned int start, const unsigned char *memory);


#endif	/* ASMSX_WAV_H */
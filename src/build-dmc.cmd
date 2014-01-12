@echo off
echo Compile asmsx with Digital Mars Compiler

SET PATH=C:\dm\bin;%PATH%
SET INCLUDE=C:\dm\include;..\..\compat_s\src
set LIB=C:\dm\lib

set mingw=C:\MinGW
set PATH=%PATH%;%mingw%\bin;%mingw%\msys\1.0\bin

flex.exe -i -Pparser1 -oparser1.c parser1.l
flex.exe -i -Pparser2 -oparser2.c parser2.l
flex.exe -i -Pparser3 -oparser3.c parser3.l
bison.exe -d -v core.y -ocore.c
flex.exe -i -olex.c lex.l

dmc.exe -A -r -w- -o+space -6 asmsx.c wav.c core.c lex.c parser1.c parser2.c parser3.c > asmsx.dmc.err

del core.c core.h lex.c parser?.c *.obj *.i *.output *.map

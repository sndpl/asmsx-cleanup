@echo off
echo Compile asmsx with MinGW

set mingw=C:\MinGW
set PATH=%PATH%;%mingw%\bin;%mingw%\msys\1.0\bin

flex.exe -i -Pparser1 -oparser1.c parser1.l
flex.exe -i -Pparser2 -oparser2.c parser2.l
flex.exe -i -Pparser3 -oparser3.c parser3.l
bison.exe core.y -ocore.c -d
flex.exe -i -olex.c lex.l
make
make clean

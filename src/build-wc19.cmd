@echo off
echo Compile asmsx with Open Watcom C32 1.9

SET PATH=C:\WATCOM\BINW;C:\WATCOM\BINNT;%PATH%
SET INCLUDE=C:\WATCOM\H;C:\WATCOM\H\NT;..\..\compat_s\src
SET WATCOM=C:\WATCOM

set mingw=C:\MinGW
set PATH=%PATH%;%mingw%\bin;%mingw%\msys\1.0\bin

flex.exe -i -Pparser1 -oparser1.c parser1.l
flex.exe -i -Pparser2 -oparser2.c parser2.l
flex.exe -i -Pparser3 -oparser3.c parser3.l
bison.exe -d -v -b y core.y -ocore.c
flex.exe -i -olex.c lex.l

wcc386.exe /W4 asmsx.c
wcc386.exe /W4 wav.c
wcc386.exe /W4 core.c
wcc386.exe /W4 lex.c
wcc386.exe /W4 parser1.c
wcc386.exe /W4 parser2.c
wcc386.exe /W4 parser3.c
link386.exe asmsx.obj core.obj lex.obj parser1.obj parser2.obj parser3.obj wav.obj

del core.c core.h lex.c parser?.c *.obj

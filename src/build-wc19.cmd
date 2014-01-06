@echo off
echo Compile asmsx with Open Watcom C32 1.9

SET PATH=C:\WATCOM\BINW;C:\WATCOM\BINNT;%PATH%
SET INCLUDE=C:\WATCOM\H;C:\WATCOM\H\NT
SET WATCOM=C:\WATCOM

set mingw=C:\MinGW
set PATH=%PATH%;%mingw%\bin;%mingw%\msys\1.0\bin

flex.exe -i -Pparser1 -oparser1.c parser1.l
flex.exe -i -Pparser2 -oparser2.c parser2.l
flex.exe -i -Pparser3 -oparser3.c parser3.l
bison.exe core.y -ocore.c -d
flex.exe -i -olex.c lex.l

wcc386.exe asmsx.c
echo.
wcc386.exe core.c
echo.
wcc386.exe lex.c 
echo.
wcc386.exe parser1.c
echo.
wcc386.exe parser2.c
echo.
wcc386.exe parser3.c
echo.
wcc386.exe wav.c 
echo.
link386.exe asmsx.obj core.obj lex.obj parser1.obj parser2.obj parser3.obj wav.obj

del core.c core.h lex.c parser?.c *.obj

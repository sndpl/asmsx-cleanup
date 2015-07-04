@echo off
echo Compile asmsx with Visual C++ 98 (6.0)

set VCDIR=C:\Program Files\Microsoft Visual Studio
set INCLUDE=%VCDIR%\VC98\INCLUDE
set LIB=%VCDIR%\VC98\LIB
set PATH=%VCDIR%\Common\msdev98\bin;%VCDIR%\VC98\bin;%PATH%

flex -i -Pparser1 -olex.parser1.c parser1.l
flex -i -Pparser2 -olex.parser2.c parser2.l
flex -i -Pparser3 -olex.parser3.c parser3.l
bison -d -v z80gen.y -oz80gen.tab.c
flex.exe -i -olex.scan.c scan.l 

cl.exe /nologo /TC /G6 /W4 /Os asmsx.c warnmsg.c wav.c z80gen.tab.c lex.scan.c lex.parser1.c lex.parser2.c lex.parser3.c > asmsx.vc6.err
rem /W1 to /W4 for warnings, /WX to treat warning as errors, /O2 for moderate optimization

del *.tab.c *.tab.h lex.*.c *.obj *.i *.output *.map

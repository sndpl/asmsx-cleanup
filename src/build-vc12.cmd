@echo off
echo Compile asmsx with Visual C++ 2013 (12)

set VCDIR=C:\Program Files (x86)\Microsoft Visual Studio 12.0
set INCLUDE=%VCDIR%\VC\include;C:\Program Files (x86)\Windows Kits\8.1\Include\um
set LIB=%VCDIR%\VC\lib;C:\Program Files (x86)\Windows Kits\8.1\Lib\winv6.3\um\x86
set PATH=%VCDIR%\Common7\IDE;%VCDIR%\VC\bin;%PATH%

flex -i -Pparser1 -olex.parser1.c parser1.l
flex -i -Pparser2 -olex.parser2.c parser2.l
flex -i -Pparser3 -olex.parser3.c parser3.l
bison -d -v z80gen.y -oz80gen.tab.c
flex.exe -i -olex.scan.c scan.l 

cl.exe /nologo /TC /W4 /Os asmsx.c warnmsg.c wav.c z80gen.tab.c lex.scan.c lex.parser1.c lex.parser2.c lex.parser3.c > asmsx.vc2013.err
rem /W1 to /W4 for warnings, /WX to treat warning as errors, /O2 for moderate optimization

del *.tab.c *.tab.h lex.*.c *.obj *.i *.output *.map

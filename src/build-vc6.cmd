@echo off
echo Compile asmsx with Visual C++ 98 (6.0)

set VCDIR=C:\Program Files\Microsoft Visual Studio
set INCLUDE=%VCDIR%\VC98\INCLUDE;..\..\compat_s\src
set LIB=%VCDIR%\VC98\LIB
set PATH=%VCDIR%\Common\msdev98\bin;%VCDIR%\VC98\bin;%PATH%

set PATH=%PATH%;C:\win_flex_bison-2.5.1

win_flex --wincompat -i -Pparser1 -olex.parser1.c parser1.l
win_flex --wincompat -i -Pparser2 -olex.parser2.c parser2.l
win_flex --wincompat -i -Pparser3 -olex.parser3.c parser3.l
win_bison -d -v z80gen.y -oz80gen.tab.c
win_flex.exe --wincompat -i -olex.scan.c scan.l 

cl.exe /nologo /TC /G6 /W4 /Os asmsx.c wav.c z80gen.tab.c lex.scan.c lex.parser1.c lex.parser2.c lex.parser3.c > asmsx.vc6.err
rem /W1 to /W4 for warnings, /WX to treat warning as errors, /O2 for moderate optimization

del *.tab.c *.tab.h lex.*.c *.obj *.i *.output *.map

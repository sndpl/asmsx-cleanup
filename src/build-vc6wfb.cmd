@echo off
echo Compile asmsx with Visual C++ 98 (6.0)

set VCDIR=C:\Program Files\Microsoft Visual Studio
set INCLUDE=%VCDIR%\VC98\INCLUDE;..\..\compat_s\src
set LIB=%VCDIR%\VC98\LIB
set PATH=%VCDIR%\Common\msdev98\bin;%VCDIR%\VC98\bin;%PATH%

set wfb=C:\win_flex_bison-2.4.1
rem set wfb=C:\win_flex_bison-2.5.1
set PATH=%PATH%;%wfb%

win_flex.exe --wincompat -i -Pparser1 -oparser1.c parser1.l
win_flex.exe --wincompat -i -Pparser2 -oparser2.c parser2.l
win_flex.exe --wincompat -i -Pparser3 -oparser3.c parser3.l
win_bison.exe core.y -ocore.c -d
win_flex.exe --wincompat -i -olex.c lex.l
cl.exe /nologo /G6 /W4 asmsx.c core.c lex.c parser1.c parser2.c parser3.c wav.c > asmsx.vc6.err
rem /W1 to /W4 for warnings, /WX to treat warning as errors, /O2 for moderate optimization

del core.c core.h lex.c parser?.c *.obj *.i

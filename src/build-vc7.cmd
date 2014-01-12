@echo off
echo Compile asmsx with Visual C++ .NET 2002 (7.0)

set VCDIR=C:\Program Files\Microsoft Visual Studio .NET
set INCLUDE=%VCDIR%\VC7\INCLUDE;..\..\compat_s\src
set LIB=%VCDIR%\VC7\LIB
set PATH=%VCDIR%\Common7\IDE;%VCDIR%\VC7\BIN;%PATH%

set mingw=C:\MinGW
set PATH=%PATH%;%mingw%\bin;%mingw%\msys\1.0\bin

flex.exe -i -Pparser1 -oparser1.c parser1.l
flex.exe -i -Pparser2 -oparser2.c parser2.l
flex.exe -i -Pparser3 -oparser3.c parser3.l
bison.exe -d -v core.y -ocore.c
flex.exe -i -olex.c lex.l
cl.exe /nologo /TC /G6 /W4 /Os asmsx.c wav.c core.c lex.c parser1.c parser2.c parser3.c > asmsx.vc7.err
rem /W1 to /W4 for warnings, /WX to treat warning as errors, /O2 for moderate optimization

del core.c core.h lex.c parser?.c *.obj *.i *.output *.map

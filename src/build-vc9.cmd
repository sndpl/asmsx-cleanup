@echo off
echo Compile asmsx with Visual C++ 2008 (9.0)

set VCDIR=C:\Program Files\Microsoft Visual Studio 9.0
set PSDK=C:\Program Files\Microsoft SDKs\Windows\v6.0A
set INCLUDE=%VCDIR%\VC\INCLUDE;%PSDK%\INCLUDE
set LIB=%VCDIR%\VC\LIB;%PSDK%\LIB
set PATH=%VCDIR%\Common7\IDE;%VCDIR%\VC\BIN;%PATH%

set mingw=C:\MinGW
set PATH=%PATH%;%mingw%\bin;%mingw%\msys\1.0\bin

flex.exe -i -Pparser1 -oparser1.c parser1.l
flex.exe -i -Pparser2 -oparser2.c parser2.l
flex.exe -i -Pparser3 -oparser3.c parser3.l
bison.exe core.y -ocore.c -d
flex.exe -i -olex.c lex.l
cl.exe /nologo /W3 asmsx.c core.c lex.c parser1.c parser2.c parser3.c wav.c > asmsx.vc9.err
rem /W1 to /W4 for warnings, /WX to treat warning as errors, /O2 for moderate optimization

del core.c core.h lex.c parser?.c *.obj

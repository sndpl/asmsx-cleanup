@echo off
echo Compile asmsx with Visual C++ 2013 (12.0)

set VCDIR=C:\Program Files (x86)\Microsoft Visual Studio 12.0
set PSDK=C:\Program Files (x86)\Windows Kits\8.1
set INCLUDE=%VCDIR%\VC\INCLUDE;%PSDK%\Include\um
set LIB=%VCDIR%\VC\LIB;%PSDK%\Lib\winv6.3\um\x86
set PATH=%VCDIR%\Common7\IDE;%VCDIR%\VC\BIN;%PATH%

set mingw=C:\MinGW
set PATH=%PATH%;%mingw%\bin;%mingw%\msys\1.0\bin

flex.exe -i -Pparser1 -oparser1.c parser1.l
flex.exe -i -Pparser2 -oparser2.c parser2.l
flex.exe -i -Pparser3 -oparser3.c parser3.l
bison.exe core.y -ocore.c -d
flex.exe -i -olex.c lex.l 
cl.exe /W2 asmsx.c parser1.c parser2.c parser3.c > asmsx.vc12.err
rem /W1 to /W4 for warnings, /WX to treat warning as errors, /O2 for moderate optimization

del core.c core.h lex.c parser?.c *.obj

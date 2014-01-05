@echo off
set mingw=C:\MinGW
set PATH=%PATH%;%mingw%\bin;%mingw%\msys\1.0\bin
make -f makefile.mingw
make -f makefile.mingw clean

@echo off
set mingwpath=C:\MinGW\bin
set msyspath=C:\MinGW\msys\1.0\bin
set PATH=%PATH%;%mingwpath%;%msyspath%
make -f makefile.mingw
make -f makefile.mingw clean

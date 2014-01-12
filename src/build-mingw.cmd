@echo off
echo Compile asmsx with MinGW

set mingw=C:\MinGW
set PATH=%PATH%;%mingw%\bin;%mingw%\msys\1.0\bin

make
make clean

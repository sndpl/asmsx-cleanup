asmsx
=====

Z80 cross assembler for MSX family of 8-bit computers

Original scope of this project was to provide full English translation of cjv99 asmsx 0.16 WIP release. This work is complete.

Currently project is working on the following goals:

- explicitly define all functions and variables;
- add "extern" function definions were necessary;
- check all implicit type casts and either make them explicit if they are ok or fix them if they are bad;
- try to get rid of mutable global state - make all refactored functions take all input via const parameters, some global constants are acceptable;
- move code out of scanner and lexer files (*.y and *.l)
- expand manual, move it from plain text to texinfo and start generating both txt and pdf versions.


Directory structure:

./examples	source for two simple games

./doc		asmsx manual

./src		asmsx source code


Compiling instructions:

You'll need to install MinGW with gcc, flex and bison. Use build-mingw.cmd to compile asmsx for Windows using MinGW.


Credits:

- Eduardo 'Pitpan' Robsy for creating and eventually selling rights to asmsx;
- cjv99 for buying rights for asmsx and releasing it as free software under GPLv3 license.

Adrian Oboroc
http://oboroc.com
http://twitter.com/AdrianOboroc

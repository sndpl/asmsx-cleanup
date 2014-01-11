asmsx
=====

Z80 cross assembler for MSX family of 8-bit computers


Current project goals:

- get rid of mutable global state: remove global variables and have functions take all input as "by value" parameters;
- move code out of scanner and lexer files (*.y and *.l);
- replace custom list and hash code with uthash macros;
- expand manual, move it from plain text to texinfo and start generating both txt and pdf versions.


Completed goals:

- full English translation of cjv99 asmsx 0.16 WIP release;
- explicitly define all functions and variables;
- add "extern" function definions were necessary;
- check all implicit type casts and either make them explicit if they are ok or fix them if they are bad;
- eliminate gloal variable name clash;
- separate wav writer to a dedicated unit with no mutable state;


Directory structure:

./examples	source for two simple games

./doc		asmsx manual

./src		asmsx source code


Compiling instructions:

You'll need to install MinGW with gcc, flex and bison. Use build-mingw.cmd to compile asmsx for Windows using MinGW.


Credits:

- Eduardo 'Pitpan' Robsy for creating and eventually selling rights to asmsx;
- cjv99 for buying rights for asmsx and releasing it as free software under GPLv3 license.

Adrian Oboroc <http://oboroc.com> <http://twitter.com/AdrianOboroc>

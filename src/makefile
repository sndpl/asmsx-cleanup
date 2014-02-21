asmsx:	asmsx.c wav.c z80gen.y scan.l lex.parser1.c lex.parser2.c lex.parser3.c
	bison -d -v z80gen.y -oz80gen.tab.c
	flex -i -olex.scan.c scan.l
	gcc -c -Os z80gen.tab.c lex.scan.c lex.parser1.c lex.parser2.c lex.parser3.c 
	gcc asmsx.c wav.c z80gen.tab.o lex.scan.o lex.parser1.o lex.parser2.o lex.parser3.o -Wall -Wextra -Wconversion -pedantic -oasmsx.bin -lm -Os

lex.parser1.c: parser1.l
	flex -i -Pparser1 -olex.parser1.c parser1.l

lex.parser2.c: parser2.l
	flex -i -Pparser2 -olex.parser2.c parser2.l

lex.parser3.c: parser3.l
	flex -i -Pparser3 -olex.parser3.c parser3.l

clean:
	rm -f *.tab.c *.tab.h lex.*.c *.o *.i *.output *.map

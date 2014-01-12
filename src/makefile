asmsx:	asmsx.c wav.c core.y lex.l parser1.c parser2.c parser3.c
	bison -d -v core.y -ocore.c
	flex -i -olex.c lex.l 
	gcc asmsx.c wav.c core.c lex.c parser1.c parser2.c parser3.c -oasmsx.exe -s -lm -Wall -Wextra -Wconversion -Os -I../../compat_s/src 2> asmsx.mingw.err
parser1.c: parser1.l
	flex -i -Pparser1 -oparser1.c parser1.l
parser2.c: parser2.l
	flex -i -Pparser2 -oparser2.c parser2.l
parser3.c: parser3.l
	flex -i -Pparser3 -oparser3.c parser3.l
clean:
	rm -f core.c core.h lex.c parser?.c *.o

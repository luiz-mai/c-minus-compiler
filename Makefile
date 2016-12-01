all: bison flex gcc

bison: trab.y
	@bison -v trab.y

flex: trab.l
	@flex trab.l

gcc: scanner.c parser.c tree.c literalsTable.c symbolsTable.c interpreter.c
	@gcc -Wall -o trab3 scanner.c parser.c tree.c literalsTable.c symbolsTable.c interpreter.c -ly

clean:
	@rm -f *.pdf *.o *.output *.dot scanner.c parser.h parser.c trab3

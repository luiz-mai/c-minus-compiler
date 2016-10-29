all: bison flex gcc
	@echo "Done."

bison: trab.y
	bison -v trab.y

flex: trab.l
	flex trab.l

gcc: scanner.c parser.c tree.c literalsTable.c symbolsTable.c
	gcc -Wall -o trab3 scanner.c parser.c tree.c literalsTable.c symbolsTable.c -ly

clean:
	@rm -f *.pdf *.o *.output scanner.c parser.h parser.c trab3

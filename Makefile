
all: tree bison flex gcc
	@echo "Done."

tree: tree.c
	gcc -c tree.c

bison: trab3.y
	bison -v trab3.y

flex: trab3.l
	flex trab3.l

gcc: scanner.c parser.c tree.o
	gcc -Wall -o trab3 scanner.c parser.c tree.o -ly

clean:
	@rm -f *.o *.output scanner.c parser.h parser.c trab3

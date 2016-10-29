#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define WORD_MAX_SIZE 128

typedef struct symNode {
        char symbol[WORD_MAX_SIZE];
        int line;
        struct symNode* next;
} SymbolNode;

typedef struct symTable {
        SymbolNode* head;
        SymbolNode* tail;
        int size;
} SymbolsTable;

SymbolsTable* createSymbolsTable(void);

int symbolExists(SymbolsTable*, char*);

int addSymbol(SymbolsTable*, char*, int);

int getSymbolLine(SymbolsTable*, char*);

void printSymbolsTable(SymbolsTable*);

void freeSymbolsTable(SymbolsTable*);

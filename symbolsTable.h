#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "tree.h"
#define WORD_MAX_SIZE 128

typedef struct symNode {
        char symbol[WORD_MAX_SIZE];
        int line;
        int scope;
        int arity;
        struct symNode* next;
} SymbolNode;

typedef struct symTable {
        SymbolNode* head;
        SymbolNode* tail;
        int size;
} SymbolsTable;

SymbolsTable* createSymbolsTable(void);

int symbolExists(SymbolsTable*, char*);

int addSymbol(SymbolsTable*, char*, int, int, int);

int getSymbolLine(SymbolsTable*, char*);

int getSymbolScope(SymbolsTable*, char*);

int getSymbolArity(SymbolsTable*, char*);

int getSymbolIndex(SymbolsTable*, Tree*, int);

void printVariablesTable(SymbolsTable*);

void printFunctionsTable(SymbolsTable*);

void freeSymbolsTable(SymbolsTable*);

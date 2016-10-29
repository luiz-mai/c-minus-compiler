#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define WORD_MAX_SIZE 128

typedef struct litNode {
        char literal[WORD_MAX_SIZE];
        struct litNode* next;
} LiteralNode;

typedef struct litTable {
        LiteralNode* head;
        LiteralNode* tail;
        int size;
} LiteralsTable;

LiteralsTable* createLiteralsTable(void);

int literalExists(LiteralsTable* lt, char* literal);

int addLiteral(LiteralsTable* lt, char* literal);

void printLiteralsTable(LiteralsTable* lt);

void freeLiteralsTable(LiteralsTable* lt);

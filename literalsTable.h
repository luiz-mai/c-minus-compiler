#include "tree.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define WORD_MAX_SIZE 128

typedef struct litNode {
  char literal[WORD_MAX_SIZE];
  struct litNode *next;
} LiteralNode;

typedef struct litTable {
  LiteralNode *head;
  LiteralNode *tail;
  int size;
} LiteralsTable;

LiteralsTable *createLiteralsTable(void);

int literalExists(LiteralsTable *lt, char *literal);

int getLiteralIndex(LiteralsTable *lt, char *literal);

char *getLiteral(LiteralsTable *lt, int index);

int addLiteral(LiteralsTable *lt, char *literal);

void printLiteralsTable(LiteralsTable *lt);

void freeLiteralsTable(LiteralsTable *lt);

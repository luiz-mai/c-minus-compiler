#include "symbolsTable.h"

SymbolsTable* createSymbolsTable(void){
        SymbolsTable *st = (SymbolsTable*)malloc(sizeof(SymbolsTable));
        st->head = NULL;
        st->tail = NULL;
        st->size = 0;
        return st;
}

int symbolExists(SymbolsTable* st, char* symbol){
        SymbolNode* current = st->head;
        while (current != NULL) {
                if (strcmp(current->symbol, symbol) == 0) {
                        return 1;
                }
                current = current->next;
        }
        return 0;
}

int addSymbol(SymbolsTable* st, char* symbol, int line){
        if(symbolExists(st, symbol)) return -1;
        SymbolNode* newNode = (SymbolNode*)malloc(sizeof(SymbolNode));
        strcpy(newNode->symbol, symbol);
        newNode->line = line;
        newNode->next = NULL;
        st->tail->next = newNode;
        st->size++;
        st->tail = newNode;
        return 0;
}

int getSymbolLine(SymbolsTable* st, char* symbol){
  SymbolNode* current = st->head;
  while (current != NULL) {
          if(strcmp(current->symbol, symbol) == 0){
            return current->line;
          }
          current = current->next;
  }
  return -1;
}

void printSymbolsTable(SymbolsTable* st) {
        printf("The Symbols Table has %d entries, which are:\n", st->size);
        SymbolNode* current = st->head;
        int i = 1;
        while (current != NULL) {
                printf("Entry %d is %s, located at line %d\n", i, current->symbol, current->line);
                current = current->next;
                i++;
        }
        return;
}

void freeSymbolsTable(SymbolsTable* st) {
        SymbolNode* temp;

        while (st->head != NULL)
        {
                temp = st->head;
                st->head = st->head->next;
                free(temp);
        }
        return;
}

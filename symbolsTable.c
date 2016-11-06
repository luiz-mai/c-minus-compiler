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

int addSymbol(SymbolsTable* st, char* symbol, int line, int scope, int arity){

        SymbolNode* newNode = (SymbolNode*)malloc(sizeof(SymbolNode));
        strcpy(newNode->symbol, symbol);
        newNode->line = line;
        if(scope != -1) newNode->scope = scope;
        if(arity != -1) newNode->arity = arity;
        newNode->next = NULL;

        if(st->head == NULL) {
                st->head = newNode;
                st->tail = newNode;
        } else{
                st->tail->next = newNode;
                st->tail = newNode;
        }
        st->size++;

        return 0;
}

int getSymbolLine(SymbolsTable* st, char* symbol){
        SymbolNode* current = st->head;
        while (current != NULL) {
                if(strcmp(current->symbol, symbol) == 0) {
                        return current->line;
                }
                current = current->next;
        }
        return -1;
}


int getSymbolScope(SymbolsTable* st, char* symbol){
        SymbolNode* current = st->head;
        while (current != NULL) {
                if(strcmp(current->symbol, symbol) == 0) {
                        return current->scope;
                }
                current = current->next;
        }
        return -1;
}


int getSymbolArity(SymbolsTable* st, char* symbol){
        SymbolNode* current = st->head;
        while (current != NULL) {
                if(strcmp(current->symbol, symbol) == 0) {
                        return current->arity;
                }
                current = current->next;
        }
        return -1;
}

int getSymbolIndex(SymbolsTable* st, Tree* symbol, int scope){
        SymbolNode* current = st->head;
        int i = 0;
        while (current != NULL) {
                if(scope == -1) {
                        if (strcmp(current->symbol, symbol->text) == 0) {
                                return i;
                        }
                } else{
                        if (strcmp(current->symbol, symbol->text) == 0 && current->scope == scope) {
                                return i;
                        }
                }
                current = current->next;
                i++;
        }
        return 0;
}

void printVariablesTable(SymbolsTable* st) {
        printf("\nVariables table:");
        SymbolNode* current = st->head;
        int i = 0;
        while (current != NULL) {
                printf("\nEntry %d -- name: %s, line: %d, scope: %d", i, current->symbol, current->line, current->scope);
                current = current->next;
                i++;
        }
        printf("\n\n");
        return;
}

void printFunctionsTable(SymbolsTable* st) {
        printf("\nFunctions table:");
        SymbolNode* current = st->head;
        int i = 0;
        while (current != NULL) {
                printf("\nEntry %d -- name: %s, line: %d, arity: %d", i, current->symbol, current->line, current->arity);
                current = current->next;
                i++;
        }
        printf("\n");
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

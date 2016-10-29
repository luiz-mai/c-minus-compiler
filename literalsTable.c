#include "literalsTable.h"

LiteralsTable* createLiteralsTable(void){
        LiteralsTable *lt = (LiteralsTable*)malloc(sizeof(LiteralsTable));
        lt->head = NULL;
        lt->tail = NULL;
        lt->size = 0;
        return lt;
}

int literalExists(LiteralsTable* lt, char* literal){
        LiteralNode* current = lt->head;
        while (current != NULL) {
                if (strcmp(current->literal, literal) == 0) {
                        return 1;
                }
                current = current->next;
        }
        return 0;
}

int addLiteral(LiteralsTable* lt, char* literal){
        if(literalExists(lt, literal)) return -1;
        LiteralNode* newNode = (LiteralNode*)malloc(sizeof(LiteralNode));
        strcpy(newNode->literal, literal);
        newNode->next = NULL;
        lt->tail->next = newNode;
        lt->size++;
        lt->tail = newNode;
        return 0;
}

void printLiteralsTable(LiteralsTable* lt) {
        printf("The Literals Table has %d entries, which are:\n", lt->size);
        LiteralNode* current = lt->head;
        int i = 1;
        while (current != NULL) {
                printf("Entry %d is %s\n", i, current->literal);
                current = current->next;
                i++;
        }
        return;
}

void freeLiteralsTable(LiteralsTable* lt) {
        LiteralNode* temp;

        while (lt->head != NULL)
        {
                temp = lt->head;
                lt->head = lt->head->next;
                free(temp);
        }
        return;
}

#include "literalsTable.h"

LiteralsTable *createLiteralsTable(void) {
  LiteralsTable *lt = (LiteralsTable *)malloc(sizeof(LiteralsTable));
  lt->head = NULL;
  lt->tail = NULL;
  lt->size = 0;
  return lt;
}

int literalExists(LiteralsTable *lt, char *literal) {
  LiteralNode *current = lt->head;
  int i = 0;
  while (current != NULL) {
    if (strcmp(current->literal, literal) == 0) {
      return i;
    }
    current = current->next;
    i++;
  }
  return 0;
}

int addLiteral(LiteralsTable *lt, char *literal) {
  if (literalExists(lt, literal))
    return getLiteralIndex(lt, literal);

  LiteralNode *newNode = (LiteralNode *)malloc(sizeof(LiteralNode));
  strcpy(newNode->literal, literal);
  newNode->next = NULL;

  if (lt->head == NULL) {
    lt->head = newNode;
    lt->tail = newNode;
  } else {
    lt->tail->next = newNode;
    lt->tail = newNode;
  }

  return lt->size++;
}

int getLiteralIndex(LiteralsTable *lt, char *literal) {
  LiteralNode *current = lt->head;
  int i = 0;
  while (current != NULL) {
    if (strcmp(current->literal, literal) == 0) {
      return i;
    }
    current = current->next;
    i++;
  }
  return 0;
}

void printLiteralsTable(LiteralsTable *lt) {
  printf("\nLiterals table:");
  LiteralNode *current = lt->head;
  int i = 0;
  while (current != NULL) {
    printf("\nEntry %d -- %s", i, current->literal);
    current = current->next;
    i++;
  }
  printf("\n\n");
  return;
}

void freeLiteralsTable(LiteralsTable *lt) {
  LiteralNode *temp;

  while (lt->head != NULL) {
    temp = lt->head;
    lt->head = lt->head->next;
    free(temp);
  }
  return;
}

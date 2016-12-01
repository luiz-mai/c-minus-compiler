#include "tree.h"
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

Tree *new_node(NodeKind kind) {
  Tree *node = malloc(sizeof(Tree));
  node->kind = kind;
  node->child = malloc(CHILDREN_LIMIT * sizeof(Tree));
  node->count = 0;
  node->data = -1;
  node->allocated = 0;
  for (int i = 0; i < CHILDREN_LIMIT; i++) {
    node->child[i] = NULL;
    node->allocated++;
  }
  return node;
}

Tree *new_custom_node(NodeKind kind, int data) {
  Tree *node = malloc(sizeof(Tree));
  node->kind = kind;
  node->data = data;
  node->child = malloc(CHILDREN_LIMIT * sizeof(Tree));
  node->count = 0;
  node->allocated = 0;
  for (int i = 0; i < CHILDREN_LIMIT; i++) {
    node->child[i] = NULL;
    node->allocated++;
  }
  return node;
}

Tree *add_child(Tree *parent, Tree *child) {

  if (parent->count >= parent->allocated) {
    parent->allocated++;
    parent->child = realloc(parent->child, sizeof(Tree *) * parent->allocated);
    parent->child[parent->count] = child;
    parent->count++;
  } else {
    parent->child[parent->count] = child;
    parent->count++;
  }
  return parent;
}

Tree *new_subtree(NodeKind kind, int child_count, ...) {
  Tree *node = new_node(kind);
  va_list ap;
  va_start(ap, child_count);
  for (int i = 0; i < child_count; i++) {
    add_child(node, va_arg(ap, Tree *));
  }
  va_end(ap);
  return node;
}

NodeKind get_node_kind(Tree *node) { return node->kind; }

int get_node_data(Tree *node) { return node->data; }

int get_node_child_count(Tree *node) { return node->count; }

void print_node(Tree *node, int level) {
  char data[128];
  sprintf(data, "%d", node->data);
  if (!node->data) {
    printf("%d: Node -- Addr: %p -- Text: %s -- Count: %d\n", level, node,
           kind2str(node->kind), node->count);
  } else {
    printf("%d: Node -- Addr: %p -- Text: %s -- Count: %d\n", level, node,
           strcat(kind2str(node->kind), strcat(",", data)), node->count);
  }

  for (int i = 0; i < node->count; i++) {
    print_node(node->child[i], level + 1);
  }
}

void print_tree(Tree *tree) { print_node(tree, 0); }

void free_tree(Tree *tree) {
  if (tree == NULL)
    return;
  for (int i = 0; i < tree->allocated; i++) {
    free_tree(tree->child[i]);
  }
  free(tree);
}

// Dot output.

int nr;

int print_node_dot(Tree *node) {
  int my_nr = nr++;
  if (node->data == -1) {
    printf("node%d[label=\"%s\"];\n", my_nr, kind2str(node->kind));
  } else {
    char data[128];
    sprintf(data, "%s,%d", kind2str(node->kind), node->data);
    printf("node%d[label=\"%s\"];\n", my_nr, data);
  }
  for (int i = 0; i < node->count; i++) {
    int child_nr = print_node_dot(node->child[i]);
    printf("node%d -> node%d;\n", my_nr, child_nr);
  }
  return my_nr;
}

void print_dot(Tree *tree) {
  nr = 0;
  printf("digraph {\ngraph [ordering=\"out\"];\n");
  print_node_dot(tree);
  printf("}\n");
}

char *kind2str(NodeKind kind) {
  switch (kind) {
  case FUNC_DECL_LIST_NODE:
    return "funcDeclList";
  case FUNC_DECL_NODE:
    return "funcDecl";
  case FUNC_HEADER_NODE:
    return "funcHeader";
  case FUNC_BODY_NODE:
    return "funcBody";
  case VAR_LIST_NODE:
    return "varList";
  case PARAM_NODE:
    return "param";
  case STMT_LIST_NODE:
    return "stmtList";
  case ASSIGN_NODE:
    return "=";
  case IF_NODE:
    return "if";
  case ELSE_NODE:
    return "else";
  case WHILE_NODE:
    return "while";
  case RETURN_NODE:
    return "return";
  case OUTPUT_NODE:
    return "output";
  case INPUT_NODE:
    return "input";
  case WRITE_NODE:
    return "write";
  case ARG_LIST_NODE:
    return "argList";
  case LT_NODE:
    return "<";
  case LEQ_NODE:
    return "<=";
  case GT_NODE:
    return ">";
  case GEQ_NODE:
    return ">=";
  case EQ_NODE:
    return "==";
  case NEQ_NODE:
    return "!=";
  case PLUS_NODE:
    return "+";
  case MINUS_NODE:
    return "-";
  case TIMES_NODE:
    return "*";
  case OVER_NODE:
    return "/";
  case ID_NODE:
    return "id";
  case NUM_NODE:
    return "num";
  case STRING_NODE:
    return "string";
  case FCALL_NODE:
    return "fcall";
  case SVAR_NODE:
    return "svar";
  case CVAR_NODE:
    return "cvar";
  case INT_NODE:
    return "INT";
  case VOID_NODE:
    return "VOID";
  default:
    return "ERRO";
  }
}

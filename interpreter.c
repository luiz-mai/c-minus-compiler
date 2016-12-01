#include "interpreter.h"
#include "literalsTable.h"
#include "symbolsTable.h"
#include <stdio.h>
#include <stdlib.h>

extern SymbolsTable *vart;

// Data stack -----------------------------------------------------------------

#define STACK_SIZE 100

int stack[STACK_SIZE];
int sp; // stack pointer

void push(int x) { stack[++sp] = x; }

int pop() { return stack[sp--]; }

void init_stack() {
  for (int i = 0; i < STACK_SIZE; i++) {
    stack[i] = 0;
  }
  sp = -1;
}

void print_stack() {
  printf("*** STACK: ");
  for (int i = 0; i <= sp; i++) {
    printf("%d / ", stack[i]);
  }
  printf("\n");
}

// ----------------------------------------------------------------------------

// Variables memory -----------------------------------------------------------

#define MEM_SIZE 100

int mem[MEM_SIZE];

void store(int addr, int val) { mem[addr] = val; }

int load(int addr) { return mem[addr]; }

void init_mem() {
  for (int addr = 0; addr < MEM_SIZE; addr++) {
    mem[addr] = 0;
  }
}

// ----------------------------------------------------------------------------

// #define TRACE
#ifdef TRACE
#define trace(msg) printf("TRACE: %s\n", msg)
#else
#define trace(msg)
#endif

void rec_run_ast(Tree *node);

void run_funcDeclList(Tree *node) {
  trace("funcDeclList");
  int size = get_node_child_count(node);
  for (int i = 0; i < size; i++) {
    rec_run_ast(node->child[i]);
  }
}

void run_funcDecl(Tree *node) {
  trace("funcDecl");
  rec_run_ast(node->child[0]);
  rec_run_ast(node->child[1]);
}

void run_funcHeader(Tree *node) {
  trace("funcHeader");
  int size = get_node_child_count(node);
  rec_run_ast(node->child[size - 1]);
  // PARAM LIST is always the last children of funcHeader
}

void run_paramList(Tree *node) {}

void run_funcBody(Tree *node) {
  trace("funcBody");
  rec_run_ast(node->child[0]); // VAR LIST
  rec_run_ast(node->child[1]); // STMT LIST
}

void run_varList(Tree *node) {}

void run_stmtList(Tree *node) {
  trace("stmtList");
  int size = get_node_child_count(node);
  for (int i = 0; i < size; i++) {
    rec_run_ast(node->child[i]);
  }
}

void run_input(Tree *node) {
  trace("input");
  int x;
  scanf("%d", &x);
  push(x);
}

void run_output(Tree *node) {
  trace("output");
  int x = pop();
  printf("%d", x);
}

void run_write(Tree *node) {
  trace("write");
  char *str = (char *)malloc(128 * sizeof(char));
  Tree *child = node->child[0];
 strcpy(str, getLiteral(lt, child->data);
 printf("%s", str);
}

void run_assign(Tree *node) {}

void run_num(Tree *node) {
  trace("num");
  push(node->data);
}

void run_svar(Tree *node) {}

void run_cvar(Tree *node) {}

void run_plus(Tree *node) {}

void run_minus(Tree *node) {}

void run_times(Tree *node) {}

void run_over(Tree *node) {}

void run_lt(Tree *node) {}

void run_leq(Tree *node) {}

void run_gt(Tree *node) {}

void run_geq(Tree *node) {}

void run_eq(Tree *node) {}

void run_neq(Tree *node) {}

void run_if(Tree *node) {}

void run_while(Tree *node) {}

void run_fcall(Tree *node) {}

void run_argList(Tree *node) {}

void rec_run_ast(Tree *node) {
  switch (get_node_kind(node)) {
  case FUNC_DECL_LIST_NODE:
    run_funcDeclList(node);
    break;
  case FUNC_DECL_NODE:
    run_funcDecl(node);
    break;
  case FUNC_HEADER_NODE:
    run_funcHeader(node);
    break;
  case PARAM_NODE:
    run_paramList(node);
    break;
  case FUNC_BODY_NODE:
    run_funcBody(node);
    break;
  case VAR_LIST_NODE:
    run_varList(node);
    break;
  case STMT_LIST_NODE:
    run_stmtList(node);
    break;
  case INPUT_NODE:
    run_input(node);
    break;
  case OUTPUT_NODE:
    run_output(node);
    break;
  case WRITE_NODE:
    run_write(node);
    break;
  case ASSIGN_NODE:
    run_assign(node);
    break;
  case NUM_NODE:
    run_num(node);
    break;
  case SVAR_NODE:
    run_svar(node);
    break;
  case CVAR_NODE:
    run_cvar(node);
    break;
  case PLUS_NODE:
    run_plus(node);
    break;
  case MINUS_NODE:
    run_minus(node);
    break;
  case TIMES_NODE:
    run_times(node);
    break;
  case OVER_NODE:
    run_over(node);
    break;
  case LT_NODE:
    run_lt(node);
    break;
  case LEQ_NODE:
    run_leq(node);
    break;
  case GT_NODE:
    run_gt(node);
    break;
  case GEQ_NODE:
    run_geq(node);
    break;
  case EQ_NODE:
    run_eq(node);
    break;
  case NEQ_NODE:
    run_neq(node);
    break;
  case IF_NODE:
    run_if(node);
    break;
  case WHILE_NODE:
    run_while(node);
    break;
  case FCALL_NODE:
    run_fcall(node);
    break;
  case ARG_LIST_NODE:
    run_argList(node);
    break;
  default:
    fprintf(stderr, "Invalid kind: %s!\n", kind2str(get_node_kind(node)));
    exit(1);
  }
}

void run_ast(Tree *node) {
  init_stack();
  init_mem();
  rec_run_ast(node);
}

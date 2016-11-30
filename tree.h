#ifndef TREE_H
#define TREE_H

#define CHILDREN_LIMIT 7
#define TEXT_LIMIT 256

typedef enum {
  FUNC_DECL_LIST_NODE,
  FUNC_DECL_NODE,
  FUNC_HEADER_NODE,
  FUNC_BODY_NODE,
  VAR_LIST_NODE,
  PARAM_NODE,
  STMT_LIST_NODE,
  ASSIGN_NODE,
  IF_NODE,
  ELSE_NODE,
  WHILE_NODE,
  RETURN_NODE,
  OUTPUT_NODE,
  INPUT_NODE,
  WRITE_NODE,
  ARG_LIST_NODE,
  LT_NODE,
  LEQ_NODE,
  GT_NODE,
  GEQ_NODE,
  EQ_NODE,
  NEQ_NODE,
  PLUS_NODE,
  MINUS_NODE,
  TIMES_NODE,
  OVER_NODE,
  ID_NODE,
  NUM_NODE,
  STRING_NODE,
  FCALL_NODE,
  SVAR_NODE,
  CVAR_NODE,
  INT_NODE,
  VOID_NODE
} NodeKind;

typedef struct node {
  NodeKind kind;
  int data;
  int count;
  int allocated;
  struct node **child;
} Tree;

// Creates a new Tree node containing the text from the parameter
Tree *new_node(NodeKind kind);

// Creates a different kind of node containing the type of the node and its
// position at the table.
Tree *new_custom_node(NodeKind kind, int data);

// Adds a new child to a Tree node.
Tree *add_child(Tree *parent, Tree *child);

// Creates a node already containing and all of its children.
Tree *new_subtree(NodeKind kind, int child_count, ...);

// Returns the node's text.
NodeKind get_node_kind(Tree *node);
int get_node_data(Tree *node);

// Prints an user-friendly tree.
void print_tree(Tree *tree);

// Prints the .dot used to build the tree's PDF representation.
void print_dot(Tree *tree);

// Frees the memory allocated to the tree.
void free_tree(Tree *tree);

char *kind2str(NodeKind kind);
#endif

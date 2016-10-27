#ifndef TREE_H
#define TREE_H

struct node; // Opaque structure to ensure encapsulation.

typedef struct node Tree;

Tree* new_node(const char *text);

void add_child(Tree *parent, Tree *child);

Tree* new_subtree(const char *text, int child_count, ...);

void print_tree(Tree *tree);
void print_dot(Tree *tree);

void free_tree(Tree *tree);

#endif

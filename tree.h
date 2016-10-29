#ifndef TREE_H
#define TREE_H

#define CHILDREN_LIMIT 7
#define TEXT_LIMIT 256

struct node {
    char text[TEXT_LIMIT];
    int count;
    struct node* child[CHILDREN_LIMIT];
};

typedef struct node Tree;

Tree* new_node(const char *text);

void add_child(Tree *parent, Tree *child);

Tree* new_subtree(const char *text, int child_count, ...);

void print_tree(Tree *tree);
void print_dot(Tree *tree);

void free_tree(Tree *tree);

#endif

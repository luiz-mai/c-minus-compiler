#ifndef TREE_H
#define TREE_H

#define CHILDREN_LIMIT 7
#define TEXT_LIMIT 256

typedef struct node {
        char text[TEXT_LIMIT];
        int count;
        struct node* child[CHILDREN_LIMIT];
} Tree;


Tree* new_node(const char *text);
Tree* new_custom_node(const char* type, int position);

Tree* add_child(Tree *parent, Tree *child);

Tree* new_subtree(const char *text, int child_count, ...);
char* get_node_text(Tree* node);
void print_tree(Tree *tree);
void print_dot(Tree *tree);

void free_tree(Tree *tree);

#endif

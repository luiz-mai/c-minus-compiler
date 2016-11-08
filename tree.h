#ifndef TREE_H
#define TREE_H

#define CHILDREN_LIMIT 7
#define TEXT_LIMIT 256

typedef struct node {
        char text[TEXT_LIMIT];
        int count;
        int allocated;
        struct node** child;
} Tree;

//Creates a new Tree node containing the text from the parameter
Tree* new_node(const char *text);

//Creates a different kind of node containing the type of the node and its
//position at the table.
Tree* new_custom_node(const char* type, int position);

//Adds a new child to a Tree node.
Tree* add_child(Tree *parent, Tree *child);

//Creates a node already containing and all of its children.
Tree* new_subtree(const char *text, int child_count, ...);

//Returns the node's text.
char* get_node_text(Tree* node);

//Prints an user-friendly tree.
void print_tree(Tree *tree);

//Prints the .dot used to build the tree's PDF representation.
void print_dot(Tree *tree);

//Frees the memory allocated to the tree.
void free_tree(Tree *tree);

#endif

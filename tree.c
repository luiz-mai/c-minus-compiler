
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tree.h"

#define CHILDREN_LIMIT 7
#define TEXT_LIMIT 256

struct node {
    char text[TEXT_LIMIT];
    int count;
    Tree* child[CHILDREN_LIMIT];
};

Tree* new_node(const char *text) {
    Tree* node = malloc(sizeof * node);
    strcpy(node->text, text);
    node->count = 0;
    for (int i = 0; i < CHILDREN_LIMIT; i++) {
        node->child[i] = NULL;
    }
    return node;
}

void add_child(Tree *parent, Tree *child) {
    if (parent->count == CHILDREN_LIMIT) {
        fprintf(stderr, "Cannot add another child!\n");
        exit(1);
    }
    parent->child[parent->count] = child;
    parent->count++;
}

Tree* new_subtree(const char *text, int child_count, ...) {
    if (child_count > CHILDREN_LIMIT) {
        fprintf(stderr, "Too many children as arguments!\n");
        exit(1);
    }

    Tree* node = new_node(text);
    va_list ap;
    va_start(ap, child_count);
    for (int i = 0; i < child_count; i++) {
        add_child(node, va_arg(ap, Tree*));
    }
    va_end(ap);
    return node;
}

void print_node(Tree *node, int level) {
    printf("%d: Node -- Addr: %p -- Text: %s -- Count: %d\n",
           level, node, node->text, node->count);
    for (int i = 0; i < node->count; i++) {
        print_node(node->child[i], level+1);
    }
}

void print_tree(Tree *tree) {
    print_node(tree, 0);
}

void free_tree(Tree *tree) {
    for (int i = 0; i < tree->count; i++) {
        free_tree(tree->child[i]);
    }
    free(tree);
}

// Dot output.

int nr;

int print_node_dot(Tree *node) {
    int my_nr = nr++;
    printf("node%d[label=\"%s\"];\n", my_nr, node->text);
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

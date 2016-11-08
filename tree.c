#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tree.h"

Tree* new_node(const char *text) {
        Tree* node = malloc(sizeof(Tree));
        strcpy(node->text, text);
        node->child = malloc(CHILDREN_LIMIT * sizeof(Tree));
        node->count = 0;
        node->allocated = 0;
        for (int i = 0; i < CHILDREN_LIMIT; i++) {
                node->child[i] = NULL;
                node->allocated++;
        }
        return node;
}

Tree* new_custom_node(const char* type, int position) {
        Tree* node = malloc(sizeof(Tree));
        char str[TEXT_LIMIT];
        sprintf(str, "%s,%d", type, position);
        strcpy(node->text, str);
        node->child = malloc(CHILDREN_LIMIT*sizeof(Tree));
        node->count = 0;
        node->allocated = 0;
        for (int i = 0; i < CHILDREN_LIMIT; i++) {
                node->child[i] = NULL;
                node->allocated++;
        }
        return node;
}

Tree* add_child(Tree *parent, Tree *child) {

        if(parent->count >= parent->allocated) {
                parent->allocated++;
                parent->child = realloc(parent->child, sizeof(Tree*) * parent->allocated);
                parent->child[parent->count] = child;
                parent->count++;
        }
        else{
                parent->child[parent->count] = child;
                parent->count++;
        }
        return parent;
}

Tree* new_subtree(const char *text, int child_count, ...) {
        Tree* node = new_node(text);
        va_list ap;
        va_start(ap, child_count);
        for (int i = 0; i < child_count; i++) {
                add_child(node, va_arg(ap, Tree*));
        }
        va_end(ap);
        return node;
}

char* get_node_text(Tree* node){
        return node->text;
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
        if(tree == NULL) return;
        for (int i = 0; i < tree->allocated; i++) {
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

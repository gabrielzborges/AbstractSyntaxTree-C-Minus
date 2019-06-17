#ifndef AST_H
#define AST_H

typedef enum {
    STMT_SEQ_NODE,
    IF_NODE,
    REPEAT_NODE,
    ASSIGN_NODE,
    READ_NODE,
    WRITE_NODE,
    PLUS_NODE,
    MINUS_NODE,
    TIMES_NODE,
    OVER_NODE,
    LT_NODE,
    EQ_NODE,
    NUM_NODE,
    ID_NODE
} NodeKind;

struct node; // Opaque structure to ensure encapsulation.

typedef struct node AST;

AST* new_node(NodeKind kind, int data);

void add_child(AST *parent, AST *child);
AST* get_child(AST *parent, int idx);

AST* new_subtree(NodeKind kind, int child_count, ...);

NodeKind get_kind(AST *node);
char* kind2str(NodeKind kind);
int get_data(AST *node);
int get_child_count(AST *node);

void print_tree(AST *ast);
void print_dot(AST *ast);

void free_tree(AST *ast);

#endif

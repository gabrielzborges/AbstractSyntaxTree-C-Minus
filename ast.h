#ifndef AST_H
#define AST_H

typedef enum {
    FUNC_LIST_NODE,
    FUNC_DECL_NODE,
    FUNC_HEADER_NODE,
    FUNC_NAME_NODE,
    FUNC_BODY_NODE,
    PARAM_LIST_NODE,
    VAR_LIST_NODE,
    VAR_DECL_NODE,
    VAR_USE,
    STMT_SEQ_NODE,
    IF_NODE,
    BLOCK_NODE,
    WHILE_NODE,
    RETURN_NODE,
    INPUT_CALL_NODE,
    OUTPUT_CALL_NODE,
    ARG_LIST_NODE,
    REPEAT_NODE,
    ASSIGN_NODE,
    READ_NODE,       //TINY
    WRITE_NODE,
    FCALL_NODE,
    PLUS_NODE,
    MINUS_NODE,
    TIMES_NODE,
    OVER_NODE,
    LT_NODE,
    LE_NODE,
    GT_NODE,
    GE_NODE,
    EQ_NODE,
    NEQ_NODE,
    NUM_NODE,
    STRING_NODE,
    ID_NODE          //TINY
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

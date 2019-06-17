
#ifndef TABLES_H
#define TABLES_H

// Literals Table
// ----------------------------------------------------------------------------

// Opaque structure.
// For simplicity, the table is implemented as a sequential list.
struct lit_table;
typedef struct lit_table LitTable;

// Creates an empty literal table.
LitTable* create_lit_table();

// Adds the given string to the table without repetitions.
// String 's' is copied internally.
// Returns the index of the string in the table.
int add_literal(LitTable* lt, char* s);

// Returns a pointer to the string stored at index 'i'.
char* get_literal(LitTable* lt, int i);

// Prints the given table to stdout.
void print_lit_table(LitTable* lt);

// Clears the allocated structure.
void free_lit_table(LitTable* lt);


// Symbols Table
// ----------------------------------------------------------------------------

// Opaque structure.
// For simplicity, the table is implemented as a sequential list.
// This table stores the variable name, the declaration line, scope and var's size (0 for int,
// -1 for array's reference in a func's param, greater 0 for an arrays (store the array's length)).
struct sym_table;
typedef struct sym_table SymTable;

// Creates an empty symbol table.
SymTable* create_sym_table();

// Adds a fresh var to the table.
// No check is made by this function, so make sure to call 'lookup_var' first.
// Returns the index where the variable was inserted.
int add_var(SymTable* st, char* s, int line, int scope, int size);

// Returns the index where the given variable is stored or -1 otherwise.
int lookup_var(SymTable* st, char* s, int actual_scope);

// Returns the variable name stored at the given index.
// No check is made by this function, so make sure that the index is valid first.
char* get_name(SymTable* st, int i);

// Returns the declaration line of the variable stored at the given index.
// No check is made by this function, so make sure that the index is valid first.
int get_line(SymTable* st, int i);

// Returns the scope of the variable stored at the given index.
// No check is made by this function, so make sure that the index is valid first.
int get_scope(SymTable* st, int i);

// Returns the size of the variable stored at the given index.
// No check is made by this function, so make sure that the index is valid first.
int get_size(SymTable* st, int i);

// Prints the given table to stdout.
void print_sym_table(SymTable* st);

// Clears the allocated structure.
void free_sym_table(SymTable* st);


// Func table
// -----------------------------------------------------------------------------------
// Opaque structure.
// For simplicity, the table is implemented as a sequential list.
// This table stores the variable name, the declaration line, scope and var's size (0 for int,
// -1 for array's reference in a func's param, greater 0 for an arrays (store the array's length)).
#define SYMBOL_FUNC_MAX_SIZE 128
#define SYMBOL_FUNC_TABLE_MAX_SIZE 100

// It's necessary to define the struct here in the header
typedef struct {
  char name[SYMBOL_FUNC_MAX_SIZE];
  int line;
  int arity;
} Func_Entry;
struct sym_func_table {
    Func_Entry t[SYMBOL_FUNC_TABLE_MAX_SIZE];
    int size;
};
typedef struct sym_func_table SymFuncTable;

// Creates an empty symbol table.
SymFuncTable* create_sym_func_table();

// Adds a fresh var to the table.
// No check is made by this function, so make sure to call 'lookup_var' first.
// Returns the index where the variable was inserted.
int add_func(SymFuncTable* sft, char* s, int line, int arity);

// Returns the index where the given variable is stored or -1 otherwise.
int lookup_func(SymFuncTable* sft, char* s);

// Returns the function name stored at the given index.
// No check is made by this function, so make sure that the index is valid first.
char* get_func_name(SymFuncTable* sft, int i);

// Returns the declaration line of the function stored at the given index.
// No check is made by this function, so make sure that the index is valid first.
int get_func_line(SymFuncTable* sft, int i);

// Returns the arity of the function's params stored at the given index.
// No check is made by this function, so make sure that the index is valid first.
int get_func_arity(SymFuncTable* sft, int i);


// Prints the given table to stdout.
void print_sym_func_table(SymFuncTable* sft);

// Clears the allocated structure.
void free_sym_func_table(SymFuncTable* sft);

#endif // TABLES_H


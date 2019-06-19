%output "parser.c"
%defines "parser.h"

//error message for syntax error
%define parse.error verbose
//enable lookahead
%define parse.lac full

%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include "parser.h"
  #include "ast.h"
  #include "tables.h"
  extern int yylineno; //sera utilizado na funcao yyerror
  extern char *yytext;
  extern char id_name_copy[100];  //global auxiliar array to copy the ID name
                                  //(it's necessary to deal with some bison's behavior)

  int yylex(void);
  void yyerror (char const *s);
  void var_verify();
  void var_new();
  void arity_verify();
  void func_verify();
  void func_new();

  char func_name[100];  //global auxiliar array to copy function's name when declared because the params are IDs
                        //(in user_call_function the name is store in id_name_copy because params are n t IDs)
  int f_idx_in_table;   //global auxiliar variable to store the function's index in the func_tb
  int actual_arity = 0; //global arity counter
  int actual_scope = 0; //global scope counter to distinguish IDs with the same name but in scopes differentes

  extern LitTable *lit_tb; //used in the scanner
  SymTable *sym_tb;
  SymFuncTable *func_tb;

  AST* ast;
%}

%define api.value.type {AST*} //type of variable yylval

//tokens
%token ELSE IF INPUT INT OUTPUT RETURN VOID WHILE WRITE
%token SEMI COMMA LPAREN RPAREN LBRACK RBRACK LBRACE RBRACE
%token ASSIGN
%token NUM STRING
%token ID


//tratando a precedencia de operadores
%left LT LE GT GE EQ NEQ
%left PLUS MINUS
%left TIMES OVER

%%
program: func_decl_list { ast = $1 };

func_decl_list: 
  func_decl_list func_decl {actual_scope++; add_child($1, $2); $$ = $1; } 
| func_decl {actual_scope++; $$ = new_subtree(FUNC_LIST_NODE, 1, $1); }
;

func_decl: 
  func_header func_body { $$ = new_subtree(FUNC_DECL_NODE, 2, $1, $2); }
;

func_header: 
  ret_type ID {strcpy(func_name, yytext);} LPAREN params RPAREN {func_new(func_name, actual_arity); $2 = new_node(FUNC_NAME_NODE, lookup_func(func_tb, func_name)); $$ = new_subtree(FUNC_HEADER_NODE, 2, $2, $5);}
; //func_name receive the name of the function because the params are IDs and will override the id_name_copy

func_body: 
  LBRACE opt_var_decl opt_stmt_list RBRACE {$$ = new_subtree(FUNC_BODY_NODE, 2, $2, $3);}
;

opt_var_decl: 
  %empty { $$ = new_node(VAR_DECL_NODE, 0);}
| var_decl_list { $$ = $1; }
;

opt_stmt_list: 
  %empty //{ $$ = new_node(EMPTY, 0);}
| stmt_list { $$ = $1; }
;

ret_type: 
  INT 
| VOID
;

params: 
  VOID
| param_list { $$ = $1; }
;

param_list: 
  param_list COMMA param { add_child($1, $3); $$ = new_subtree(PARAM_LIST_NODE, 1, $2); }
| param { $$ = $1; }
;

param: 
  INT ID {actual_arity++; var_new(id_name_copy, 0, actual_scope); $2 = new_node(VAR_DECL_NODE, lookup_var(sym_tb, id_name_copy, actual_scope)); $$ = $2;}
| INT ID {actual_arity++; var_new(id_name_copy, -1, actual_scope); $2 = new_node(VAR_DECL_NODE, lookup_var(sym_tb, id_name_copy, actual_scope)); $$ = $2;} LBRACK RBRACK
;

var_decl_list: 
  var_decl_list var_decl { add_child($1, $2); $$ = new_subtree(VAR_LIST, 1, $1); }
| var_decl { $$ = $1; }
;

var_decl: 
  INT ID {var_new(id_name_copy, 0, actual_scope); $2 = new_node(VAR_DECL_NODE, lookup_var(sym_tb, id_name_copy, actual_scope)); $$ = $2;} SEMI 
| INT ID LBRACK NUM {var_new(id_name_copy, atoi(yytext), actual_scope);} RBRACK SEMI
;

stmt_list: 
  stmt_list stmt { add_child($1, $2); $$ = $1; }
| stmt { $$ = $1; }
;

stmt: 
  assign_stmt    { $$ = $1; }
| if_stmt        { $$ = $1; }
| while_stmt     { $$ = $1; }
| return_stmt    { $$ = $1; }
| func_call SEMI { $$ = $1; }
;

assign_stmt: 
  lval ASSIGN arith_expr SEMI { $$ = new_subtree(ASSIGN_NODE, 2, $1, $3); }
;

lval: 
  ID {var_verify(id_name_copy, actual_scope); $$ = new_node(VAR_USE, lookup_var(sym_tb, id_name_copy, actual_scope));} 
| ID LBRACK NUM RBRACK { $$ = new_node(VAR_USE, lookup_var(sym_tb, id_name_copy, actual_scope));}
| ID { $$ = new_node(VAR_USE, lookup_var(sym_tb, id_name_copy, actual_scope));} LBRACK ID {var_verify(id_name_copy, actual_scope);} RBRACK
;

if_stmt: 
  IF LPAREN bool_expr RPAREN block              { $$ = new_subtree(IF_NODE, 2, $3, $5); }
| IF LPAREN bool_expr RPAREN block ELSE block   { $$ = new_subtree(IF_NODE, 3, $3, $5, $7); }
;

block: 
  LBRACE opt_stmt_list RBRACE { $$ = new_subtree(BLOCK_NODE, 1, $2); }
;

while_stmt: 
  WHILE LPAREN bool_expr RPAREN block { $$ = new_subtree(WHILE_NODE, 2, $3, $5); }
;

return_stmt: 
  RETURN SEMI 
| RETURN arith_expr SEMI  { $$ = new_subtree(RETURN_NODE, 1, $2); }
;

func_call: 
  output_call      { $$ = $1; }
| write_call       { $$ = $1; }
| user_func_call   { $$ = $1; }
;

input_call: 
  INPUT LPAREN RPAREN { $$ = new_node(INPUT_CALL_NODE, 0); }
;

output_call: 
  OUTPUT LPAREN arith_expr RPAREN { $$ = new_subtree(OUTPUT_CALL_NODE, 1, $3); }
;

write_call: 
  WRITE LPAREN STRING RPAREN { $3 = new_node(STRING_NODE, 0); $$ = new_subtree(WRITE_NODE, 1, $3); }
;

user_func_call: 
  ID {func_verify(id_name_copy); $1 = new_node(FCALL_NODE, lookup_func(func_tb, id_name_copy));} LPAREN opt_arg_list RPAREN { $$ = add_child($1, $4); arity_verify(func_tb, f_idx_in_table, actual_arity);}
; //funct_verify receive id_name_copy because the params aren't IDs, therefore, won't override id_name_copy

opt_arg_list: 
  %empty    { $$ = new_node(ARG_LIST_NODE, 0);}
| arg_list  { $$ = $1; }
;

arg_list: 
  arg_list COMMA arith_expr {actual_arity++; add_child($1, $3); $$ = new_subtree(ARG_LIST_NODE, 1, $1);}
| arith_expr {actual_arity++; $$ = add_child(new_node(ARG_LIST_NODE, 0), $1);}
;

bool_expr: 
  arith_expr LT arith_expr    { $$ = new_subtree(LT_NODE, 2, $1, $3); }
| arith_expr LE arith_expr    { $$ = new_subtree(LE_NODE, 2, $1, $3); }
| arith_expr GT arith_expr    { $$ = new_subtree(GT_NODE, 2, $1, $3); }
| arith_expr GE arith_expr    { $$ = new_subtree(GE_NODE, 2, $1, $3); }
| arith_expr EQ arith_expr    { $$ = new_subtree(EQ_NODE, 2, $1, $3); }
| arith_expr NEQ arith_expr   { $$ = new_subtree(NEQ_NODE, 2, $1, $3); }
;

arith_expr: 
  arith_expr PLUS arith_expr    { $$ = new_subtree(PLUS_NODE, 2, $1, $3); }
| arith_expr MINUS arith_expr   { $$ = new_subtree(MINUS_NODE, 2, $1, $3); }
| arith_expr TIMES arith_expr   { $$ = new_subtree(TIMES_NODE, 2, $1, $3); }
| arith_expr OVER arith_expr    { $$ = new_subtree(OVER_NODE, 2, $1, $3); }
| LPAREN arith_expr RPAREN      { $$ = $2; }
| lval                          { $$ = $1; }
| input_call                    { $$ = $1; }
| user_func_call                { $$ = $1; }
| NUM                           { $$ = new_node(NUM_NODE, atoi(yytext)); }
;
%%

//function to handle parse error
void yyerror (char const *s){ 
        printf("PARSE ERROR (%d): %s\n", yylineno, s);
}

//functio to check if the variable was declared
void var_verify(char* var_name, int scope){
  int index = lookup_var(sym_tb, var_name, scope);
  if(index == -1){
    printf("SEMANTIC ERROR (%d): variable '%s' was not declared.\n",
      yylineno, id_name_copy);
    exit(1);
  }
}

//function to store the variable in the variables table
//the function check if another variable was already declared with the same name
void var_new(char* var_name, int size, int scope){
  int index = lookup_var(sym_tb, var_name, scope);
  if(index != -1){
    printf("SEMANTIC ERROR (%d): variable '%s' already declared at line %d.\n",
      yylineno, var_name, get_line(sym_tb, index));
    exit(1);
  }
  add_var(sym_tb, var_name, yylineno, scope, size);
}

//function to check the arity
void arity_verify(SymFuncTable *sft, int index, int arity, char* fname){
    if(sft->t[index].arity != arity){
      printf("SEMANTIC ERROR (%d): function '%s' was called with %d arguments but declared with %d parameters.\n", 
        yylineno, id_name_copy, arity, get_func_arity(func_tb, index));
      exit(1);
    }
    actual_arity = 0; //restart arity counter
}

//function to check if the function was declared
void func_verify(char *fname){
  int index = lookup_func(func_tb, fname);
  if(index == -1){
    printf("SEMANTIC ERROR (%d): function '%s' was not declared.\n",
      yylineno, id_name_copy);
    exit(1);
  }
  f_idx_in_table = index;
}

//function to store the function in the functions table
//the function check if another function was already declared with the same name 
void func_new(char* fname, int arity){
  int index = lookup_func(func_tb, fname);
  if(index != -1){
    printf("SEMANTIC ERROR (%d): function '%s' already declared at line %d.\n",
      yylineno, fname, get_func_line(func_tb, index));
    exit(1);
  }
  add_func(func_tb, fname, yylineno, arity);
  actual_arity = 0; //restart arity counter
}

int main(void){
  //creating the tables
  lit_tb = create_lit_table();
  sym_tb  = create_sym_table();
  func_tb = create_sym_func_table();

  int parse_success = yyparse();
  
  if(parse_success == 0){  //if the parse was successful then execute the prints
    printf("PARSE SUCCESSFUL!\n");

    //printing the tables
    printf("\n");
    print_lit_table(lit_tb);
    printf("\n\n");
    print_sym_table(sym_tb);
    printf("\n\n");
    print_sym_func_table(func_tb);

    //free tables
    free_lit_table(lit_tb);
    free_sym_table(sym_tb);
    free_sym_func_table(func_tb);
  }
  return 0;
}
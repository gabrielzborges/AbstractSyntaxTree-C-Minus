%option outfile="scanner.c"
%option noyywrap
%option nounput
%option noinput
%option yylineno
%{
#include "parser.h"
#include "tables.h"
#include <string.h>
char id_name_copy[100];
LitTable *lit_tb;
%}

/* LABELS */
ELSE    (else)
IF      (if)
INPUT   (input)
INT     (int)
OUTPUT  (output)
RETURN  (return)
VOID    (void)
WHILE   (while)
WRITE   (write)

PLUS    ("+")
MINUS   ("-")
TIMES   ("*")
OVER    ("/")
LT      ("<")
LE      ("<=")
GT      (">")
GE      (">=")
EQ      ("==")
NEQ     ("!=")
ASSIGN  ("=")

SEMI    (";")
COMMA   (",")
LPAREN  ("(")
RPAREN  (")")
LBRACK  ("[")
RBRACK  ("]")
LBRACE  ("{")
RBRACE  ("}")

NUM     [0-9]+
ID      [a-zA-Z][0-9a-zA-Z]*
STRING   \"([^\\\"]|\\.)*\"

SPACE   [ \t\n]
/* abaixo temos o comentario. a expressao regular dele é alguma coisa que comece com //                                         */
/*                                                             OU                                                               */
/* alguma coisa que comece com contrabarra+asterisco, tenha qualquer caractere execeto '*' ou contenha * mas nao contenha       */
/* asterisco+contrabarra, e termine com asterisco+contrabarra                                                                   */
COMMENT ("//".*)|"/*"([^*]|(\*+[^*/]))*\*+\/
UNKNOWN .

/* yylineno nos diz a linha e eh incrementada pelo %option yylineno; yytext nos diz os caracteres lidos */
%%
{ELSE}    {return ELSE; }
{IF}      {return IF; }
{INPUT}   {return INPUT; }
{INT}     {return INT; }
{OUTPUT}  {return OUTPUT; }
{RETURN}  {return RETURN; }
{VOID}    {return VOID; }
{WHILE}   {return WHILE; }
{WRITE}   {return WRITE; }

{PLUS}    {return PLUS; }
{MINUS}   {return MINUS; }
{TIMES}   {return TIMES; }
{OVER}    {return OVER; }
{LT}      {return LT; }
{LE}      {return LE; }
{GT}      {return GT; }
{GE}      {return GE; }
{EQ}      {return EQ; }
{NEQ}     {return NEQ; }
{ASSIGN}  {return ASSIGN; }

{SEMI}    {return SEMI; }
{COMMA}   {return COMMA; }
{LPAREN}  {return LPAREN; }
{RPAREN}  {return RPAREN; }
{LBRACK}  {return LBRACK; }
{RBRACK}  {return RBRACK; }
{LBRACE}  {return LBRACE; }
{RBRACE}  {return RBRACE; }

{NUM}     {return NUM; }
{ID}      {strcpy(id_name_copy, yytext); return ID; }
{STRING}  {add_literal(lit_tb, yytext); return STRING; }

{SPACE}   {}
{COMMENT} {}
{UNKNOWN} {
            printf("SCANNING ERROR (%d): Unknown symbol %s\n", yylineno, yytext);
            exit(1); 
          }
%%

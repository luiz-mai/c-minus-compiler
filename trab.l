/*Configuração*/
%option outfile="scanner.c"
%option noyywrap
%option nounput
%option noinput

%{

/*Inclusão de bibliotecas*/
#include "tree.h"
#include "parser.h"
#include "literalsTable.h"
#include "symbolsTable.h"

#define process_token(type)return type

extern LiteralsTable *lt;
extern SymbolsTable *vart;
extern SymbolsTable *aux_vart;
extern SymbolsTable *funct;

%}

/*Definição de estados e opções*/
%x linecomment
%x blockcomment
%option yylineno

%%

<INITIAL,blockcomment>"\n"    	{ }
<linecomment>"\n"    		{ BEGIN(INITIAL);}

"/\*"				{ BEGIN(blockcomment); }	/*Início de comentário em bloco*/
"//"				{ BEGIN(linecomment); }		/*Início de comentário em linha*/

<blockcomment>[^*\n]*		;				/*Ignora o que não for "*" */
<blockcomment>"*"+[^*/\n]*	;				/*Ignora o que não for "*<barra>" */
<blockcomment>"*"+"/"		{ BEGIN(INITIAL); }
<linecomment>[^"\n"]		;


"else"  	 		           {  yylval = new_node(ELSE_NODE); process_token(ELSE); }	/*PALAVRAS RESERVADAS*/
"if"   				           {  yylval = new_node(IF_NODE); process_token(IF); }
"input"   			         {  yylval = new_node(INPUT_NODE); process_token(INPUT); }
"int"   			           {  yylval = new_node(INT_NODE); process_token(INT); }
"output"   			         {  yylval = new_node(OUTPUT_NODE); process_token(OUTPUT); }
"return"   			         {  yylval = new_node(RETURN_NODE); process_token(RETURN); }
"void"   			           {  yylval = new_node(VOID_NODE); process_token(VOID); }
"while"   			         {  yylval = new_node(WHILE_NODE); process_token(WHILE); }
"write"   			         {  yylval = new_node(WRITE_NODE); process_token(WRITE); }

"+"   				           {  yylval = new_node(PLUS_NODE); process_token(PLUS); }	/*OPERADORES*/
"-"   				           {  yylval = new_node(MINUS_NODE); process_token(MINUS); }
"*"   				           {  yylval = new_node(TIMES_NODE); process_token(TIMES); }
"/"   				           {  yylval = new_node(OVER_NODE); process_token(OVER); }
"<"   				           {  yylval = new_node(LT_NODE); process_token(LT); }
"<="   				           {  yylval = new_node(LEQ_NODE); process_token(LE); }
">"   				           {  yylval = new_node(GT_NODE); process_token(GT); }
">="   				           {  yylval = new_node(GEQ_NODE); process_token(GE); }
"=="   				           {  yylval = new_node(EQ_NODE); process_token(EQ); }
"!="   				           {  yylval = new_node(NEQ_NODE); process_token(NEQ); }
"="   				           {  yylval = new_node(ASSIGN_NODE); process_token(ASSIGN); }
;   				             {  process_token(SEMI); }
,   				             {  process_token(COMMA); }
"("   				           {  process_token(LPAREN); }
")"   				           {  process_token(RPAREN); }
"["   				           {  process_token(LBRACK); }
"]"   				           {  process_token(RBRACK); }
"{"   				           {  process_token(LBRACE); }
"}"   				           {  process_token(RBRACE); }

\"([^\"]*)\"			       { yylval = new_custom_node(STRING_NODE, addLiteral(lt, yytext)); process_token(STRING); }	/*MÚLTIPLOS LEXEMAS*/
[0-9]+				           { yylval = new_custom_node(NUM_NODE, atoi(yytext)); process_token(NUM); }
[a-zA-Z]+[0-9a-zA-Z]*		 { yylval = new_custom_node(ID_NODE, addOrLookSymbol(aux_vart, yytext, yylineno, -1, -1)); process_token(ID); }

[ \n\t]+                 { }
.     			             { printf("SCANNING ERROR (%d): Unknown symbol %s\n", yylineno, yytext); exit(0);};

%%

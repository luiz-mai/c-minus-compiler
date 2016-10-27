/*################################################################################
##										##
##			   TRABALHO 2 DE COMPILADORES				##
##			    Luiz Felipe Ferreira Mai				##
##										##
##			       Prof. Eduardo Zambon				##
##				      2016/2					##
##										##
##										##
##			Melhor visualizado com tabulação 8			##
##										##
################################################################################*/

//Opções do bison
%output "parser.c"
%defines "parser.h"
%define parse.error verbose
%define parse.lac full
%define parse.trace

%{

#include <stdio.h>
#include "tree.h"

int yylex(void);
void yyerror(char const *s);

extern int yylineno;
Tree *tree;

%}

%define api.value.type {Tree*} // Type of variable yylval;

//DEFINIÇÃO DOS TOKENS

//Palavras reservadas
%token IF
%token ELSE
%token INPUT
%token INT
%token OUTPUT
%token RETURN
%token VOID
%token WHILE
%token WRITE

//Operadores
%token PLUS
%token MINUS
%token TIMES
%token OVER
%token LT
%token LE
%token GT
%token GE
%token EQ
%token NEQ
%token ASSIGN
%token SEMI
%token COMMA
%token LPAREN
%token RPAREN
%token LBRACK
%token RBRACK
%token LBRACE
%token RBRACE

//Múltiplos lexemas
%token NUM
%token ID
%token STRING

//Definição de precedência
%left NEQ EQ LT LE GT GE
%left PLUS MINUS
%left TIMES OVER

%start program

%%

program: funcDeclList																{ tree = new_subtree("program", 1, $1); };

funcDeclList: funcDecl															{ $$ = new_subtree("funcDeclList", 1, $1); }
| funcDeclList funcDecl															{ $$ = new_subtree("funcDeclList", 2, $1, $2); };

funcDecl: funcHeader funcBody												{ $$ = new_subtree("funcDecl", 2, $1, $2); };

funcHeader: retType ID LPAREN params RPAREN					{ $$ = new_subtree("funcHeader", 5, $1, $2, $3, $4, $5); };

funcBody: LBRACE optVarDecl optStmtList RBRACE			{ $$ = new_subtree("funcBody", 4, $1, $2, $3, $4); };

optVarDecl: %empty																	{ $$ = new_subtree("optVarDecl", 1, ""); };
| varDeclList																				{ $$ = new_subtree("optVarDecl", 1, $1); };

optStmtList: %empty																	{ $$ = new_subtree("optStmtList", 1, ""); };
| stmtList																					{ $$ = new_subtree("optStmtList", 1, $1); };

retType: INT																				{ $$ = new_subtree("retType", 1, $1); }
| VOID																							{ $$ = new_subtree("retType", 1, $1); };

params: VOID																				{ $$ = new_subtree("params", 1, $1); }
| paramList																					{ $$ = new_subtree("params", 1, $1); };

paramList: param																		{ $$ = new_subtree("paramList", 1, $1); }
| paramList COMMA param															{ $$ = new_subtree("paramList", 3, $1, $2, $3); };

param: INT ID																				{ $$ = new_subtree("param", 2, $1, $2); }
| INT ID LBRACK RBRACK															{ $$ = new_subtree("param", 4, $1, $2, $3, $4); };

varDeclList: varDecl																{ $$ = new_subtree("varDeclList", 1, $1); }
| varDeclList varDecl																{ $$ = new_subtree("varDeclList", 2, $1, $2); };

varDecl: INT ID SEMI																{ $$ = new_subtree("varDecl", 3, $1, $2, $3); }
| INT ID LBRACK NUM RBRACK SEMI											{ $$ = new_subtree("varDecl", 6, $1, $2, $3, $4, $5, $6); };

stmtList: stmt																			{ $$ = new_subtree("stmtList", 1, $1); }
| stmtList stmt																			{ $$ = new_subtree("stmtList", 2, $1, $2); };

stmt: assignStmt																		{ $$ = new_subtree("stmt", 1, $1); }
| ifStmt																						{ $$ = new_subtree("stmt", 1, $1); }
| whileStmt																					{ $$ = new_subtree("stmt", 1, $1); }
| returnStmt																				{ $$ = new_subtree("stmt", 1, $1); }
| funcCall SEMI																			{ $$ = new_subtree("stmt", 2, $1, $2); };

assignStmt: lval ASSIGN arithExpr SEMI							{ $$ = new_subtree("assignStmt", 4, $1, $2, $3, $4); };

lval: ID																						{ $$ = new_subtree("lval", 1, $1); }
| ID LBRACK NUM RBRACK															{ $$ = new_subtree("lval", 4, $1, $2, $3, $4); }
| ID LBRACK ID RBRACK																{ $$ = new_subtree("lval", 4, $1, $2, $3, $4); };

ifStmt: IF LPAREN boolExpr RPAREN block							{ $$ = new_subtree("ifStmt", 5, $1, $2, $3, $4, $5); }
| IF LPAREN boolExpr RPAREN block ELSE block				{ $$ = new_subtree("ifStmt", 7, $1, $2, $3, $4, $5, $6, $7); };

block: LBRACE optStmtList RBRACE										{ $$ = new_subtree("block", 3, $1, $2, $3); };

whileStmt: WHILE LPAREN boolExpr RPAREN block				{ $$ = new_subtree("whileStmt", 5, $1, $2, $3, $4, $5); };

returnStmt: RETURN SEMI															{ $$ = new_subtree("returnStmt", 2, $1, $2); }
| RETURN arithExpr SEMI															{ $$ = new_subtree("returnStmt", 3, $1, $2, $3); };

funcCall: outputCall																{ $$ = new_subtree("funcCall", 1, $1); }
| writeCall																					{ $$ = new_subtree("funcCall", 1, $1); }
| userFuncCall																			{ $$ = new_subtree("funcCall", 1, $1); };

inputCall: INPUT LPAREN RPAREN											{ $$ = new_subtree("inputCall", 3, $1, $2, $3); };

outputCall: OUTPUT LPAREN arithExpr RPAREN					{ $$ = new_subtree("outputCall", 4, $1, $2, $3, $4); };

writeCall: WRITE LPAREN STRING RPAREN								{ $$ = new_subtree("writeCall", 4, $1, $2, $3, $4); };

userFuncCall: ID LPAREN optArgList RPAREN						{ $$ = new_subtree("userFuncCall", 4, $1, $2, $3, $4); };

optArgList: %empty																	{ $$ = new_subtree("optArgList", 1, ""); };
| argList																						{ $$ = new_subtree("optArgList", 1, $1); };

argList: arithExpr																	{ $$ = new_subtree("argList", 1, $1); }
| argList COMMA arithExpr														{ $$ = new_subtree("argList", 3, $1, $2, $3); };

boolExpr: arithExpr LT arithExpr										{ $$ = new_subtree("boolExpr", 3, $1, $2, $3); }
| arithExpr LE arithExpr														{ $$ = new_subtree("boolExpr", 3, $1, $2, $3); }
| arithExpr GT arithExpr														{ $$ = new_subtree("boolExpr", 3, $1, $2, $3); }
| arithExpr GE arithExpr														{ $$ = new_subtree("boolExpr", 3, $1, $2, $3); }
| arithExpr EQ arithExpr														{ $$ = new_subtree("boolExpr", 3, $1, $2, $3); }
| arithExpr NEQ arithExpr														{ $$ = new_subtree("boolExpr", 3, $1, $2, $3); };

arithExpr: NUM																			{ $$ = new_subtree("arithExpr", 1, $1); }
| inputCall																					{ $$ = new_subtree("arithExpr", 1, $1); }
| lval																							{ $$ = new_subtree("arithExpr", 1, $1); }
| userFuncCall																			{ $$ = new_subtree("arithExpr", 1, $1); }
| LPAREN arithExpr RPAREN														{ $$ = new_subtree("arithExpr", 3, $1, $2, $3); }
| arithExpr PLUS arithExpr													{ $$ = new_subtree("arithExpr", 3, $1, $2, $3); }
| arithExpr MINUS arithExpr													{ $$ = new_subtree("arithExpr", 3, $1, $2, $3); }
| arithExpr TIMES arithExpr													{ $$ = new_subtree("arithExpr", 3, $1, $2, $3); }
| arithExpr OVER arithExpr													{ $$ = new_subtree("arithExpr", 3, $1, $2, $3); };

%%

int main() {

	yydebug = 0;

	if(yyparse() == 0){
		//printf("PARSE SUCESSFUL!\n");
		print_dot(tree);
		free_tree(tree);
	}
	return 0;
}

void yyerror (char const *s) {
	extern int yylineno;
	printf("PARSE ERROR (%d): %s\n", yylineno, s);
}

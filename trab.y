//Opções do bison
%output "parser.c"
%defines "parser.h"
%define parse.error verbose
%define parse.lac full
%{

#include <stdio.h>
#include <stdlib.h>
#include "tree.h"
#include "literalsTable.h"
#include "symbolsTable.h"

int yylex(void);
void yyerror(char const *s);
void checkSymbol(char*, Tree*, int, int, int);
void newSymbol(char*, Tree*, int, int, int);

extern int yylineno;
Tree *tree;
LiteralsTable* lt;
SymbolsTable* vart;
SymbolsTable* funct;
int calledArity = 0;
int declaredArity = 0;
int scope = 0;


%}

%define api.value.type {Tree*} // Type of variable yylval;

//Palavras reservadas
%token IF ELSE INPUT INT OUTPUT RETURN VOID WHILE WRITE

//Operadores
%token PLUS MINUS TIMES OVER LT LE GT GE EQ NEQ ASSIGN SEMI COMMA LPAREN RPAREN LBRACK RBRACK LBRACE RBRACE

//Múltiplos lexemas
%token NUM ID STRING

//Definição de precedência
%left NEQ EQ LT LE GT GE
%left PLUS MINUS
%left TIMES OVER

%start program

%%

program: funcDeclList																{ tree = new_subtree("program", 1, $1); };

funcDeclList: funcDecl															{ $$ = new_subtree("funcDeclList", 1, $1); }
| funcDeclList funcDecl															{ $$ = new_subtree("funcDeclList", 2, $1, $2); };

funcDecl: funcHeader funcBody												{ scope++; $$ = new_subtree("funcDecl", 2, $1, $2); };

funcHeader: retType ID LPAREN params RPAREN					{ newSymbol("function", $2, yylineno, -1, declaredArity); declaredArity = 0;  $$ = new_subtree("funcHeader", 5, $1, $2, $3, $4, $5); };

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

param: INT ID																				{ declaredArity++; newSymbol("variable", $2, yylineno, scope, -1); $$ = new_subtree("param", 2, $1, $2); }
| INT ID LBRACK RBRACK															{ declaredArity++; newSymbol("variable", $2, yylineno, scope, -1); $$ = new_subtree("param", 4, $1, $2, $3, $4); };

varDeclList: varDecl																{ $$ = new_subtree("varDeclList", 1, $1); }
| varDeclList varDecl																{ $$ = new_subtree("varDeclList", 2, $1, $2); };

varDecl: INT ID SEMI																{ newSymbol("variable", $2, yylineno, scope, -1); $$ = new_subtree("varDecl", 3, $1, $2, $3); }
| INT ID LBRACK NUM RBRACK SEMI											{ newSymbol("variable", $2, yylineno, scope, -1); $$ = new_subtree("varDecl", 6, $1, $2, $3, $4, $5, $6); };

stmtList: stmt																			{ $$ = new_subtree("stmtList", 1, $1); }
| stmtList stmt																			{ $$ = new_subtree("stmtList", 2, $1, $2); };

stmt: assignStmt																		{ $$ = new_subtree("stmt", 1, $1); }
| ifStmt																						{ $$ = new_subtree("stmt", 1, $1); }
| whileStmt																					{ $$ = new_subtree("stmt", 1, $1); }
| returnStmt																				{ $$ = new_subtree("stmt", 1, $1); }
| funcCall SEMI																			{ $$ = new_subtree("stmt", 2, $1, $2); };

assignStmt: lval ASSIGN arithExpr SEMI							{ $$ = new_subtree("assignStmt", 4, $1, $2, $3, $4); };

lval: ID																						{ checkSymbol("variable", $1, yylineno, scope, -1); $$ = new_subtree("lval", 1, $1); }
| ID LBRACK NUM RBRACK															{ checkSymbol("variable", $1, yylineno, scope, -1); $$ = new_subtree("lval", 4, $1, $2, $3, $4); }
| ID LBRACK ID RBRACK																{ checkSymbol("variable", $1, yylineno, scope, -1);  checkSymbol("variable", $3, yylineno, scope, -1); $$ = new_subtree("lval", 4, $1, $2, $3, $4); };

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

userFuncCall: ID LPAREN optArgList RPAREN						{ checkSymbol("function", $1, yylineno, -1, calledArity); calledArity = 0; $$ = new_subtree("userFuncCall", 4, $1, $2, $3, $4); };

optArgList: %empty																	{ $$ = new_subtree("optArgList", 1, ""); };
| argList																						{ $$ = new_subtree("optArgList", 1, $1); };

argList: arithExpr																	{ calledArity++; $$ = new_subtree("argList", 1, $1); }
| argList COMMA arithExpr														{ calledArity++; $$ = new_subtree("argList", 3, $1, $2, $3); };

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

  lt = createLiteralsTable();
  vart = createSymbolsTable();
  funct = createSymbolsTable();

	if(yyparse() == 0){
		printf("PARSE SUCESSFUL!\n");
		printLiteralsTable(lt);
    printVariablesTable(vart);
    printFunctionsTable(funct);
	}

  freeSymbolsTable(vart);
  freeSymbolsTable(funct);
  freeLiteralsTable(lt);
	//TODO: FREE TREE;
	return 0;
}

void yyerror (char const *s) {
	extern int yylineno;
	printf("PARSE ERROR (%d): %s\n", yylineno, s);
}

void checkSymbol(char* type, Tree* node, int line, int scope, int calledArity) {
  if(strcmp(type, "variable") == 0){
    if(!symbolExists(vart, node->text)){
        printf("SEMANTIC ERROR (%d): variable '%s' was not declared.\n", line, node->text);
        exit(1);
    }
  }
    if(strcmp(type, "function") == 0){
      if(!symbolExists(funct, node->text)){
            printf("SEMANTIC ERROR (%d): function '%s' was not declared.\n", line, node->text);
            exit(1);
        }
        int declaredArity = getSymbolArity(funct, node->text);
        if(calledArity != declaredArity){
          printf("SEMANTIC ERROR (%d): function '%s' was called with %d arguments but declared with %d parameters.\n", line, node->text, calledArity, declaredArity);
          exit(1);
        }
    }
}

void newSymbol(char* type, Tree* node, int line, int scope, int declaredArity) {
  if(strcmp(type, "variable") == 0){
    if (symbolExists(vart, node->text) && scope == getSymbolScope(vart, node->text)) {
        printf("SEMANTIC ERROR (%d): variable '%s' already declared at line %d.\n",
            line, node->text, getSymbolLine(vart, node->text));
        exit(1);
    }
    addSymbol(vart, node->text, line, scope, declaredArity);
  }
  if(strcmp(type, "function") == 0){
    if (symbolExists(funct, node->text)) {
        printf("SEMANTIC ERROR (%d): function '%s' already declared at line %d.\n",
            line, node->text, getSymbolLine(funct, node->text));
        exit(1);
    }

    addSymbol(funct, node->text, line, scope, declaredArity);
  }
}

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

program: funcDeclList																{ tree = $1; };

funcDeclList: funcDecl															{ $$ = new_subtree("funcDeclList", 1, $1); }
| funcDeclList funcDecl															{ $$ = add_child($$, $2); };

funcDecl: funcHeader funcBody												{ scope++; $$ = new_subtree("funcDecl", 2, $1, $2); };

funcHeader: retType ID LPAREN params RPAREN					{ newSymbol("function", $2, yylineno, -1, declaredArity); declaredArity = 0;  $$ = new_subtree("funcHeader", 3, $1, new_custom_node("id", getSymbolIndex(funct, $2, -1)), $4); };

funcBody: LBRACE optVarDecl optStmtList RBRACE			{ $$ = new_subtree("funcBody", 2, $2, $3); };

optVarDecl: %empty																	{ $$ = new_subtree("varList", 0); };
| varDeclList																				{ $$ = $1; };

retType: INT																				{ $$ = new_node("INT"); }
| VOID																							{ $$ = new_node("VOID"); };

params: VOID																				{ $$ = new_node("VOID"); }
| paramList																					{ $$ = $1; };

paramList: param																		{ $$ = new_subtree("param", 1, $1); }
| paramList COMMA param															{ $$ = add_child($$, $3); };

param: INT ID																				{ declaredArity++; newSymbol("variable", $2, yylineno, scope, -1); $$ = new_custom_node("svar", getSymbolIndex(vart, $2, scope)); }
| INT ID LBRACK RBRACK															{ declaredArity++; newSymbol("variable", $2, yylineno, scope, -1); $$ = new_custom_node("cvar", getSymbolIndex(vart, $2, scope)); };

varDeclList: varDecl																{ $$ = new_subtree("varList", 1, $1); }
| varDeclList varDecl																{ $$ = add_child($$, $2); };

varDecl: INT ID SEMI																{ newSymbol("variable", $2, yylineno, scope, -1); $$ = new_custom_node("svar", getSymbolIndex(vart, $2, scope));  }
| INT ID LBRACK NUM RBRACK SEMI											{ newSymbol("variable", $2, yylineno, scope, -1); Tree* varDeclNode = new_custom_node("cvar", getSymbolIndex(vart, $2, scope)); $$ = add_child(varDeclNode, new_custom_node("num", atoi(get_node_text($4)))); };

block: LBRACE optStmtList RBRACE										{ $$ = $2; };

optStmtList: stmtList															  { };

stmtList: %empty																		{ $$ = new_subtree("stmtList", 0); }
| stmtList stmt																			{ $$ = add_child($$, $2); };

stmt: assignStmt																		{ $$ = $1; }
| ifStmt																						{ $$ = $1; }
| whileStmt																					{ $$ = $1; }
| returnStmt																				{ $$ = $1; }
| funcCall SEMI																			{ $$ = $1; };

assignStmt: lval ASSIGN arithExpr SEMI							{ $$ = new_subtree("=", 2, $1, $3); };

lval: ID																						{ checkSymbol("variable", $1, yylineno, scope, -1); $$ = new_custom_node("svar", getSymbolIndex(vart, $1, scope)); }
| ID LBRACK NUM RBRACK															{ checkSymbol("variable", $1, yylineno, scope, -1);   }
| ID LBRACK ID RBRACK																{ checkSymbol("variable", $1, yylineno, scope, -1);  checkSymbol("variable", $3, yylineno, scope, -1); Tree* lvalNode = new_custom_node("cvar", getSymbolIndex(vart, $1, scope)); add_child(lvalNode, $$ = new_custom_node("svar", getSymbolIndex(vart, $3, scope))); $$ = lvalNode;};

ifStmt: IF  LPAREN boolExpr RPAREN block							{ $$ = new_subtree("if", 2, $3, $5); }
| IF LPAREN boolExpr RPAREN block ELSE block				{ $$ = new_subtree("if", 3, $3, $5, $7); };

whileStmt: WHILE LPAREN boolExpr RPAREN block				{ $$ = new_subtree("while", 2, $3, $5); };

returnStmt: RETURN SEMI															{ $$ = new_subtree("return", 0); }
| RETURN arithExpr SEMI															{ $$ = new_subtree("return", 1, $2); };

funcCall: outputCall																{ $$ = $1; }
| writeCall																					{ $$ = $1; }
| userFuncCall																			{ $$ = $1; };

inputCall: INPUT LPAREN RPAREN											{ $$ = $1; };

outputCall: OUTPUT LPAREN arithExpr RPAREN					{ $$ = new_subtree("output", 1, $3); };

writeCall: WRITE LPAREN STRING RPAREN								{ $$ = new_subtree("write", 1, new_custom_node("string", getLiteralIndex(lt, $3))); };

userFuncCall: ID LPAREN optArgList RPAREN						{ checkSymbol("function", $1, yylineno, -1, calledArity); calledArity = 0; Tree* fcall = new_custom_node("fcall", getSymbolIndex(funct, $1, -1)); $$ = add_child(fcall, $3);};

optArgList: %empty																	{  };
| argList																						{ $$ = $1; };

argList: arithExpr																	{ calledArity++; $$ = new_subtree("argList", 1, $1); }
| argList COMMA arithExpr														{ calledArity++; $$ = add_child($$, $3); };

boolExpr: arithExpr LT arithExpr										{ $$ = new_subtree("<", 2, $1, $3); }
| arithExpr LE arithExpr														{ $$ = new_subtree("<=", 2, $1, $3); }
| arithExpr GT arithExpr														{ $$ = new_subtree(">", 2, $1, $3); }
| arithExpr GE arithExpr														{ $$ = new_subtree(">=", 2, $1, $3); }
| arithExpr EQ arithExpr														{ $$ = new_subtree("==", 2, $1, $3); }
| arithExpr NEQ arithExpr														{ $$ = new_subtree("!=", 2, $1, $3); };

arithExpr: NUM																			{ $$ = new_custom_node("num", atoi(get_node_text($1))); }
| inputCall																					{ $$ = $1; }
| lval																							{ $$ = $1; }
| userFuncCall																			{ $$ = $1; }
| LPAREN arithExpr RPAREN														{ $$ = $2; }
| arithExpr PLUS arithExpr													{ $$ = new_subtree("+", 2, $1, $3); }
| arithExpr MINUS arithExpr													{ $$ = new_subtree("-", 2, $1, $3); }
| arithExpr TIMES arithExpr													{ $$ = new_subtree("*", 2, $1, $3); }
| arithExpr OVER arithExpr													{ $$ = new_subtree("/", 2, $1, $3); };

%%


int main() {

  lt = createLiteralsTable();
  vart = createSymbolsTable();
  funct = createSymbolsTable();

	if(yyparse() == 0){
		printf("PARSE SUCESSFUL!\n");
	}

  freeSymbolsTable(vart);
  freeSymbolsTable(funct);
  freeLiteralsTable(lt);
	free_tree(tree);
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

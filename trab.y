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
SymbolsTable* aux_vart;
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

funcDeclList: funcDecl															{ $$ = new_subtree(FUNC_DECL_LIST_NODE, 1, $1); }
| funcDeclList funcDecl															{ $$ = add_child($$, $2); };

funcDecl: funcHeader funcBody												{ scope++; $$ = new_subtree(FUNC_DECL_NODE, 2, $1, $2); };

funcHeader: retType ID LPAREN params RPAREN					{ newSymbol("function", $2, yylineno, -1, declaredArity); declaredArity = 0;  $$ = new_subtree(FUNC_HEADER_NODE, 3, $1, new_custom_node(ID_NODE, getSymbolIndex(funct, getSymbolName(aux_vart, $2->data), -1)), $4); };

funcBody: LBRACE optVarDecl optStmtList RBRACE			{ $$ = new_subtree(FUNC_BODY_NODE, 2, $2, $3); };

optVarDecl: %empty																	{ $$ = new_subtree(VAR_LIST_NODE, 0); };
| varDeclList																				{ $$ = $1; };

retType: INT																				{ $$ = new_node(INT_NODE); }
| VOID																							{ $$ = new_node(VOID_NODE); };

params: VOID																				{ $$ = new_node(VOID_NODE); }
| paramList																					{ $$ = $1; };

paramList: param																		{ $$ = new_subtree(PARAM_NODE, 1, $1); }
| paramList COMMA param															{ $$ = add_child($$, $3); };

param: INT ID																				{ declaredArity++; newSymbol("variable", $2, yylineno, scope, -1); $$ = new_custom_node(SVAR_NODE, getSymbolIndex(vart, getSymbolName(aux_vart, $2->data), scope)); }
| INT ID LBRACK RBRACK															{ declaredArity++; newSymbol("variable", $2, yylineno, scope, -1); $$ = new_custom_node(CVAR_NODE, getSymbolIndex(vart, getSymbolName(aux_vart, $2->data), scope)); };

varDeclList: varDecl																{ $$ = new_subtree(VAR_LIST_NODE, 1, $1); }
| varDeclList varDecl																{ $$ = add_child($$, $2); };

varDecl: INT ID SEMI																{ newSymbol("variable", $2, yylineno, scope, -1); $$ = new_custom_node(SVAR_NODE, getSymbolIndex(vart, getSymbolName(aux_vart, $2->data), scope));  }
| INT ID LBRACK NUM RBRACK SEMI											{ newSymbol("variable", $2, yylineno, scope, -1); Tree* varDeclNode = new_custom_node(CVAR_NODE, getSymbolIndex(vart, getSymbolName(aux_vart, $2->data), scope)); $$ = add_child(varDeclNode, $4); };

block: LBRACE optStmtList RBRACE										{ $$ = $2; };

optStmtList: stmtList															  { };

stmtList: %empty																		{ $$ = new_subtree(STMT_LIST_NODE, 0); }
| stmtList stmt																			{ $$ = add_child($$, $2); };

stmt: assignStmt																		{ $$ = $1; }
| ifStmt																						{ $$ = $1; }
| whileStmt																					{ $$ = $1; }
| returnStmt																				{ $$ = $1; }
| funcCall SEMI																			{ $$ = $1; };

assignStmt: lval ASSIGN arithExpr SEMI							{ $$ = new_subtree(ASSIGN_NODE, 2, $1, $3); };

lval: ID																						{ checkSymbol("variable", $1, yylineno, scope, -1); $$ = new_custom_node(SVAR_NODE, getSymbolIndex(vart, getSymbolName(aux_vart, $1->data), scope)); }
| ID LBRACK NUM RBRACK															{ checkSymbol("variable", $1, yylineno, scope, -1);   }
| ID LBRACK ID RBRACK																{ checkSymbol("variable", $1, yylineno, scope, -1);  checkSymbol("variable", $3, yylineno, scope, -1); Tree* lvalNode = new_custom_node(CVAR_NODE, getSymbolIndex(vart, getSymbolName(aux_vart, $1->data), scope)); add_child(lvalNode, $$ = new_custom_node(SVAR_NODE, getSymbolIndex(vart, getSymbolName(aux_vart, $3->data), scope))); $$ = lvalNode;};

ifStmt: IF  LPAREN boolExpr RPAREN block							{ $$ = new_subtree(IF_NODE, 2, $3, $5); }
| IF LPAREN boolExpr RPAREN block ELSE block				{ $$ = new_subtree(IF_NODE, 3, $3, $5, $7); };

whileStmt: WHILE LPAREN boolExpr RPAREN block				{ $$ = new_subtree(WHILE_NODE, 2, $3, $5); };

returnStmt: RETURN SEMI															{ $$ = new_subtree(RETURN_NODE, 0); }
| RETURN arithExpr SEMI															{ $$ = new_subtree(RETURN_NODE, 1, $2); };

funcCall: outputCall																{ $$ = $1; }
| writeCall																					{ $$ = $1; }
| userFuncCall																			{ $$ = $1; };

inputCall: INPUT LPAREN RPAREN											{ $$ = $1; };

outputCall: OUTPUT LPAREN arithExpr RPAREN					{ $$ = new_subtree(OUTPUT_NODE, 1, $3); };

writeCall: WRITE LPAREN STRING RPAREN								{ $$ = new_subtree(WRITE_NODE, 1, $3); };

userFuncCall: ID LPAREN optArgList RPAREN						{ checkSymbol("function", $1, yylineno, -1, calledArity); calledArity = 0; Tree* fcall = new_custom_node(FCALL_NODE, getSymbolIndex(funct, getSymbolName(aux_vart, $1->data), -1)); $$ = add_child(fcall, $3);};

optArgList: %empty																	{  };
| argList																						{ $$ = $1; };

argList: arithExpr																	{ calledArity++; $$ = new_subtree(ARG_LIST_NODE, 1, $1); }
| argList COMMA arithExpr														{ calledArity++; $$ = add_child($$, $3); };

boolExpr: arithExpr LT arithExpr										{ $$ = new_subtree(LT_NODE, 2, $1, $3); }
| arithExpr LE arithExpr														{ $$ = new_subtree(LEQ_NODE, 2, $1, $3); }
| arithExpr GT arithExpr														{ $$ = new_subtree(GT_NODE, 2, $1, $3); }
| arithExpr GE arithExpr														{ $$ = new_subtree(GEQ_NODE, 2, $1, $3); }
| arithExpr EQ arithExpr														{ $$ = new_subtree(EQ_NODE, 2, $1, $3); }
| arithExpr NEQ arithExpr														{ $$ = new_subtree(NEQ_NODE, 2, $1, $3); };

arithExpr: NUM																			{ $$ = $1; }
| inputCall																					{ $$ = $1; }
| lval																							{ $$ = $1; }
| userFuncCall																			{ $$ = $1; }
| LPAREN arithExpr RPAREN														{ $$ = $2; }
| arithExpr PLUS arithExpr													{ $$ = new_subtree(PLUS_NODE, 2, $1, $3); }
| arithExpr MINUS arithExpr													{ $$ = new_subtree(MINUS_NODE, 2, $1, $3); }
| arithExpr TIMES arithExpr													{ $$ = new_subtree(TIMES_NODE, 2, $1, $3); }
| arithExpr OVER arithExpr													{ $$ = new_subtree(OVER_NODE, 2, $1, $3); };

%%


int main() {

  lt = createLiteralsTable();
  vart = createSymbolsTable();
  aux_vart = createSymbolsTable();
  funct = createSymbolsTable();

	if(yyparse() == 0){
		//printf("PARSE SUCESSFUL!\n");
	}
 print_dot(tree);

  freeSymbolsTable(aux_vart);
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
 char* name = getSymbolName(aux_vart, node->data);
  if(strcmp(type, "variable") == 0){
    if(!symbolExists(vart, name)){
        printf("SEMANTIC ERROR (%d): variable '%s' was not declared.\n", line, name);
        exit(1);
    }
  }
    if(strcmp(type, "function") == 0){
      if(!symbolExists(funct, name)){
            printf("SEMANTIC ERROR (%d): function '%s' was not declared.\n", line, name);
            exit(1);
        }
        int declaredArity = getSymbolArity(funct, name);
        if(calledArity != declaredArity){
          printf("SEMANTIC ERROR (%d): function '%s' was called with %d arguments but declared with %d parameters.\n", line, name, calledArity, declaredArity);
          exit(1);
        }
    }
}

void newSymbol(char* type, Tree* node, int line, int scope, int declaredArity) {
 char* name = getSymbolName(aux_vart, node->data);
  if(strcmp(type, "variable") == 0){
    if (symbolExists(vart, name) && scope == getSymbolScope(vart, name)) {
        printf("SEMANTIC ERROR (%d): variable '%s' already declared at line %d.\n",
            line, name, getSymbolLine(vart, name));
        exit(1);
    }
    addOrLookSymbol(vart, name, line, scope, declaredArity);
  }
  if(strcmp(type, "function") == 0){
    if (symbolExists(funct, name)) {
        printf("SEMANTIC ERROR (%d): function '%s' already declared at line %d.\n",
            line, name, getSymbolLine(funct, name));
        exit(1);
    }
    addOrLookSymbol(funct, name, line, scope, declaredArity);
  }
}

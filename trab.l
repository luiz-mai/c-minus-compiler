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

/*Configuração*/
%option outfile="scanner.c"
%option noyywrap
%option nounput
%option noinput

%{

/*Inclusão de bibliotecas*/
#include "tree.h"
#include "parser.h"

#define process_token(type) yylval = new_node(yytext); return type

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


"else"  	 		{ process_token(ELSE); }	/*PALAVRAS RESERVADAS*/
"if"   				{ process_token(IF); }
"input"   			{ process_token(INPUT); }
"int"   			{ process_token(INT); }
"output"   			{ process_token(OUTPUT); }
"return"   			{ process_token(RETURN); }
"void"   			{ process_token(VOID); }
"while"   			{ process_token(WHILE); }
"write"   			{ process_token(WRITE); }

"+"   				{ process_token(PLUS); }	/*OPERADORES*/
"-"   				{ process_token(MINUS); }
"*"   				{ process_token(TIMES); }
"/"   				{ process_token(OVER); }
"<"   				{ process_token(LT); }
"<="   				{ process_token(LE); }
">"   				{ process_token(GT); }
">="   				{ process_token(GE); }
"=="   				{ process_token(EQ); }
"!="   				{ process_token(NEQ); }
"="   				{ process_token(ASSIGN); }
;   				{ process_token(SEMI); }
,   				{ process_token(COMMA); }
"("   				{ process_token(LPAREN); }
")"   				{ process_token(RPAREN); }
"["   				{ process_token(LBRACK); }
"]"   				{ process_token(RBRACK); }
"{"   				{ process_token(LBRACE); }
"}"   				{ process_token(RBRACE); }

\"([^\"]*)\"			{ process_token(STRING); }	/*MÚLTIPLOS LEXEMAS*/
[0-9]+				{ process_token(NUM); }
[a-zA-Z]+[0-9a-zA-Z]*				{ process_token(ID); }

[ \n\t]+
.     			{ printf("SCANNING ERROR (%d): Unknown symbol %s\n", yylineno, yytext); exit(0);};

%%

D                       [0-9]
L                       [a-zA-Z_]
H                       [a-fA-F0-9]
E                       [Ee][+-]?{D}+
FS                      (f|F|l|L)
IS                      (u|U|l|L)*

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
%}

%option yylineno
%%

[ \t\v\n\f]             {/* Sert a supprimer les blancs*/ }

"extern"                { return EXTERN; }

"if"                    { return IF; }
"else"                  { return ELSE; }
"while"                 { return WHILE; }
"for"					{ return FOR; }
"goto"					{ return GOTO; }

"switch"                { return SWITCH; }
"break"                 { return BREAK; }
"case"                  { return CASE; }
"default"               { return DEFAULT; }

"return"                { return RETURN; }

"int"                   { return INT; }
"void"                  { return VOID; }

[/][*][^*]*[*]+([^*/][^*]*[*]+)*[/]  {/* Sert a ignorer les commentaires */}

[-]?[0-9]+						{ return CONSTANTE; }
[_]?[a-zA-Z]([a-zA-Z]|[0-9])* 	{ return IDENTIFICATEUR; }

">>"					{ return RSHIFT; }
"<<"					{ return LSHIFT; }

"&&"                    { return LAND; }
"||"                    { return LOR; }
"<="                    { return LEQ; }
">="                    { return GEQ; }
"=="                    { return EQ; }
"!="                    { return NEQ; }

"+"						{ return PLUS; }
"-"						{ return MOINS; }
"/"						{ return DIV; }
"*"						{ return MUL; }

"<"						{ return LT; }
">"						{ return GT; }

.						{ return yytext[0]; }

%%

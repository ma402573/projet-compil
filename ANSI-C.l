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
%%

[ \t\v\n\f]             {/* Sert a supprimer les blancs*/ }

"extern"                { return EXTERN; }

"if"                    { return IF; }
"else"                  { return ELSE; }
"while"                 { return WHILE; }
"for"			{ return FOR; }

"switch"                { return SWITCH; }
"break"                 { return BREAK; }
"case"                  { return CASE; }
"default"               { return DEFAULT; }

"return"                { return RETURN; }

"int"                   { return INT; }
"void"                  { return VOID; }

[/][*][^*]*[*]+([^*/][^*]*[*]+)*[/]  {/* Sert a ignorer les commentaires */}

"-"?D+			{ yylval.intval = atoi(yytext); return CONSTANTE; }
L(L|D)*           	{ yylval.strval = strdup(yytext); return IDENTIFICATEUR; }

">>"			{ return RSHIFT; }
"<<"			{ return LSHIFT; }

"&&"                    { return LAND; }
"||"                    { return LOR; }
"<="                    { return LEQ; }
">="                    { return GEQ; }
"=="                    { return EQ; }
"!="                    { return NEQ; }

"+"			{ return '+'; }
"-"			{ return '-'; }
"*"			{ return '*'; }
"/"			{ return '/'; }

"&"			{ return '&'; }
"|"			{ return '|'; }

"<"			{ return '<'; }
">"			{ return '>'; }

.			{ printf ("%d Erreur lexicale.\n",yytext[0]); }
%%


D                       [0-9]Je di
L                       [a-zA-Z_]
H                       [a-fA-F0-9]
E                       [Ee][+-]?{D}+
FS                      (f|F|l|L)
IS                      (u|U|l|L)*

%{
#include <stdio.h>
/*include "y.tab.h"*/


/* Ne gère pas les commentaires. A rajouter */
/* Supprimer les lignes dont vous n'avez pas besoin. */

%}

%%

D+			{ yylval = atoi(yytext); return NB; }
H+			{ yylval.strval = strdup(yytext); return IDENTIFICATEUR; }


"extern"                { return EXTERN; }

"goto"                  { return GOTO; }
"if"                    { return IF; }
"int"                   { return INT; }

"return"                { return RETURN; }

"void"                  { return VOID; }

"+"						{ return '+'; }
"-"						{ return '-'; }
"*"						{ return '*'; }
"/"						{ return '/'; }

"&"						{ return '&'; }
">>"					{ return RSHIFT; }
"<<"					{ return LSHIFT; }
"|"						{ return '|'; }

"<"						{ return '<'; }
">"						{ return '>'; }
"&&"                    { return LAND; }
"||"                    { return LOR; }
"<="                    { return LEQ; }
">="                    { return GEQ; }
"=="                    { return EQ; }
"!="                    { return NEQ; }

[ \t\v\n\f]             {/* Sert a supprimer les blancs*/ }
.						{ printf ("Erreur lexicale"); return yytext[0]; }





"auto"                  {  }
"break"                 {  }
"case"                  {  }
"char"                  {  }
"const"                 {  }
"continue"              {  }
"default"               {  }
"do"                    {  }
"double"                {  }
"else"                  {  }
"enum"                  {  }

"float"                 {  }

"long"                  {  }
"register"              {  }

"short"                 {  }
"signed"                {  }
"sizeof"                {  }
"static"                {  }
"struct"                {  }
"switch"                {  }
"typedef"               {  }
"union"                 {  }
"unsigned"              {  }

"volatile"              {  }
"while"                 {  }


L?\"(\\.|[^\\"])*\"     {  }

"..."                   {  }
">>="                   {  }
"<<="                   {  }
"+="                    {  }
"-="                    {  }
"*="                    {  }
"/="                    {  }
"%="                    {  }
"&="                    {  }
"^="                    {  }
"|="                    {  }

"++"                    {  }
"--"                    {  }
"->"                    {  }

%%


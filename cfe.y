%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
%}
%token IDENTIFICATEUR CONSTANTE 
%token VOID INT 
%token FOR WHILE IF ELSE SWITCH CASE DEFAULT
%token BREAK RETURN
%token PLUS MOINS MUL DIV LSHIFT RSHIFT BAND BOR LAND LOR LT GT 
%token GEQ LEQ EQ NEQ NOT EXTERN


%left PLUS MOINS
%left MUL DIV
%left LSHIFT RSHIFT
%left BOR BAND
%left LAND LOR

%nonassoc THEN
%nonassoc ELSE

%left OP
%left REL

%union {
	int intval;
	char* strval;
	char* code;
	}

%start programme

%%


programme	:	
		liste_declarations liste_fonctions
			{$$.code = concat($1.code, $2.code);
			printf("%s ", $$.code); }
;

liste_declarations	:	
		liste_declarations declaration 
			{$$.code = concat($1.code, $2.code); }

	|	
			{$$.code = ""; }
;

liste_fonctions	:	
		liste_fonctions fonction
			{$$.code = concat($1.code, $2.code); }

	|       fonction
			{$$.code = $1.code; }
;

declaration	:	
		type liste_declarateurs ';'
			{char* sTab[3] = {$1.code, $2.code, ";\n"};
			$$.code = concatTab(sTab, 3); }
;

liste_declarateurs	:	
		liste_declarateurs ',' declarateur
			{char* sTab[3] = {$1.code, ", ", $3.code};
			$$.code = concatTab(sTab, 3); }

	|	declarateur
			{$$.code = $1.code; }
;

declarateur	:	
		IDENTIFICATEUR
			{$$.code = strdup($1.strval); }

	|	declarateur '[' CONSTANTE ']'
			{char* sTab[4] = {$1.code, "[", itoa($3.intval), "]\n"};
			$$.code = concatTab(sTab, 4); }
;

fonction	:	
		type IDENTIFICATEUR '(' liste_parms ')' '{' liste_declarations liste_instructions '}'
			{char* sTab[8] = {$1.code, $2.strval, "(", $4.code, ") {\n", $7.code, $8.code, "}\n"};
			$$.code = concatTab(sTab, 8); }

	|	EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';'
			{char* sTab[6] = {"extern ", $2.code, $3.strval, "(", $5.code, ");\n"};
			$$.code = concatTab(sTab, 6); }
;

type	:	
		VOID
			{$$.code = "void "; }
	|	INT
			{$$.code = "int "; }
;

liste_parms	:
		parm 
			{$$.code = $1.code; }

	|	liste_parms ',' parm 
			{char* sTab[3] = {$1.code, ", ", $3.code};
			$$.code = concatTab(sTab, 3); }

	|
			{$$.code = ""; }
;

parm	:
		INT IDENTIFICATEUR
			{$$.code = concat("int ", $2.strval); }
;

liste_instructions :	
		liste_instructions instruction
			{$$.code = concat($1.code, $2.code);
			printf("Instruct : %s\n %s\n",$1.code,$2.code); }
	|
			{$$.code = ""; }
;

instruction	:	
		iteration
			{$$.code = $1.code;
			printf("Iter\n"); }
	|	selection
			{$$.code = $1.code;
			printf("Select\n"); }
	|	saut
			{$$.code = $1.code;
			printf("Saut\n"); }
	|	affectation ';'
			{$$.code = concat($1.code, ";");
			printf("Affect\n"); }
	|	bloc
			{$$.code = $1.code;
			printf("Bloc\n"); }
	|	appel
			{$$.code = $1.code; 
			printf("Appel\n"); }
;

iteration	:	
		FOR '(' affectation ';' condition ';' affectation ')' instruction
			{char* sTab[8] = {"for(", $3.code, "; ", $5.code, "; ", $7.code, ")", $9.code};
			$$.code = concatTab(sTab, 8); }

	|	WHILE '(' condition ')' instruction
			{char* sTab[4] = {"while( ", $3.code, ") ", $5.code};
			$$.code = concatTab(sTab, 4); }
;

selection	:	
		IF '(' condition ')' instruction %prec THEN
			{char* sTab[4] = {"if ( ", $3.code, ") ", $5.code};
			$$.code = concatTab(sTab, 4); }

	|	IF '(' condition ')' instruction ELSE instruction
			{char* sTab[6] = {"if (", $3.code, ") ", $5.code, " else ", $7.code};
			$$.code = concatTab(sTab, 6); }

	|	SWITCH '(' expression ')' instruction
			{char* sTab[4] = {"switch (", $3.code, ") ", $5.code};
			$$.code = concatTab(sTab, 4); }

	|	CASE CONSTANTE ':' instruction
			{char* sTab[4] = {"case ", itoa($2.intval), " : ", $4.code};
			$$.code = concatTab(sTab, 4); }

	|	DEFAULT ':' instruction
			{$$.code = concat("default : ", $3.code); }
;

saut	:	
		BREAK ';'
			{$$.code = "break;\n"; }
	|	RETURN ';'
			{$$.code = "return;\n"; }

	|	RETURN expression ';'
			{char* sTab[3] = {"return", $2.code, ";\n"};
			$$.code = concatTab(sTab, 3); }
;

affectation	:	
		variable '=' expression
			{char* sTab[3] = {$1.code, " = ", $3.code};
			$$.code = concatTab(sTab, 3); 
			printf("%s = %s \n",$1.code,$3.code);}
;

bloc	:	
		'{' liste_declarations liste_instructions '}'
			{char* sTab[4] = {"{\n", $2.code, $3.code, "}\n" };
			$$.code = concatTab(sTab, 4); }
;

appel	:	
		IDENTIFICATEUR '(' liste_expressions ')' ';'
			{char* sTab[4] = {$1.strval, "(", $3.code, ");\n" };
			$$.code = concatTab(sTab, 4); }
;

variable	:	
		IDENTIFICATEUR
			{$$.code = $1.strval; }

	|	variable '[' expression ']'
			{char* sTab[4] = {$1.code, "[", $3.code, "]"};
			$$.code = concatTab(sTab, 4); }
;

expression	:	
		'(' expression ')'
			{char* sTab[3] = {"(", $2.code, ")"};
			$$.code = concatTab(sTab, 3); }

	|	expression binary_op expression %prec OP
			{char* sTab[3] = {$1.code, $2.code, $3.code};
			$$.code = concatTab(sTab, 3); }

	|	MOINS expression
			{$$.code = concat("-", $2.code); }

	|	CONSTANTE
			{$$.code = itoa($1.intval); }
			
	|	variable
			{$$.code = $1.code; }

	|	IDENTIFICATEUR '(' liste_expressions ')'
			{char* sTab[4] = {$1.strval, "(", $3.code, ")"};
			$$.code = concatTab(sTab, 4); }
;

liste_expressions	:
		liste_expressions ',' expression 
			{char* sTab[3] = {$1.code, ", ", $3.code};
			$$.code = concatTab(sTab, 3); }

	| 	expression 
			{$$.code = $1.code; }

	|
			{$$.code = ""; }
;

condition	:	
		NOT '(' condition ')'
			{char* sTab[3] = {"!( ", $3.code, " )"};
			$$.code = concatTab(sTab, 3); }

	|	condition binary_rel condition %prec REL
			{char* sTab[3] = {$1.code, $2.code, $3.code};
			$$.code = concatTab(sTab, 3); }

	|	'(' condition ')'
			{char* sTab[3] = {"(", $2.code, ")"};
			$$.code = concatTab(sTab, 3); }

	|	expression binary_comp expression
			{char* sTab[3] = {$1.code, $2.code, $3.code};
			$$.code = concatTab(sTab, 3); }
;

binary_op	:	
		PLUS
			{$$.code = " + "; }
	|       MOINS
			{$$.code = " - "; }	
	|	MUL
			{$$.code = " * "; }
	|	DIV
			{$$.code = " / "; }
	|       LSHIFT
			{$$.code = " << "; }
	|       RSHIFT
			{$$.code = " >> "; }
	|	BAND
			{$$.code = " band "; }
	|	BOR
			{$$.code = " bor "; }
;

binary_rel	:	
		LAND
			{$$.code = " && "; }
	|	LOR
			{$$.code = " || "; }
;

binary_comp	:	
		LT
			{$$.code = " < "; }
	|	GT
			{$$.code = " > "; }
	|	GEQ
			{$$.code = " >= "; }
	|	LEQ
			{$$.code = " <= "; }
	|	EQ
			{$$.code = " == "; }
	|	NEQ
			{$$.code = " != "; }
;

%%

char* res = "";

char* concat(char* s1, char* s2)
	{
		char* s = malloc(sizeof(char) * (strlen(s1) + strlen(s2) +1));
        	strcpy(s,s1);
		strcat(s,s2);
        	return s;
	}



char* concatTab(char** sTab, int n)
	{
		int i;
		int size = 1;
		for(i = 0; i < n; i++){
			size += strlen(sTab[i]);
		}
		char* s = malloc(sizeof(char) * size);
		for(i = 0; i < n; i++){
			s=concat(s, sTab[i]);
		}
		return s;
	}



char* itoa(int nb)
	{
		int i = nb;
		int dizaines = 0;
		while(i > 9){
			i = i/10;
		}
		char* s = malloc(sizeof(char) * dizaines);
		sprintf(s, "%d", nb);
		return s;
	}



int main()
	{
		yyparse();
	}


int yywrap()
	{
       		 return 1;
	} 


char* insererDansRes(char* ajout){
	res=concat(res,ajout);
}

int ecrireFichierRes()
{
	FILE* fichier = NULL;
	fichier = fopen("result_backend.c", "w");
	if (fichier != NULL)
	{
		fputs(res, fichier);
		fclose(fichier);
	}
	return 0;
}

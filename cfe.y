%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

int yylex();
int yylineno;
char* yytext;

void yyerror(const char *str)
{
    fprintf(stderr,"Error Line: %d Token: %s %s\n",yylineno, yytext, str);
}

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
			insererDansRes($$.code); }
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
			{//addVar(&tabF, $1.strval, tabPos);
			tabPos = addChar(tabF, $1.strval, tabPos);
			$$.code = strdup($1.strval); }

	|	declarateur '[' CONSTANTE ']'
			{char* sTab[4] = {$1.code, "[", itoa($3.intval), "]"};
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
			{$$.code = concat($1.code, $2.code); }
	|
			{$$.code = ""; }
;

instruction	:	
		iteration
			{$$.code = $1.code;  }
	|	selection
			{$$.code = $1.code; }
	|	saut
			{$$.code = $1.code; }
	|	affectation ';'
			{//varExist($1.code, tabF);
			$$.code = concat($1.code, "\n"); }
	|	bloc
			{$$.code = $1.code; }
	|	appel
			{$$.code = $1.code; }
;

iteration	:	
		FOR '(' affectation ';' condition ';' affectation ')' instruction
			{//char* sTab[8] = {"for(", $3.code, "; ", $5.code, "; ", $7.code, ")", $9.code};
			char* l1 = newLink();
			char* l2 = newLink();
			char* sTab[16] = {$3.code, "\n",l1, ": ", "if (", inverser($5.code), ") goto ", l2, ";\n", $9.code, $7.code, "\n goto ", l1, ";\n", l2, ": "};
			$$.code = concatTab(sTab, 16); }

	|	WHILE '(' condition ')' instruction
			{//char* sTab[4] = {"while( ", $3.code, ") ", $5.code};

			char* l1 = newLink();
			char* l2 = newLink();
			char* sTab[14] = { "goto ", l1, ";\n", l2, ": ", $5.code, "\n", l1, ": ", "if (", inverser($3.code), ") goto ", l2, ";\n"};
			$$.code = concatTab(sTab, 14); }
;

selection	:	
		IF '(' condition ')' instruction %prec THEN
			{//char* sTab[4] = {"if ( ", $3.code, ") ", $5.code};

			char* l = newLink();
			char* sTab[9] = {"if ( ", inverser($3.code), ") goto ", l,";\n", $5.code,"\n",l,":"};
			$$.code = concatTab(sTab, 9); }

	|	IF '(' condition ')' instruction ELSE instruction
			{//char* sTab[6] = {"if (", $3.code, ") ", $5.code, " else ", $7.code};

			char* l1 = newLink();
			char* l2 = newLink();
			char* sTab[15] = {"if (", inverser($3.code), ") goto ", l1, ";\n", $5.code, "goto ", l2, ";\n", l1, ": ", $7.code, "\n", l2, ": "};
			$$.code = concatTab(sTab, 15); }


	|	SWITCH '(' expression ')' instruction
			{
			//printf("COUCOU\n");
			char* sTab[1] = { $5.code};
			
			char** resAcc = replaceCond(tabCase, $3.code, "condition");
			for (int i = 0; resAcc[i]; i++){
				printf("CHAINE \n%s\n", resAcc[i]);
			}
			char* acc = concatTab(resAcc, tabPosCase);
			//char* acc2 = concatTab(tabBreak, tabPosBreak);

			char* sTabBis = concatTab(sTab, 1);
			char* res = concat(sTabBis, acc);
			//res = concat(res, acc2);
			$$.code = res;
			}


	|	CASE CONSTANTE ':' instruction
			{//char* sTab[6] = {"case ", itoa($2.intval), "variable :", "pouet", " : ", $4.code};
			char* l1 = newLink();
			char* l2 = newLink();
			//etiqSwitch(tabEtiqCase, l1, l2);

			//tabEtiqCaseNb = addChar(tabEtiqCase, l2, tabEtiqCaseNb);
			char* acc = concatTab(tabBreak, tabPosBreak);
			//char* acc2 = concat($4, 
			char* sTab[10] = {l1, ": if (", " condition", " != ", itoa($2.intval), ") goto ", l2, ";\n", /*etiquette suivante*/ $4.code, acc};
			char* strCase = concatTab(sTab, 10);

			tabPosCase = addChar(tabCase, strCase, tabPosCase);
			$$.code = ""; 
			}

	|	DEFAULT ':' instruction
			{$$.code = concat("default : ", $3.code); }
;

saut	:	
		BREAK ';'
			{//$$.code = "break;\n";
			char* l = " LExit";
			char* sTab[3] = {"goto ", l, "\n"};
			char* strBreak = concatTab(sTab, 3);
			tabPosBreak = addChar(tabBreak, strBreak, 0);
			$$.code = "";}

	|	RETURN ';'
			{$$.code = "return;\n"; }

	|	RETURN expression ';'
			{char* sTab[3] = {"return ", $2.code, ";\n"};
			$$.code = concatTab(sTab, 3); }
;

affectation	:	
		variable '=' expression
			{varExist($1.code, tabF);
			char* sTab[4] = {$1.code, " = ", $3.code, ";"};
			$$.code = concatTab(sTab, 4); }
;

bloc	:	
		'{' liste_declarations liste_instructions '}'
			{//char* sTab[3] = {"{\n", $2.code, $3.code };
			//$$.code = concatTab(sTab, 3); 
			$$.code = concat($2.code, $3.code); }
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
int newNum = 1;
int tabPos = 0;
int tabPosSwitch = 0;
int tabPosCase = 0;
int tabPosBreak = 0;
int accEtiq = 0;
char tab[1];
//char* tmpSwitch = "";
char* tabF[300];
char* tabSwitch = NULL;
char* tabCase[300];
char* tabBreak[300];
char* tabEtiqCase[600] = {"0"};


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

////////////////////////////////////////////////////////////////////

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

////////////////////////////////////////////////////////////////////

int addChar(char *tab[], char* var, int position) {

    char *ptr = var;
	tab[position] = ptr;

	position++;
	return position;
}


bool varExist(char* var, char* tab[]){

    for (int i = 0; tab[i]; i++) {
        if (!strcmp(tab[i], var)){
            return true;
        }
    }
    printf("%s %s %s\n", "La variable", var, "n'est pas définie");
    return false;
}

////////////////////////////////////////////////////////////////////

char **str_split (char *s, const char *ct)
{
   char **tab = NULL;

   if (s != NULL && ct != NULL)
   {
      int i;
      char *cs = NULL;
      size_t size = 1;

      for (i = 0; (cs = strtok (s, ct)); i++)
      {
         if (size <= i + 1)
         {
            void *tmp = NULL;

            size <<= 1;
            tmp = realloc (tab, sizeof (*tab) * size);
            if (tmp != NULL)
            {
               tab = tmp;
            }
            else
            {
               fprintf (stderr, "Memoire insuffisante\n");
               free (tab);
               tab = NULL;
               exit (EXIT_FAILURE);
            }
         }
         tab[i] = cs;
         s = NULL;
      }
      tab[i] = NULL;
   }
   return tab;
}

char* inverser(char* cond){
	char **tab = str_split(cond," ");
	char * acc = "";
	for (int i=0;tab[i];i++){	
		char * sTab[2];
    	sTab[0]=acc;
        if (! strcmp (tab[i],"<")){
            sTab[1]=" >= ";
        }
        else if (! strcmp (tab[i],">")){
            sTab[1]=" <= ";
        }
        else if (! strcmp (tab[i],"<=")){
        	sTab[1]=" > ";
        }
        else if (! strcmp (tab[i],">=")){
        	sTab[1]=" < ";
        }
        else if (! strcmp (tab[i],"==")){
        	sTab[1]=" != ";
        }
        else if (! strcmp (tab[i],"!=")){
        	sTab[1]=" == ";
        }
        else {
        	sTab[1]=tab[i];
        }
        acc = concatTab(sTab,2);
	}
    return acc;
}

////////////////////////////////////////////////////////////////////

char* newLink() {
		int link = newNum;
		newNum++;
		char* s = malloc (sizeof(char) * (10 + 1));
		if (s == NULL){ exit(0); }
		s = concat("L", itoa(link));
		return (char *) s;		
		}

char* etiqSwitch(char* tab[], char* l1, char* l2){
	
	//printf("tab[0] : %s\n", tab[0]);
	char* elemUn = tab[0];
	printf("%s\n", elemUn);
    if ( strcmp(elemUn, "0") == 0){
	printf("Je passe");
		addChar(tab, newLink(), accEtiq);
        addChar(tab, newLink(), accEtiq+1);
        l1 = tab[accEtiq];
        l2 = tab[accEtiq + 1];
        accEtiq++;
        return l1, l2;

    } else {
		printf("Je colle");
        addChar(tab, newLink(), accEtiq);
        l1 = tab[accEtiq-1];
        l2 = tab[accEtiq];
        accEtiq++;
        return l1, l2;
    }
}

char** replaceCond(char* tab[], char* cond, char* txt){
		char** tmp;
		for (int i = 0; tab[i]; i++){
			int j = 0;
			printf("tab[iDEBUT] : %s\n", tab[i]);
			tmp = str_split(tab[i], " ");
			printf("tab[i_POST_SPLIT] : %s\n", tab[i]);

			for( j; tmp[j]; j++){
				printf("TMPJJJJ : %s \n", tmp[j]);
				//printf("pouet : %s\n", cond); 

				if(strcmp(txt, tmp[j]) == 0){
					//printf("%s ", tmp[j]);
					tmp[j] = cond;
					//printf("tmp[j] : %s\n", tmp[j]);
					tab[i] = *tmp;
					//printf("tab[i] : %s\n", tab[i]);
				} else { tab[i] = *tmp; }
			}tab[i] = concatTab(tmp, j);
	
		}
	return tab;
	printf("Pas de condition\n");	
}

////////////////////////////////////////////////////////////////////

int main()
	{
		yyparse();
		ecrireFichierRes();
	}


int yywrap()
	{
       		 return 1;
	} 



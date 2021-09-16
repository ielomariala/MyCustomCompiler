%{
#include "Table_des_symboles.h"
#include "Attribute.h"

#include <stdio.h>
  
extern int yylex();
extern int yyparse();
extern char* yytext;

void yyerror (char* s) {
  printf ("%s\n",s);
}

// Added Header
#include <string.h>
#include <stdlib.h>

FILE * fc;
FILE * fh;
int k = 1; // Pour stocker les paramètres d'une fonction
int once = 1; // Pour Sauvegarder fp et nouveau fp une fois 
char *func_name;

attribute op_attribute(attribute x, char* op, attribute y){
  attribute r = new_attribute();
  int bool = 0;
  if (are_types_compatible(x,y)){
    r->type_val = x->type_val;
    r->star_number = x->star_number;
    bool = 1; // Types are compatibles
  }
  else{
    fprintf(stderr,"ERROR : Uncompatible types \n");
    exit(-1);
  }
  r->reg_number = new_reg(r);
  fprintf(fc, "r%d = r%d %s r%d;\n",
    r->reg_number,x->reg_number,op,y->reg_number);
  r->name = custom_strcat("@r",r->reg_number);
  set_symbol_value(r->name,r);
  return r;
};

%}

%union { 
	struct ATTRIBUTE * val;
  int number;
}
%token <val> NUMI NUMF
%token TINT // TFLOAT STRUCT
%token <val> ID
%token AO AF PO PF PV VIR
%token RETURN VOID EQ
%token <val> IF ELSE WHILE

%token <val> AND OR NOT DIFF EQUAL SUP INF
%token PLUS MOINS STAR DIV
%token DOT ARR

%left DIFF EQUAL SUP INF       // low priority on comparison
%left PLUS MOINS               // higher priority on + - 
%left STAR DIV                 // higher priority on * /
%left OR                       // higher priority on ||
%left AND                      // higher priority on &&
%left DOT ARR                  // higher priority on . and -> 
%nonassoc UNA                  // highest priority on unary operator
%nonassoc ELSE

%start prog  

%type <val> exp type inst block vir app
%type <number> pointer bool_cond else while_cond while typename


%%

prog : func_list               {}
;

func_list : func_list fun      {}
| fun                          {}
;


// I. Functions

fun : type fun_head fun_body        {debug("Fonction"); k = 1;}
;

fun_head : ID po pf            {$1->type_val = FUNC; $1->type_ret = $<val>0->type_val; set_symbol_value($1->name, $1);}
| ID po params pf              {$1->type_val = FUNC; $1->type_ret = $<val>0->type_val; set_symbol_value($1->name, $1);} // Peut etre il faut ajouter une AO
;

po : PO                        {
                                  if(strcmp($<val>0->name,"main") == 0 && $<val>0->type_ret == VOD){
                                  fprintf(fc, "void %s (){\n", $<val>-0->name);
                                  }
                                  else{
                                  fprintf(fc, "void call_%s (){\n", $<val>-0->name);}
                                  }
;

pf : PF                        {;}
;

params: params vir type ID     {
                                $4->type_val = $3->type_val; $4->star_number = $3->star_number; $4->block_number = current_block();
                                $4->reg_number = new_reg($4); set_symbol_value($4->name,$4);
                                char* s = attribute__get_star($4);
                                fprintf(fh, "%s %s%s;\n", attribute__get_type($4), s, $4->name);
                                if ($4->star_number > 0) { // Allocation dynamique si pointeur
                                      fprintf(fc,"%s = malloc(sizeof(%s%s));\n", $4->name, attribute__get_type($4),s);}
                                fprintf(fc, "r%d = (%s%s)*(fp + %d);\n",$4->reg_number,attribute__get_type($4),attribute__get_star($4), k++);
                                fprintf(fc, "%s = r%d;\n", $4->name, $4->reg_number);
                                free(s);}

| type ID                      {
                                $2->type_val = $1->type_val; $2->star_number = $1->star_number; $2->block_number = current_block();
                                $2->reg_number = new_reg($2); set_symbol_value($2->name,$2);
                                fprintf(fh, "%s %s%s;\n", attribute__get_type($2), attribute__get_star($2), $2->name);
                                char* s = attribute__get_star($2);
                                if ($2->star_number > 0) { // Allocation dynamique si pointeur
                                      fprintf(fc,"%s = malloc(sizeof(%s%s));\n", $2->name, attribute__get_type($2),s);}
                                fprintf(fc, "r%d = (%s%s)*(fp + %d);\n", $2->reg_number,attribute__get_type($2),attribute__get_star($2), k++);
                                fprintf(fc, "%s = r%d;\n", $2->name, $2->reg_number);
                                free(s);}
;
vlist: vlist vir ID            {$3->type_val = $<val>0->type_val;
                                $3->star_number = $<val>0->star_number;
                                $3->block_number = current_block();
                                char* s = attribute__get_star($3);
                                fprintf(fh,"%s %s%s;\n",attribute__get_type($3),s,$3->name);
                                set_symbol_value($3->name,$3);
                                if ($3->star_number > 0) { // Allocation dynamique si pointeur
                                      fprintf(fc,"%s = malloc(sizeof(%s%s));\n", $3->name, attribute__get_type($3),s);}
                                free(s);}
| ID                           {$1->type_val = ($<val>0->type_val);
                                $1->star_number = ($<val>0->star_number);
                                $1->block_number = current_block();
                                char* s = attribute__get_star($1);
                                fprintf(fh,"%s %s%s;\n",attribute__get_type($1),s,$1->name);
                                set_symbol_value($1->name,$1);
                                if ($1->star_number > 0) { // Allocation dynamique si pointeur
                                      fprintf(fc,"%s = malloc(sizeof(%s%s));\n", $1->name, attribute__get_type($1),s);}
                                free(s);}
;

vir : VIR                      {$$ = $<val>-1;}
;

fun_body : AO block AF         {fprintf(fc,"nothing ++;\n");
                                fprintf(fc,"}\n");}
;

// Block
block:
decl_list inst_list            {;}
;

// I. Declarations

decl_list : decl_list decl     {;}
|                              {;}
;

decl: var_decl PV              {;}
;

var_decl : type vlist          {free($1);}
;

type
: typename pointer             {$$ = new_attribute();
                                $$->type_val = $1;
                                $$->star_number = $2;}
                                 
| typename                     { $$ = new_attribute();
                                $$->type_val = $1;
                                $$->star_number = 0;}
;

typename
: TINT                          { $$ = INT;}
| VOID                          { $$ = VOD;}
;

pointer
: pointer STAR                 {$$ = $1 + 1;}
| STAR                         {$$ = 1;}
;


// II. Intructions

inst_list: inst PV inst_list {}
| inst pvo                   {}
;

pvo : PV                     {;}
|                            {;}
;


inst:
exp                           {}
| AO block AF                 {debug(" Block");}
| aff                         {debug(" Affectation");}
| ret                         {debug(" Return");}
| cond                        {debug(" Condition");}
| loop                        {debug(" Loop");}
| PV                          {}
;


// II.1 Affectations

aff : ID EQ exp               { attribute x = get_symbol_value($1->name);
                                if (search_block(x) && search_block($3)){
                                  fprintf(fc, "%s = (%s)r%d;\n",x->name,attribute__get_type(x),$3->reg_number);
                                  fprintf(fc,"printf(\"%s = %s\\n\",%s);\n",x->name,"%d", x->name);}
                                else {fprintf(stderr,"ERROR: Variables not known in this block !\n");}
                              }

| STAR exp  EQ exp            { if (search_block($2) && search_block($4)){
                                  fprintf(fc, "*r%d = (%s)r%d;\n",$2->reg_number,attribute__get_type($2),$4->reg_number);
                                  fprintf(fc,"printf(\"*%s = %s\\n\",*%s);\n",$2->name,"%d", $2->name);}
                                else {fprintf(stderr,"ERROR: Variables not known in this block !\n");}
                              }
;


// II.2 Return
ret : RETURN exp              { fprintf(fc, "*fp = r%d;\n", $2->reg_number); // compilation de return
                                }
| RETURN PO PF                {;}
;

// II.3. Conditionelles
//           N.B. ces rêgles génèrent un conflit déclage reduction qui est résolu comme on le souhaite
//           i.e. en lisant un ELSE en entrée, si on peut faire une reduction elsop, on la fait...

cond :
if bool_cond inst elsop       {}
;

elsop : else inst             {fprintf(fc, "label%d:\n", $1);}
|                             {fprintf(fc, "label%d:\n", $<number>-1);}
;

bool_cond : PO exp PF         {$$ = new_lab(); fprintf(fc,"if (!r%d) goto label%d;\n",$2->reg_number, $$);}
;

if : IF                       {}
;

else : ELSE                   {$$ = new_lab(); fprintf(fc, "goto label%d;\nlabel%d:\n", $$,$<number>-1);}
;

// II.4. Iterations

loop : while while_cond inst  {fprintf(fc, "goto label%d;\nlabel%d:\n", $1, $2);}
;

while_cond : PO exp PF        {$$ = new_lab(); fprintf(fc, "if(!r%d) goto label%d;\n",$2->reg_number, $$);}

while : WHILE                 {$$ = new_lab(); fprintf(fc, "label%d:\n", $$);}
;


// II.3 Expressions
exp
// II.3.0 Exp. arithmetiques
: MOINS exp %prec UNA         {$$ = new_attribute(); $$->type_val = $2->type_val;  $$->reg_number = new_reg($$);  fprintf(fc, "r%d = -r%d;\n",$$->reg_number, $2->reg_number); $$->name = custom_strcat("@r",$$->reg_number); set_symbol_value($$->name,$$);}
| exp PLUS exp                {$$ = op_attribute($1,"+",$3);}
| exp MOINS exp               {$$ = op_attribute($1,"-",$3);}
| exp STAR exp                {$$ = op_attribute($1,"*",$3);}
| exp DIV exp                 {$$ = op_attribute($1,"/",$3);}
| PO exp PF                   {$$ = $2;}
| ID                          {$$ = get_symbol_value($1->name);
                                if (search_block($$)){
                                $$->reg_number = new_reg($$);fprintf(fc,"r%d = %s;\n",$$->reg_number,$1->name);}
                                else {fprintf(stderr,"ERROR: variable %s (declared in block %d) cannot be used in current block %d\n",$$->name, $$->block_number, current_block());}}
| app                         {debug("Application de fonction");}
| NUMI                        {$1->reg_number = new_reg($1); $1->star_number = 0; fprintf(fc,"r%d = %s;\n",$1->reg_number,yytext);$$ = $1; $$->name = custom_strcat("@r",$$->reg_number); set_symbol_value($$->name,$$);}
| NUMF                        {$1->reg_number = new_reg($1); $1->star_number = 0; fprintf(fc,"r%d = %s;\n",$1->reg_number,yytext);$$ = $1; $$->name = custom_strcat("@r",$$->reg_number); set_symbol_value($$->name,$$);}

// II.3.1 Déréférencement

| STAR exp %prec UNA          {$$ = new_attribute(); $$->type_val = $2->type_val; $$->star_number = $2->star_number-1; $$->reg_number = new_reg($$); fprintf(fc, "r%d = *r%d;\n",$$->reg_number, $2->reg_number);$$->name = custom_strcat("@r",$$->reg_number); set_symbol_value($$->name,$$);}

// II.3.2. Booléens

| NOT exp %prec UNA           {$$ = new_attribute(); $$->type_val = $2->type_val; $$->reg_number = new_reg($$); fprintf(fc,"r%d = !r%d\n",$$->reg_number,$2->reg_number);$$->name = custom_strcat("@r",$$->reg_number); set_symbol_value($$->name,$$);}
| exp INF exp                 {$$ = op_attribute($1,"<",$3);}
| exp SUP exp                 {$$ = op_attribute($1,">",$3);}
| exp EQUAL exp               {$$ = op_attribute($1,"==",$3);}
| exp DIFF exp                {$$ = op_attribute($1,"!=",$3);}
| exp AND exp                 {$$ = op_attribute($1,"&&",$3);}
| exp OR exp                  {$$ = op_attribute($1,"||",$3);}

;

// II.4 Applications de fonctions

app : ID poapp args PF           { k = 1;
                                attribute f = get_symbol_value($1->name);
                                if(f->type_val == FUNC){
                                  fprintf(fc, "call_%s ();\n",$1->name);
                                  if (f->type_ret != VOD){
                                    $$ = new_attribute(); $$->type_val = f->type_ret; $$->reg_number = new_reg($$);
                                    fprintf(fc, "r%d = *fp;\n", $$->reg_number);
                                  }
                                  else{
                                    $$ = NULL;
                                  }
                                  fprintf(fc, "sp = fp - 1;\nfp = (long int*)*sp;\n");}}

;

poapp : PO                      {fprintf(fc, "*sp = (long int) fp;\nsp = sp + 1;\n"); // Sauvegarder fp
                                  fprintf(fc, "fp = sp;\nsp = sp + 1;\n"); // Nouveau fp
                                  }
;

args :  arglist               {}
|                             {}
;

arglist : arglist VIR exp     {fprintf(fc, "*sp = (long int)r%d;\nsp = sp + 1;\n", $3->reg_number); k++;}
| exp                         {fprintf(fc, "*sp = (long int)r%d;\nsp = sp + 1;\n", $1->reg_number); k++;}
;



%% 
int main (int argc, char* argv[]) {
  
  fh = fopen (argv[1], "w");
  fc = fopen (argv[2], "w");
  
  fprintf(fh, "#ifndef FILE_H\n");
  fprintf(fh, "#define FILE_H\n");
  fprintf(fh, "#include <stdio.h>\n");
  fprintf(fh, "#include <stdlib.h>\n");
  fprintf(fh, "#include <string.h>\n");
  fprintf(fh, "#define SIZE 255\n");


  fprintf(fc, "#include \"../%s\"\n",argv[1]);
  fprintf(fc, "long int pile[SIZE];\n");
  fprintf(fc, "long int *sp = pile;\n");
  fprintf(fc, "long int *fp = pile;\n");
  fprintf(fc, "int nothing = 0; // Pour qu'un label ne soit jamais vide\n");

  yyparse ();

  fprintf(fh, "#endif\n");

  fclose(fh); fclose(fc);
  

} 


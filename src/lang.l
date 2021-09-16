%option noyywrap
/* avoid dependency with library fl */

%{ 
#include "y.tab.h"
#include "Table_des_symboles.h"
#include "Attribute.h"
#include <stdio.h>

%} 
%% 

"="                      { return EQ;}

"+"                      { return PLUS;}
"-"                      { return MOINS;}
"*"                      { return STAR;}
"/"                      { return DIV;}
"||"                     { return OR;}
"&&"                     { return AND;}
"!"                      { return NOT;}

"=="                     { return EQUAL;}
"!="                     { return DIFF;}
"<"                      { return INF;}
">"                      { return SUP;}

"("                      { return PO;}
")"                      { return PF;}
"{"                      { open_block(); return AO;}
"}"                      { free_symbol(); close_block(); return AF;}

"int"                    { return TINT;}

"return"                 { return RETURN;}
"void"                   { return VOID;}
"if"                     { return IF;}
"else"                   { return ELSE;}
"while"                  { return WHILE;}

"."                      { return DOT;}
"->"                     { return ARR;}

";"                      { return PV;}
","                      { return VIR;}


[0-9]+                   { yylval.val = new_attribute();
                           yylval.val -> type_val = INT;
                           return NUMI; }
[0-9]*"."[0-9]+          { yylval.val = new_attribute();
                           yylval.val -> type_val = FLOAT;
                           return NUMF; }
[A-Za-z][A-Za-z0-9]*     { yylval.val = new_attribute();
                           yylval.val -> name = string_to_sid(yytext);
		           return ID; }
[ \t\n]                   { /* on avale sans rendre la main */; }

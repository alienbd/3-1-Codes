%{
#include<iostream>
#include<stdlib.h>
#include<string.h>
#include "Symbol_Table.h"

#define YYSTYPE symbolInfo*
#include "y.tab.h"


using namespace std;

extern YYSTYPE yylval;
extern SymbolTable *table;
void yyerror(char *);

extern int line_count;
extern int error_count;


%}



digit [0-9]
letter [A-Za-z]
delim [ \t\r\f\v]
newline \n
ws [delim]+
id (_|{letter})(_|{letter}|{digit})*
integer {digit}+
number {digit}*(\.{digit}+)?(E[+-]?{digit}+)?
ADDOP [+-] 
MULOP [*/%]

%%

{delim}+	{}
{newline} {line_count++;}

"if" {return IF;}
"else" {return ELSE;}
"for" {return FOR;}
"while" {return WHILE;}
"int" {return INT;}
"float" {return FLOAT;}
"double" {return DOUBLE;}
"char" {return CHAR;}
"return" {return RETURN;}
"void" {return VOID;}
"println"	{return PRINTLN;}

{ADDOP} { 
			symbolInfo *s= new  symbolInfo();
			s->setName(yytext);
        	s->setType((char *)"ADDOP");
			yylval = (YYSTYPE)s;
			return ADDOP;
		}



{MULOP}	{
			symbolInfo *s= new  symbolInfo();
			s->setName(yytext);
        	s->setType((char *)"MULOP");
			yylval = (YYSTYPE)s;
			return MULOP;
		}


"=" 	{return ASSIGNOP;}

">" |
"<" |
">=" |
"<=" |
"==" |
"!=" {
		symbolInfo *s= new  symbolInfo();
		s->setName(yytext);
        s->setType((char *)"RELOP");
		yylval = (YYSTYPE)s;
		return RELOP;
	}

"&&"	|
"||"	{
			symbolInfo *s= new  symbolInfo();
			s->setName(yytext);
        	s->setType((char *)"LOGICOP");
			yylval = (YYSTYPE)s;
			return LOGICOP;
		}
"!"		{	
	return NOT; }


";" 	{
	return SEMICOLON;
	}
"," 	{return COMMA;}
"(" 	{return LPAREN;}
")" 	{return RPAREN;}
"{" 	{return LCURL;}
"}" 	{return RCURL;}
"[" 	{return LTHIRD;}
"]" 	{return RTHIRD;}
"++" 	{return INCOP;}
"--" 	{return DECOP;}



{integer}	{
				symbolInfo *s= new  symbolInfo();
				s->setName(yytext);
        		s->setType((char *)"CONST_INT");
				yylval = (YYSTYPE)s;
				return CONST_INT;
			}
{number} 	{	
				symbolInfo *s= new  symbolInfo();
				s->setName(yytext);
        		s->setType((char *)"CONST_FLOAT");
				yylval = (YYSTYPE)s;
				return CONST_FLOAT; 
			}
{id} 		{	 
				symbolInfo *s= table->lookUp(yytext);
				if(s==0)
				{					
					s= new symbolInfo();
					s->setName(yytext);
        			s->setType((char *)"ID");
				}
				yylval = (YYSTYPE)s;
							
				return ID;
			}


%%

int yywrap(void)
{
	return 1;
}







%{
#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include "Symbol_Table.h"
#define YYSTYPE symbolInfo*

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
FILE *fp;
FILE *errortext=fopen("error.txt","w");
FILE *logtext= fopen("log.txt","w");
int line_count=1;
int error_count=0;
extern int scopeCount = 0;


SymbolTable *table = new SymbolTable(10,logtext);
vector<symbolInfo *> declarationVector;
vector<symbolInfo *> argumentVector;
vector<symbolInfo *> parameterVector;

void yyerror(char *s)
{
	//write your code
	fprintf(stderr,"Line no %d : %s\n",line_count,s);
}


%}

%token IF ELSE FOR WHILE DO 
%token INT FLOAT CHAR DOUBLE VOID
%token RETURN DEFAULT PRINTLN ID 
%token CONST_INT CONST_FLOAT CONST_CHAR
%token ADDOP MULOP INCOP RELOP ASSIGNOP LOGICOP BITOP NOT DECOP
%token LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON

%left RELOP LOGICOP BITOP 
%left ADDOP 
%left MULOP

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE


%start start;

%%

start : program
	{
		//write your code in this block in all the similar blocks below
		fprintf(logtext,"At line no:  %d start : program \n\n",line_count);
		$$ = new symbolInfo();
		$$->setName($1->getName());
		fprintf(logtext,"%s \n\n",$$->getName().c_str());
		table->printAll();
	}
	;

program : program unit 
		{	
			fprintf(logtext,"At line no:  %d program : program unit \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName()+$2->getName());
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
		}
	| unit
		{
			fprintf(logtext,"At line no:  %d program : unit \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName());
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
		}
	;
	
unit : var_declaration
		{
			fprintf(logtext,"At line no:  %d unit : var_declaration \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName());
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
		}
     | func_declaration
	 	{
			fprintf(logtext,"At line no:  %d unit : func_declaration \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName());
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
		}
     | func_definition
		{
			fprintf(logtext,"At line no:  %d unit : func_definition \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName());
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
		}
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
		{

			fprintf(logtext,"At line no:  %d func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName() + $2->getName() + "( " + $4->getName() + " );\n");

			symbolInfo* functionInfoFromTable = table->lookUp($2->getName());

			if(functionInfoFromTable == NULL)
			{	
				functionInfo* funInfo = new functionInfo();

				table->insert($2->getName(),"ID","function");

				functionInfoFromTable = table->lookUp($2->getName());

				funInfo->setReturnType($1->getName());
				funInfo->setParamList(parameterVector);
				funInfo->setNumberOfParam();

				functionInfoFromTable->setIsFunction(true);
				functionInfoFromTable->setFunctionInfo(funInfo);

				//cout<<"here "<<functionInfoFromTable->getFunctionInfo()->getParamList()[0]->getName();
				parameterVector.clear();
								
			}

			else
			{
				if($2->isFunction() == false)
				{
					error_count++;
					$$->setName("(error)"+$1->getName() + $2->getName() + "( " + $4->getName() + " );\n");
					fprintf(errortext,"Error at Line No.%d: Not declared as Function \n\n",line_count);

				}

				string returnTypeFromTable = functionInfoFromTable->getFunctionInfo()->getReturnType();
				string returnTypeThis      = $1->getName();
				//cout<<"ret type: "<<returnTypeFromTable<<" "<<returnTypeThis;
				if(returnTypeFromTable != returnTypeThis)
				{
					error_count++;
					$$->setName("(error)"+$1->getName() + $2->getName() + "( " + $4->getName() + " );\n");
					fprintf(errortext,"Error at Line No.%d: Return Type Doesn't Match with previous Declaration \n\n",line_count);

				}
				
				else
				{
					int paramNumberFromTable = functionInfoFromTable->getFunctionInfo()->getNumberOfParam();
					int paramNumberThis      = parameterVector.size();
					//cout<<"param size: "<<paramNumberFromTable<<" "<<paramNumberThis;
					if(paramNumberFromTable != paramNumberThis)
					{
						error_count++;
						$$->setName($1->getName() + $2->getName() + "( (error)" + $4->getName() + " );\n");
						fprintf(errortext,"Error at Line No.%d: Number Of Parameters Doesn't Match with previous Declaration \n\n",line_count);

					}

					else
					{
						vector< symbolInfo* > paramListFromTable = functionInfoFromTable->getFunctionInfo()->getParamList();

						for(int i=0;i<paramNumberThis;i++)
						{
							string paramTypeFromTable = paramListFromTable[i]->getVariableType();
							string paramTypeThis      = parameterVector[i]->getVariableType();
							//cout<<"paramType: table: "<<paramTypeFromTable<<"this: "<<paramTypeThis<<endl;
							if(paramTypeFromTable != paramTypeThis)
							{
								error_count++;
								$$->setName($1->getName() + $2->getName() + "( (error)" + $4->getName() + " );\n");
								fprintf(errortext,"Error at Line No.%d: Parameter Type Doesn't Match with previous Declaration \n\n",line_count);
								break;
							}
						}

						parameterVector.clear();
					}
				}
			}


			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			

		}
		| type_specifier ID LPAREN RPAREN SEMICOLON
		{

			fprintf(logtext,"At line no:  %d func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName() + $2->getName() + "( );\n");

			symbolInfo* functionInfoFromTable = table->lookUp($2->getName());

			if(functionInfoFromTable == NULL)
			{	
				functionInfo* funInfo = new functionInfo();

				table->insert($2->getName(),"ID","function");

				functionInfoFromTable = table->lookUp($2->getName());

				funInfo->setReturnType($1->getName());
				funInfo->setParamList(parameterVector);
				funInfo->setNumberOfParam();

				functionInfoFromTable->setIsFunction(true);
				functionInfoFromTable->setFunctionInfo(funInfo);

				//cout<<"here "<<functionInfoFromTable->getFunctionInfo()->getNumberOfParam();
				//parameterVector.clear();
								
			}

			else
			{
				if($2->isFunction() == false)
				{
					error_count++;
					$$->setName("(error)"+$1->getName() + $2->getName() + "( );\n");
					fprintf(errortext,"Error at Line No.%d: Not declared as Function \n\n",line_count);

				}

				string returnTypeFromTable = functionInfoFromTable->getFunctionInfo()->getReturnType();
				string returnTypeThis      = $1->getName();
				//cout<<"ret type: "<<returnTypeFromTable<<" "<<returnTypeThis;
				if(returnTypeFromTable != returnTypeThis)
				{
					error_count++;
					$$->setName("(error)"+$1->getName() + $2->getName() + "( );\n");
					fprintf(errortext,"Error at Line No.%d: Return Type Doesn't Match with previous Declaration \n\n",line_count);

				}

				else
				{
					int paramNumberFromTable = functionInfoFromTable->getFunctionInfo()->getNumberOfParam();
					if(paramNumberFromTable != 0)
					{
						error_count++;
						$$->setName($1->getName() + $2->getName() + "( (error) );\n");
						fprintf(errortext,"Error at Line No.%d: Number of Parameter Doesn't Match with previous Declaration \n\n",line_count);

					}
				}
				
			}

			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
		}
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN 
		{
			$$ = new symbolInfo();
			symbolInfo* functionInfoFromTable = table->lookUp($2->getName());

			if(functionInfoFromTable == NULL)
			{
				functionInfo* funInfo = new functionInfo();

				table->insert($2->getName(),"ID","function");

				functionInfoFromTable = table->lookUp($2->getName());

				funInfo->setReturnType($1->getName());
				funInfo->setParamList(parameterVector);
				funInfo->setNumberOfParam();

				functionInfoFromTable->setIsFunction(true);
				functionInfoFromTable->setFunctionInfo(funInfo);
				functionInfoFromTable->setIsDefined(true);

				//cout<<"here "<<functionInfoFromTable->getFunctionInfo()->getParamList()[0]->getName();
				
				//parameterVector.clear();
				
			}

			else
			{
				if(functionInfoFromTable->isDefined() == false)
				{
					string returnTypeFromTable = functionInfoFromTable->getFunctionInfo()->getReturnType();
					string returnTypeThis      = $1->getName();
					//cout<<"ret type: "<<returnTypeFromTable<<" "<<returnTypeThis;

					if(returnTypeFromTable != returnTypeThis)
					{
						error_count++;
						fprintf(errortext,"Error at Line No.%d: Return Type Doesn't Match with previous Declaration \n\n",line_count);

					}

					else
					{
						int paramNumberFromTable = functionInfoFromTable->getFunctionInfo()->getNumberOfParam();
						int paramNumberThis      = parameterVector.size();

						//cout<<"param size: "<<paramNumberFromTable<<" "<<paramNumberThis;

						if(paramNumberFromTable != paramNumberThis)
						{
							error_count++;
							fprintf(errortext,"Error at Line No.%d: Number Of Parameters Doesn't Match with previous Declaration \n\n",line_count);

						}

						else
						{
							vector< symbolInfo* > paramListFromTable = functionInfoFromTable->getFunctionInfo()->getParamList();
							
							int i = 0;

							for(i=0;i<paramNumberThis;i++)
							{
								string paramTypeFromTable = paramListFromTable[i]->getVariableType();
								string paramTypeThis      = parameterVector[i]->getVariableType();
								cout<<"paramType: table: "<<paramTypeFromTable<<"this: "<<paramTypeThis<<endl;
								if(paramTypeFromTable != paramTypeThis)
								{
									error_count++;
									fprintf(errortext,"Error at Line No.%d: Parameter Type Doesn't Match with previous Declaration \n\n",line_count);
									break;
								}
							}

							if(i == paramNumberThis)
							{
								functionInfoFromTable->setIsDefined(true);
							}

							//parameterVector.clear();


						}
					}
				}
				else
				{
					error_count++;
					fprintf(errortext,"Error at Line No.%d: %s Function Already Declared \n\n",line_count,$2->getName().c_str());
				}
			}

		} compound_statement
		{
			fprintf(logtext,"At line no:  %d func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement \n\n",line_count);
			string varTypeF = $1->getName();
			$$->setVariableType(varTypeF);
			$$->setName($1->getName() + $2->getName() + "( " + $4->getName() + " )\n" + $7->getName());			
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
		}

		| type_specifier ID LPAREN RPAREN
		{
			$$ = new symbolInfo();

			symbolInfo* functionInfoFromTable = table->lookUp($2->getName());

			if(functionInfoFromTable == NULL)
			{
				functionInfo* funInfo = new functionInfo();

				table->insert($2->getName(),"ID","function");

				functionInfoFromTable = table->lookUp($2->getName());

				funInfo->setReturnType($1->getName());
				funInfo->setParamList(parameterVector);
				funInfo->setNumberOfParam();

				functionInfoFromTable->setIsFunction(true);
				functionInfoFromTable->setFunctionInfo(funInfo);
				functionInfoFromTable->setIsDefined(true);

				//cout<<"here "<<functionInfoFromTable->getFunctionInfo()->getNumberOfParam();
				
			}

			else
			{
				if(functionInfoFromTable->isDefined() == false)
				{
					string returnTypeFromTable = functionInfoFromTable->getFunctionInfo()->getReturnType();
					string returnTypeThis      = $1->getName();
					//cout<<"ret type: "<<returnTypeFromTable<<" "<<returnTypeThis;

					if(returnTypeFromTable != returnTypeThis)
					{
						error_count++;
						fprintf(errortext,"Error at Line No.%d: Return Type Doesn't Match with previous Declaration \n\n",line_count);

					}

					else
					{
						int paramNumberFromTable = functionInfoFromTable->getFunctionInfo()->getNumberOfParam();

						if (paramNumberFromTable != 0)
						{
							error_count++;
							fprintf(errortext,"Error at Line No.%d: Number Of Parameters Doesn't Match with previous Declaration \n\n",line_count);

						}

						functionInfoFromTable->setIsDefined(true);
						
					}
				}

				else
				{
					error_count++;
					fprintf(errortext,"Error at Line No.%d: %s Function Already Declared \n\n",line_count,$2->getName().c_str());
				}
			}

		} compound_statement
		{
			fprintf(logtext,"At line no:  %d func_definition : type_specifier ID LPAREN RPAREN compound_statement \n\n",line_count);
			string varTypeF = $1->getName();
			$$->setVariableType(varTypeF);
			$$->setName($1->getName() + $2->getName() + "( )\n" + $6->getName());
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
		}
 		;				


parameter_list  : parameter_list COMMA type_specifier ID
		{
			fprintf(logtext,"At line no:  %d parameter_list : parameter_list COMMA type_specifier ID \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName()+" , "+$3->getName()+" "+$4->getName());

			if($3->getName() == "void ")
			{
				error_count++;
				$$->setName("(error)");
				fprintf(errortext,"Error at Line No.%d: Parameter Type Cannot Be VOID \n\n",line_count);

			}

			else
			{
				symbolInfo *param = new symbolInfo();

				param->setName($4->getName());
				param->setType("");
				param->setVariableType($3->getName());

				parameterVector.push_back(param);
			}
			

			// for(int i=0;i<parameterVector.size();i++)
			// {
			// 	cout<<parameterVector[i]->getName();
			// 	cout<<parameterVector[i]->getVariableType()<<endl;
			// }

			fprintf(logtext,"%s \n\n",$$->getName().c_str());	
		}
		| parameter_list COMMA type_specifier
		{
			fprintf(logtext,"At line no:  %d parameter_list : parameter_list COMMA type_specifier \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName()+" , "+$3->getName());

			if($3->getName() == "void ")
			{
				error_count++;
				$$->setName("(error)");
				fprintf(errortext,"Error at Line No.%d: Parameter Type Cannot Be VOID \n\n",line_count);

			}

			else
			{
				symbolInfo *param = new symbolInfo();

				param->setName("");
				param->setType("");
				param->setVariableType($3->getName());

				parameterVector.push_back(param);

			}
			
			// for(int i=0;i<parameterVector.size();i++)
			// {
			// 	cout<<parameterVector[i]->getName();
			// 	cout<<parameterVector[i]->getVariableType()<<endl;
			// }

			fprintf(logtext,"%s \n\n",$$->getName().c_str());	
		}
 		| type_specifier ID
		{
			fprintf(logtext,"At line no:  %d parameter_list : type_specifier ID \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName()+" "+$2->getName());

			//cout<<$1->getName()<<"here"<<$2->getName()<<endl;

			if($1->getName() == "void ")
			{
				error_count++;
				$$->setName("(error)");
				fprintf(errortext,"Error at Line No.%d: Parameter Type Cannot Be VOID \n\n",line_count);

			}

			else
			{
				symbolInfo *param = new symbolInfo();

				param->setName($2->getName());
				param->setType("");
				param->setVariableType($1->getName());

				parameterVector.push_back(param);
			}

			// for(int i=0;i<parameterVector.size();i++)
			// {
			// 	cout<<parameterVector[i]->getName();
			// 	cout<<parameterVector[i]->getVariableType()<<endl;
			// }

			fprintf(logtext,"%s \n\n",$$->getName().c_str());	
		}
		| type_specifier
		{
			fprintf(logtext,"At line no:  %d parameter_list : type_specifier \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName());

			//cout<<$1->getName()<<"here"<<endl;

			symbolInfo *param = new symbolInfo();

			if($1->getName() == "void ")
			{
				error_count++;
				$$->setName("(error)");
				fprintf(errortext,"Error at Line No.%d: Parameter Type Cannot Be VOID \n\n",line_count);

			}

			else
			{
				param->setName("");
				param->setType("");
				param->setVariableType($1->getName());

				parameterVector.push_back(param);
			}	

			fprintf(logtext,"%s \n\n",$$->getName().c_str());
		}
 		;

 		
compound_statement : LCURL
			{

				//cout<<"size from c:"<<parameterVector.size()<<endl;
				table->enterScope();

				for(int i=0;i<parameterVector.size();i++)
				{
					string name = parameterVector[i]->getName();
					string varType = parameterVector[i]->getVariableType();

					// cout<<name;
					// cout<<varType<<endl;

					table->insert(name,"ID",varType);
				}

				parameterVector.clear();
				//table->printAll();
			}
			 statements RCURL
			{

			$$ = new symbolInfo();
			fprintf(logtext,"At line no:  %d compound_statement : LCURL statements RCURL \n\n",line_count);
			$$->setName("{\n" + $3->getName() + "\n}");
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			table->printAll();
			table->exitScope();
			
		    }
 		    | LCURL
			{
				//cout<<"size from c:"<<parameterVector.size()<<endl;
				table->enterScope();

				for(int i=0;i<parameterVector.size();i++)
				{
					string name = parameterVector[i]->getName();
					string varType = parameterVector[i]->getVariableType();

					// cout<<name;
					// cout<<varType<<endl;

					table->insert(name,"ID",varType);
				}

				parameterVector.clear();
				//table->printAll();

			}
			RCURL
			{
			
			$$ = new symbolInfo();
			fprintf(logtext,"At line no:  %d compound_statement : LCURL RCURL \n\n",line_count);
			$$->setName("{ }");
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			table->printAll();
			table->exitScope();
			
		    }
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON
		{
			fprintf(logtext,"At line no:  %d var_declaration : type_specifier declaration_list SEMICOLON \n\n",line_count);
			$$ = new symbolInfo();
			//$$->setName($1->getName()+" "+$2->getName()+";\n");
				

			string typeOfdec = $1->getName();

			if(typeOfdec == "void ")
			{
				error_count++;
				fprintf(errortext,"Error at Line No.%d:  Variable Type cann't be VOID \n\n",line_count);
				$$->setName("(error)void "+$2->getName()+";\n");
			}

			else
			{
				for(int i=0;i<declarationVector.size();i++)
				{
					string varName = declarationVector[i]->getName();
					string varType = declarationVector[i]->getType();

					//cout<<varName<<" "<<varType<<endl;

					if(table->lookUpCur(varName) != NULL)
					{
						error_count++;
						fprintf(errortext,"Error at Line No.%d:  Multiple Defination of %s \n\n",line_count,varName.c_str());
						$$->setName($1->getName()+" (error)"+$2->getName()+";\n");
					}

					if(varType == "ID_ARRAY")
					{
						varType = typeOfdec + "array";
						$$->setName($1->getName()+" "+$2->getName()+";\n");
						table->insert(varName,"ID",varType);
					}

					else
					{
						varType = typeOfdec;
						$$->setName($1->getName()+" "+$2->getName()+";\n");
						//cout<<varType;
						table->insert(varName,"ID",varType);
					}
					
				}
				declarationVector.clear();
			}

			//table->printAll();
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
		}
 		 ;
 		 
type_specifier	: INT
		{
			$$ = new symbolInfo();
			$$->setName("int ");
			fprintf(logtext,"Line at %d: type_specifier	: INT \n\n",line_count);
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
		}
 		| FLOAT
		{
			$$ = new symbolInfo();
			$$->setName("float ");
			fprintf(logtext,"Line at %d: type_specifier	: FLOAT \n\n",line_count);
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
		}
 		| VOID
		 {
			$$ = new symbolInfo();
			$$->setName("void ");
			fprintf(logtext,"Line at %d: type_specifier	: VOID \n\n",line_count);
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
		}
 		;
 		
declaration_list : declaration_list COMMA ID
			{ 
				fprintf(logtext,"At line no:  %d declaration_list : declaration_list COMMA ID \n\n",line_count);
				$$ = new symbolInfo();
				$$->setName($1->getName()+" , "+$3->getName());
				fprintf(logtext,"%s \n\n", $$->getName().c_str());

				symbolInfo *var = new symbolInfo();
				var->setName($3->getName());
				var->setType("ID");
				declarationVector.push_back(var);
				// for(int i=0;i<declarationVector.size();i++)
				//   {
				// 	cout<<declarationVector[i]->getName()<<endl;
				// 	cout<<declarationVector[i]->getType()<<endl;
				// }
			
			}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
		   {

				fprintf(logtext,"At line no:  %d declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD \n\n",line_count);
				$$ = new symbolInfo();
				$$->setName($1->getName() + "," + $3->getName() + "[" + $5->getName() + "]");
				fprintf(logtext,"%s \n\n",$$->getName().c_str());

				symbolInfo *var = new symbolInfo();
				var->setName($3->getName());
				var->setType("ID_ARRAY");
				declarationVector.push_back(var);
				// for(int i=0;i<declarationVector.size();i++){
				// 	cout<<declarationVector[i]->getName()<<endl;
				// 	cout<<declarationVector[i]->getType()<<endl;
				// }
			
			}

 		  | ID
		   {
				fprintf(logtext,"At line no:  %d declaration_list : ID \n\n",line_count);
				$$ = new symbolInfo();
				$$->setName($1->getName());
				fprintf(logtext,"%s \n\n",$$->getName().c_str());

				symbolInfo *var = new symbolInfo();
				var->setName($1->getName());
				var->setType("ID");
				declarationVector.push_back(var);

				// for(int i=0;i<declarationVector.size();i++){
				// 	cout<<declarationVector[i]->getName()<<endl;
				// 	cout<<declarationVector[i]->getType()<<endl;
				// }
			}
 		  | ID LTHIRD CONST_INT RTHIRD
		   {

				fprintf(logtext,"At line no:  %d declaration_list : ID LTHIRD CONST_INT RTHIRD \n\n",line_count);
				$$ = new symbolInfo();
				$$->setName($1->getName() + "[" + $3->getName() + "]");
				fprintf(logtext,"%s \n\n",$$->getName().c_str());

				symbolInfo *var = new symbolInfo();
				var->setName($1->getName());
				var->setType("ID_ARRAY");
				declarationVector.push_back(var);
				// for(int i=0;i<declarationVector.size();i++){
				// 	cout<<declarationVector[i]->getName()<<endl;
				// 	cout<<declarationVector[i]->getType()<<endl;
				// }
			
		   }
 		  ;
 		  
statements : statement
		{
			fprintf(logtext,"At line no:  %d statements : statement \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName());
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
		}
	   | statements statement
	   {
			fprintf(logtext,"At line no:  %d statements : statements statement \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName()+$2->getName());
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
		}
	   ;
	   
statement : var_declaration
	  	{
			fprintf(logtext,"At line no:  %d statement : var_declaration \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName());
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
		}
	  | expression_statement
	  {
			fprintf(logtext,"At line no:  %d statement : expression_statement \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName());
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
	  }
	  | compound_statement
	  {
			fprintf(logtext,"At line no:  %d statement : compound_statement \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName());
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
	  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
	  {
			fprintf(logtext,"At line no:  %d statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName("for( "+$3->getName() + $4->getName() + $5->getName() + " )\n" + $7->getName());

			if($3->getVariableType() == "void " || $4->getVariableType() == "void " || $5->getVariableType() == "void ")
			{
				error_count++;
				fprintf(errortext,"Error at Line No.%d: Type MisMatch, Set As VOID \n\n",line_count);

			}
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
	  }
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE 
	  {
		  
		  fprintf(logtext,"Line at %d : statement	:	IF LPAREN expression RPAREN statement\n\n",line_count);
		  $$=new symbolInfo();
		  $$->setName("if(" + $3->getName() + ")\n" + $5->getName());

		  if($3->getVariableType() == "void ")
			{
				error_count++;
				fprintf(errortext,"Error at Line No.%d: Type MisMatch, Set As VOID \n\n",line_count);

			}

		  fprintf(logtext,"%s \n\n",$$->getName().c_str());

  	  }
	  | IF LPAREN expression RPAREN statement ELSE statement
	  {
			fprintf(logtext,"At line no:  %d statement : IF LPAREN expression RPAREN statement ELSE statement \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName("if(" + $3->getName() + ")\n" + $5->getName() + "\nelse\n" + $7->getName());

			if($3->getVariableType() == "void ")
			{
				error_count++;
				fprintf(errortext,"Error at Line No.%d: Type MisMatch, Set As VOID \n\n",line_count);

			}

			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
	  }	
	  | WHILE LPAREN expression RPAREN statement
	  {
			fprintf(logtext,"At line no:  %d statement : WHILE LPAREN expression RPAREN statement \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName("while( "+$3->getName()+ " )\n" + $5->getName());

			if($3->getVariableType() == "void ")
			{
				error_count++;
				fprintf(errortext,"Error at Line No.%d: Type MisMatch, Set As VOID \n\n",line_count);

			}
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
	  {
			fprintf(logtext,"At line no:  %d statement : PRINTLN LPAREN ID RPAREN SEMICOLON \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName("println( " + $3->getName() + " );\n");
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
	  }
	  | RETURN expression SEMICOLON
	  {
			fprintf(logtext,"At line no:  %d statement : RETURN expression SEMICOLON \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName("return " + $2->getName() + " ;");

			if($2->getVariableType() == "void ")
			{
				error_count++;
				fprintf(errortext,"Error at Line No.%d: Type MisMatch, Set As VOID \n\n",line_count);

			}

			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
	  }
	  ;
	  
expression_statement 	: SEMICOLON	
			{
				$$ = new symbolInfo();
				$$->setName(";\n");
				fprintf(logtext,"Line at %d: expression_statement	: SEMICOLON \n\n",line_count);
				fprintf(logtext,"%s \n\n",$$->getName().c_str());
				
			}		
			| expression SEMICOLON 
			{
				fprintf(logtext,"At line no:  %d expression_statement 	:  expression SEMICOLON  \n\n",line_count);
				$$ = new symbolInfo();
				$$->setName($1->getName()+";\n");
				fprintf(logtext,"%s \n\n",$$->getName().c_str());			
			}
			;
	  
variable : ID
		{	
			fprintf(logtext,"At line no:  %d variable : ID \n\n",line_count);
			$$ = new symbolInfo();
			//$$->setName($1->getName());
			//fprintf(logtext,"%s \n\n",$$->getName().c_str());

			string varName = $1->getName();
			string varType = $1->getType();
			
			//cout<<varName<<" "<<varType<<endl;
			symbolInfo* variableInfo = new symbolInfo();
			variableInfo = table->lookUp(varName);

			if(variableInfo == NULL)
			{
				error_count++;
				$$->setName("(error) "+$1->getName());
				fprintf(errortext,"Error at Line No.%d: %s Undeclared Before Use \n\n",line_count,varName.c_str());
			}
			
			else
			{	
				//cout<<variableInfo->getName()<<" "<<variableInfo->getType()<<" "<<variableInfo->getVariableType();
				if(variableInfo->getVariableType().find("array") != string::npos)
				{
					error_count++;
					$$->setName("(error) "+$1->getName());
					fprintf(errortext,"Error at Line No.%d:Type MisMatch. Not an Array Operation. \n\n",line_count);
				}
				else
				{
					//cout<<variableInfo->getVariableType();
					$$->setName($1->getName());
					$$->setVariableType(variableInfo->getVariableType());
				}

			}
			
			fprintf(logtext,"%s \n\n",$$->getName().c_str());	
		}
	 | ID LTHIRD expression RTHIRD
		{
			fprintf(logtext,"At line no:  %d variable : ID LTHIRD expression RTHIRD \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName()+"["+$3->getName()+"]");
			//fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
			string varName = $1->getName();
			string varType = $1->getType();
			
			symbolInfo* variableInfo = new symbolInfo();
			variableInfo = table->lookUp(varName);

			//cout<<variableInfo->getName()<<" here "<<variableInfo->getType()<<" "<<variableInfo->getVariableType();
			if(variableInfo == NULL)
			{
				error_count++;
				$$->setName("(error) "+$1->getName()+"["+$3->getName()+"]");
				fprintf(errortext,"Error at Line No.%d: %s Undeclared Before Use \n\n",line_count,varName.c_str());
			}
			else
			{
				string indexType = $3->getVariableType();
				//cout<<"idx:"<<indexType<<endl;
				if(variableInfo->getVariableType() != "int array" && variableInfo->getVariableType() != "float array")
				{
					cout<<variableInfo->getVariableType()<<"here"<<endl;
					error_count++;
					$$->setName("(error)"+$1->getName()+"["+$3->getName()+"]");
					fprintf(errortext,"Error at Line No.%d: %s Not Declared as Array. Type MisMatch \n\n",line_count,varName.c_str());
				}
				else
				{
					if(indexType != "int " && indexType != "int array")
					{
						error_count++;
						$$->setName($1->getName()+"[(error) "+$3->getName()+"]");
						fprintf(errortext,"Error at Line No.%d: Array index is not integer Type \n\n",line_count);
					}
					else
					{
						//cout<<"vartype:"<<$1->getVariableType()<<endl;
						$$->setName($1->getName()+"["+$3->getName()+"]");
						$$->setVariableType($1->getVariableType());
					}
				}
				

				
			}

			fprintf(logtext,"%s \n\n",$$->getName().c_str());
		} 
	 ;
	 
 expression : logic_expression
		{
			fprintf(logtext,"At line no:  %d expression : logic_expression \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName());
			$$->setVariableType($1->getVariableType()+"");
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
		}
	   | variable ASSIGNOP logic_expression
	   {
			fprintf(logtext,"At line no:  %d expression : variable ASSIGNOP logic_expression \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName()+"="+$3->getName());
			
			
			string lhstype = $1->getVariableType();
			string rhstype = $3->getVariableType();
			//cout<<lhstype<<" = "<<rhstype<<endl;

			if(lhstype == "int array") lhstype = "int ";
			if(lhstype == "float array") lhstype = "float ";

			if(rhstype == "int array") rhstype = "int ";
			if(rhstype == "float array") rhstype = "float ";

			if(lhstype != rhstype)
			{
				error_count++;
				$$->setName("(error)"+$1->getName()+"="+$3->getName());
				fprintf(errortext,"Error at Line No.%d: Type MisMatch \n\n",line_count);

			}

			else
			{
				if($3->getVariableType() == "void ")
				{
					error_count++;
					fprintf(errortext,"Error at Line No.%d: Type MisMatch, Set As VOID \n\n",line_count);

				}
			}
			$$->setVariableType($1->getVariableType()+"");
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
		} 	
	   ;
			
logic_expression : rel_expression
		{
			fprintf(logtext,"At line no:  %d logic_expression : rel_expression \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName());
			$$->setVariableType($1->getVariableType()+"");
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
		}
		 | rel_expression LOGICOP rel_expression
		 {
			fprintf(logtext,"At line no:  %d logic_expression : rel_expression LOGICOP rel_expression \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName()+$2->getName()+$3->getName());
			$$->setVariableType("int ");

			if($1->getVariableType() == "void " || $3->getVariableType() == "void ")
			{
				error_count++;
				fprintf(errortext,"Error at Line No.%d: Type MisMatch, Set As VOID \n\n",line_count);

			}

			fprintf(logtext,"%s \n\n",$$->getName().c_str());	
		} 	
		 ;
			
rel_expression	: simple_expression 
		{
			fprintf(logtext,"At line no:  %d rel_expression	: simple_expression  \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName());
			$$->setVariableType($1->getVariableType()+"");
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
		}
		| simple_expression RELOP simple_expression
		{	
			fprintf(logtext,"At line no:  %d rel_expression	: simple_expression RELOP simple_expression  \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName()+$2->getName()+$3->getName());
			$$->setVariableType("int ");

			if($1->getVariableType() == "void " || $3->getVariableType() == "void ")
			{
				error_count++;
				fprintf(errortext,"Error at Line No.%d: Type MisMatch, Set As VOID \n\n",line_count);

			}

			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
		}	
		;
				
simple_expression : term
		  {
			fprintf(logtext,"At line no:  %d simple_expression : term \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName());
			$$->setVariableType($1->getVariableType()+"");
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
		  }
		  | simple_expression ADDOP term 
		  {
			fprintf(logtext,"At line no:  %d simple_expression : simple_expression ADDOP term  \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName()+$2->getName()+$3->getName());
			
			if($1->getVariableType() == "void " || $3->getVariableType() == "void ")
			{
				error_count++;
				fprintf(errortext,"Error at Line No.%d: Type MisMatch, Set As VOID \n\n",line_count);

			}

			if($1->getVariableType() == "float " || $1->getVariableType() == "float array" || $3->getVariableType() == "float " || $3->getVariableType() == "float array")
			{
				$$->setVariableType("float ");
			}
			else
			{
				$$->setVariableType("int ");
			}
			
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
		  }
		  ;
					
term :	unary_expression
	{
			fprintf(logtext,"At line no:  %d term :	unary_expression \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName());
			$$->setVariableType($1->getVariableType()+"");
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
	}
    |  term MULOP unary_expression
	{
			fprintf(logtext,"At line no:  %d term :	term MULOP unary_expression \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName()+$2->getName()+$3->getName());
			
			if($1->getVariableType() == "void " || $3->getVariableType() == "void ")
			{
				error_count++;
				fprintf(errortext,"Error at Line No.%d: Type MisMatch, Set As VOID \n\n",line_count);

			}

			if($2->getName() == "/" ||$1->getVariableType() == "float " || $1->getVariableType() == "float array" || $3->getVariableType() == "float " || $3->getVariableType() == "float array")
			{
				$$->setVariableType("float ");
			}
			else
			{
				$$->setVariableType("int ");
			}

			if($2->getName() == "%")
			{
				string dividendType = $1->getVariableType();
				string divisorType = $3->getVariableType();
				int flag = 0;



				if(dividendType != "int " && dividendType != "int array")
				{
					flag = 1;
					error_count++;
					$$->setName("(error)"+$1->getName()+$2->getName()+$3->getName());
					fprintf(errortext,"Error at Line No.%d: Non-Integer operand on modulus operator \n\n",line_count);
				}

				if(divisorType != "int " && divisorType != "int array")
				{
					$$->setName($1->getName()+$2->getName()+"(error)"+$3->getName());
					if(flag == 1)
					{
						$$->setName("(error)"+$1->getName()+$2->getName()+"(error)"+$3->getName());
					}
					if(flag != 1)
					{
						error_count++;
						fprintf(errortext,"Error at Line No.%d: Non-Integer operand on modulus operator \n\n",line_count);
					}
				}

				$$->setVariableType("int ");
			}

			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
	}
    ;

unary_expression : ADDOP unary_expression 
		{
			fprintf(logtext,"At line no:  %d unary_expression : ADDOP unary_expression \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName()+$2->getName());
			$$->setVariableType($2->getVariableType()+"");

			if($2->getVariableType() == "void ")
			{
				error_count++;
				fprintf(errortext,"Error at Line No.%d: Type MisMatch, Set As VOID \n\n",line_count);

			}

			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
		}
		| NOT unary_expression
		{
			fprintf(logtext,"At line no:  %d unary_expression : NOT unary_expression \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName("!"+$2->getName());
			$$->setVariableType($2->getVariableType()+"");

			if($2->getVariableType() == "void ")
			{
				error_count++;
				fprintf(errortext,"Error at Line No.%d: Type MisMatch, Set As VOID \n\n",line_count);

			}

			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
		} 
		| factor
		{
			fprintf(logtext,"At line no:  %d unary_expression : factor \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName());
			$$->setVariableType($1->getVariableType()+"");
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
		}
		 ;
	
factor	: variable
		{
			fprintf(logtext,"At line no:  %d factor	: variable \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName());
			$$->setVariableType($1->getVariableType()+"");
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
		}
	| ID LPAREN argument_list RPAREN
		{
			fprintf(logtext,"At line no:  %d factor	: ID LPAREN argument_list RPAREN \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName()+"("+$3->getName()+")");
			
			symbolInfo* functionInfoFromTable = table->lookUp($1->getName());

			if(functionInfoFromTable == NULL)
			{
				error_count++;
				$$->setName("(error)"+$1->getName()+"("+$3->getName()+")");
				fprintf(errortext,"Error at Line No.%d: Undeclared Function \n\n",line_count);

			}

			else
			{
				if(functionInfoFromTable->isFunction() != true)
				{
					error_count++;
					$$->setName("(error)"+$1->getName()+"("+$3->getName()+")");
					fprintf(errortext,"Error at Line No.%d: Not declared as Function \n\n",line_count);
				}

				else if(functionInfoFromTable->isDefined() != true)
				{
					error_count++;
					$$->setName("(error)"+$1->getName()+"("+$3->getName()+")");
					fprintf(errortext,"Error at Line No.%d: Not Defined Before Use \n\n",line_count);

				}

				else
				{
					int paramNumberFromTable = functionInfoFromTable->getFunctionInfo()->getNumberOfParam();
					int argNumberThis      = argumentVector.size();
					//cout<<"param size: "<<paramNumberFromTable<<" "<<argNumberThis;
					if(paramNumberFromTable != argNumberThis)
					{
						error_count++;
						fprintf(errortext,"Error at Line No.%d: Number Of Parameters Doesn't Match \n\n",line_count);

					}

					else
					{
						vector< symbolInfo* > paramListFromTable = functionInfoFromTable->getFunctionInfo()->getParamList();

						int i = 0;

						for(i=0;i<argNumberThis;i++)
						{
							string paramTypeFromTable = paramListFromTable[i]->getVariableType();
							string argTypeThis      =   argumentVector[i]->getVariableType();
							//cout<<"paramType: table: "<<paramTypeFromTable<<"this: "<<argTypeThis<<endl;
							if(paramTypeFromTable != argTypeThis)
							{
								error_count++;
								$$->setName($1->getName() + $2->getName() + "( (error)" + $4->getName() + " );\n");
								fprintf(errortext,"Error at Line No.%d: Parameter Type Doesn't Match with previous Declaration \n\n",line_count);
								break;
							}
						}

						if(argNumberThis == i)
						{
							string returnType = functionInfoFromTable->getFunctionInfo()->getReturnType();
							//cout<<returnType<<"here";
							$$->setVariableType(returnType);
						}

						argumentVector.clear();
					}
				}
			}

			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
		}
	| LPAREN expression RPAREN
		{
			fprintf(logtext,"At line no:  %d factor	: LPAREN expression RPAREN \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName("("+$2->getName()+")");
			$$->setVariableType($2->getVariableType()+"");
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
		}
	| CONST_INT 
	{
			fprintf(logtext,"At line no:  %d factor	: CONST_INT \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName());
			$$->setVariableType("int ");
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
	}
	| CONST_FLOAT
	{
			fprintf(logtext,"At line no:  %d factor	: CONST_FLOAT \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName());
			$$->setVariableType("float ");
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
	}
	| variable INCOP
	{
			fprintf(logtext,"At line no:  %d factor	: variable INCOP \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName()+"++");
			$$->setVariableType($1->getVariableType()+"");
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
	} 
	| variable DECOP
	{
			fprintf(logtext,"At line no:  %d factor	: variable DECOP \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName()+"--");
			$$->setVariableType($1->getVariableType()+"");
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
	} 
	;
	
argument_list : arguments
			{
			fprintf(logtext,"At line no:  %d argument_list : arguments\n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName());
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
			// for(int i=0;i<argumentVector.size();i++)
			// {
			// 	cout<<"here"<<endl;
			// 	cout<<"name: "<<argumentVector[i]->getName()<<endl;
			// 	cout<<"varType: "<<argumentVector[i]->getVariableType()<<endl;
			// }

		  	}
			| 
			{ 
				fprintf(logtext,"At line no:  %d argument_list : \n\n",line_count);
				$$ = new symbolInfo();
				$$->setName("");
				fprintf(logtext,"%s \n\n",$$->getName().c_str());
			}

			  ;
	
arguments : arguments COMMA logic_expression
		  {
			fprintf(logtext,"At line no:  %d arguments : arguments COMMA logic_expression\n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName()+","+$3->getName());
			argumentVector.push_back($3);
			// for(int i=0;i<argumentVector.size();i++)
			// {
			// 	cout<<"name: "<<argumentVector[i]->getName()<<endl;
			// 	cout<<"varType: "<<argumentVector[i]->getVariableType()<<endl;
			// }
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
		  }
	      | logic_expression
		  {
			fprintf(logtext,"At line no:  %d arguments : logic_expression \n\n",line_count);
			$$ = new symbolInfo();
			$$->setName($1->getName());
			argumentVector.push_back($1);
			// for(int i=0;i<argumentVector.size();i++)
			// {
			// 	cout<<"here"<<endl;
			// 	cout<<"name: "<<argumentVector[i]->getName()<<endl;
			// 	cout<<"varType: "<<argumentVector[i]->getVariableType()<<endl;
			// }
			fprintf(logtext,"%s \n\n",$$->getName().c_str());
			
		  }
	      ;
 

%%
int main(int argc,char *argv[])
{

	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}

	// fp2= fopen(argv[2],"w");
	// fclose(fp2);
	// fp3= fopen(argv[3],"w");
	// fclose(fp3);
	
	// fp2= fopen(argv[2],"a");
	// fp3= fopen(argv[3],"a");
	

	yyin=fp;
	yyparse();
	fprintf(logtext,"Total Lines : %d \n\n",line_count);
	fprintf(logtext,"Total Errors : %d \n\n",error_count);
	fprintf(errortext,"Total Errors : %d \n\n",error_count);

	// fclose(fp2);
	// fclose(fp3);
	
	return 0;
}


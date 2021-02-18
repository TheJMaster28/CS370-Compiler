/*
Jeffrey Lansford
Lab 9
May 3, 2019
YACC program to check syntax of the outputed tokens from LEX with the grammer defined for C-Algol. Will print what line errors happens on when they occur. 
Input from LEX tokens. Outputs error if syntax is not correct. 
Now has semantic actions to create an AST based on the grammer. Incorpates the C file 'ast.c' and its .h file to have the functions to create the AST. 
Added to the union structre a ASTnodetype pointer to allow the nonterminals to return the nodes and a SYSTYPES enum to allow operator nonterminals to return the type.
Added Symbol Table to allow language to check declared variables and type checking.  
now sends AST to emit to generate NASM code
*/
%{
int yylex();
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include "ast.h"
#include "emit.h"
int debugEMIT = 0;
int lineCount; 
int level = 0;
int offset = 0;
int goffset = 0;
int maxOffset = 0;
// 1 to view table after every Insert
int debugI = 0;
// pointer for holding error message
char *err;
void yyerror (s) 
        char *s;
{
   	/* prints what line error occurs at when YACC comes across a syntax error */
	fprintf(stderr,"%s line: %d\n", s, lineCount );
}
// function used to combine 2 seperate char*
char* combineStrings( char *s1, char* s2 ) {
	char *final = (char*) malloc( sizeof(s1) + sizeof(s2) );
	sprintf(final,"%s%s", s1, s2 );
	return final;
}
%}

%start P
/* union structure to allow tokens to be string or integers, allows nonterminals to be ASTnodes or SYSTEMTYPES enum */ 
%union {
    char *string;
    int integer;
    struct ASTnodetype * node;
    struct SymbTab *symNode;
    enum SYSTEMTYPES types;
}
/* all tokens returned form LEX */
%token <string> ID STRING
%token INT VOID BOOLEAN BEGINNING END OF WHILE DO READ RETURN WRITE AND OR TRUE FALSE NOT ELSE IF THEN GE LE EE NE 
%token <integer> NUM 
%type <node> P decls decl varDecl varList funDecl params compoundSt paramList param localDec expressionSt  returnSt iterationSt
%type <node> stateList statement writeSt expression simpleExpr addExpr term factor var readSt  call args argList selectionSt assignmentSt
%type <types> relop addop multop typeSp 
%left '+' '-'
%left '*' '/' '%'

%%
/* grammer to define the syntax of the C-Algol lanaguge */

P           :   decls { program = $1; /* set program to the begining of the tree */ }  /* program -> declaration list */
            ;
decls       :   decl  { $$ = $1; /* passes node from decl to decls */ }  /* declaration list -> declaration { declaration } */
            |   decl decls { $1->next = $2; /* chains declarations together with the next pointer */
                             $$ = $1; /* pass node */
                             }
            ;
decl        :   varDecl  { $$ = $1; /* pass the node from varDecl */ }/* declartion -> var-declaration | fun-declartion */
            |   funDecl  { $$ = $1; } 
            ;
varDecl     :   typeSp varList ';'{ 
				    $$ = $2; /* passes node from varList */
				    /* sets type for all varlists */
				    ASTnode *p;
				    p = $2;
				    while ( p != NULL ) {
                                       p->sysType = $1;
                                       (p->symbol)->Type = $1;
                                       p = p->s1;
                                    }
				    }  /* var-declartion -> type-specifier var-list ; */
            ;
varList     :   ID  { 
                        /* checks if symbol is not already declared */
                        if ( Search( $1, level, 0 ) != NULL ) {
                            err = combineStrings( "Name already used: ", $1 ); 
                            yyerror(err);
                            exit(1); 
                        }
                        $$ = ASTCreateNode(VARDEC); /* create node */ 
                        /* inserts in symbol table and store pointer to entry */   
                        $$->symbol = Insert($1, 0, ISFUN_SCALER, level, 1, offset, NULL); 
                        offset++; /* increment offset for each insert */
                        $$->name = $1; /* set name to its ID */
                        if (debugI ) Display();
                   }    /* var-list -> ID | ID [NUM] | ID , var-list | ID[NUM] , var-list */                                                           
            |   ID '[' NUM ']' { 
                                    if ( Search( $1, level, 0 ) != NULL ) { 
                                            err = combineStrings( "Name already used: ", $1 ); 
                                            yyerror(err);
                                            exit(1); 
                                    }

                                    $$ = ASTCreateNode(VARDEC); /* creates node */
                                    $$->name = $1; /* sets name to its ID */
                                    $$->value =$3; /* sets value from the NUM of the size of the array */
                                    $$->symbol = Insert( $1 , 0, ISFUN_ARRAY, level, $3, offset, NULL );
                                    offset += $3;
                                    if ( debugI ) Display();
                                }
            |   ID ',' varList { 
                                    if ( Search( $1, level, 0) != NULL ) {
                                        err = combineStrings("Name already used: ", $1 );
                                        yyerror(err);
                                        exit(1);
                                    }
                                    $$ = ASTCreateNode(VARDEC);
                                    $$->name = $1;
                                    $$->symbol = Insert($1, 0, ISFUN_SCALER, level, 1, offset, NULL);
                                    offset++;
                                    if (debugI ) Display();
                                    $$->s1 = $3; /* chains VARDECs together with the s1 pointer */
                                }
            |   ID '[' NUM ']' ',' varList { 
                                    if ( Search( $1, level, 0 ) != NULL ) {
                                        err = combineStrings("Name already used: ", $1 );
                                        yyerror(err);
                                        exit(1);
                                    } 
                                    $$ = ASTCreateNode(VARDEC); 
                                    $$->name = $1;
                                    $$->value = $3;
                                    $$->symbol = Insert( $1 , 0, ISFUN_ARRAY, level, $3, offset, NULL );
                                    offset += $3;
                                    $$->s1 = $6; /* chains VARDECs together with the s1 pointer */
                                    if ( debugI ) Display();
                                }
            ;
typeSp      :   INT  { $$ = INTTYPE;  /* sets type of the function or variable */}  /* type-specifier -> int | void | boolean */
            |   VOID { $$ = VOIDTYPE; }
            |   BOOLEAN { $$ = BOOLEANTYPE; }
            ;   
funDecl     :   typeSp ID '('  { 
                                /* checks if ID is already been declared */
                                if ( Search( $2, level, 1 ) != NULL ) { 
                                    err = combineStrings("Name already used: ", $2 );
                                    yyerror(err); 
                                    exit(1);
                                } 
                                /* inserts entry into symbol table, stores pointer in sementic value */
                                $<symNode>$ = Insert ( $2, $1, ISFUN_FUNCTION, level, 1, 0, NULL ); 
                                /* sets globel offset to current offset */
                                goffset = offset;
                                /* resets ofset */
                                offset = 2;
                                maxOffset = offset;
                            }
        params{ $<symNode>4->fparms = $5;/* sets parameters to the symbol table entry */ }
        ')' compoundSt  {
                           $$ = ASTCreateNode(FUNDEC);
                           $$->name = $2;
                           $$->sysType = $1;
                           $$->s1 = $5; 
                           $$->s2 = $8; /* sets the block statement to the s2 pointer */ 
                           /* stores entry into ASTnode */
                           $$->symbol = $<symNode>4;
                           if ( maxOffset < offset ) 
                               maxOffset = offset;
                           $$->symbol->offset = maxOffset;
                           /* delete elements in level 1 */
                           offset -= Delete(1);
                           /* sets level and offset back to orginally values before function */
                           level = 0;
                           offset = goffset;
                           if ( debugI ) Display();
                        }/* fun-declartion -> type-specifer ID (params) compound-stmt */
            ;
params      :   VOID   { $$ = ASTCreateNode(PARAM); /* create a PARAM node and sets type to NULLTYPE to sesemble no parameters */
                         $$->sysType = NULLTYPE; 
                         } /* params -> void | param-list */
            |   paramList { $$ = $1; }
            ;
paramList   :   param   { $$ = $1; }/* param-list -> param { , param } */
            |   param ',' paramList { $1->next = $3; /* chains parameters together with next pointer */
                                      $$ = $1; 
                                      }
            ;
param       :   typeSp ID  { 
                                /* checks and adds to symbol table */
                                if ( Search( $2, level+1, 0 ) != NULL ) { 
                                    err = combineStrings("Name already used: " ,$2 );
                                    yyerror(err); 
                                    exit(1); 
                                }
                                $$ = ASTCreateNode(PARAM); /* creates PARAM node, then sets its name and type */
                                $$->name = $2; 
                                $$->sysType = $1;
                                $$->symbol = Insert( $2, $1, ISFUN_SCALER, level+1, 1, offset, NULL );
                                offset++;
                                if ( debugI ) Display();
                            }/* param -> type-specifer ID [ [] ]+ */
            |   typeSp ID '[' ']' {
                                        if ( Search( $2, level+1, 0 ) != NULL ) { 
                                            err = combineStrings("Name already used: " ,$2 );
                                            yyerror(err); 
                                            exit(1); 
                                        }
                                        $$ = ASTCreateNode(PARAM);
                                        $$->name = $2;
                                        $$->value = 1; /* sets value to 1 for printing */
                                        $$->sysType = $1;
                                        $$->symbol = Insert ( $2, $1, ISFUN_ARRAY, level+1, 1, offset, NULL ); 
                                        offset++;
                                        
                                        if ( debugI ) Display();
                                    } 
            ;
compoundSt  :   BEGINNING { level++; }  
	        localDec stateList END {          
                                        $$ = ASTCreateNode(BLOCK); /* creates BLOCK node */
                                        $$->s1 = $3; /* sets localDec to s1 */
                                        $$->s2 = $4; /* sets sataList to s2 */
                                        if ( debugI) Display();
                                        if ( maxOffset < offset ) 
                                            maxOffset = offset;
                                        offset-=Delete(level);
                                        level--;
                                   } /* compound-stmt -> begin local-declarations statement-list end */
            ;
localDec    :   /* empty */  {$$ = NULL; }   /* local-declarations -> { var-declaration } */
            |   varDecl localDec { $1->next = $2; /* chains localDec together with next */
                                   $$ = $1; 
                                   }
            ;
stateList   :   /*empty*/ {$$ = NULL; }       /* statement-list -> { statement } */
            |   statement stateList { if ( $1 != NULL ) { /* checks if statement is not NULL */
                                        $1->next = $2; /* chains statments together with next */
                                        $$ = $1; /* sets to statement */
                                        }
                                      else {
                                        $$ = $2; /* sets to stateList if statement is NULL */
                                        }
                                      }
            ;
statement   :   expressionSt { $$ = $1; /* passes nodes created by each different statement */}   /* statement -> expression-stmt | compound-stmt | selction-stmt | iteration-stmt | assignment-stmt | return-stmt | read-stmt | write-stmt */
            |   compoundSt { $$ = $1; }
            |   selectionSt { $$ = $1; }
            |   iterationSt { $$ = $1; }
            |   assignmentSt { $$ = $1; }
            |   returnSt { $$ = $1; }
            |   readSt { $$ = $1; }
            |   writeSt { $$ = $1; }
            ;
expressionSt:   expression ';' { $$=$1; /* passes node from expression */}  /* expression-stmt -> expression ; | ; */ 
            |   ';' { $$ = NULL; /* sets to null for no expressions */ }
            ;
selectionSt :   IF expression THEN statement  { $$ = ASTCreateNode(SELESTMT); /* creates a SELESTMT node */
                                                     $$->s1 = ASTCreateNode(IFTHEN); /* creates a IFTHEN node in the SELESTMT's s1 */
                                                     ($$->s1)->s1 = $2; /* sets IFTHEN's s1 with the expression */
                                                     ($$->s1)->s2 = $4; /* sets IFTHEN's s2 with the statement */
                                                     }/* selection-stmt -> if expression then statment [ else statement ]+ */
            |   IF expression THEN statement ELSE statement  { $$ = ASTCreateNode(SELESTMT); 
                                                                    $$->s1 = ASTCreateNode(IFTHEN); 
                                                                    ($$->s1)->s1 = $2; 
                                                                    ($$->s1)->s2 = $4; 
                                                                    $$->s2 = ASTCreateNode(ELSESTMT); /* creats an ELSESTMT in SELESTMT's s2 */
                                                                    ($$->s2)->s1 = $6; /* sets the ELSESTMT's s1 with the second expression */
                                                                    }
            ;
iterationSt :   WHILE expression DO statement { $$ = ASTCreateNode(WHILEDO); /* creates WHILEDO node */
                                                $$->s1 = $2; /* sets s1 with epression */
                                                $$->s2 = $4; /* sets s2 with statement */
                                                }   /* iteration-stmt -> while expression do statement */ 
            ;
returnSt    :   RETURN ';'  { $$ = ASTCreateNode(RETURNT); /* creates RETURN node */ } /* return-stmt -> return [ expression ]+ */ 
            |   RETURN expression ';' { $$ = ASTCreateNode(RETURNT); /* creates RETURN node with s1 set to the expression */
                                        $$->s1 = $2; 
                                        } 
            ;
readSt      :   READ var ';'{ $$ = ASTCreateNode(READT); /* creates READST node, sets s1 to var */
                              $$->s1=$2; 
                              } /* read-stmt -> read variable */
            ;
writeSt     :   WRITE expression ';' { $$= ASTCreateNode(WRITET); /* creates WRITEST node, sets s1 to expression */
                                       $$->s1 = $2; } /* write-stmt -> write expression ; */ 
            |   WRITE STRING ';' { $$ = ASTCreateNode(WRITET);
                                   $$->name = $2;
                                 }
            ;
assignmentSt:   var '=' simpleExpr ';' {
                                            /* checks type of RHS and LHS */
                                            enum SYSTEMTYPES p;
                                            /* if RHS is an EXPR node, then get generated temp value type */
                                            p = $3->isType;
                                            if ( $1->sysType != p ) {
                                                err = combineStrings ( "Type Mismatch: ", $1->name );
                                                yyerror(err);
                                                exit(1);
                                            }
                                            $$ = ASTCreateNode(ASSIGN); /* creates ASSIGN node */ 
                                            $$->symbol = Insert( CreateTemp(), p, ISFUN_SCALER, level, 1, offset, NULL );
                                            offset++;
                                            $$->s1 = $1; /* sets s1 to var */
                                            $$->s2 = $3; /* sets s2 to simpleExpr */ 
                                       } /* assignment-stmt -> var = simple-expression ; */ 
            ;
expression  :   simpleExpr { $$ = $1; }  /* expression -> simple-expression */
            ;
var         :   ID {
                        /* checks if ID is in symbol table */
                        struct SymbTab *p = Search( $1, level, 1 ); 
                        if ( p == NULL ) { 
                            err = combineStrings("Name not found: ",$1);
                            yyerror(err); 
                            exit(1); 
                        }
                        /* entry must be a scaler to be used in this context */
                        if ( p->IsAFunc != ISFUN_SCALER ) { 
                            err = combineStrings($1," Name used in wrong context");
                            yyerror(err); 
                            exit(1);
                        }
                        $$ = ASTCreateNode(IDENT); /* creates IDENT node and sets name to the ID */
                        $$->name = $1;
                        $$->symbol = Search( $1, level, 1 ); 
                        $$->sysType = p->Type;
                        $$->isType = p->Type;
                   }/* var -> ID [ [expression] ]+ */
            |   ID '[' expression ']' { 
                                        struct SymbTab *p = Search( $1, level, 1 ); 
                                        if ( p  == NULL ) { 
                                            err = combineStrings("Name not found: ",$1);
                                            yyerror(err); 
                                            exit(1); 
                                        }
                                        /* entry must be an array to be used in this context */ 
                                        if ( p->IsAFunc != ISFUN_ARRAY ) { 
                                            err = combineStrings($1," Name used in wrong context");
                                            yyerror(err); 
                                            exit(1); 
                                        }
                                        $$ = ASTCreateNode(IDENT); 
                                        $$->name = $1; 
                                        $$->value = 1; /* sets value for printing */
                                        $$->s1 = $3; /* sets s1 to expression */
                                        $$->symbol = Search( $1, level, 1 ); 
                                        $$->sysType = p->Type;
                                        $$->isType = p->Type;
                                      } 
            ;
simpleExpr  :   addExpr { $$ = $1; }  /* simple-expression -> additive-expression [ relop additive-expression ]+ */
            |   addExpr relop addExpr { 
                                        /* checks type for RHS and LHS, if either is an EXPR, then get generate temp value's type */
                                        enum SYSTEMTYPES p;
                                        p = $1->isType;
                                        enum SYSTEMTYPES q;
                                        q = $3->isType;
                                        if ( p != q ) {
                                            yyerror("Type mismatch\n");
                                            exit(1);
                                        }
                                        $$ = ASTCreateNode(EXPR); /* creates EXPR node */ 
                                        $$->sysType = $2; /* setstype to the relop */
                                        $$->s1 = $1; /* sets left and right addExpr to s1 and s2 */
                                        $$->s2 = $3;
                                        /* inserts a generate value into symbol table */
                                        $$->symbol = Insert( CreateTemp(), p, ISFUN_SCALER, level, 1, offset, NULL );
                                        $$->isType = p;
                                        if ( debugI ) Display();
                                        offset++;
                                      }
            ;
relop       :   LE { $$ = LET; /* returns types according to the operator */ }          /* relop -> <= | < | > | >= | == | != */
            |   '<' { $$ = LT; }
            |   '>' { $$ = GT; }
            |   GE { $$ = GET; }
            |   EE { $$ = EET; }
            |   NE { $$ = NET; }
            ;
addExpr     :   term { $$ = $1; }        /* additive-expression -> term { addop term } */ 
            |   addExpr addop term { 
                                    enum SYSTEMTYPES p;
                                    p = $1->isType;
                                    enum SYSTEMTYPES q;
                                    q = $3->isType;
                                    if ( p != q ) {
                                        yyerror("Type mismatch\n");
                                        exit(1);
                                    }
                                    $$ = ASTCreateNode(EXPR); /* creates EXPR node */
                                    $$->s1 = $1; /* sets s1 to addExpr */
                                    $$->s2 = $3; /* sets s2 to term */
                                    $$->sysType = $2; /* sets type according to addop */
                                    $$->symbol = Insert( CreateTemp(), p, ISFUN_SCALER, level, 1, offset, NULL );
                                    $$->isType = p;
                                    if ( debugI ) Display();
                                    offset++;      
                                   }
            ;
addop       :   '+'    { $$ = ADDOPER;  /* returns type ADDOPER for addition */} /* addop -> + | - */ 
            |   '-'    { $$ = SUBOPER; /* returns type SUBOPER for subtraction */ }
            ;
term        :   factor { $$ = $1; } /* term -> factor { multop factor } */
            |   term multop factor { 
                                    enum SYSTEMTYPES p;
                                    p = $1->isType;
                                    enum SYSTEMTYPES q;
                                    q = $3->isType;
                                    if ( p != q ) { 
                                        yyerror("Type mismatch\n");
                                        exit(1);
                                    }
                                    $$ = ASTCreateNode(EXPR); /* creates EXPR node */
                                    $$->s1 = $1; /* sets s1 to term */
                                    $$->s2 = $3; /* sets s2 to factor */
                                    $$->sysType = $2; /* sets type according to multop */ 
                                    $$->symbol = Insert( CreateTemp(), p, ISFUN_SCALER, level, 1, offset, NULL );
                                    $$->isType = p;
                                    if ( debugI ) Display();
                                    offset++;
                                   }
            ;
multop      :   '*'  { $$ = MULTOPER; /* returns type for each operator */ }  /* multop -> * | / | and | or */
            |   '/'  { $$ = DIVDOPER; }
            |   AND  { $$ = ANDOPER; }
            |   OR   { $$ = OROPER; }
            ;
factor      :   '(' expression ')' { $$ = $2; /* passes node form expression */ } /* factor -> ( expression ) | NUM | var | call | true | false | not factor */ 
            |   NUM { $$ = ASTCreateNode(NUMT); /* makes NUMT node and sets value to the number */
                      $$->sysType = INTTYPE;
                      $$->isType = INTTYPE;
                      $$->value = $1; 
                      }
            |   var { $$ = $1; /* passes node from var */ }
            |   call { $$ = $1; /* passes node from call */ }
            |   TRUE { $$ = ASTCreateNode(BOOLT); /* creates BOOLT node */
		               $$->sysType = BOOLEANTYPE;
		               $$->isType = BOOLEANTYPE;
                       $$->value = 1; /* sets value to 1 for ttrue */
                       }
            |   FALSE { $$ = ASTCreateNode(BOOLT); /* creates BOOT node */
		                $$->sysType = BOOLEANTYPE;
		                $$->isType = BOOLEANTYPE;
                        $$->value = 0; /* sets value to 0 for false */
                        }
            |   NOT factor { $$= ASTCreateNode(EXPR); /* creates EXPR node */
                             $$->s1 = $2; /* sets s1 to factor */
                             $$->sysType = BOOLEANTYPE; /* sets type to NOTT for not operator */
                             $$->symbol = Insert( CreateTemp(), BOOLEANTYPE, ISFUN_SCALER, level, 1, offset ,NULL );
                             $$->isType = $$->symbol->Type;
                             if ( debugI ) Display();
                             offset++;
                             }
            ;
call        :   ID '(' args ')' { 
                                    /* finds ID in symbol table */
                                    struct SymbTab *p = Search ( $1, level, 1 );
                                    /* error if not found */
                                    if ( p == NULL ) { 
                                        err = combineStrings("Name not found: ",$1);
                                        yyerror(err); 
                                        exit(1); 
                                    }
                                    /* error if ID is not a function */
                                    if ( p->IsAFunc != ISFUN_FUNCTION ) { 
                                        err = combineStrings( $1," Name used in wrong context");
                                        yyerror(err); 
                                        exit(1); 
                                    }
                                    /* get arugments and parameters into pointers to use for comparing */
                                    ASTnode *n = $3;
                                    ASTnode *para = p->fparms;
                                    
                                    if  ( para->sysType == NULLTYPE && n != NULL ) {
                                        err = combineStrings( $1, " Too many aruguments");
                                        yyerror(err); 
                                        exit(1); 
                                    }
                                    else if ( para->sysType != NULLTYPE ) {
                                        /* error if there are arguments when no parameters */
                                        if ( para == NULL && n != NULL ) { 
                                                err = combineStrings( $1, " Too many aruguments");
                                                yyerror(err); 
                                                exit(1); 
                                            
                                        }
                                        /* error if there are no arguments when there are parameter */
                                        if ( n == NULL && para != NULL ) { 
                                                err = combineStrings($1," Too few arugments");
                                                yyerror(err); 
                                                exit(1); 
                                            
                                        }
                                        /* loop to go through the arugment lis and parameter list */
                                        while ( n != NULL && para != NULL ) {
                                            /* if types do not amtch then error */
                                            if ( n->s1->isType != para->sysType ) {
                                                err = combineStrings("Invaild type of parameter: ",para->name );
                                                yyerror(err);
                                                exit(1);
                                            }
                                            /* if there are no more arguments, and still parameters, then error */
                                            if ( n->next != NULL && para->next == NULL ) {
                                                    err = combineStrings( $1, " Too many aruguments");
                                                    yyerror(err); 
                                                    exit(1); 
                                                }
                                            /* error if there are still parameter but no more arguments */
                                            if ( para->next != NULL && n->next == NULL ) { 
                                                    err = combineStrings($1, " Too few arugments");
                                                    yyerror(err); 
                                                    exit(1); 
                                                }
                                            n = n->next;
                                            para = para->next;	
                                        }

                                    }
                                    $$ = ASTCreateNode(CALLT); /* creates CALL node */
                                    $$->s1= $3; /* sets s1 to args */
                                    $$->name = $1; /* sets name to the ID */
                                    $$->sysType = p->Type;
                                    $$->symbol = p;
                                } /* call -> ID ( args ) */
            ;
args        :   /* empty */ { $$ = NULL; /* sets to NULL if no args */ } /* args -> arg-list | empty */
            |   argList { $$ = $1; /* passes node from argList */ } 
            ;
argList     :   expression  {     
                              $$ = ASTCreateNode(ARGLIST);
                              $$->s1 = $1;
                              $$->symbol = Insert( CreateTemp(), INTTYPE, ISFUN_SCALER, level, 1, offset, NULL );
                              offset++;
                              } /* arg-list -> expression { , expression } */
            |   expression ',' argList { $$ = ASTCreateNode(ARGLIST);
                                         $$->next = $3; /* chains argList together with next to expression's node */
                                         $$->s1 = $1; /* passes expression node */
                                         /* have temp store location for call */
                                         $$->symbol = Insert( CreateTemp(), INTTYPE, ISFUN_SCALER, level, 1, offset, NULL );
                                         offset++;
                                         } 
            ;
        
%%

int main ( int argc, char* argv[] )
{
    int i;
    // makes default name of file to NASMfile.asm if no name is given
    FILE *fp = NULL;
    char *fileBegin = "NASMfile";
    char *fileEnd = ".asm";
    char *fileName = NULL;
    // sets debug or sets new file name according to arugments
    for ( i = 0; i < argc; i++ ) {
        if ( strcmp(argv[i],"-d") == 0 ) {
            debugEMIT = 1;
        }
        if ( strcmp(argv[i],"-o") == 0 ) { 
            if ( argv[i+1] == NULL ) {
                fprintf(stderr,"No name for file\n"); 
                exit(1);
            }
            fileBegin = argv[i+1];
        }
    }
    // combines strings for file name
    fileName = combineStrings(fileBegin, fileEnd);
    yyparse();
    if ( debugEMIT ) ASTprint(0, program);
    // creates file
    fp = fopen( fileName, "w" );
    
    if ( fp != NULL ) {
        // puts header for all asm files
        fprintf(fp, "%s", "%include \"io64.inc\"\n");
        // emits globel variables
        emitGLOBEL(program, fp);
        fprintf(fp,"\n");
        fprintf(fp, "section .data\n\n");
        // emits all strings used in program 
        emitSTRINGS( program, fp );
        emit(fp,"","","");
        fprintf(fp,"section .text\n");
        emit(fp,"","global main","");
        // emit program
        emitAST(program,fp);
    }
    else {
        fprintf(stderr, "No output file\n"); 
    }
    //printf("Final table\n");
    //Display();
    //ASTprint(0,program);

    printf("Done Compiling!");
}

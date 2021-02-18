/*   Abstract syntax tree code

     This code is used to define an AST node, 
    routine for printing out the AST
    defining an enumerated type so we can figure out what we need to
    do with this.  The ENUM is basically going to be every non-terminal
    and terminal in our language.

    Shaun Cooper February 2015

*/

/*
 * Jeffrey Lansford
 * Lab 7
 * Apirl 9, 2019
 * AST code that defines the AST node and defines how to print each node
 * 
 */

#include<stdio.h>
#include<malloc.h>
#include "ast.h" 
#include "symtable.h"
int debug = 0; 

// initializes all of ASTnode data
ASTnode *ASTCreateNode(enum ASTtype mytype ) {
    
    
    // creates a pointer p and allocates memory
    ASTnode *p;
    p = (ASTnode *)malloc(sizeof(ASTnode));
    if(debug) printf("Creating AST Node\n");
    // sets type to parameter
    p->type=mytype;
    // sets name, s1, s2, and next to NULL  
    p->name = NULL;
    p->next = NULL;
    p->s1 = NULL;
    p->s2 = NULL;
    // sets value to 0
    p->value = 0;
    p->symbol = NULL;
    return(p);
}

// function used to add spacing
void printspace ( int level ) {
    int t;
    for( int t= level; t > 1; t-- ) { printf("    "); }   
}

// function to print type of the node p
void printType ( ASTnode *p ) {
    switch(p->sysType) {
        case INTTYPE:
            printf("INT %s", p->name);
            break;
        case VOIDTYPE:
            printf("VOID %s" , p->name);
            break;
        case BOOLEANTYPE:
            printf("BOOLEAN %s", p->name);
            break;
        default:
            printf("NULL");
            break;
    }
}

// prints each different type of node with all of their payload 
void ASTprint(int level,ASTnode *p) {
    
    // creates variable for for loops
    int i;
    // leaves if node is NULL
    if (p == NULL) { return; }
    int t;
    // puts spacing according to level, excludes type STMT since nothing gets printed out
    if ( p->type != SELESTMT ) {
        printspace(level);
    }
    // switch statemnt for all types of nodes
    switch(p->type){
        
        
        case VARDEC : 
            // prints different types according to VARDEC's sysType
            printf("VARIABLE ");
            printType(p);
            // prints name of VARDEC
            //printf(" %s", p->name );
            // if VARDEC is a array, then print size
            if (p->value > 0) printf("[%d]\n",p->value);
            else printf("\n");
            // goes to the chained VARDECs
            ASTprint(level, p->s1 );
            break;
        
        case FUNDEC:
            // prints the type and name of FUNDEC
            printf("FUNCTION ");
            printType(p);
            printf("\n(\n");
            // goes in FUNDEC's parameters
            ASTprint(level+1, p->s1);
            printf(")\n");
            // goes into FUNDEC's block statement, add 1 to level for indenation 
            ASTprint(level+1, p->s2);
            break;
        
        case PARAM:
            // prints VOID if no pararmeters
            if ( p->sysType == NULLTYPE) printf("VOID\n");
            // prints type of parameter and name
            else { 
                printf("PARAMETER ");
                printType(p);
                // prints brackets if it is an array 
                if ( p->value != 0 ) printf("[ ]\n");
                else printf("\n");
            }
            break;

        case BLOCK: 
            // prints block statement 
            printf("BLOCK STATEMENT\n");
            // goes into localDec
            ASTprint(level+1,p->s1);
            // goes into stateList
            ASTprint(level+1,p->s2);
            printspace(level);
            printf("END\n");
            break;
            
        case WRITET:
            // prints write statement
            printf("WRITE STATMENT\n");
            // goes ino WRITET expression 
            ASTprint(level+1, p->s1);
            break;
            
        case READT:
            // prits read statment
            printf("READ STATEMENT\n");
            // goes into var
            ASTprint(level+1, p->s1);
            break;
            
        case NUMT:
            // prints Number from the NUMT node
            printf("NUMBER with value %d\n",p->value);
            break;
            
        case BOOLT: 
            // prints BOOLEAN and if it is true or false
            printf("BOOLEAN %s\n", (p->value== 1 ? "TRUE" : "FALSE")); 
            break;
            
        case IDENT:
            // prints name
            printf("IDENTIFIER %s\n", p->name);
            // prints array reference if it is an array
            if ( p->value != 0 ) { 
                printspace(level+1);
                printf("ARRAY REFERENCE [\n"); 
                ASTprint(level+2,p->s1); 
                printspace(level+1);
                printf("] end of array\n"); 
            } 
            break;
            
        case CALLT:
            // prints name
            printf( "CALL IDENTIFIER %s ( \n", p->name);
            // prints VOID if no arguments
            if ( p->s1 == NULL ) { 
                printspace(level+1);
                printf("VOID\n"); 
            }
            // goes into arguments
            ASTprint(level +1, p->s1);
            printspace(level);
            printf(")\n");
            break;
            
        case RETURNT:
	    if ( p->s1 == NULL ) { printf("RETURN\n"); break; }
            // prints return and goes into s1 for expression 
            printf("RETURN (\n");
            ASTprint(level+1, p->s1);
	    printspace(level);
	    printf(")\n");
            break;
            
        case SELESTMT:
            // goes to IFTHEN
            ASTprint(level,p->s1);
            // goes into ElSESTMT
            ASTprint(level,p->s2);
            break;
            
        case IFTHEN:
            // prints expression
            printf("IF\n");
            ASTprint(level+1,p->s1);
            // then prints statement
            printspace(level);
            printf("THEN\n");
            ASTprint(level+1,p->s2);
            break;
            
        case ELSESTMT:
            // prints statement for else
            printf("ELSE\n");
            ASTprint(level+1,p->s1);
            break;
            
        case WHILEDO:
            // prints expression 
            printf("WHILE\n");
            ASTprint(level+1, p->s1);
            // then prints statement
            printspace(level);
            printf("DO\n");
            ASTprint(level+1, p->s2);
            break;
            
        case ASSIGN:
            // prints variable 
            printf("ASSGINMENT\n");
            ASTprint(level+1, p->s1);
            // prints expression
            printspace(level+1);
            printf("TO\n");
            ASTprint(level+1, p->s2);
            break;
            
        case EXPR:
            
            // prints all operators 
            switch (p->sysType) {
                
                case LET:
                    printf("LESS THAN OR EQUAL\n");
                    break;
                
                case GET:
                    printf("GREATER THAN OR EQUAL\n");
                    break;
                    
                case EET: 
                    printf("GREATER THAN OR EQUAL\n");
                    break;
                    
                case LT:
                    printf("EQUAL\n");
                    break;
                    
                case GT:
                    printf("LESS THAN\n");
                    break;
                    
                case NET:
                    printf("NOT EQUAL\n");
                    break;
                    
                case ADDOPER:
                    printf("OPERATOR +\n");
                    break;
                    
                case SUBOPER:
                    printf("OPERATOR -\n");
                    break;
                    
                case MULTOPER:
                    printf("OPERATOR *\n");
                    break;
                    
                case DIVDOPER:
                    printf("OPERATOR /\n");
                    break;
                    
                case ANDOPER:
                    printf("OPERATOR AND\n");
                    break;
                    
                case OROPER:
                    printf("OPERATOR OR\n");
                    break;
                
                case NOTT:
                    printf("NOT\n");
                    break;
                
                case NULLTYPE:
                    printf("\b");
                    break;
                    
                default :
                    printf("UNKNOWN TYPE\n");
            }
            // goes into s1 and s2 for EXPR, different for different operators
            ASTprint(level+1, p->s1);
            ASTprint(level+1, p->s2);
            break;
            
        case ARGLIST:
            printf("ARGUMENTS\n");
            // prints out the expressions associated with the argslist
            ASTprint(level+1,p->s1);
            break;
                    
        // default for unknown types
        default:
                printf("unknown type in ASTprint\n");
                break;
    }
    // goes to next of p 
    ASTprint(level,p->next);
}






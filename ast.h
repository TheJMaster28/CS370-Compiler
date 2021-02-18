/*   Abstract syntax tree code


 Header file   
 Shaun Cooper January 2019

*/
/* 
 * Jeffrey Lansford
 * Lab 7
 * Apirl 9, 2019
 * header file for ast.c Defines enum ASTtype and SYSTYMTYPES, functions ASTCreateNode and ASTprint, and the ASTnodetype structure. 
 */ 
#include<stdio.h>
#include<malloc.h>
#ifndef AST_H
#define AST_H
static int mydebug;

/* define the enumerated types for the AST.  THis is used to tell us what 
sort of production rule we came across */
// enumerated types for nodes of the AST
enum ASTtype {
    VARDEC,
    FUNDEC,
    PARAM,
    BLOCK,
    WRITET,
    READT,
    NUMT,
    BOOLT,
    IDENT,
    EXPR,
    CALLT,
    RETURNT,
    SELESTMT,
    IFTHEN,
    ELSESTMT,
    WHILEDO,
    ASSIGN,
    ARGLIST
};
// enumerated types for differnt operators and types
enum SYSTEMTYPES {
    INTTYPE,
    VOIDTYPE,
    BOOLEANTYPE,
    NULLTYPE,
    LET,
    GET,
    EET,
    LT,
    GT,
    NET,
    ADDOPER,
    SUBOPER,
    MULTOPER,
    DIVDOPER,
    ANDOPER,
    OROPER,
    NOTT,
};

// stucture of the AST node
typedef struct ASTnodetype {
    enum ASTtype type;
    enum SYSTEMTYPES sysType;
    char *name;
    int value;
    struct ASTnodetype *next, *s1, *s2;
    struct SymbTab *symbol;
    // type checking for expressions
    enum SYSTEMTYPES isType;
} ASTnode;

#include "symtable.h"

/* uses malloc to create an ASTnode and passes back the heap address of the newley created node */
ASTnode *ASTCreateNode(enum ASTtype mytype);

// intializes program for YACC and ASTprint
ASTnode *program;

/*  Print out the abstract syntax tree */
void ASTprint(int level,ASTnode *p);

#endif // of AST_H

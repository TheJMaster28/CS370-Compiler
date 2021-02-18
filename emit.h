#include "ast.h"

#ifndef EMIT_H
#define EMIT_H
#define WSIZE 8

int debugEMIT;
void emit ( FILE *fp, char *label, char *cmd, char* comm );
void emitAST( ASTnode* p, FILE *fp ) ;
void emitGLOBEL ( ASTnode *p , FILE *fp );
void emitSTRINGS ( ASTnode *p, FILE *fp );
void emit_functionHeader ( ASTnode *p, FILE *fp );
void emit_functionEnder ( ASTnode *p, FILE *fp, int flag);
void emit_handleReturn( ASTnode *p, FILE *fp);  
void emit_ident(ASTnode *p, FILE *fp );
void emit_expr( ASTnode *p, FILE *fp );
void emit_call( ASTnode *p, FILE *fp);
void emitAST(ASTnode *p, FILE *fp );
#endif 

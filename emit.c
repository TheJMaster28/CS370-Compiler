
/*
 * Jeffrey Lansford
 * Lab 9
 * Apirl 14, 2019
 * EMITAST program
 * emits NASM code according to the AST tree structure of the program 
 */

#include <string.h>
#include <math.h>
#include "emit.h"
int LTEMP =  0;
int LTEMP_W = 0;

/**
 * PRE: P is a ASTNode
 * gets function name of the return statment is in for function ending
 * goes through all statments in main function block
 */
void getFunctionName ( char *name, ASTnode *p, FILE *fp ) {
    if ( p == NULL ) return;
    // sets Return type node's name to the function's name for functionEnder() 
    if ( p->type == RETURNT )
        p->name = strdup(name);
    getFunctionName(name, p->s1, fp);
    getFunctionName(name, p->s2, fp);
    getFunctionName(name, p->next, fp);
    
}
/*
 * creates strings with incremeting labels for strings and labels in NASM code
 */
char * CreateTEMPLab() {
    char hold[100];
    char *s;
    sprintf(hold,"_L%d", LTEMP++);
    s=strdup(hold);
    return (s);
}
/*
 * provides formating with emiting to assembly file
 */
void emit ( FILE *fp, char *label, char *cmd, char* comm ) {
    fprintf(fp, "%s\t%s\t\t%s\n", label, cmd, comm);
}
/*
 * PRE: P can be any ASTnode
 * emits globel variable to assembly file by search through AST
 */
void emitGLOBEL( ASTnode *p, FILE *fp ) {
    
    // recurrivly goes through next connected nodes and writes common globel variable into NASM file
    if ( p == NULL ) return;
    char s[100];
    int t;
    if ( p->type == VARDEC ) {
        if ( debugEMIT ) 
            printf("%s writing to asm\n", p->name );
        // VARDEC is an array and value needs to be total size of array
        if ( p->value != 0 ) 
            t = p->value * WSIZE; 
        // sets to WSIZE for scalers
        else 
            t = WSIZE;
        sprintf(s,"common %s %d", p->name, t );
        emit(fp,"", s,"; globel variable" );
        emitGLOBEL(p->s1, fp );
    }
    emitGLOBEL(p->next, fp );
}

/*
 * PRE: p can be any ASTnode
 * emits strings by going through AST 
 */
void emitSTRINGS ( ASTnode *p, FILE *fp ) {
    // recurrivly goes through the entire AST structure to find STRINGS 
    if ( p == NULL ) return;
    
    if ( p->type == WRITET && p->name != NULL ) {
            if ( debugEMIT ) printf("writing String %s\n", p->name);
            // creates label and string to emit to NASM file
            char *s = CreateTEMPLab();
            strcat(s, ":");
            char str[100];
            sprintf(str,"db %s, 0", p->name);
            emit( fp, s, str, "; global string");
        }
        emitSTRINGS( p->s1, fp);
        emitSTRINGS( p->s2, fp);
        emitSTRINGS( p->next, fp);
}

/*
 * PRE: p is a FUNDEC ASTnode
 * emits requiresents for headers of all functions 
 */
void emit_functionHeader ( ASTnode *p, FILE *fp ) {
    if ( debugEMIT ) printf("writng FUNC header\n");
    char s[100];
    sprintf(s, "%s:", p->name);
    emit(fp,"","",""); // blank line
    emit(fp,"","","");
    emit(fp, s, "", ";Start of functiuon");
    // must set base pointer to stack pointer for main only
    if ( strcmp(p->name , "main" ) == 0 ) 
        emit(fp,"","mov rbp, rsp",";special RSP to RSB for main only");
    // store base pointer and stack pointer into Activation record of function
    emit(fp,"","mov r8, rsp",";FUNC header RSP har to be at most RBP");
    sprintf(s,"add r8, -%d",p->symbol->offset * WSIZE );
    emit(fp,"",s,";adjust stack pointer oractivatio record");
    emit(fp,"","mov [r8], rbp",";Storing old BP");
    sprintf(s,"mov [ r8 + %d ], rsp",WSIZE);
    emit(fp,"",s,";storing old SP");
    // function's BP needs to be at SP, but not for main 
    if ( strcmp(p->name , "main") != 0 )
        emit(fp,"","mov rbp, rsp",";FUNC header has to be at most RBP");
    emit(fp,"","mov rsp, r8",";set new SP");
    emit(fp,"","",""); //blanK LINE
    
}

/* 
 * PRE: p is a RETURN or FUNDEC AStnode
 * emits requirments for ending functions
 */
void emit_functionEnder ( ASTnode *p, FILE *fp, int flag ) {
    if ( debugEMIT ) printf("writing FUNC ending\n");
    char s[100];
    emit(fp,"","","");
    emit(fp,"", "", ";End of function");
    // restore BP and SP
    emit(fp,"","mov rbp, [rsp]",";Func end restore BP");
    sprintf(s, "mov rsp,[ rsp + %d ]", WSIZE);
    emit(fp,"",s,";FUNC restoer old SP");
    // requirement for main 
    if ( strcmp( p->name, "main") == 0 )
        emit(fp,"","mov rsp, rbp",";stack and BP need to be same on exit for main");
    // if there is no return set rax to 0 
    if ( flag ) emit(fp,"","xor rax, rax",";no value specificate, then it is 0");
    emit(fp,"","ret","");
    
}

/*
 * handles Return for the two different types of return node
 * PRECONDISTION: p must be a RETURNT 
 */
void emit_handleReturn( ASTnode *p, FILE *fp ) {
    
    if ( debugEMIT ) printf("handling return\n");
    char s[100];    
    // calcauate the expr of return
    if ( p->s1 != NULL ) {
        switch (p->s1->type) {
            case BOOLT:
            case NUMT:
                // put value into RAX
                sprintf(s,"mov rax, %d", p->s1->value);
                emit(fp,"",s,";ARG of CALL is a NUM or BOOL");
                break;

            case IDENT:
                // put value of IDENT from its mem location into RAX 
                emit_ident(p->s1, fp);
                emit(fp,"","mov rax, [rax]",";dereference RAX");
                break;

            case EXPR:
                // put value of EXPR from its temp location into RAX
                emit_expr(p->s1, fp);
                sprintf(s,"mov rax, [ rsp + %d ]", p->s1->symbol->offset * WSIZE );
                emit(fp,"",s,";get EXPR value for CALL");
                break;
                
            case CALLT:
                // return value already in RAX
                emit_call(p->s1, fp);
                break;

            default: 
                printf("UNKNOWN TYPE\n");
                break;
            }
        }
    // do function ending
    if ( p->s1 == NULL ) 
        emit_functionEnder(p,fp,1);
    else
        emit_functionEnder(p,fp,0);
    
}

/*
 * Precondistion: p is a IDENT
 * Postcondistion: RAX will be the memory address where IDENT is stored
 * emits NASM code to get ident's mem location 
 */
void emit_ident(ASTnode *p, FILE *fp ) {
    if ( debugEMIT ) printf("writng IDENT\n");
    char s[100];
    
    // calcualte array's expr
    if ( p->symbol->IsAFunc == ISFUN_ARRAY ) {
            switch (p->s1->type) {
                case NUMT:
                    // put value into RDX
                    sprintf(s,"mov rdx, %d", p->s1->value );
                    emit(fp,"",s,";puts value into result");
                    break;
                    
                case IDENT:
                    // put value of IDENT in mem location into RDX
                    emit_ident(p->s1, fp);
                    emit(fp,"","mov rdx, [rax]",";puts memory address into result");
                    break;
                    
                case EXPR:
                    // get EXPR value and put into RDX
                    emit_expr(p->s1, fp);
                    sprintf(s, "mov rdx, [ rsp + %d ]", p->s1->symbol->offset * WSIZE );
                    emit(fp,"",s,";get value of EXPR of ARRAY");
                    
                    break;
                    
                case CALLT:
                    // put return value into RDX
                    emit_call(p->s1, fp);
                    emit(fp,"","mov rdx, rax",";move CALL return value into RDX");
                    break;     
            }
        // times by WSIZE
        int x = (int) ( log10(WSIZE) / log10(2) );
        sprintf(s,"shl rdx, %d", x );
        emit(fp,"",s,";times by WSIZE");
    }
    // get value if it is a globel variable
    if ( p->symbol->level == 0 ) {
        sprintf(s,"mov rax, %s", p->name);
        emit(fp,"",s,";gets globel variabel value");
    }
    // get offset 
    else {    
        sprintf(s, "mov rax, %d", p->symbol->offset * WSIZE);
        emit(fp,"",s,";get ident offset");
        emit(fp,"","add rax, rsp",";add to stack pointer");
    }
    // add expr to offset for array element offset
    if ( p->s1 != NULL ) 
        emit(fp,"","add rax, rdx",";add offset");
        
}

/*
 * Precondition: p is an EXPR
 * Postcondistion: result is in stored in p->symbol->offset
 * emits NASM code to calcaluate expr
 */
void emit_expr( ASTnode *p, FILE *fp ) {
    if ( debugEMIT ) printf("writng EXPR\n");
    char s[100];
    if ( p == NULL ) return;
    // LHS
    // puts s1 into rax
    switch ( p->s1->type ) {
        case BOOLT: // gets value of the node, boolean and num store value at the same place
        case NUMT:
            sprintf(s,"mov rax, %d", p->s1->value );
            emit(fp,"",s,";puts value into result");
            break;
            
        case IDENT: // gets IDENT vale in its memory location
            emit_ident(p->s1, fp );
            emit(fp,"","mov rax, [rax]",";puts memory address into result");
            break;
            
        case EXPR:  // recurrivly go into s1 to get temp value
            emit_expr(p->s1, fp);
            sprintf(s,"mov rax, [ rsp + %d ]", p->s1->symbol->offset * WSIZE);
            emit(fp,"",s,";gets temp address for result");
            break;
            
        case CALLT:  // goto call function and rax has value
            emit_call(p->s1, fp);
            break;
            
        default: 
            printf("SYMBOL NOT RECOGIZE\n");
            break;
    }
    // put rax into temp saving it later since other function could mess with rax
    sprintf(s,"mov [ rsp + %d ], rax", p->symbol->offset * WSIZE);
    emit(fp,"",s,";put result for LHS into temp"); 
    
    // for NOT operatation since s2 is null
    if ( p->s2 != NULL ) { 
        
    // RHS
        // rbx has s2
        switch ( p->s2->type ) {
            case BOOLT: // gets value of the node, boolean and num store value at the same place
            case NUMT:
                sprintf(s,"mov rbx, %d", p->s2->value );
                emit(fp,"",s,";puts value into result");
                break;
                
            case IDENT: // gets IDENT vale in its memory location
                emit_ident(p->s2, fp );
                emit(fp,"","mov rbx, [rax]",";puts memory address into result");
                break;
                
            case EXPR:  // recurrivly go into s1 to get temp value
                emit_expr(p->s2, fp);
                sprintf(s,"mov rbx, [ rsp + %d ] ", p->s2->symbol->offset * WSIZE);
                emit(fp,"",s,";gets temp address for result");
                break;
                
            case CALLT:
                emit_call(p->s2, fp);
                emit(fp,"","mov rbx, rax",";get CALL value into RHS");
                break;
                
            default: 
                printf("SYMBOL NOT RECOGIZE\n");
                break;
        }
    }
    // gets back stored LHS value
    sprintf(s, "mov rax, [ rsp + %d ]", p->symbol->offset * WSIZE);
    emit(fp,"",s,";move stored LHS back into rax");
    // performs operatation based on the node type
    switch (p->sysType ) {
        case ADDOPER: // +
            emit(fp,"","add rax, rbx",";add LHS and RHS");
            break;
        
        case SUBOPER: // -
            emit(fp,"","sub rax, rbx",";subtact LHS and RHS");
            break;
            
        case MULTOPER: // *
            emit(fp,"","imul rax, rbx",";multply LHS and RHS");
            break;
            
        case DIVDOPER:  // /
            // do some push ups for getting rid of reminder
            emit(fp,"","xor rdx, rdx",";set RDX to zero for reminder");
            emit(fp,"","idiv rbx",";divde LHS and RHS");
            break;
            
        case ANDOPER:  // AND
            // get if rax and rbx is true or false, then bitwise-and them to get correct results
            emit(fp,"","cmp rax, 0",";check if RAX is false");
            emit(fp,"","setne al",";set low bytes to 1 or 0");
            emit(fp,"","mov rcx, 1",";set rcx to filter RAX");
            emit(fp,"","and rax, rcx",";filter RAX");
            emit(fp,"","cmp rbx, 0",";check if RVX is false");
            emit(fp,"","setne bl",";set low btes to 0 or 1");
            emit(fp,"","and rbx, rcx",";filter RBX");
            emit(fp,"","and rax, rbx",";do peration AND");
            break;
            
        case OROPER:  // OR
            emit(fp,"","or rax, rbx",";or LHS and RHS");
            break;
        
            // mostly the same operation for boolean operations 
        case LET: // <=
            emit(fp,"","cmp rax, rbx",";EXPR Less than or equal");
            // set lower byte of rax if cmp was less or equal
            emit(fp,"","setle al",";set to Less than or equal");
            // fiter rax to get entire register to 0 or 1
            emit(fp,"","mov rbx, 1",";set rbx to filter rax");
            emit(fp,"","and rax, rbx",";filter rax");
            break;
            
        case GET:  // >=
            emit(fp,"","cmp rax, rbx",";EXPR Greater than or equal");
            // set lower byte of rax if cmp was Greater or equal
            emit(fp,"","setge al",";set to Greater than or equal");
            emit(fp,"","mov rbx, 1",";set rbx to filter rax");
            emit(fp,"","and rax, rbx",";filter rax");
            break;
            
        case EET:  // ==
            emit(fp,"","cmp rax, rbx",";EXPR Equal");
            // set lower byte of rax if cmp was equal
            emit(fp,"","sete al",";set to Equal");
            emit(fp,"","mov rbx, 1",";set rbx to filter rax");
            emit(fp,"","and rax, rbx",";filter rax");
            break;
            
        case LT:  // <
            emit(fp,"","cmp rax, rbx",";EXPR Less than");
            // set lower byte of rax if cmp was Less
            emit(fp,"","setl al",";set to Less than");
            emit(fp,"","mov rbx, 1",";set rbx to filter rax");
            emit(fp,"","and rax, rbx",";filter rax");
            break;
            
        case GT:  // >
            emit(fp,"","cmp rax, rbx",";EXPR Greater than");
            // set lower byte of rax if cmp was Greater
            emit(fp,"","setg al",";set to Greater than");
            emit(fp,"","mov rbx, 1",";set rbx to filter rax");
            emit(fp,"","and rax, rbx",";filter rax");
            break;
            
        case NET: // !=
            emit(fp,"","cmp rax, rbx",";EXPR Not equal");
            // set lower byte of rax if cmp was not equal
            emit(fp,"","setne al",";set to Not equal");
            emit(fp,"","mov rbx, 1",";set rbx to filter rax");
            emit(fp,"","and rax, rbx",";filter rax");
            break;
            
        case BOOLEANTYPE: // NOT 
            // cmp with 0 for NOT 
            emit(fp,"","cmp rax, 0",";compare to zero for NOT");
            // set lower byte of rax if cmp is equal to 0
            emit(fp,"","sete al",";set to equal for NOT");
            emit(fp,"","mov rbx, 1",";load 1 to rbx for filtering");
            emit(fp,"","and rax, rbx",";filter rax");
            break;
            
        default:
            printf("OPERAOTR NOT REGONISED\n");
            break;
    }
    
    // store result into temp memory location
    sprintf(s,"mov [ rsp + %d ], rax", p->symbol->offset * WSIZE );
    emit(fp,"",s,";store rax back to expr location");
}

/**
 * PRECONDISTION: p is a CALL node
 * POSTCONDISTION: rax will have result
 * emits NASM code to call functions 
 */
void emit_call( ASTnode *p, FILE *fp ) { 
    if ( debugEMIT ) printf("writng CALL\n");
    char s[100];

    // gets the ARGLIST of the CALL node for going through next connected arguments
    ASTnode *q = p->s1;
    ASTnode *parm = p->symbol->fparms;
    int offsetT = 0;
    
    // do call parameters first for accounting for Activation record of each call 
    while ( q != NULL ) {
        if ( q->s1->type == CALLT ) {
            emit_call(q->s1, fp);
            sprintf(s,"mov [ rsp + %d ], rax", q->symbol->offset * WSIZE);
            emit(fp,"",s,";do CALL then move value into stored place");
        }
        q = q->next;
    }
    
    q = p->s1;
    parm = p->symbol->fparms;
    // loop to go through arglist tp put parameters into future Activation record
    while ( q != NULL ) {
        // calcualte arglist's expr
        switch (q->s1->type) {
            case BOOLT:
            case NUMT:
                // set rax to value of NUM
                sprintf(s,"mov rax, %d", q->s1->value);
                emit(fp,"",s,";ARG of CALL is a NUM or BOOL");
                break;

            case IDENT:
                // get mem location of ident and dereference in rax
                emit_ident(q->s1, fp);
                emit(fp,"","mov rax, [rax]",";dereference RAX");
                break;

            case EXPR:
                // evaluate expr then get temp vale and stick in rax
                emit_expr(q->s1, fp);
                sprintf(s,"mov rax, [ rsp + %d ]", q->s1->symbol->offset * WSIZE );
                emit(fp,"",s,";get EXPR value for CALL");
                break;
            
            case CALLT:
                // get back stored value of the call 
                sprintf(s,"mov rax, [ rsp + %d ]", q->symbol->offset * WSIZE);
                emit(fp,"",s,";get back value from calls");
                break;

            default: 
                printf("UNKNOWN TYPE\n");
                break;
            
        }  
        
        // put value into future activation record of called function
        emit(fp,"","mov r8, rsp",";get RSP");
        sprintf(s,"sub r8, %d", (p->symbol->offset + 1 ) * WSIZE );
        emit(fp,"",s,";substract SP from FUN offset");
        sprintf(s,"mov [r8 + %d ], rax", ( parm->symbol->offset ) * WSIZE );
        emit(fp,"",s,";move value PARAM offset"); 
        q = q->next;
        parm = parm->next;
        
    }
    
    // emit call of function 
    sprintf(s,"call %s", p->symbol->name );
    emit(fp,"",s,";call FUNCTION");
    emit(fp,"","","");
    
}
/*
 * PRE: p is a WRITE ASTnode
 * emits NASM code to write to output
 */ 
void emit_write( ASTnode *p, FILE *fp ) {
    if ( debugEMIT ) printf("writng WRITE\n");
    char s[100];
    // wries globel String
    if ( p->name != NULL ) {
        sprintf(s, "PRINT_STRING _L%d", LTEMP_W++ );
        emit(fp,"",s,";print string");
        emit(fp,"","NEWLINE", ";standrd newline");
    }
    // not a String        
    else { 
    
        switch (p->s1->type) {
            case BOOLT:  // puts node's value into rsi 
            case NUMT:
                sprintf(s,"mov rsi, %d", p->s1->value);
                emit(fp, "", s, ";move value into register");
                break;
                    
            case IDENT:
                emit_ident(p->s1, fp); // value of IDENT in rax 
                // dereference for writing
                emit(fp,"","mov rsi, [rax]",";put memory address into rsi for printing");
                break;
                        
            case EXPR:  
                emit_expr(p->s1, fp); // value of EXPR in temp 
                sprintf(s,"mov rsi, [ rsp + %d ]", p->s1->symbol->offset * WSIZE );
                emit(fp,"",s,";set result to rsi");
                break;
                        
            case CALLT: // rax has value of returned call function
                emit_call(p->s1, fp);
                emit(fp,"","mov rsi, rax",";put value of call into RSI");
                break;
                        
            default: 
                printf("ERROR TYPE NOT RECOGIZED\n"); 
                break;
        }
        // write rsi to output
        sprintf(s, "PRINT_DEC %d, rsi", WSIZE);
        emit(fp,"",s,";print to output");
        emit(fp,"","NEWLINE","");
    }
    emit(fp,"","","");
}
/*
 * PRE: p is a READ ASTnode
 * emits NASM code to read form input
 */
void emit_read( ASTnode *p, FILE *fp ) {
    if ( debugEMIT ) printf("writng READ\n");
    char s[100];
    // gets IDENT 
    emit_ident(p->s1, fp); 
    // puts input into memory of IDENT
    sprintf(s, "GET_DEC %d, [rax]", WSIZE);
    emit(fp,"",s,";Read in var");
    emit(fp,"","","");
}

void emit_if ( ASTnode *p, FILE *fp ) {
    if ( debugEMIT ) printf("writng IF statement\n");
    char s[100];
    // generate labels
    char *t = CreateTEMPLab();
    char *r = CreateTEMPLab();
    // grab expression value
    switch (p->s1->s1->type) {
        case BOOLT:  
        case NUMT:
            // puts node's value into rsi 
            sprintf(s,"mov rsi, %d", p->s1->s1->value);
            emit(fp, "", s, ";move value into register");
            break;
                    
        case IDENT:
            // value of IDENT in rax 
            emit_ident(p->s1->s1, fp); 
            // dereference for writing
            emit(fp,"","mov rsi, [rax]",";put memory address into rsi for printing");
            break;
                        
       case EXPR:  
            // value of EXPR in temp
            emit_expr(p->s1->s1, fp); 
            // get value in temp 
            sprintf(s,"mov rsi, [ rsp + %d ]", p->s1->s1->symbol->offset * WSIZE );
            emit(fp,"",s,";set result to rsi");
            break;
                        
       case CALLT:
            // do call than move return value into RSI
            emit_call(p->s1->s1, fp);
            emit(fp,"","mov rsi, rax",";move CALL return value into RSI");
            break;
                        
       default: 
            printf("ERROR TYPE NOT RECOGIZED\n"); 
            break;
    }
    // compare with zero
    emit(fp,"","cmp rsi, 0","; compare to zero for evaluation of IF");
    // make jmp label to else
    sprintf(s, "je %s", t);
    emit(fp,"",s,";jump to ELSE");  
    
    // write postive statemt
    emit(fp,"","",";Positive Stmt");
    emitAST(p->s1->s2, fp);
    sprintf(s,"jmp %s", r);
    emit(fp,"",s,";jump out of IF");
    
    // write negtive statement
    sprintf(s,"%s:", t);
    emit(fp,s,"",";begin ELSE");
    if ( p->s2 != NULL ) 
        emitAST(p->s2->s1, fp );
    sprintf(s,"%s:", r);
    emit(fp,s,"",";end of IF");
    emit(fp,"","","");
}

/*
 * PRE: p is a WHILE ASTnode 
 * emits NASM code form of a while loop
 */
void emit_while ( ASTnode *p, FILE *fp ) {
    if ( debugEMIT ) printf("writng WHILE\n");
    char s[100];
    char *t = CreateTEMPLab();
    char *r = CreateTEMPLab();
    sprintf(s,"%s:", t);
    emit(fp,s,"",";start of WHILE");
    
    // calcualte expr of while loop 
    switch ( p->s1->type) {
        
        case BOOLT:
        case NUMT:
            // put value into rsi 
            sprintf(s,"mov rsi, %d", p->s1->value);
            emit(fp, "", s, ";move value into register");
            break;
        
        case IDENT:
            emit_ident(p->s1, fp); // value of IDENT in rax 
            // dereference for writing
            emit(fp,"","mov rsi, [rax]",";put memory address into rsi for printing");
            break;
        
        case EXPR:
            emit_expr(p->s1, fp); // value of EXPR in temp 
            sprintf(s,"mov rsi, [ rsp + %d ]", p->s1->symbol->offset * WSIZE );
            emit(fp,"",s,";set result to rsi");
            break;
        
        case CALLT:
            // put return value into rsi 
            emit_call(p->s1, fp);
            emit(fp,"","mov rsi, rax",";put value into RSI");
            break;
    }
    // check if expr evaluated to false
    emit(fp,"","cmp rsi, 0",";compare to Zero WHILE");
    // then jump out if it is false
    sprintf(s,"je %s", r);
    emit(fp,"",s,";get out of while of condistion is no longer true");
    // do body of loop
    emit(fp,"","",";body of loop");
    emitAST(p->s2, fp);
    // jump back to condistion
    sprintf(s, "jmp %s", t);
    emit(fp,"",s,";goto condistion");
    sprintf(s,"%s:", r);
    emit(fp,s,"",";end of WHILE"); 
    emit(fp,"","","");
}

/*
 * PRE: p is a ASSGIN ASTnode 
 * emits NASM code to change values of variable
 */
void emit_assgin ( ASTnode *p, FILE *fp ) { 
    if ( debugEMIT ) printf("writng ASSGIN\n");
    char s[100];
    // calcaluate right side of assgin 
    switch (p->s2->type) {
        case BOOLT:
        case NUMT:
            // put value into RBX
            sprintf(s,"mov rbx, %d", p->s2->value);
            emit(fp, "", s, ";move value into register");
            break;
                    
        case IDENT:
            // put derefernced mem location into RBX
            emit_ident(p->s2, fp);
            emit(fp,"","mov rbx, [ rax ]",";put value of IDENT in RBX");
            break;
                    
        case EXPR:
            // put value from temp location into RBX
            emit_expr(p->s2, fp);
            sprintf(s,"mov rbx, [ rsp + %d ]", p->s2->symbol->offset * WSIZE);
            emit(fp,"",s,";grab RHS value");
            break;
                    
        case CALLT:
            // put return value into RBX
            emit_call(p->s2, fp );
            emit(fp,"","mov rbx, rax",";move return value of CALL");
            break;
                    
        default:
            printf("UNKNOWN ASSGIN TYPE\n");
            break;
    }
    // stores RHS to symbol entry of ASSGIN ASTnode
    sprintf(s, "mov [rsp + %d], rbx", p->symbol->offset * WSIZE);
    emit(fp,"",s,";save rbx value");
    // get ident mem location
    emit_ident(p->s1, fp);
    // set RHS to value of ident
    sprintf(s,"mov rbx, [rsp + %d]", p->symbol->offset * WSIZE );
    emit (fp, "",s,";load back RBX");
    emit(fp,"","mov [ rax ], rbx",";store RBX into identfier");
    emit(fp,"","","");
}

/*
 * travels through entire AST tree to find different nodes and do functions according to node type
 */
void emitAST(ASTnode *p, FILE *fp ) {    
    // leaves if node is NULL
    if (p == NULL) { return; }
    char *t;
    char *r;
    char s[100];
    
    // switch statemnt for all types of nodes
    switch(p->type){
        
        case VARDEC : 
            break;
        
        case FUNDEC:
        {
            ASTnode *q = p->s2->s2;
            getFunctionName(p->name, q, fp);
            
            // write header
            emit_functionHeader( p, fp );
            // writes statements in block of function
            emitAST(p->s1, fp);
            emitAST(p->s2, fp);
            emit_functionEnder(p, fp,1);
            
            // write ender
        }   break;
        
        case PARAM:
            break;

        case BLOCK: 
            emitAST(p->s1, fp);
            emitAST(p->s2, fp);
            break;
            
        case WRITET:
            emit_write(p, fp);
            break;
            
        case READT:
            emit_read(p, fp );
            break;
            
        case NUMT:
            break;
            
        case BOOLT: 
            break;
            
        case IDENT:
            break;
            
        case CALLT:
            emit_call(p, fp);
            break;
            
        case RETURNT:
            emit_handleReturn(p, fp);
            break;
            
        case SELESTMT:
            emit_if(p, fp);
            break;
            
        case IFTHEN:
            break;
            
        case ELSESTMT:
            break;
            
        case WHILEDO: 
            emit_while(p,fp);
            break;
        
        case ASSIGN:
            emit_assgin(p, fp);
            break;
            
        case EXPR:
            
            break;
                    
        case ARGLIST:
            break;
                    
        // default for unknown types
        default:
            printf("unknown type in ASTprint\n");
            break;
    }
    // goes to next of p 
    emitAST(p->next, fp );
}

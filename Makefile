# Jeffrey Lansford
# Lab 9
# May 3, 2019 
# makefile to compile Yacc file with the lex file and ast.c and symtable.c 
all:
	yacc -d -v lab9.y 
	lex lab9.l
	gcc -g lex.yy.c y.tab.c symtable.c emit.c ast.c -o lab9

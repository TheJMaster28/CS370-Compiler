/*
Jeffrey Lansford
Lab 9
May 3, 2019
Lex program that creates token based on the languge C-Agol. Must have an input file of the Agol language to work properly. Outputs tokens for YACC to check for syntax. 
Tokens are the reserve words for the language, some boolean operators, IDs, numbers, and single character operators or other symbols that are used in the language.
Counts number of new lines for YACC to use for error output. 
*/

%{
#include"ast.h"
#include"y.tab.h"
int lineCount = 1;
int debugLEX = 0;
%}

%%
int         { if(debugLEX) fprintf(stderr,"return INT\n"); return (INT); /* all reserve words for the language */ } 
void        { if(debugLEX) fprintf(stderr,"return VOID\n"); return (VOID); } 
boolean     { if(debugLEX) fprintf(stderr,"return BOOLEAN\n"); return (BOOLEAN); } 
begin       { if(debugLEX) fprintf(stderr,"return BEGINNING\n"); return (BEGINNING); } 
end         { if(debugLEX) fprintf(stderr,"return END\n"); return (END); } 
of          { if(debugLEX) fprintf(stderr,"return OF\n"); return (OF); } 
while       { if(debugLEX) fprintf(stderr,"return WHILE\n"); return (WHILE); } 
do          { if(debugLEX) fprintf(stderr,"return DO\n"); return (DO); } 
read        { if(debugLEX) fprintf(stderr,"return READ\n"); return (READ); } 
return      { if(debugLEX) fprintf(stderr,"return RETURN\n"); return (RETURN); } 
write       { if(debugLEX) fprintf(stderr,"return WRITE\n"); return (WRITE); } 
and         { if(debugLEX) fprintf(stderr,"return AND\n"); return (AND); } 
or          { if(debugLEX) fprintf(stderr,"return OR\n"); return (OR); } 
true        { if(debugLEX) fprintf(stderr,"return TRUE\n"); return (TRUE); } 
false       { if(debugLEX) fprintf(stderr,"return FALSE\n"); return (FALSE); } 
not         { if(debugLEX) fprintf(stderr,"return NOT\n"); return (NOT); } 
else        { if(debugLEX) fprintf(stderr,"return ELSE\n"); return (ELSE); }
if          { if(debugLEX) fprintf(stderr,"return IF\n"); return (IF); }
then        { if(debugLEX) fprintf(stderr,"return THEN\n"); return (THEN); }
 
(>=)        { if(debugLEX) fprintf(stderr,"return >=\n"); return (GE); /* boolean operations in language */ }
(<=)        { if(debugLEX) fprintf(stderr,"return <=\n"); return (LE); }
(==)        { if(debugLEX) fprintf(stderr,"return ==\n"); return (EE); }
(!=)        { if(debugLEX) fprintf(stderr,"return !=\n"); return (NE); }

\".*\"      { if(debugLEX) fprintf(stderr, "String return]n"); yylval.string = strdup(yytext); return(STRING); }
[a-zA-Z][a-zA-Z0-9]*   { yylval.string = strdup(yytext); if(debugLEX) fprintf(stderr,"return ID: %s\n", yylval.string); return (ID); /* variables in language */ }
[0-9][0-9]*     { yylval.integer = atoi((const char *)yytext); if(debugLEX) fprintf(stderr,"return NUM\n"); return (NUM); /* to allow digits to be used in language */ }

[=<>!+\-*/();\[\],] { if(debugLEX) fprintf(stderr,"return token: %c\n", *yytext);return (*yytext); /* operators and other symbols used in language */ } 

\n      { if(debugLEX) fprintf(stderr,"catrige return\n");lineCount++; /* counts number of lines for errors(YACC) in lanuage */ } 
.       {; /* thorw out any other charaters */ } 

%%

int yywrap(void) {
return 1;
}

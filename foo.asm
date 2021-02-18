%include "io64.inc"
	common a 8		; globel variable
	common b 80		; globel variable
	common c 8		; globel variable

section .data

_L0:	db "write 1:", 0		; global string
_L1:	db "read a", 0		; global string
_L2:	db "write a + 1", 0		; global string
_L3:	db "c = a", 0		; global string
_L4:	db "all expr on c: c +2, c - 2, c * 2, c / 2", 0		; global string
_L5:	db "compleax assginment statement", 0		; global string
_L6:	db "simple if of a < 0", 0		; global string
_L7:	db "postive stmt", 0		; global string
_L8:	db "negitive stmt", 0		; global string
_L9:	db "simple if of a > 0", 0		; global string
_L10:	db "postive stmt", 0		; global string
_L11:	db "negitive stmt", 0		; global string
_L12:	db "simple if of a >=0", 0		; global string
_L13:	db "postive stmt", 0		; global string
_L14:	db "negitive stmt", 0		; global string
_L15:	db "simple if of a <= 0", 0		; global string
_L16:	db "postive stmt", 0		; global string
_L17:	db "negitive stmt", 0		; global string
_L18:	db "simple if of a == 0", 0		; global string
_L19:	db "postive stmt", 0		; global string
_L20:	db "negitive stmt", 0		; global string
_L21:	db "simple if of a != 0", 0		; global string
_L22:	db "postive stmt", 0		; global string
_L23:	db "negitive stmt", 0		; global string
_L24:	db "not of a", 0		; global string
_L25:	db "d:", 0		; global string
_L26:	db "do and & or on d", 0		; global string
_L27:	db "and was true", 0		; global string
_L28:	db "or was true", 0		; global string
_L29:	db "print 'hello' a times", 0		; global string
_L30:	db "hello", 0		; global string
_L31:	db "b[0] = 2 + a", 0		; global string
_L32:	db "b[1+2+3] = 5", 0		; global string
_L33:	db "factorial of a", 0		; global string
_L34:	db "compleax call statement", 0		; global string
			
section .text
	global main		
			
			
q:			;Start of functiuon
	mov r8, rsp		;FUNC header RSP har to be at most RBP
	add r8, -32		;adjust stack pointer oractivatio record
	mov [r8], rbp		;Storing old BP
	mov [ r8 + 8 ], rsp		;storing old SP
	mov rbp, rsp		;FUNC header has to be at most RBP
	mov rsp, r8		;set new SP
			
	mov rax, 16		;get ident offset
	add rax, rsp		;add to stack pointer
	mov rax, [rax]		;dereference RAX
			
			;End of function
	mov rbp, [rsp]		;Func end restore BP
	mov rsp,[ rsp + 8 ]		;FUNC restoer old SP
	ret		
			
			;End of function
	mov rbp, [rsp]		;Func end restore BP
	mov rsp,[ rsp + 8 ]		;FUNC restoer old SP
	xor rax, rax		;no value specificate, then it is 0
	ret		
			
			
fact:			;Start of functiuon
	mov r8, rsp		;FUNC header RSP har to be at most RBP
	add r8, -56		;adjust stack pointer oractivatio record
	mov [r8], rbp		;Storing old BP
	mov [ r8 + 8 ], rsp		;storing old SP
	mov rbp, rsp		;FUNC header has to be at most RBP
	mov rsp, r8		;set new SP
			
	mov rax, 16		;get ident offset
	add rax, rsp		;add to stack pointer
	mov rax, [rax]		;puts memory address into result
	mov [ rsp + 24 ], rax		;put result for LHS into temp
	mov rbx, 0		;puts value into result
	mov rax, [ rsp + 24 ]		;move stored LHS back into rax
	cmp rax, rbx		;EXPR Less than or equal
	setle al		;set to Less than or equal
	mov rbx, 1		;set rbx to filter rax
	and rax, rbx		;filter rax
	mov [ rsp + 24 ], rax		;store rax back to expr location
	mov rsi, [ rsp + 24 ]		;set result to rsi
	cmp rsi, 0		; compare to zero for evaluation of IF
	je _L35		;jump to ELSE
			;Positive Stmt
	mov rax, 1		;ARG of CALL is a NUM or BOOL
			
			;End of function
	mov rbp, [rsp]		;Func end restore BP
	mov rsp,[ rsp + 8 ]		;FUNC restoer old SP
	ret		
	jmp _L36		;jump out of IF
_L35:			;begin ELSE
_L36:			;end of IF
			
	mov rax, 16		;get ident offset
	add rax, rsp		;add to stack pointer
	mov rax, [rax]		;puts memory address into result
	mov [ rsp + 48 ], rax		;put result for LHS into temp
	mov rax, 16		;get ident offset
	add rax, rsp		;add to stack pointer
	mov rax, [rax]		;puts memory address into result
	mov [ rsp + 32 ], rax		;put result for LHS into temp
	mov rbx, 1		;puts value into result
	mov rax, [ rsp + 32 ]		;move stored LHS back into rax
	sub rax, rbx		;subtact LHS and RHS
	mov [ rsp + 32 ], rax		;store rax back to expr location
	mov rax, [ rsp + 32 ]		;get EXPR value for CALL
	mov r8, rsp		;get RSP
	sub r8, 64		;substract SP from FUN offset
	mov [r8 + 16 ], rax		;move value PARAM offset
	call fact		;call FUNCTION
			
	mov rbx, rax		;get CALL value into RHS
	mov rax, [ rsp + 48 ]		;move stored LHS back into rax
	imul rax, rbx		;multply LHS and RHS
	mov [ rsp + 48 ], rax		;store rax back to expr location
	mov rax, [ rsp + 48 ]		;get EXPR value for CALL
			
			;End of function
	mov rbp, [rsp]		;Func end restore BP
	mov rsp,[ rsp + 8 ]		;FUNC restoer old SP
	ret		
			
			;End of function
	mov rbp, [rsp]		;Func end restore BP
	mov rsp,[ rsp + 8 ]		;FUNC restoer old SP
	xor rax, rax		;no value specificate, then it is 0
	ret		
			
			
main:			;Start of functiuon
	mov rbp, rsp		;special RSP to RSB for main only
	mov r8, rsp		;FUNC header RSP har to be at most RBP
	add r8, -304		;adjust stack pointer oractivatio record
	mov [r8], rbp		;Storing old BP
	mov [ r8 + 8 ], rsp		;storing old SP
	mov rsp, r8		;set new SP
			
	PRINT_STRING _L0		;print string
	NEWLINE		;standrd newline
			
	mov rsi, 1		;move value into register
	PRINT_DEC 8, rsi		;print to output
	NEWLINE		
			
	mov rax, a		;gets globel variabel value
	GET_DEC 8, [rax]		;Read in var
			
	PRINT_STRING _L1		;print string
	NEWLINE		;standrd newline
			
	mov rax, a		;gets globel variabel value
	mov rsi, [rax]		;put memory address into rsi for printing
	PRINT_DEC 8, rsi		;print to output
	NEWLINE		
			
	PRINT_STRING _L2		;print string
	NEWLINE		;standrd newline
			
	mov rax, a		;gets globel variabel value
	mov rax, [rax]		;puts memory address into result
	mov [ rsp + 24 ], rax		;put result for LHS into temp
	mov rbx, 1		;puts value into result
	mov rax, [ rsp + 24 ]		;move stored LHS back into rax
	add rax, rbx		;add LHS and RHS
	mov [ rsp + 24 ], rax		;store rax back to expr location
	mov rsi, [ rsp + 24 ]		;set result to rsi
	PRINT_DEC 8, rsi		;print to output
	NEWLINE		
			
	mov rax, a		;gets globel variabel value
	mov rbx, [ rax ]		;put value of IDENT in RBX
	mov [rsp + 32], rbx		;save rbx value
	mov rax, c		;gets globel variabel value
	mov rbx, [rsp + 32]		;load back RBX
	mov [ rax ], rbx		;store RBX into identfier
			
	PRINT_STRING _L3		;print string
	NEWLINE		;standrd newline
			
	mov rax, c		;gets globel variabel value
	mov rsi, [rax]		;put memory address into rsi for printing
	PRINT_DEC 8, rsi		;print to output
	NEWLINE		
			
	PRINT_STRING _L4		;print string
	NEWLINE		;standrd newline
			
	mov rax, c		;gets globel variabel value
	mov rax, [rax]		;puts memory address into result
	mov [ rsp + 40 ], rax		;put result for LHS into temp
	mov rbx, 2		;puts value into result
	mov rax, [ rsp + 40 ]		;move stored LHS back into rax
	add rax, rbx		;add LHS and RHS
	mov [ rsp + 40 ], rax		;store rax back to expr location
	mov rsi, [ rsp + 40 ]		;set result to rsi
	PRINT_DEC 8, rsi		;print to output
	NEWLINE		
			
	mov rax, c		;gets globel variabel value
	mov rax, [rax]		;puts memory address into result
	mov [ rsp + 48 ], rax		;put result for LHS into temp
	mov rbx, 2		;puts value into result
	mov rax, [ rsp + 48 ]		;move stored LHS back into rax
	sub rax, rbx		;subtact LHS and RHS
	mov [ rsp + 48 ], rax		;store rax back to expr location
	mov rsi, [ rsp + 48 ]		;set result to rsi
	PRINT_DEC 8, rsi		;print to output
	NEWLINE		
			
	mov rax, c		;gets globel variabel value
	mov rax, [rax]		;puts memory address into result
	mov [ rsp + 56 ], rax		;put result for LHS into temp
	mov rbx, 2		;puts value into result
	mov rax, [ rsp + 56 ]		;move stored LHS back into rax
	imul rax, rbx		;multply LHS and RHS
	mov [ rsp + 56 ], rax		;store rax back to expr location
	mov rsi, [ rsp + 56 ]		;set result to rsi
	PRINT_DEC 8, rsi		;print to output
	NEWLINE		
			
	mov rax, c		;gets globel variabel value
	mov rax, [rax]		;puts memory address into result
	mov [ rsp + 64 ], rax		;put result for LHS into temp
	mov rbx, 2		;puts value into result
	mov rax, [ rsp + 64 ]		;move stored LHS back into rax
	xor rdx, rdx		;set RDX to zero for reminder
	idiv rbx		;divde LHS and RHS
	mov [ rsp + 64 ], rax		;store rax back to expr location
	mov rsi, [ rsp + 64 ]		;set result to rsi
	PRINT_DEC 8, rsi		;print to output
	NEWLINE		
			
	PRINT_STRING _L5		;print string
	NEWLINE		;standrd newline
			
	mov rax, 3		;puts value into result
	mov [ rsp + 72 ], rax		;put result for LHS into temp
	mov rax, a		;gets globel variabel value
	mov rbx, [rax]		;puts memory address into result
	mov rax, [ rsp + 72 ]		;move stored LHS back into rax
	imul rax, rbx		;multply LHS and RHS
	mov [ rsp + 72 ], rax		;store rax back to expr location
	mov rax, [ rsp + 72 ]		;gets temp address for result
	mov [ rsp + 80 ], rax		;put result for LHS into temp
	mov rbx, 1		;puts value into result
	mov rax, [ rsp + 80 ]		;move stored LHS back into rax
	add rax, rbx		;add LHS and RHS
	mov [ rsp + 80 ], rax		;store rax back to expr location
	mov rax, [ rsp + 80 ]		;gets temp address for result
	mov [ rsp + 96 ], rax		;put result for LHS into temp
	mov rax, 3		;puts value into result
	mov [ rsp + 88 ], rax		;put result for LHS into temp
	mov rax, a		;gets globel variabel value
	mov rbx, [rax]		;puts memory address into result
	mov rax, [ rsp + 88 ]		;move stored LHS back into rax
	imul rax, rbx		;multply LHS and RHS
	mov [ rsp + 88 ], rax		;store rax back to expr location
	mov rbx, [ rsp + 88 ] 		;gets temp address for result
	mov rax, [ rsp + 96 ]		;move stored LHS back into rax
	sub rax, rbx		;subtact LHS and RHS
	mov [ rsp + 96 ], rax		;store rax back to expr location
	mov rbx, [ rsp + 96 ]		;grab RHS value
	mov [rsp + 104], rbx		;save rbx value
	mov rax, c		;gets globel variabel value
	mov rbx, [rsp + 104]		;load back RBX
	mov [ rax ], rbx		;store RBX into identfier
			
	mov rax, c		;gets globel variabel value
	mov rsi, [rax]		;put memory address into rsi for printing
	PRINT_DEC 8, rsi		;print to output
	NEWLINE		
			
	PRINT_STRING _L6		;print string
	NEWLINE		;standrd newline
			
	mov rax, a		;gets globel variabel value
	mov rax, [rax]		;puts memory address into result
	mov [ rsp + 112 ], rax		;put result for LHS into temp
	mov rbx, 0		;puts value into result
	mov rax, [ rsp + 112 ]		;move stored LHS back into rax
	cmp rax, rbx		;EXPR Less than
	setl al		;set to Less than
	mov rbx, 1		;set rbx to filter rax
	and rax, rbx		;filter rax
	mov [ rsp + 112 ], rax		;store rax back to expr location
	mov rsi, [ rsp + 112 ]		;set result to rsi
	cmp rsi, 0		; compare to zero for evaluation of IF
	je _L37		;jump to ELSE
			;Positive Stmt
	PRINT_STRING _L7		;print string
	NEWLINE		;standrd newline
			
	jmp _L38		;jump out of IF
_L37:			;begin ELSE
	PRINT_STRING _L8		;print string
	NEWLINE		;standrd newline
			
_L38:			;end of IF
			
	PRINT_STRING _L9		;print string
	NEWLINE		;standrd newline
			
	mov rax, a		;gets globel variabel value
	mov rax, [rax]		;puts memory address into result
	mov [ rsp + 120 ], rax		;put result for LHS into temp
	mov rbx, 0		;puts value into result
	mov rax, [ rsp + 120 ]		;move stored LHS back into rax
	cmp rax, rbx		;EXPR Greater than
	setg al		;set to Greater than
	mov rbx, 1		;set rbx to filter rax
	and rax, rbx		;filter rax
	mov [ rsp + 120 ], rax		;store rax back to expr location
	mov rsi, [ rsp + 120 ]		;set result to rsi
	cmp rsi, 0		; compare to zero for evaluation of IF
	je _L39		;jump to ELSE
			;Positive Stmt
	PRINT_STRING _L10		;print string
	NEWLINE		;standrd newline
			
	jmp _L40		;jump out of IF
_L39:			;begin ELSE
	PRINT_STRING _L11		;print string
	NEWLINE		;standrd newline
			
_L40:			;end of IF
			
	PRINT_STRING _L12		;print string
	NEWLINE		;standrd newline
			
	mov rax, a		;gets globel variabel value
	mov rax, [rax]		;puts memory address into result
	mov [ rsp + 128 ], rax		;put result for LHS into temp
	mov rbx, 0		;puts value into result
	mov rax, [ rsp + 128 ]		;move stored LHS back into rax
	cmp rax, rbx		;EXPR Greater than or equal
	setge al		;set to Greater than or equal
	mov rbx, 1		;set rbx to filter rax
	and rax, rbx		;filter rax
	mov [ rsp + 128 ], rax		;store rax back to expr location
	mov rsi, [ rsp + 128 ]		;set result to rsi
	cmp rsi, 0		; compare to zero for evaluation of IF
	je _L41		;jump to ELSE
			;Positive Stmt
	PRINT_STRING _L13		;print string
	NEWLINE		;standrd newline
			
	jmp _L42		;jump out of IF
_L41:			;begin ELSE
	PRINT_STRING _L14		;print string
	NEWLINE		;standrd newline
			
_L42:			;end of IF
			
	PRINT_STRING _L15		;print string
	NEWLINE		;standrd newline
			
	mov rax, a		;gets globel variabel value
	mov rax, [rax]		;puts memory address into result
	mov [ rsp + 136 ], rax		;put result for LHS into temp
	mov rbx, 0		;puts value into result
	mov rax, [ rsp + 136 ]		;move stored LHS back into rax
	cmp rax, rbx		;EXPR Less than or equal
	setle al		;set to Less than or equal
	mov rbx, 1		;set rbx to filter rax
	and rax, rbx		;filter rax
	mov [ rsp + 136 ], rax		;store rax back to expr location
	mov rsi, [ rsp + 136 ]		;set result to rsi
	cmp rsi, 0		; compare to zero for evaluation of IF
	je _L43		;jump to ELSE
			;Positive Stmt
	PRINT_STRING _L16		;print string
	NEWLINE		;standrd newline
			
	jmp _L44		;jump out of IF
_L43:			;begin ELSE
	PRINT_STRING _L17		;print string
	NEWLINE		;standrd newline
			
_L44:			;end of IF
			
	PRINT_STRING _L18		;print string
	NEWLINE		;standrd newline
			
	mov rax, a		;gets globel variabel value
	mov rax, [rax]		;puts memory address into result
	mov [ rsp + 144 ], rax		;put result for LHS into temp
	mov rbx, 0		;puts value into result
	mov rax, [ rsp + 144 ]		;move stored LHS back into rax
	cmp rax, rbx		;EXPR Equal
	sete al		;set to Equal
	mov rbx, 1		;set rbx to filter rax
	and rax, rbx		;filter rax
	mov [ rsp + 144 ], rax		;store rax back to expr location
	mov rsi, [ rsp + 144 ]		;set result to rsi
	cmp rsi, 0		; compare to zero for evaluation of IF
	je _L45		;jump to ELSE
			;Positive Stmt
	PRINT_STRING _L19		;print string
	NEWLINE		;standrd newline
			
	jmp _L46		;jump out of IF
_L45:			;begin ELSE
	PRINT_STRING _L20		;print string
	NEWLINE		;standrd newline
			
_L46:			;end of IF
			
	PRINT_STRING _L21		;print string
	NEWLINE		;standrd newline
			
	mov rax, a		;gets globel variabel value
	mov rax, [rax]		;puts memory address into result
	mov [ rsp + 152 ], rax		;put result for LHS into temp
	mov rbx, 0		;puts value into result
	mov rax, [ rsp + 152 ]		;move stored LHS back into rax
	cmp rax, rbx		;EXPR Not equal
	setne al		;set to Not equal
	mov rbx, 1		;set rbx to filter rax
	and rax, rbx		;filter rax
	mov [ rsp + 152 ], rax		;store rax back to expr location
	mov rsi, [ rsp + 152 ]		;set result to rsi
	cmp rsi, 0		; compare to zero for evaluation of IF
	je _L47		;jump to ELSE
			;Positive Stmt
	PRINT_STRING _L22		;print string
	NEWLINE		;standrd newline
			
	jmp _L48		;jump out of IF
_L47:			;begin ELSE
	PRINT_STRING _L23		;print string
	NEWLINE		;standrd newline
			
_L48:			;end of IF
			
	PRINT_STRING _L24		;print string
	NEWLINE		;standrd newline
			
	mov rax, a		;gets globel variabel value
	mov rax, [rax]		;puts memory address into result
	mov [ rsp + 160 ], rax		;put result for LHS into temp
	mov rax, [ rsp + 160 ]		;move stored LHS back into rax
	cmp rax, 0		;compare to zero for NOT
	sete al		;set to equal for NOT
	mov rbx, 1		;load 1 to rbx for filtering
	and rax, rbx		;filter rax
	mov [ rsp + 160 ], rax		;store rax back to expr location
	mov rsi, [ rsp + 160 ]		;set result to rsi
	PRINT_DEC 8, rsi		;print to output
	NEWLINE		
			
	mov rax, 16		;get ident offset
	add rax, rsp		;add to stack pointer
	GET_DEC 8, [rax]		;Read in var
			
	PRINT_STRING _L25		;print string
	NEWLINE		;standrd newline
			
	mov rax, 16		;get ident offset
	add rax, rsp		;add to stack pointer
	mov rsi, [rax]		;put memory address into rsi for printing
	PRINT_DEC 8, rsi		;print to output
	NEWLINE		
			
	PRINT_STRING _L26		;print string
	NEWLINE		;standrd newline
			
	mov rax, 16		;get ident offset
	add rax, rsp		;add to stack pointer
	mov rax, [rax]		;puts memory address into result
	mov [ rsp + 168 ], rax		;put result for LHS into temp
	mov rbx, 1		;puts value into result
	mov rax, [ rsp + 168 ]		;move stored LHS back into rax
	cmp rax, 0		;check if RAX is false
	setne al		;set low bytes to 1 or 0
	mov rcx, 1		;set rcx to filter RAX
	and rax, rcx		;filter RAX
	cmp rbx, 0		;check if RVX is false
	setne bl		;set low btes to 0 or 1
	and rbx, rcx		;filter RBX
	and rax, rbx		;do peration AND
	mov [ rsp + 168 ], rax		;store rax back to expr location
	mov rsi, [ rsp + 168 ]		;set result to rsi
	cmp rsi, 0		; compare to zero for evaluation of IF
	je _L49		;jump to ELSE
			;Positive Stmt
	PRINT_STRING _L27		;print string
	NEWLINE		;standrd newline
			
	jmp _L50		;jump out of IF
_L49:			;begin ELSE
_L50:			;end of IF
			
	mov rax, 16		;get ident offset
	add rax, rsp		;add to stack pointer
	mov rax, [rax]		;puts memory address into result
	mov [ rsp + 176 ], rax		;put result for LHS into temp
	mov rbx, 0		;puts value into result
	mov rax, [ rsp + 176 ]		;move stored LHS back into rax
	or rax, rbx		;or LHS and RHS
	mov [ rsp + 176 ], rax		;store rax back to expr location
	mov rsi, [ rsp + 176 ]		;set result to rsi
	cmp rsi, 0		; compare to zero for evaluation of IF
	je _L51		;jump to ELSE
			;Positive Stmt
	PRINT_STRING _L28		;print string
	NEWLINE		;standrd newline
			
	jmp _L52		;jump out of IF
_L51:			;begin ELSE
_L52:			;end of IF
			
	PRINT_STRING _L29		;print string
	NEWLINE		;standrd newline
			
	mov rax, a		;gets globel variabel value
	mov rbx, [ rax ]		;put value of IDENT in RBX
	mov [rsp + 184], rbx		;save rbx value
	mov rax, c		;gets globel variabel value
	mov rbx, [rsp + 184]		;load back RBX
	mov [ rax ], rbx		;store RBX into identfier
			
_L53:			;start of WHILE
	mov rax, c		;gets globel variabel value
	mov rax, [rax]		;puts memory address into result
	mov [ rsp + 192 ], rax		;put result for LHS into temp
	mov rbx, 0		;puts value into result
	mov rax, [ rsp + 192 ]		;move stored LHS back into rax
	cmp rax, rbx		;EXPR Greater than
	setg al		;set to Greater than
	mov rbx, 1		;set rbx to filter rax
	and rax, rbx		;filter rax
	mov [ rsp + 192 ], rax		;store rax back to expr location
	mov rsi, [ rsp + 192 ]		;set result to rsi
	cmp rsi, 0		;compare to Zero WHILE
	je _L54		;get out of while of condistion is no longer true
			;body of loop
	PRINT_STRING _L30		;print string
	NEWLINE		;standrd newline
			
	mov rax, c		;gets globel variabel value
	mov rax, [rax]		;puts memory address into result
	mov [ rsp + 200 ], rax		;put result for LHS into temp
	mov rbx, 1		;puts value into result
	mov rax, [ rsp + 200 ]		;move stored LHS back into rax
	sub rax, rbx		;subtact LHS and RHS
	mov [ rsp + 200 ], rax		;store rax back to expr location
	mov rbx, [ rsp + 200 ]		;grab RHS value
	mov [rsp + 208], rbx		;save rbx value
	mov rax, c		;gets globel variabel value
	mov rbx, [rsp + 208]		;load back RBX
	mov [ rax ], rbx		;store RBX into identfier
			
	jmp _L53		;goto condistion
_L54:			;end of WHILE
			
	PRINT_STRING _L31		;print string
	NEWLINE		;standrd newline
			
	mov rax, 2		;puts value into result
	mov [ rsp + 200 ], rax		;put result for LHS into temp
	mov rax, a		;gets globel variabel value
	mov rbx, [rax]		;puts memory address into result
	mov rax, [ rsp + 200 ]		;move stored LHS back into rax
	add rax, rbx		;add LHS and RHS
	mov [ rsp + 200 ], rax		;store rax back to expr location
	mov rbx, [ rsp + 200 ]		;grab RHS value
	mov [rsp + 208], rbx		;save rbx value
	mov rdx, 0		;puts value into result
	shl rdx, 3		;times by WSIZE
	mov rax, b		;gets globel variabel value
	add rax, rdx		;add offset
	mov rbx, [rsp + 208]		;load back RBX
	mov [ rax ], rbx		;store RBX into identfier
			
	mov rdx, 0		;puts value into result
	shl rdx, 3		;times by WSIZE
	mov rax, b		;gets globel variabel value
	add rax, rdx		;add offset
	mov rsi, [rax]		;put memory address into rsi for printing
	PRINT_DEC 8, rsi		;print to output
	NEWLINE		
			
	PRINT_STRING _L32		;print string
	NEWLINE		;standrd newline
			
	mov rbx, 5		;move value into register
	mov [rsp + 232], rbx		;save rbx value
	mov rax, 1		;puts value into result
	mov [ rsp + 216 ], rax		;put result for LHS into temp
	mov rbx, 2		;puts value into result
	mov rax, [ rsp + 216 ]		;move stored LHS back into rax
	add rax, rbx		;add LHS and RHS
	mov [ rsp + 216 ], rax		;store rax back to expr location
	mov rax, [ rsp + 216 ]		;gets temp address for result
	mov [ rsp + 224 ], rax		;put result for LHS into temp
	mov rbx, 3		;puts value into result
	mov rax, [ rsp + 224 ]		;move stored LHS back into rax
	add rax, rbx		;add LHS and RHS
	mov [ rsp + 224 ], rax		;store rax back to expr location
	mov rdx, [ rsp + 224 ]		;get value of EXPR of ARRAY
	shl rdx, 3		;times by WSIZE
	mov rax, b		;gets globel variabel value
	add rax, rdx		;add offset
	mov rbx, [rsp + 232]		;load back RBX
	mov [ rax ], rbx		;store RBX into identfier
			
	mov rdx, 6		;puts value into result
	shl rdx, 3		;times by WSIZE
	mov rax, b		;gets globel variabel value
	add rax, rdx		;add offset
	mov rsi, [rax]		;put memory address into rsi for printing
	PRINT_DEC 8, rsi		;print to output
	NEWLINE		
			
	PRINT_STRING _L33		;print string
	NEWLINE		;standrd newline
			
	mov rax, a		;gets globel variabel value
	mov rax, [rax]		;dereference RAX
	mov r8, rsp		;get RSP
	sub r8, 64		;substract SP from FUN offset
	mov [r8 + 16 ], rax		;move value PARAM offset
	call fact		;call FUNCTION
			
	mov rsi, rax		;put value of call into RSI
	PRINT_DEC 8, rsi		;print to output
	NEWLINE		
			
	PRINT_STRING _L34		;print string
	NEWLINE		;standrd newline
			
	mov rdx, 0		;puts value into result
	shl rdx, 3		;times by WSIZE
	mov rax, b		;gets globel variabel value
	add rax, rdx		;add offset
	mov rax, [rax]		;puts memory address into result
	mov [ rsp + 288 ], rax		;put result for LHS into temp
	mov rax, a		;gets globel variabel value
	mov rax, [rax]		;dereference RAX
	mov r8, rsp		;get RSP
	sub r8, 64		;substract SP from FUN offset
	mov [r8 + 16 ], rax		;move value PARAM offset
	call fact		;call FUNCTION
			
	mov [ rsp + 264 ], rax		;do CALL then move value into stored place
	mov rdx, 6		;puts value into result
	shl rdx, 3		;times by WSIZE
	mov rax, b		;gets globel variabel value
	add rax, rdx		;add offset
	mov rax, [rax]		;puts memory address into result
	mov [ rsp + 248 ], rax		;put result for LHS into temp
	mov rbx, 2		;puts value into result
	mov rax, [ rsp + 248 ]		;move stored LHS back into rax
	add rax, rbx		;add LHS and RHS
	mov [ rsp + 248 ], rax		;store rax back to expr location
	mov rax, [ rsp + 248 ]		;get EXPR value for CALL
	mov r8, rsp		;get RSP
	sub r8, 40		;substract SP from FUN offset
	mov [r8 + 16 ], rax		;move value PARAM offset
	mov rax, [ rsp + 264 ]		;get back value from calls
	mov r8, rsp		;get RSP
	sub r8, 40		;substract SP from FUN offset
	mov [r8 + 24 ], rax		;move value PARAM offset
	call q		;call FUNCTION
			
	mov [ rsp + 280 ], rax		;do CALL then move value into stored place
	mov rax, [ rsp + 280 ]		;get back value from calls
	mov r8, rsp		;get RSP
	sub r8, 64		;substract SP from FUN offset
	mov [r8 + 16 ], rax		;move value PARAM offset
	call fact		;call FUNCTION
			
	mov rbx, rax		;get CALL value into RHS
	mov rax, [ rsp + 288 ]		;move stored LHS back into rax
	add rax, rbx		;add LHS and RHS
	mov [ rsp + 288 ], rax		;store rax back to expr location
	mov rbx, [ rsp + 288 ]		;grab RHS value
	mov [rsp + 296], rbx		;save rbx value
	mov rax, c		;gets globel variabel value
	mov rbx, [rsp + 296]		;load back RBX
	mov [ rax ], rbx		;store RBX into identfier
			
	mov rax, c		;gets globel variabel value
	mov rsi, [rax]		;put memory address into rsi for printing
	PRINT_DEC 8, rsi		;print to output
	NEWLINE		
			
			
			;End of function
	mov rbp, [rsp]		;Func end restore BP
	mov rsp,[ rsp + 8 ]		;FUNC restoer old SP
	mov rsp, rbp		;stack and BP need to be same on exit for main
	xor rax, rax		;no value specificate, then it is 0
	ret		

%{

  open Lexing
  open Mml

%}

%token PLUS STAR MINUS DIV MOD (*+ * - / mod*)
%token EQ NQ LT LE GE GT AND OR (* for equal notequal lessThan LessEqual ..  *)
%token LPAR RPAR
%token FUN ARROW LET REC IN IF THEN ELSE  
%token DOT (* for sometype.attribute*)
%token PV (* pour point virgule*)
%token <int> CST
%token <bool> BOOL 
%token <unit> UNIT  (* for () *)
%token <string> IDENT
%token EOF


%left PLUS
%left STAR


%start program
%type <Mml.prog> program

%%

program:
| (* à compléter *) code=expression EOF { {types=[]; code} }
;

simple_expression:
| n=CST { Int(n) }
;

expression:
| e=simple_expression { e }
| e1=expression op=binop e2=expression { Bop(op, e1, e2) }
;

%inline binop:
| PLUS { Add }
| STAR { Mul }
;


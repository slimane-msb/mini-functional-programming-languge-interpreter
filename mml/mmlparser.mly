%{

  open Lexing
  open Mml

%}

%token PLUS STAR MINUS DIV MOD (*+ * - / mod*)
%token EQ  (* for equal*)
%token EQEQ NQ LT LE GE GT  AND OR (* for equalequal notequal lessThan LessEqual ..  *)
%token LPAR RPAR
%token FUN ARROW LET REC IN IF THEN ELSE  
%token DOT (* for sometype.attribute*)
%token PV (* pour point virgule*)
%token <int> CST
%token <bool> BOOL 
%token <unit> UNIT  (* for () *)
%token <string> IDENT
%token EOF


%left PLUS MINUS (*ordre de l'addition et soustraction*)
%left STAR DIV (*ordre de la multiplication et division*)
%right PV 
%left EQEQ NQ LT GT LE GE  (* ordre des operator conditionnels*)
%left OR
%left AND 
%left DOT


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


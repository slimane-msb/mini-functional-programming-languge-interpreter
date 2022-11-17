%{

  open Lexing
  open Mml

%}

%token PLUS STAR MINUS DIV MOD (*+ * - / mod*)
%token NEG NOT
%token EQ  (* for equal*)
%token EQEQ NQ LT LE GE GT  AND OR (* for equalequal notequal lessThan LessEqual ..  *)
%token LPAR RPAR
%token FUN ARROW LET REC IN IF THEN ELSE  
%token DOT (* for sometype.attribute*)
%token PV DP(* pour point virgule, deux points*)
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
  | n=CST             { Int(n) }
  | b=BOOL            { Bool(b) }
  | u=UNIT            { Unit }
  | id=IDENT            { Var(id) }
  | se=simple_expression DOT id=IDENT { GetF(se,id)}
  | id=IDENT EQ e=expression PV er=expression{ SetF(e,id,er)} (* je suis pas de l'ordre de e et er, id en tous cas doit etre au milieu*)
  | LPAR e=expression RPAR { e } 
;

expression:
  | e=simple_expression { e }
  | e1=expression op=binop e2=expression { Bop(op, e1, e2) }
  | up=unop e=expression {Uop(up,e)}
  | e=expression se=simple_expression { App(e,se)}
  | IF ef=expression THEN et=expression {If(ef,et,Unit)}
  | IF ef=expression THEN et=expression ELSE el=expression {IF(ef,et,el)}
  | FUN x=IDENT ARROW e=expression {Fun(x, Unit, e)}
  | LET f=IDENT LPAR x=IDENT DP t0=IDENT (*or? TYPE*) RPAR DP t1=IDENT EQ e1=expression IN e2=expression  {Let(f,Fun(x,t0,e1), e2)} (*si on a pleusieur par*)
  | LET REC f=IDENT LPAR x=IDENT DP t0=IDENT (*or? TYPE*) RPAR DP t1=IDENT EQ e1=expression IN e2=expression {Let(f, Fix(f, TFun(t0, t1), Fun(x, t0, e1)), e2)} (*si on a pleusieur par*)


;


%inline binop:
  | PLUS { Add }
  | STAR { Mul }
;


%inline unop:
  | NEG { Neg}
  | NOT { Not }
;



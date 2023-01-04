%{

  open Lexing
  open Mml

%}

%token <int> CST  // constante
%token <string> IDENT // identifiant
%token <bool> BOOL // booléen
%token UNIT // unit

%token LPAR RPAR // parenthèses (  )
%token LBRAC RBRAC // accolades { }

%token SEMICOLON DOT COLON // ; . :

%token LARROW RARROW  // flèche gauche et droite : <- ->

/* arithmétique */
%token PLUS STAR MINUS DIV MOD // opérateurs binaires arithmétiques : + * - / mod
/* %token U_MINUS // opérateur unaire arithmétique  -   */

/* logique */
%token TRUE FALSE // true false
%token EQ // =
%token EQEQ NEQ LE LT AND OR // opérateurs binaires logiques :  == != <= < && ||
%token NOT // opérateur unaire logique : not
%token IF THEN ELSE // if then else

%token EOF // end of file


%token FUN LET REC IN TYPE  MUTABLE // let rec in fun type mutable


  %nonassoc IN 

  %nonassoc SEMICOLON

  %nonassoc THEN
  %nonassoc LARROW
  %nonassoc ELSE

  %nonassoc RARROW


  %nonassoc OR AND

  %left EQEQ NEQ LE LT 
  %left MINUS PLUS
  %left DIV STAR MOD

  %nonassoc LBRAC LPAR IDENT CST FALSE TRUE 

%start program
%type <Mml.prog> program

%%

/* TODO : Vérifier que quand y'a une liste que ça fonctionne bien
Je ne suis pas sur que des trucs du genre list ( MUTABLE {m}  ,x = IDENT COLON etc ) { blabla } fonctionne comme on le pense
*/
program:
|  lt = list( type_def ) code=expression EOF { {types = lt  ; code} }  // [<type_def>]* <expr> eof
;

type_def:
| TYPE x = IDENT EQ LBRAC l = nonempty_list( m = option(MUTABLE) ;  x = IDENT ;  COLON;  t = typ ;  SEMICOLON {let b = m <> None in (x,t,b) } )
RBRAC { x,l }  // type ident = { [[mutable]? ident : <type> ;]+ }


typ: 
| CST { TInt } // int
| BOOL { TBool  } // bool 
| UNIT { TUnit } // unit 
| x = IDENT { match x with | "int" -> TInt | "bool" -> TBool  | "unit" -> TUnit | _ -> TStrct x} // ident 
| t1 = typ RARROW t2 = typ { TFun(t1,t2) } // <type> -> <type>
| LPAR t = typ RPAR { t } // ( <type> )
;

simple_expression:
| n=CST { Int(n) } // n
| TRUE  { Bool(true) } // true
| FALSE { Bool(false) } // false
| LPAR RPAR { Unit } // ()
| x = IDENT { Var(x) }  // ident
| se = simple_expression DOT x = IDENT { GetF(se,x) } // <s_expr> . ident
| LBRAC  l = nonempty_list( x = IDENT ; EQ ;  e = expression ; SEMICOLON { (x,e) } ) RBRAC {  Strct(l)  } // { [ident = <expr> ;]+ }
| LPAR e = expression RPAR { e } // ( <expr> )
;

expression:
| e=simple_expression { e } // <s_expr>
| op = uop se = simple_expression  { Uop(op, se) }  // <uop> <s_expr>
| e1=expression op=binop e2=expression { Bop(op, e1, e2) }  // <expr> <bop> <expr>
| e =expression se = simple_expression { App (e, se) } // <expr> <s_expr>

| IF c = expression THEN e = expression { If (c,e, Unit) }// if <expr> then <expr>
| IF c = expression THEN e1 = expression ELSE e2 = expression { If (c,e1,e2) } // if <expr> then <expr> else <expr>
| FUN LPAR x = IDENT COLON t = typ RPAR RARROW e = expression { Fun(x,t,e) }  // fun ident -> <expr>

| LET x = IDENT l = list(LPAR; x = IDENT ; COLON  ; t = typ ; RPAR { (x,t) } ) 
EQ e1 = expression IN e2 = expression { let fn = mk_fun l e1 in Let(x,fn,e2)} //  let ident [( ident : <type> )]* = <expr> in <expr>
| LET REC x = IDENT l = list(LPAR ; x = IDENT ; COLON  ; t1 = typ ;  RPAR { (x,t1) }) COLON t2 = typ EQ e1 = expression IN e2 = expression
{ let tfn = mk_fun_type l t2 in let fn = mk_fun l e1 in  Let(x,Fix(x,tfn,fn), e2 )} // let rec ident [( ident : <type> )]* : <type> = <expr> in <expr>

| se  = simple_expression DOT x = IDENT LARROW e = expression  { SetF(se,x,e) } // <s_expr> . ident <- <expr>
| e1 = expression SEMICOLON e2 = expression { Seq(e1,e2) } // <expr> ; <expr>
;



%inline binop:
| PLUS { Add }
| STAR { Mul }
| MINUS { Sub } 
| DIV { Div }
| MOD { Mod }
| EQEQ { Eq }
| NEQ { Neq }
| LT { Lt }
| LE { Le } 
| AND { And } 
| OR { Or } 
;


%inline   uop: 
| MINUS { Neg } 
| NOT { Not } 
;


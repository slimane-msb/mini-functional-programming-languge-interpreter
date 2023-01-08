%{

  open Lexing
  open Mml

  open Exception

%}

%token <int> CST  // constante
%token <string> IDENT // identifiant
%token <bool> BOOL // booléen
%token UNIT // unit

%token LPAR RPAR // parenthèses (  )
%token LBRACES RBRACES // accolades { }
%token LBRACKET RBRACKET // crochets [ ]
%token SEMICOLON  DOT  COLON
  
%token NEW // new

%token PRINT // print

%token LARROW RARROW  // flèche gauche et droite : <- ->

/* arithmétique */
%token PLUS STAR MINUS DIV MOD // opérateurs binaires arithmétiques : + * - / mod
/* %token U_MINUS // opérateur unaire arithmétique  -   */

/* logique */
%token TRUE FALSE // true false
%token EQ NEQ // = <>
%token EQEQ NEQEQ LE LT GE GT AND OR // opérateurs binaires logiques :  == != <= < >= > && ||
%token NOT // opérateur unaire logique : not
%token IF THEN ELSE // if then else

%token EOF // end of file
%token WHILE DO DONE // while

 %token REF
%token DEREF  
%token ASSIGN
 
%token FUN LET REC IN TYPE  MUTABLE // let rec in fun type mutable


%token COMMA // ,



//%right LET 
%nonassoc IN 

%right SEMICOLON


%nonassoc THEN
%right ELSE

%nonassoc PRINT

%nonassoc LARROW ASSIGN

%nonassoc RARROW


%nonassoc OR AND

%left EQEQ NEQEQ EQ NEQ LE LT GE GT
%left MINUS PLUS
%left DIV STAR MOD
%nonassoc REF 
%nonassoc DEREF
%nonassoc DOT
%nonassoc  LBRACKET LBRACES LPAR IDENT CST FALSE TRUE 



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
| TYPE x = IDENT EQ LBRACES l = nonempty_list( m = option(MUTABLE) ;  x = IDENT ;  COLON;  t = typ ; SEMICOLON {let b = m <> None in (x,t,b) })
RBRACES { x,l }  // type ident = { [[mutable]? ident : <type> ;]+ }
| TYPE error { expecting "identifier" }
;

typ: 
| CST { TInt } // int
| BOOL { TBool  } // bool 
| UNIT { TUnit } // unit 
| x = IDENT { match x with | "int" -> TInt | "bool" -> TBool  | "unit" -> TUnit | _ -> TStrct x} // ident 
| t1 = typ RARROW t2 = typ { TFun(t1,t2) } // <type> -> <type>
| LPAR t = typ RPAR { t }  // ( <type> )
;

simple_expression:
| n=CST { Int(n) } // n
| TRUE  { Bool(true) } // true
| FALSE { Bool(false) } // false
| LPAR RPAR { Unit } // ()
| x = IDENT { Var(x) }  // ident
| se = simple_expression DOT x = IDENT { GetF(se,x) } // <s_expr> . ident
| e1 = simple_expression LBRACKET e2 = expression RBRACKET { GetA(e1,e2) } // <expr> [ <expr> ]
| LBRACES  l = nonempty_list( x = IDENT ; EQ ;  e = expression ; SEMICOLON { (x,e) } ) RBRACES {  Strct(l)  } // { [ident = <expr> ;]+ }





| REF se = simple_expression { Ref(se) } // ref <expr>
| DEREF se = simple_expression { Deref(se) } // !<expr>


| LPAR e = expression RPAR { e } // ( <expr> )
| LPAR e = expression error { unclosed "parenthesis" } // ( <expr> )

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
| LET error { expecting "identifier" }

| LET REC x = IDENT l = list(LPAR ; x = IDENT ; COLON  ; t1 = typ ;  RPAR { (x,t1) }) COLON t2 = typ EQ e1 = expression IN e2 = expression
{ let tfn = mk_fun_type l t2 in let fn = mk_fun l e1 in  Let(x,Fix(x,tfn,fn), e2 )} // let rec ident [( ident : <type> )]* : <type> = <expr> in <expr>

| se  = simple_expression DOT x = IDENT LARROW e = expression  { SetF(se,x,e) } // <s_expr> . ident <- <expr>

| e1 = expression SEMICOLON e2 = expression { Seq(e1,e2) } // <expr> ; <expr>

| WHILE c = expression DO e = expression DONE { While(c,e) } // while <expr> do <expr>

(*array *)
| NEW se=simple_expression LBRACKET e = expression RBRACKET { NewArray(se,e) } // new <se> [ <expr> ]

| e1 = simple_expression LBRACKET e2 = expression RBRACKET LARROW e3 = expression { SetA(e1,e2,e3) } // <expr> [ <expr> ] <- <expr>

| LBRACKET l = list( e = expression ; SEMICOLON { e } ) RBRACKET { Array(l) } // [ [ <expr> ; ]* ]
(* print *)
| PRINT e = expression { Print(e) } // print <expr>
| e1 = simple_expression ASSIGN e2 = expression { Assign(e1,e2) } // <expr> := <expr> */

(* type énuméré *)
/* | TYPE x = IDENT EQ LPAR l = nonempty_list( x = IDENT ; PIPE { x } ) RPAR { Enum(x,l) } // type ident = ( ident | )+
| TYPE error { expecting "identifier" } */
;


%inline binop:
| PLUS { Add }
| STAR { Mul }
| MINUS { Sub } 
| DIV { Div }
| MOD { Mod }
| EQ { Eq }
| NEQ { Neq }
| EQEQ { Eqeq }
| NEQEQ { Neqeq }
| LT { Lt }
| LE { Le } 
| GT { Gt }
| GE { Ge }
| AND { And } 
| OR { Or } 
;


%inline   uop: 
| MINUS { Neg } 
| NOT { Not } 
;


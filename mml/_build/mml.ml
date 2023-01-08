(* Syntaxe abstraite Mini-ML *)

type typ = 
  | TInt 
  | TBool
  | TUnit
  | TFun of typ * typ
  | TStrct of string
  | TRef of typ
  | TArray of typ
type strct = (string * typ * bool) list



let rec typ_to_string = function
  | TInt  -> "int"
  | TBool -> "bool"
  | TUnit -> "unit"
  | TFun(typ1, typ2) -> 
     Printf.sprintf "(%s) -> %s" (typ_to_string typ1) (typ_to_string typ2)
  | TStrct s -> s 
  | TRef t -> Printf.sprintf "ref %s" (typ_to_string t)
  | TArray t -> Printf.sprintf "array %s" (typ_to_string t)



type uop = Neg | Not
type bop = Add | Sub | Mul | Div | Mod | Eq | Neq | Eqeq | Neqeq | Lt | Le | Ge | Gt | And | Or

type expr =
  | Int   of int
  | Bool  of bool
  | Unit
  | Uop   of uop * expr
  | Bop   of bop * expr * expr
  | Var   of string
  | Let   of string * expr * expr
  | If    of expr * expr * expr
  | Fun   of string * typ * expr
  | App   of expr * expr
  | Fix   of string * typ * expr
  | Strct of (string * expr) list
  | GetF  of expr * string
  | SetF  of expr * string * expr
  | Seq   of expr * expr

  | While of expr * expr
  | Ref  of expr
  | Deref of expr
  | Assign of expr * expr

  | NewArray of expr * expr
  | GetA of expr * expr
  | SetA of expr * expr * expr
  | Array of expr list

  | Print of expr


type prog = {
    types: (string * strct) list;
    code: expr;
  }

(* Fonctions auxiliaires, utilisables pour gérer le sucre syntaxique
     let f (x1:t1) ... (xN:tN) = ...
   de définition d'une fonction à plusieurs arguments. *)
let rec mk_fun xs e = match xs with
  | [] -> e
  | (x, t)::xs -> Fun(x, t, mk_fun xs e)
  
let rec mk_fun_type xs t = match xs with
  | [] -> t
  | (_, t')::xs -> TFun(t', mk_fun_type xs t)

(* Interprète Mini-ML *)

open Mml

(* Environnement : associe des valeurs à des noms de variables *)
module Env = Map.Make(String)

(* Valeurs *)
type value =
  | VInt   of int
  | VBool  of bool
  | VUnit
  | VPtr   of int
(* Élements du tas *)
type heap_value =
  | VClos  of string * expr * value Env.t
  | VStrct of (string, value) Hashtbl.t

let print_value = function
  | VInt n  -> Printf.printf "%d\n" n
  | VBool b -> Printf.printf "%b\n" b
  | VUnit   -> Printf.printf "()\n"
  | VPtr p  -> Printf.printf "@%d\n" p

(* Interprétation d'un programme complet *)
let eval_prog (p: prog): value =
  
  (* Initialisation de la mémoire globale *)
  let (mem: (int, heap_value) Hashtbl.t) = Hashtbl.create 16 in

  (* Création de nouvelles adresses *)
  let new_ptr =
    let cpt = ref 0 in
    fun () -> incr cpt; !cpt
  in

  (* Interprétation d'une expression, en fonction d'un environnement
     et de la mémoire globale *)
  let rec eval (e: expr) (env: value Env.t): value = 
    match e with
    | Int n  -> VInt n
    | Bool b  -> VBool b
    | Unit   -> VUnit
    | Ptr n  -> VPtr n 

    | Var x ->  Map.find env x
    | GetF(e,x) -> Hashtbl.find (eval e) x
    
    (*if then eslse*)
    | If(ef,et,el) -> if (eval ef env ) then (eval et env) else (eval el env)


    | Bop(Add, e1, e2) -> VInt ((evali e1 env) + (evali e2 env))
    | Bop(Mul, e1, e2) -> VInt ((evali e1 env) * (evali e2 env))
    | Bop(Sub, e1, e2) -> VInt ((evali e1 env) - (evali e2 env))
    | Bop(Div, e1, e2) -> VInt ((evali e1 env) / (evali e2 env))
    | Bop(Mod, e1, e2) -> VInt ((evali e1 env) mod (evali e2 env))

    | Bop(Eq, e1, e2) ->  VBool ((evalb e1 env) == (evalb e2 env))
    | Bop(Lt, e1, e2) ->  VBool ((evalb e1 env) <  (evalb e2 env))
    | Bop(Gt, e1, e2) ->  VBool ((evalb e1 env) >  (evalb e2 env))
    | Bop(Le, e1, e2) ->  VBool ((evalb e1 env) <= (evalb e2 env))
    | Bop(Ge, e1, e2) ->  VBool ((evalb e1 env) >= (evalb e2 env))
    | Bop(Neq, e1, e2) -> VBool ((evalb e1 env) != (evalb e2 env))

    | Bop(And, e1, e2) -> if (evalb e1 env) then  (evalb e2 env) else VBool(false)
    | Bop(Or, e1, e2) -> if (evalb e1 env) then VBool(true)  else (evalb e2 env) 

    | Uop(Neg, n) -> VInt (-(evali (e1) env))
    | Uop(Not, b) -> VBool (not (evalb (b) env))
    (*il reste : stct ; setf and seq ; app and fun ; let and rec*)

  (* Évaluation d'une expression dont la valeur est supposée entière *)
  and evali (e: expr) (env: value Env.t): int = 
    match eval e env with
    | VInt n -> n
    | _ -> assert false
  
  and evalb (e: expr) (env: value Env.t): bool = 
    match eval e env with
    | VBool b -> b
    | _ -> assert false

  and evalu (e: expr) (env: value Env.t): unit = 
    match eval e env with
    | VUnit -> ()
    | _ -> assert false


  and evalp (e: expr) (env: value Env.t): int (*si avec ref, dans ce cas il faudera le rajouter aussi dans type value *) = 
    match eval e env with
    | VPtr p -> p
    | _ -> assert false
  
  in

  eval p.code Env.empty

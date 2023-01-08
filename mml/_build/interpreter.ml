(* Interprète Mini-ML *)

open Mml

(* Environnement : associe des valeurs à des noms de variables *)
module Env = Map.Make (String)

(* Valeurs *)
type value = VInt of int | VBool of bool | VUnit | VPtr of int

(* Élements du tas *)
type heap_value =
  | VClos of string * expr * value Env.t
  | VStrct of (string, value) Hashtbl.t
  | VRef of value
  | VArray of (int, value) Hashtbl.t

let rec print_value = function
  | VInt n -> Printf.printf "%d\n" n
  | VBool b -> Printf.printf "%b\n" b
  | VUnit -> Printf.printf ""
  (* print the heap value*)
  | VPtr p -> Printf.printf "@%d\n" p

and print_heap_value = function
  | VStrct h ->
      Printf.printf "{";
      Hashtbl.iter
        (fun x v ->
          Printf.printf "%s = " x;
          print_value v;
          Printf.printf "; ")
        h;
      Printf.printf "}"
  | VRef v ->
      Printf.printf "ref ";
      print_value v
  | VArray h ->
      Printf.printf "[|";
      Hashtbl.iter
        (fun x v ->
          Printf.printf "%d = " x;
          print_value v;
          Printf.printf "; ")
        h;
      Printf.printf "|]"
  | _ -> Printf.printf ""

(* Interprétation d'un programme complet *)
let eval_prog (p : prog) : value =
  (* Initialisation de la mémoire globale *)
  let (mem : (int, heap_value) Hashtbl.t) = Hashtbl.create 16 in

  (* Création de nouvelles adresses *)
  let new_ptr =
    let cpt = ref 0 in
    fun () ->
      incr cpt;
      !cpt
  in

  (* Interprétation d'une expression, en fonction d'un environnement
     et de la mémoire globale *)
  let rec eval (e : expr) (env : value Env.t) : value =
    match e with
    | Int n -> VInt n
    | Bool b -> VBool b
    | Var x -> Env.find x env
    | Unit -> VUnit
    | Bop (Add, e1, e2) -> VInt (evali e1 env + evali e2 env)
    | Bop (Sub, e1, e2) -> VInt (evali e1 env - evali e2 env)
    | Bop (Mul, e1, e2) -> VInt (evali e1 env * evali e2 env)
    | Bop (Div, e1, e2) -> VInt (evali e1 env / evali e2 env)
    | Bop (Mod, e1, e2) -> VInt (evali e1 env mod evali e2 env)
    | Bop (And, e1, e2) -> VBool (evalb e1 env && evalb e2 env)
    | Bop (Or, e1, e2) -> VBool (evalb e1 env || evalb e2 env)
    (* égalité structurelle*)
    | Bop (Eq, e1, e2) -> (
        match (eval e1 env, eval e2 env) with
        | VInt n1, VInt n2 -> VBool (n1 = n2)
        | VBool b1, VBool b2 -> VBool (b1 = b2)
        | VUnit, VUnit -> VBool true
        | VPtr n1, VPtr n2 -> (
            let v1 = Hashtbl.find mem n1 in
            let v2 = Hashtbl.find mem n2 in
            match (v1, v2) with
            | VClos (x1, e1, env1), VClos (x2, e2, env2) ->
                VBool (x1 = x2 && e1 = e2 && env1 = env2)
            | VStrct h1, VStrct h2 ->
                let l1 = Hashtbl.fold (fun x v l -> (x, v) :: l) h1 [] in
                let l2 = Hashtbl.fold (fun x v l -> (x, v) :: l) h2 [] in
                VBool (l1 = l2)
            | VRef v1, VRef v2 -> VBool (v1 = v2)
            | VArray h1, VArray h2 ->
                let l1 = Hashtbl.fold (fun x v l -> (x, v) :: l) h1 [] in
                let l2 = Hashtbl.fold (fun x v l -> (x, v) :: l) h2 [] in
                VBool (l1 = l2)
            | _ -> assert false)
        | _ -> assert false)
    | Bop (Neq, e1, e2) -> (
        match (eval e1 env, eval e2 env) with
        | VInt n1, VInt n2 -> VBool (n1 <> n2)
        | VBool b1, VBool b2 -> VBool (b1 <> b2)
        | VUnit, VUnit -> VBool false
        | VPtr n1, VPtr n2 -> (
            let v1 = Hashtbl.find mem n1 in
            let v2 = Hashtbl.find mem n2 in
            match (v1, v2) with
            | VClos (x1, e1, env1), VClos (x2, e2, env2) ->
                VBool (x1 <> x2 || e1 <> e2 || env1 <> env2)
            | VStrct h1, VStrct h2 ->
                let l1 = Hashtbl.fold (fun x v l -> (x, v) :: l) h1 [] in
                let l2 = Hashtbl.fold (fun x v l -> (x, v) :: l) h2 [] in
                VBool (l1 <> l2)
            | VRef v1, VRef v2 -> VBool (v1 <> v2)
            | VArray h1, VArray h2 ->
                let l1 = Hashtbl.fold (fun x v l -> (x, v) :: l) h1 [] in
                let l2 = Hashtbl.fold (fun x v l -> (x, v) :: l) h2 [] in
                VBool (l1 <> l2)
            | _ -> assert false)
        | _ -> assert false)
    | Bop (Eqeq, e1, e2) -> VBool (eval e1 env = eval e2 env)
    | Bop (Neqeq, e1, e2) -> VBool (eval e1 env <> eval e2 env)
    | Bop (Lt, e1, e2) -> VBool (evali e1 env < evali e2 env)
    | Bop (Le, e1, e2) -> VBool (evali e1 env <= evali e2 env)
    | Bop (Gt, e1, e2) -> VBool (evali e1 env > evali e2 env)
    | Bop (Ge, e1, e2) -> VBool (evali e1 env >= evali e2 env)
    | Uop (Neg, e1) -> VInt (-evali e1 env)
    | Uop (Not, e1) -> VBool (not (evalb e1 env))
    | Let (x, e1, e2) ->
        let v1 = eval e1 env in
        eval e2 (Env.add x v1 env)
    | Fun (x, tx, e) ->
        let v = new_ptr () in
        Hashtbl.add mem v (VClos (x, e, env));
        VPtr v
    | App (e1, e2) -> (
        match eval e1 env with
        | VPtr n -> (
            let v2 = eval e2 env in
            let v = Hashtbl.find mem n in
            match v with
            | VClos (x, b, env') -> eval b (Env.add x v2 env')
            | _ -> assert false)
        | _ -> assert false)
    | Strct l ->
        let v = new_ptr () in
        let h = Hashtbl.create 16 in
        List.iter (fun (x, e) -> Hashtbl.add h x (eval e env)) l;
        Hashtbl.add mem v (VStrct h);
        VPtr v
    | GetF (e1, x) -> (
        match eval e1 env with
        | VPtr n -> (
            let v = Hashtbl.find mem n in
            match v with VStrct h -> Hashtbl.find h x | _ -> assert false)
        | _ -> assert false)
    | SetF (e1, x, e2) -> (
        match eval e1 env with
        | VPtr n -> (
            let v = Hashtbl.find mem n in
            match v with
            | VStrct h ->
                let v2 = eval e2 env in
                Hashtbl.replace h x v2;
                v2
            | _ -> assert false)
        | _ -> assert false)
    | If (e1, e2, e3) -> if evalb e1 env then eval e2 env else eval e3 env
    | Seq (e1, e2) ->
        let _ = eval e1 env in
        eval e2 env
    | Fix (x, tx, e) -> evalfix (x, tx, e) env
    | While (e1, e2) ->
        let rec loop () =
          if evalb e1 env then
            let _ = eval e2 env in
            loop ()
        in
        loop ();
        VUnit
    | Ref e ->
        let v = new_ptr () in
        let v1 = eval e env in
        Hashtbl.add mem v (VRef v1);
        VPtr v
    | Deref e -> (
        match eval e env with
        | VPtr n -> (
            let v = Hashtbl.find mem n in
            match v with VRef v1 -> v1 | _ -> assert false)
        | _ -> assert false)
    | Assign (e1, e2) -> (
        match eval e1 env with
        | VPtr n -> (
            let v = Hashtbl.find mem n in
            match v with
            | VRef v1 ->
                let v2 = eval e2 env in
                Hashtbl.replace mem n (VRef v2);
                v2
            | _ -> assert false)
        | _ -> assert false)
    | Array l ->
        let v = new_ptr () in
        let h = Hashtbl.create 16 in
        List.iteri (fun i e -> Hashtbl.add h i (eval e env)) l;
        Hashtbl.add mem v (VArray h);
        VPtr v
    | NewArray (e1, e2) -> (
        match eval e1 env with
        | VInt n ->
            let v = new_ptr () in
            let h = Hashtbl.create n in
            let v2 = eval e2 env in
            for i = 0 to n - 1 do
              Hashtbl.add h i v2
            done;
            Hashtbl.add mem v (VArray h);
            VPtr v
        | _ -> assert false)
    (*TODO: add eror out of bounds*)
    | GetA (e1, e2) -> (
        match eval e1 env with
        | VPtr n -> (
            let v = Hashtbl.find mem n in
            match v with
            | VArray h -> (
                match eval e2 env with
                | VInt i -> (
                    try Hashtbl.find h i
                    with Not_found -> failwith "out of bounds")
                | _ -> assert false)
            | _ -> assert false)
        | _ -> assert false)
    | SetA (e1, e2, e3) -> (
        match eval e1 env with
        | VPtr n -> (
            let v = Hashtbl.find mem n in
            match v with
            | VArray h -> (
                match eval e2 env with
                | VInt i ->
                    let v3 = eval e3 env in
                    Hashtbl.replace h i v3;
                    v3
                | _ -> assert false)
            | _ -> assert false)
        | _ -> assert false)    
    | Print e ->
        let v = eval e env in
        print_value v;
        
        VUnit
  (* Évaluation d'une expression dont la valeur est supposée entière *)
  and evali (e : expr) (env : value Env.t) : int =
    match eval e env with VInt n -> n | _ -> assert false
  (* Évaluation d'une expression dont la valeur est supposée booléenne *)
  and evalb (e : expr) (env : value Env.t) : bool =
    match eval e env with VBool b -> b | _ -> assert false
  (* Évaluation d'une expression dont la valeur est supposée une fonction récursive *)
  and evalfix (x, tx, e) env =
    match e with
    | Fun (x', tx', e') ->
        let v = new_ptr () in
        Hashtbl.add mem v (VClos (x', e', Env.add x (VPtr v) env));
        VPtr v
    | Strct l ->
        let v = new_ptr () in
        let h = Hashtbl.create 16 in
        List.iter
          (fun (x', e') -> Hashtbl.add h x' (eval e' (Env.add x (VPtr v) env)))
          l;
        Hashtbl.add mem v (VStrct h);
        VPtr v
    | _ -> assert false
  in

  eval p.code Env.empty

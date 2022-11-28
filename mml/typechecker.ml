open Mml

(* Environnement de typage : associe des types aux noms de variables *)
module SymTbl = Map.Make(String)
type tenv = typ SymTbl.t

(* Pour remonter des erreurs circonstanciées *)
exception Type_error of string
let error s = raise (Type_error s)
let type_error ty_actual ty_expected =
  error (Printf.sprintf "expected %s but got %s" 
           (typ_to_string ty_expected) (typ_to_string ty_actual))
(* vous pouvez ajouter d'autres types d'erreurs *)

(* Vérification des types d'un programme *)
let type_prog prog =

  (* Vérifie que l'expression [e] a le type [type] *)
  let rec check e typ tenv =
    let typ_e = type_expr e tenv in
    if typ_e <> typ then type_error typ_e typ

  (* Calcule le type de l'expression [e] *)
  and type_expr e tenv = match e with
    | Int _  -> TInt
    | Bool _ -> TBool
    | Unit -> TUnit
    | Var (x) -> SymTbl.find x tenv
    | Bop((Add | Mul | Div | Sub | Mod ), e1, e2) -> 
       check e1 TInt tenv; check e2 TInt tenv; TInt
    | Bop(( Neq | Lt | Le ), e1 ,e2 ) ->
       check e1 TInt tenv; check e2 TInt tenv; TBool
    | Bop((And | Or),e1,e2) -> 
       check e1 TBool tenv; check e2 TBool tenv; TBool
    | Bop(Eq, e1,e2) -> let t1 = type_expr e1 tenv in check e2 t1 tenv ; TBool
    | Uop((Not), e) -> check e TBool tenv ; TBool
    | Uop((Neg), e) -> check e TInt tenv ; TInt
    | Let(x,e1,e2) ->  let t1 = type_expr e1 tenv in type_expr e2 (SymTbl.add x t1 tenv) 
    | If (e1, e2 , e3) -> let t2 = type_expr e2 tenv in 
                          let t3 =  type_expr e3 tenv  in
                          check e1 TBool tenv ; 
                          if (t3 = TUnit) then 
                            (check e2 TUnit tenv; TUnit) 
                          else 
                            (check e2 t3 tenv  ; t2)   
    | Fun (x,tx,e) -> let te = type_expr e (SymTbl.add x tx tenv) in TFun(tx,te)
    | App(f, a) ->
                  let tf = type_expr f tenv in
                  let ta = type_expr a tenv in
                  begin match tf with
                    | TFun(tx, te) ->
                      if tx = ta then
                      te
                      else
                      error "Application" 
                    | _ -> error "Need function"
                  end
    | Fix(x,tx,e) -> type_expr e (SymTbl.add x tx tenv)
    (* | Strct l -> match l with [] ->   *)  
    | GetF(e,x) -> check e (TStrct e) tenv; SymTbl.find x tenv 
    | SetF(e1,x,e2) ->  check e (TStrct e) tenv; let t = type_expr x tenv in check e2 t tenv; TUnit 
    | Seq (e1,e2) -> check e1 TUnit tenv ; type_expr e2 tenv (* on peut mettre t1 et pas TUnit et mettre avertissement si pas TUnit*)

  in

  type_expr prog.code SymTbl.empty

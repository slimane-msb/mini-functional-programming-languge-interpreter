open Mml

(* Environnement de typage : associe des types aux noms de variables *)
module SymTbl = Map.Make (String)

type tenv = typ SymTbl.t

(* Pour remonter des erreurs circonstanciées *)
exception Type_error of string

let print_warning message = Printf.printf "Warning: %s" message
let error s = raise (Type_error s)

let type_error ty_actual ty_expected =
  error
    (Printf.sprintf "expected %s but got %s"
       (typ_to_string ty_expected)
       (typ_to_string ty_actual))
(* vous pouvez ajouter d'autres types d'erreurs *)

(* Vérification des types d'un programme *)
let type_prog prog =
  (* Vérifie que l'expression [e] a le type [type] *)
  let rec check e typ tenv =
    let typ_e = type_expr e tenv in
    if typ_e <> typ then type_error typ_e typ
  and check_typ t1 t2 = if t1 <> t2 then type_error t1 t2
    
  
  and check_fields types l tenv =
    let search_struct strc =
      List.for_all2
        (fun (str1, e) (str2, t, _) ->
          check e t tenv;
          str1 = str2)
        l strc
    in
    match types with
    | [] -> error "Record not Found"
    | hd :: types' ->
        if not (search_struct (snd hd)) then check_fields types' l tenv
        else TStrct (fst hd)
  and check_set_fields types e1 x e2 tenv =
    let search_struct strc = List.exists (fun (str1, t, _) -> str1 = x) strc in
    match types with
    | [] -> error "Record not Found"
    | hd :: types' ->
        if not (search_struct (snd hd)) then
          check_set_fields types' e1 x e2 tenv
        else
          let _, t, m = List.find (fun (str1, t, _) -> str1 = x) (snd hd) in
          check e1 (TStrct (fst hd)) tenv;
          if not m then error "Field is not mutable";
          check e2 t tenv;
          TUnit
  and check_get_fields types e x tenv =
    let search_struct strc = List.exists (fun (str1, t, _) -> str1 = x) strc in
    match types with
    | [] -> error "Record not Found"
    | hd :: types' ->
        if not (search_struct (snd hd)) then check_get_fields types' e x tenv
        else
          let _, t, _ = List.find (fun (str1, t, _) -> str1 = x) (snd hd) in
          check e (TStrct (fst hd)) tenv;
          t
  and find_similar_id x tenv =
    let rec find_similar_id_aux x tenv similar_id =
      match tenv with
      | [] -> similar_id
      | (id, _) :: tenv' ->
          let distance = Utils.levenshtein_distance x id in
          if distance < !Utils.min_dist then
            if similar_id = "" then find_similar_id_aux x tenv' id
            else
              let distance_similar_id = Utils.levenshtein_distance x similar_id in
              if distance < distance_similar_id then
                find_similar_id_aux x tenv' id
              else find_similar_id_aux x tenv' similar_id
          else find_similar_id_aux x tenv' similar_id
    in
    find_similar_id_aux x (SymTbl.bindings tenv) ""
  (* Calcule le type de l'expression [e] *)
  and type_expr e tenv =
    match e with
    | Int _ -> TInt
    | Bool _ -> TBool
    | Unit -> TUnit
    | Var x -> (
        (* Vérifie si l'identifiant existe dans l'environnement de types et renvoie son type, sinon lève une erreur de type *)
        try SymTbl.find x tenv
        with Not_found ->
          (* Vérifie si l'identifiant est inexistant et propose un identifiant ressemblant s'il en existe *)
          let similar_id = find_similar_id x tenv in
          if similar_id = "" then
            raise (Type_error (Printf.sprintf "Undefined identifier: %s" x))
          else
            raise
              (Type_error
                 (Printf.sprintf "Undefined identifier: %s (Did you mean '%s'?)" x similar_id)))
    | Bop ((Add | Mul | Div | Sub | Mod), e1, e2) ->
        check e1 TInt tenv;
        check e2 TInt tenv;
        TInt
    | Bop ((Lt | Le), e1, e2) ->
        check e1 TInt tenv;
        check e2 TInt tenv;
        TBool
    | Bop ((And | Or), e1, e2) ->
        check e1 TBool tenv;
        check e2 TBool tenv;
        TBool
    | Bop ((Eq | Neq), e1, e2) ->
        let t1 = type_expr e1 tenv in
        check e2 t1 tenv;
        TBool
    | Uop (Not, e) ->
        check e TBool tenv;
        TBool
    | Uop (Neg, e) ->
        check e TInt tenv;
        TInt
    | Let (x, e1, e2) ->
        let t1 = type_expr e1 tenv in
        type_expr e2 (SymTbl.add x t1 tenv)
    | If (e1, e2, e3) ->
        let t2 = type_expr e2 tenv in
        let t3 = type_expr e3 tenv in
        check e1 TBool tenv;
        if t3 = TUnit then (
          check e2 TUnit tenv;
          TUnit)
        else (
          check e2 t3 tenv;
          t2)
    | Fun (x, tx, e) ->
        let te = type_expr e (SymTbl.add x tx tenv) in
        TFun (tx, te)
    | App (f, a) -> (
        let tf = type_expr f tenv in
        let ta = type_expr a tenv in
        match tf with
        | TFun (tx, te) ->
            check_typ tx ta;
            te
        | _ -> type_error tf (TFun (ta, ta)))
    | Fix (x, tx, e) ->
        let te = type_expr e (SymTbl.add x tx tenv) in
        check_typ tx te;
        te
    | Seq (e1, e2) ->
        let typ_e1 = type_expr e1 tenv in
        if typ_e1 <> TUnit then
          print_warning "expression doit être de type TUnit";
        let typ_e2 = type_expr e2 tenv in
        typ_e2
    | Strct l -> check_fields prog.types l tenv
    | GetF (e, x) -> check_get_fields prog.types e x tenv
    | SetF (e1, x, e2) -> check_set_fields prog.types e1 x e2 tenv
  in

  type_expr prog.code SymTbl.empty

open Format
open Mml

let rec print_fields ppf = function
  | [] -> fprintf ppf ""
  | (x, t, m) :: l -> let mut = if m then "mutable " else "" in
                 fprintf ppf "%s %s: %s;@ %a" mut x (typ_to_string t) print_fields l

let rec print_types ppf = function
  | [] -> fprintf ppf "@."
  | (t, s) :: l -> fprintf ppf "type %s = { @[%a}@]@.%a" t print_fields s print_types l


let uop_to_string = function
  | Neg -> "-"
  | Not -> "not "
let bop_to_string = function
  | Add -> "+"
  | Sub -> "-"
  | Mul -> "*"
  | Div -> "/"
  | Mod -> "mod"
  | Eq -> "="
  | Neq -> "<>"
  | Eqeq  -> "=="
  | Neqeq -> "!="
  | Lt  -> "<"
  | Le  -> "<="
  | Gt  -> ">"
  | Ge  -> ">="
  | And -> "&&"
  | Or  -> "||"


let rec print_expr ppf = function
  | Int n -> fprintf ppf "%i" n
  | Bool b -> fprintf ppf "%b" b
  | Unit -> fprintf ppf "()"
  | Uop(op, e) -> fprintf ppf "(%s %a)" (uop_to_string op) print_expr e
  | Bop(op, e1, e2) -> fprintf ppf "(@[%a %s %a)@]" print_expr e1 (bop_to_string op) print_expr e2
  | Var x -> fprintf ppf "%s" x
  | Let(x, e1, e2) -> fprintf ppf "@[(let %s =@ %a in@ %a)@]" x print_expr e1 print_expr e2
  | If(c, e1, e2) -> fprintf ppf "@[if %a then@ %a else@ %a@]" print_expr c print_expr e1 print_expr e2
  | Fun(x, t, e) -> fprintf ppf "fun (%s: %s) -> %a" x (typ_to_string t) print_expr e
  | App(e1, e2) -> fprintf ppf "(%a %a)" print_expr e1 print_expr e2
  | Fix(x, t, e) -> fprintf ppf "fix (%s: %s) = %a" x (typ_to_string t) print_expr e
  | Strct l -> fprintf ppf "{ @[%a}@]" print_defs l
  | GetF(e, x) -> fprintf ppf "(%a).%s" print_expr e x
  | SetF(e1, x, e2) -> fprintf ppf "(%a).%s <- %a" print_expr e1 x print_expr e2
  | Seq(e1, e2) -> fprintf ppf "%a; %a" print_expr e1 print_expr e2

  | While(c, b) -> fprintf ppf "@[while %a do@ %a@ done@]" print_expr c print_expr b

  | Ref e -> fprintf ppf "ref %a" print_expr e
  | Deref e -> fprintf ppf "!%a" print_expr e
  | Assign(e1, e2) -> fprintf ppf "%a := %a" print_expr e1 print_expr e2



  | Array l -> fprintf ppf "[ %a ]" print_exprs l
  |NewArray (e1, e2) -> fprintf ppf "new %a[%a]" print_expr e1 print_expr e2
  |GetA (e1, e2) -> fprintf ppf "%a[%a]" print_expr e1 print_expr e2
  |SetA (e1, e2, e3) -> fprintf ppf "%a[%a] <- %a" print_expr e1 print_expr e2 print_expr e3

  | Print e -> fprintf ppf "print %a" print_expr e
and print_defs ppf = function
  | [] -> fprintf ppf ""
  | (x, e) :: l -> fprintf ppf "%s = %a; %a" x print_expr e print_defs l
  and print_exprs ppf = function
  | [] -> fprintf ppf ""
  | e :: l -> fprintf ppf "%a; %a" print_expr e print_exprs l


let print_prog ppf prog =
  fprintf ppf "%a@.%a@." print_types prog.types print_expr prog.code

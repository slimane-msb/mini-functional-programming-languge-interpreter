# mini-functional-programming-languge-interpreter
a mini mini functional programming languge interpreter using ocaml lex and yacc | compiler design 

# Partie 1: Documentation :

## mini caml :

mini caml est un langage de programmation fonctionnel, qui est également une version simplifie du langage ocaml, mais il supporte aussi des tableau et des boucle itératives.

## Spécification:

- type de données basiques : int bool unit
    
    - ce compilateur nous permet d'utiliser les types de données de base tel que Int Bool et unit, il est pas nécessaire de déclarer le type a l'initialisation de la variable, car le versificateur de type le fait pour nous, cependant, il faut repréciser le type des argument des fonctionnes nécessaire
- structure de données
    
    - les structure dans ce langage sont définie ainsi
    
    ```caml
            type t2 = { s : t1; mutable b : bool; l : int;}
    ```
    
    - ou le mot clef type pour définir la structure dont le nom est `t2` et les attributs `s` `b` `l` sont de type `t1` `bool` `int` respectivement
        - le champ `b` est mutable ce qui nous permet de pouvoir modifer ca valeur.
        - pour accéder ou modifier un champ de ce type, on procède de la manière suivante :
            - accéder a un champ : `t2.s`
            - modifier un champ mutable: `t2.s <- newValue`
- application
    
    - l'application e1 sur e2 `expr1 expr2` permet d’exécuter l'application e1 sur l'argument e2, après avoir verfie que cette ligne est bien type.
- if else then
    
    - `if e1 then e2 else e3` cella correspond a la formule logique $( e1 \land e2 ) \lor (\neg e1 \land e2)$ dont sont interprétation est évalue uniquement l'expression concerne, par conséquent correspond a la compilation paresseuse de la formule logique ci-dessus
- let x=e1 in e2
    
    - afin de garder les valeurs dont le nom de la variables est le même dans des bloc différent, leur valeurs sont enregistre dans une hashtbl ou la commande `hashtbl.update` permet de changer la valeur de la variable, `hashtbl.remove` pour supprimer la variable, et `hashtbl.add` pour ajouter une nouvelle variable tout en gardant l'ancienne
    - fonctionne `let f (a1: t1) .. (an:tn) = e1 in e2`
        - qui définit une fonction dans les argument `a1 ... an` sont de type `t1 ... tn` respectivement, a la valeur final e1 ou' les arguments sont evalue's par leur valeur donnees en paramètre lors de l'appel a la fonctionne
    - fonctionne récursive : `let rec f (a1: t1) .. (an:tn) = e1 in e2`
        - permet de définir des fonctionnes récursives, avec le mot clef `rec`
- commentaire : `(* comment *)`
    
    - les commentaire en mml commence par `(*` ou le nombre de parenthésé ouvrante doit correspondre au nombre de parenthésé fermante `*)`

## Comment compiler un fichier mml :

- Les fichiers mml sont compiler par la commande `./run.bash file.mml` ,
    
    - le fichier `run.bash` ou' `$1` correspond au nom du fichier mml, correspond a :
    
    ```bash
            ocamlbuild mmlcat.native && 
            ./mmlcat.native tests/$1.mml; 
            ocamlbuild mmli.native && 
            ./mmli.native tests/$1.mml
    ```
    
    - et cela est exécuté après avoir supprime les fichiers `rm mmli.native && rm mmlcat.native` qui contient des données correspondante a la dernières machine ou le fichier est exécuté'

# Partie 2: Devloppement

## lexxer

- mots clefs
    - les mots clefs du langage mml sont définies dans le fichier `mmllexe.mll` ou les mots clefs sont stockes dans la hashtbl `h` est les mots qui y figure pas sont envoyé' au parser comme identifiants.
- commentaire
    - les commentaires sont représente entre `(*` et `*)`, une erreur `unterminated comment` est renvoyé en cas d'un commentaire non fini.

## parser

- confit LR(1) avec %inline
    
    - avant que la grammaire est écrit, certains conflits LR(1) sont résolue grâce a la séparation des opérateur binaire et unaire avec le mot-clefs `%inline%`
- grammaire de simple expression :
    
    - type de base
        - traduction littérale de la grammaire `simple_expression -> n`, ainsi pareillement pour `true, false, unit et ident`
    
    ```caml
            simple_expression:
                | n=CST { Int(n) }
    ```
    
    - structure.get
        - qui correspond a la grammaire `simple_expression -> { [ident = <expr> ;]+ }` pour l'initialisation de la structure
        - et `simple_expression -> <s_expr> . ident` pour `structure.attribut`

```ocaml
        simple_expression : 
            | se = simple_expression DOT x = IDENT { GetF(se,x) }
            | LBRAC  l = nonempty_list( x = IDENT ; EQ ;  e = expression ; 
                SEMICOLON { (x,e) } ) RBRAC {  Strct(l)  }
```

- grammaire de expression :
    - fonctionne récursive :
        
        - cela est traduit par la grammaire suivante, prenant par exemple une fonctionne récursive a deux arguments:
        
        ```ocaml
                let rec f (x1:t1) (x2:t2) : t = e1 in e2
        
                let(f,Fix(f,t1->(t2->t),Fun(x1:t1)->Fun(x2,t2)->e1),e1)
        ```
        
        - d'ou la grammaire pour $a_{n}$ argument :

```ocaml
        |   LET REC x = IDENT 
            l = list(LPAR ; x = IDENT ; COLON  ; t1 = typ ;  RPAR { (x,t1) }) 
            COLON t2 = typ EQ e1 = expression IN e2 = expression
                { let tfn = mk_fun_type l t2 in let fn = mk_fun l e1 
                in  Let(x,Fix(x,tfn,fn), e2 )} 
```

- conflits :
    
    - priorité a gauche :
        - $e1+e2+e3/e4 \; devient \; ((e1+e2)+(e3/e4)) .$
    
    ```ocaml
            %left EQEQ NEQ LE LT 
            %left MINUS PLUS
            %left DIV STAR MOD
    ```
    
    - les solutions pour les conflit `shift/reduce` pour les token `nonassoc` par ordre de priorité:

```ocaml
        %nonassoc IN 
        %nonassoc SEMICOLON
        %nonassoc THEN
        %nonassoc LARROW
        %nonassoc ELSE
        %nonassoc RARROW
        %nonassoc OR AND
        %nonassoc LBRAC LPAR IDENT CST FALSE TRUE 
```

## interpreter

- eval_aux :
    - une fonctionne auxiliaire `evali` `evalb` sont utilisée' afin d’évaluer e1 avant d’évaluer e2, et de renvoyer une erreur sans finir l’évaluation de toute l'expression. cela permet également d'avoir une compilation paresseuse pour les expressions logiques.

```ocaml
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
        | Bop (Eq, e1, e2) -> VBool (eval e1 env = eval e2 env)
        | Bop (Neq, e1, e2) -> VBool (eval e1 env <> eval e2 env)
        | Bop (Negs, e1, e2) -> (egalite_struct e1 e2) 
        | Bop (Lt, e1, e2) -> VBool (evali e1 env < evali e2 env)
        | Bop (Le, e1, e2) -> VBool (evali e1 env <= evali e2 env)
        | Uop (Neg, e1) -> VInt (-evali e1 env)
        | Uop (Not, e1) -> VBool (not (evalb e1 env))
```

- eval `let x=e1 in e2`
    - la valeur de x correspond a eval(e1) et celle-ci est stockée' ensuite dans l’environnement représentée par une hashtbl `env`

```ocaml
        let v1 = eval e1 env in
            eval e2 (Env.add x v1 env)
```

- eval structure
    - un autre environnement est crée pour la structure ou les valeurs des attributs sont stockées qui ensuite ajoutée' a l’environnement principale par un pointeur `v` vers cette table
    - ainsi pour récupérer la valeur d'un attribut
        - get: on cherche le pointeur qui pointe vers la table de la structure `let v = Hashtbl.find mem n` et ensuite l'arribut souhaite' avec `Hashtbl.find h x`
        - set : on procède de la même manière que get pour récupérer l'attribut x, et on le remplace ensuite par `Hashtbl.replace h x v2;`

```ocaml
    | Strct l ->
        let v = new_ptr () in
        let h = Hashtbl.create 16 in
        List.iter (fun (x, e) -> Hashtbl.add h x (eval e env)) l;
        Hashtbl.add mem v (VStrct h);
        VPtr v
```

- eval application
    - `e1 e2` ou e1 correspond a `VClos (x, b, env')` et `v2` a l’évaluation de `e2`

```ocaml
    | VClos (x, b, env') -> eval b (Env.add x v2 env')
```

- eval récursive

```ocaml
    | Fun (x', tx', e') ->
            let v = new_ptr () in
            Hashtbl.add mem v (VClos (x', e', Env.add x (VPtr v) env));
            VPtr v
```

## typechecker

- check e type
    - check e typ permet de vérifier si l'expression `e` est du type `typ` et renvoi une erreur du typage `type_error` dans le cas contraire

```ocaml
    let rec check e typ tenv =
        let typ_e = type_expr e tenv in
        if typ_e <> typ then type_error typ_e typ
      and check_typ t1 t2 = if t1 <> t2 then type_error t1 t2
```

- structure :
    - afin de vérifier que la structure t est bien type:
        
        - on doit d'abord trouver la structure correspondante :
        
        ```ocaml
            let search_struct strc =
              List.for_all2
                (fun (str1, e) (str2, t, _) ->
                  check e t tenv;
                  str1 = str2)
                l strc
            in
        ```
        
        - et ensuite vérifier le type de chaque field : par la suite de la fonctionne `check_field`
        
        ```ocaml
            match types with
            | [] -> error "Record not Found"
            | hd :: types' ->
                if not (search_struct (snd hd)) then check_fields types' l tenv
                else TStrct (fst hd)
        ```
        
- arrays:
    - on vérifie que tous les éléments sont du même types que le premier élément.

```ocaml
    | Array l ->
     (  match l with
      | [] -> TArray TUnit
      | e::l ->
        let t = type_expr e tenv in
        List.iter (fun e -> check_typ (type_expr e tenv) t ) l;
        TArray t
     ) 
```

## extensions

- tableau

```ocaml
(* parser *)
    |   LBRACKET l = list( e = expression ; SEMICOLON { e } ) 
        RBRACKET { Array(l) } // [ [ <expr> ; ]* ]
    |   WHILE c = expression DO e = expression DONE { While(c,e) } 

(* interpreter*)
    |   Array l ->
            let v = new_ptr () in
            let h = Hashtbl.create 16 in
            List.iteri (fun i e -> Hashtbl.add h i (eval e env)) l;
            Hashtbl.add mem v (VArray h);
            VPtr v
```

- messages d'erreur

```ocaml
    (*parser*)
    | LET error { expecting "identifier" }
    | LPAR e = expression error { unclosed "parenthesis" } // ( <expr> 

```
{

  open Lexing
  open Mmlparser

  exception Lexing_error of string

  let keyword_or_ident =
    let h = Hashtbl.create 50 in
    List.iter (fun (s, k) -> Hashtbl.add h s k)
      [
        ( "+"    , PLUS );
        ( "*"    , STAR );
        ( "-"    , SUB  ); 
        ( "/"    , DIV  );
        ( "mod"  , MOD  );
          
        ( "-"    , NEG  );
        ( "not " , NOT  );
          
        ( "="    , EQ   );
          
        ( "=="   , EQEQ );
        ( "!="   , NEQ  );
        ( "<"    , LT   );
        ( "<="   , LE   );
        ( ">"    , GT   );
        ( ">="   , GE   );
        ( "&&"   , AND  );
        ( "||"   , OR   );

        ( "("    , LPAR  );
        ( ")"    , RPAR  );
        ( "{"    , LBRAQ );
        ( "}"    , RBRAQ );

        ( "fun"  , FUN );
        ( "let"  , LET );
        ( "rec"  , REC );
        ( "in"   , IN  );
        ( "if"   , IF  );
        ( "then" , THEN );
        ( "else" , ELSE );

        ( "true" , BOOL((bool_of_string "true")) );
        ( "false", BOOL((bool_of_string "false")) );
        

        ( "->"   , ARROW  );
        ( "<-"   , BARROW );
        ( "."    , DOT );
        ( ";"    , PV  );
        ( ":"    , DP  );
      ] ;

    fun s ->
      try  Hashtbl.find h s
      with Not_found -> IDENT(s)

  let key_o_id = keyword_or_ident ; 
        
}

let digit = ['0'-'9']
let number = digit+
let alpha = ['a'-'z' 'A'-'Z']
let ident = ['a'-'z' '_'] (alpha | '_' | digit)*
let space = [' ' '\t' '\r']+
let space_opt = [' ' '\t' '\r']*
  
rule token = parse
  | ['\n']                      { new_line lexbuf; token lexbuf }
  | space                       { token lexbuf }
  | "(*"                        { comment lexbuf; token lexbuf }
  | number as n                 { CST(int_of_string n) }
  | "(" space_opt ")"           { UNIT }

  (*id or keyword using hashtbl*)
  | ident as id_or_key          { key_o_id id_or_key }  (* key_o_id pour ne pas creer la hashtbl a chaque fois || si ca marche pas faut just remplacer key_o_id par keyword_or_ident  *)

    (* END *)
  | _                           { raise (Lexing_error ("unknown character : " ^ (lexeme lexbuf))) }
  | eof                         { EOF }

and comment = parse
  | "*)"                        { () }
  | "(*"                        { comment lexbuf; comment lexbuf }
  | _                           { comment lexbuf }
  | eof                         { raise (Lexing_error "unterminated comment") }

{

  open Lexing
  open Mmlparser

  exception Lexing_error of string

  let keyword_or_ident =
    let h = Hashtbl.create 17 in
    List.iter (fun (s, k) -> Hashtbl.add h s k)
      [ (* À compléter *)
      ] ;
    fun s ->
      try  Hashtbl.find h s
      with Not_found -> IDENT(s)
        
}

let digit = ['0'-'9']
let number = digit+
let alpha = ['a'-'z' 'A'-'Z']
let ident = ['a'-'z' '_'] (alpha | '_' | digit)*
let space = [' ' '\t' '\r']+
  
rule token = parse
  | ['\n']                      { new_line lexbuf; token lexbuf }
  | space                       { token lexbuf }
  | "(*"                        { comment lexbuf; token lexbuf }
  | number as n                 { CST(int_of_string n) }
  | ("true"|"false") as b       { BOOL(bool_of_string b) }
  | "(" space ")"               { UNIT }
  | ident as id                 { IDENT(id) }

  | "+"                         { PLUS }
  | "*"                         { STAR }
  | "-"                         { SUB  } 
  | "/"                         { DIV  }
  | "mod"                       { MOD  }
    
  | "-"                         { NEG  }
  | "not "                      { NOT  }
    
  | "="                         { EQ   }
    
  | "=="                        { EQEQ }
  | "!="                        { NEQ  }
  | "<"                         { LT   }
  | "<="                        { LE   }
  | ">"                         { GT   }
  | ">="                        { GE   }
  | "&&"                        { AND  }
  | "||"                        { OR   }

  | "("                         { LPAR  }
  | ")"                         { RPAR  }
  | "{"                         { LBRAQ }
  | "}"                         { RBRAQ }

  | "fun"                         { FUN }
  | "let"                         { LET }
  | "rec"                         { REC }
  | "in"                         { IN  }
  | "if"                         { IF  }
  | "then"                         { THEN }
  | "else"                         { ELSE }

  | "->"                         { ARROW  }
  | "<-"                         { BARROW }
  | "."                         { DOT }
  | ";"                         { PV  }
  | ":"                         { DP  }

    (* END *)
  | _                           { raise (Lexing_error ("unknown character : " ^ (lexeme lexbuf))) }
  | eof                         { EOF }

and comment = parse
  | "*)"                        { () }
  | "(*"                        { comment lexbuf; comment lexbuf }
  | _                           { comment lexbuf }
  | eof                         { raise (Lexing_error "unterminated comment") }

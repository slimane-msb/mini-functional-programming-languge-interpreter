
(* The type of tokens. *)

type token = 
  | WHILE
  | UNIT
  | TYPE
  | TRUE
  | THEN
  | STAR
  | SEMICOLON
  | RPAR
  | REF
  | REC
  | RBRACKET
  | RBRACES
  | RARROW
  | PRINT
  | PLUS
  | OR
  | NOT
  | NEW
  | NEQEQ
  | NEQ
  | MUTABLE
  | MOD
  | MINUS
  | LT
  | LPAR
  | LET
  | LE
  | LBRACKET
  | LBRACES
  | LARROW
  | IN
  | IF
  | IDENT of (string)
  | GT
  | GE
  | FUN
  | FALSE
  | EQEQ
  | EQ
  | EOF
  | ELSE
  | DOT
  | DONE
  | DO
  | DIV
  | DEREF
  | CST of (int)
  | COMMA
  | COLON
  | BOOL of (bool)
  | ASSIGN
  | AND

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val program: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Mml.prog)

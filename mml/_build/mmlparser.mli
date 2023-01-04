
(* The type of tokens. *)

type token = 
  | UNIT
  | TYPE
  | TRUE
  | THEN
  | STAR
  | SEMICOLON
  | RPAR
  | REC
  | RBRAC
  | RARROW
  | PLUS
  | OR
  | NOT
  | NEQ
  | MUTABLE
  | MOD
  | MINUS
  | LT
  | LPAR
  | LET
  | LE
  | LBRAC
  | LARROW
  | IN
  | IF
  | IDENT of (string)
  | FUN
  | FALSE
  | EQEQ
  | EQ
  | EOF
  | ELSE
  | DOT
  | DIV
  | CST of (int)
  | COLON
  | BOOL of (bool)
  | AND

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val program: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Mml.prog)

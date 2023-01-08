# 1 "mmllexer.mll"
 

  open Lexing
  open Mmlparser

  exception Lexing_error of string

  let keyword_or_ident =
    let h = Hashtbl.create 17 in
    List.iter (fun (s, k) -> Hashtbl.add h s k)
      [ "true" , TRUE;  "false" , FALSE;  "fun", FUN  ;
        "let", LET ; "rec", REC ;  "in",IN  ; 
        "if", IF  ;  "then",THEN  ; "else", ELSE ; "mod", MOD  ;
         "not" , NOT ; "type", TYPE ; 
        (* "int", INT; "bool", BOOL  ;*) "unit", UNIT  ; "mutable", MUTABLE ; "while", WHILE  ; "do", DO ; 
        "done", DONE ;
        "ref" , REF  ;"new", NEW; "print" , PRINT
      ] ;
    fun s ->
      try  Hashtbl.find h s 
      with Not_found -> IDENT(s)
        

# 26 "mmllexer.ml"
let __ocaml_lex_tables = {
  Lexing.lex_base =
   "\000\000\221\255\222\255\225\255\226\255\228\255\229\255\230\255\
    \231\255\232\255\002\000\001\000\002\000\003\000\243\255\004\000\
    \021\000\006\000\247\255\006\000\249\255\250\255\079\000\021\000\
    \037\000\002\000\255\255\253\255\234\255\242\255\233\255\240\255\
    \245\255\223\255\241\255\238\255\236\255\235\255\044\000\252\255\
    \253\255\038\000\040\000\255\255\254\255";
  Lexing.lex_backtrk =
   "\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\033\000\033\000\018\000\031\000\255\255\011\000\
    \016\000\009\000\255\255\007\000\255\255\255\255\004\000\003\000\
    \028\000\001\000\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\002\000\002\000\255\255\255\255";
  Lexing.lex_default =
   "\002\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\255\255\255\255\255\255\255\255\000\000\255\255\
    \255\255\255\255\000\000\255\255\000\000\000\000\255\255\255\255\
    \255\255\255\255\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\040\000\000\000\
    \000\000\255\255\255\255\000\000\000\000";
  Lexing.lex_trans =
   "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\025\000\026\000\025\000\000\000\025\000\000\000\025\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \025\000\013\000\025\000\000\000\000\000\000\000\011\000\036\000\
    \024\000\004\000\020\000\021\000\003\000\019\000\009\000\018\000\
    \023\000\023\000\023\000\023\000\023\000\023\000\023\000\023\000\
    \023\000\023\000\015\000\014\000\016\000\017\000\012\000\035\000\
    \034\000\033\000\030\000\029\000\028\000\023\000\023\000\023\000\
    \023\000\023\000\023\000\023\000\023\000\023\000\023\000\027\000\
    \044\000\043\000\031\000\032\000\041\000\000\000\042\000\000\000\
    \000\000\000\000\000\000\006\000\000\000\005\000\000\000\022\000\
    \000\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \022\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \022\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \022\000\022\000\022\000\008\000\010\000\007\000\037\000\022\000\
    \022\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \022\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \022\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \022\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \022\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \022\000\022\000\000\000\000\000\000\000\000\000\022\000\000\000\
    \022\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \022\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \022\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \022\000\022\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\039\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    ";
  Lexing.lex_check =
   "\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\000\000\000\000\025\000\255\255\000\000\255\255\025\000\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \000\000\000\000\025\000\255\255\255\255\255\255\000\000\011\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\012\000\
    \013\000\015\000\016\000\017\000\019\000\023\000\023\000\023\000\
    \023\000\023\000\023\000\023\000\023\000\023\000\023\000\024\000\
    \041\000\042\000\016\000\016\000\038\000\255\255\038\000\255\255\
    \255\255\255\255\255\255\000\000\255\255\000\000\255\255\000\000\
    \255\255\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\010\000\022\000\
    \022\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \022\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \022\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \022\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \022\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \022\000\022\000\255\255\255\255\255\255\255\255\022\000\255\255\
    \022\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \022\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \022\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \022\000\022\000\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \000\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\038\000\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    ";
  Lexing.lex_base_code =
   "";
  Lexing.lex_backtrk_code =
   "";
  Lexing.lex_default_code =
   "";
  Lexing.lex_trans_code =
   "";
  Lexing.lex_check_code =
   "";
  Lexing.lex_code =
   "";
}

let rec token lexbuf =
   __ocaml_lex_token_rec lexbuf 0
and __ocaml_lex_token_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 32 "mmllexer.mll"
      ( new_line lexbuf; token lexbuf )
# 158 "mmllexer.ml"

  | 1 ->
# 33 "mmllexer.mll"
                     ( token lexbuf )
# 163 "mmllexer.ml"

  | 2 ->
# 34 "mmllexer.mll"
         ( comment lexbuf; token lexbuf )
# 168 "mmllexer.ml"

  | 3 ->
let
# 35 "mmllexer.mll"
              n
# 174 "mmllexer.ml"
= Lexing.sub_lexeme lexbuf lexbuf.Lexing.lex_start_pos lexbuf.Lexing.lex_curr_pos in
# 35 "mmllexer.mll"
                ( CST(int_of_string n) )
# 178 "mmllexer.ml"

  | 4 ->
let
# 36 "mmllexer.mll"
             id
# 184 "mmllexer.ml"
= Lexing.sub_lexeme lexbuf lexbuf.Lexing.lex_start_pos lexbuf.Lexing.lex_curr_pos in
# 36 "mmllexer.mll"
                ( keyword_or_ident id )
# 188 "mmllexer.ml"

  | 5 ->
# 37 "mmllexer.mll"
        ( PLUS )
# 193 "mmllexer.ml"

  | 6 ->
# 38 "mmllexer.mll"
        ( STAR )
# 198 "mmllexer.ml"

  | 7 ->
# 39 "mmllexer.mll"
        ( MINUS )
# 203 "mmllexer.ml"

  | 8 ->
# 40 "mmllexer.mll"
        ( DIV )
# 208 "mmllexer.ml"

  | 9 ->
# 41 "mmllexer.mll"
        ( EQ )
# 213 "mmllexer.ml"

  | 10 ->
# 42 "mmllexer.mll"
         (NEQ)
# 218 "mmllexer.ml"

  | 11 ->
# 43 "mmllexer.mll"
        ( COLON )
# 223 "mmllexer.ml"

  | 12 ->
# 44 "mmllexer.mll"
        ( SEMICOLON )
# 228 "mmllexer.ml"

  | 13 ->
# 45 "mmllexer.mll"
         ( EQEQ )
# 233 "mmllexer.ml"

  | 14 ->
# 46 "mmllexer.mll"
         ( NEQEQ )
# 238 "mmllexer.ml"

  | 15 ->
# 47 "mmllexer.mll"
         ( LE )
# 243 "mmllexer.ml"

  | 16 ->
# 48 "mmllexer.mll"
        ( LT )
# 248 "mmllexer.ml"

  | 17 ->
# 49 "mmllexer.mll"
         ( GE )
# 253 "mmllexer.ml"

  | 18 ->
# 50 "mmllexer.mll"
        ( GT )
# 258 "mmllexer.ml"

  | 19 ->
# 51 "mmllexer.mll"
         ( AND )
# 263 "mmllexer.ml"

  | 20 ->
# 52 "mmllexer.mll"
         ( OR )
# 268 "mmllexer.ml"

  | 21 ->
# 53 "mmllexer.mll"
         ( RARROW )
# 273 "mmllexer.ml"

  | 22 ->
# 54 "mmllexer.mll"
         ( LARROW )
# 278 "mmllexer.ml"

  | 23 ->
# 55 "mmllexer.mll"
        ( DOT )
# 283 "mmllexer.ml"

  | 24 ->
# 56 "mmllexer.mll"
        ( LBRACES )
# 288 "mmllexer.ml"

  | 25 ->
# 57 "mmllexer.mll"
        ( RBRACES )
# 293 "mmllexer.ml"

  | 26 ->
# 58 "mmllexer.mll"
        ( LBRACKET )
# 298 "mmllexer.ml"

  | 27 ->
# 59 "mmllexer.mll"
        ( RBRACKET )
# 303 "mmllexer.ml"

  | 28 ->
# 60 "mmllexer.mll"
        ( LPAR )
# 308 "mmllexer.ml"

  | 29 ->
# 61 "mmllexer.mll"
        ( RPAR )
# 313 "mmllexer.ml"

  | 30 ->
# 62 "mmllexer.mll"
        ( COMMA )
# 318 "mmllexer.ml"

  | 31 ->
# 63 "mmllexer.mll"
        ( DEREF )
# 323 "mmllexer.ml"

  | 32 ->
# 64 "mmllexer.mll"
         ( ASSIGN )
# 328 "mmllexer.ml"

  | 33 ->
# 65 "mmllexer.mll"
      ( raise (Lexing_error ("unknown character : " ^ (lexeme lexbuf))) )
# 333 "mmllexer.ml"

  | 34 ->
# 67 "mmllexer.mll"
      ( EOF )
# 338 "mmllexer.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf;
      __ocaml_lex_token_rec lexbuf __ocaml_lex_state

and comment lexbuf =
   __ocaml_lex_comment_rec lexbuf 38
and __ocaml_lex_comment_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 71 "mmllexer.mll"
      ( () )
# 350 "mmllexer.ml"

  | 1 ->
# 73 "mmllexer.mll"
      ( comment lexbuf; comment lexbuf )
# 355 "mmllexer.ml"

  | 2 ->
# 75 "mmllexer.mll"
      ( comment lexbuf )
# 360 "mmllexer.ml"

  | 3 ->
# 77 "mmllexer.mll"
      ( raise (Lexing_error "unterminated comment") )
# 365 "mmllexer.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf;
      __ocaml_lex_comment_rec lexbuf __ocaml_lex_state

;;


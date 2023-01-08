  exception Expecting of string
  let expecting nonterm  = 
    raise (Expecting ("Expecting " ^ nonterm))
  let unclosed nonterm  = 
    raise (Expecting ("Unclosed " ^ nonterm))
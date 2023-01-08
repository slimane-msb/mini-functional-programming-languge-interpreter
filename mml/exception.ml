  exception Expecting of string
  let expecting nonterm  = 
    raise (Expecting ("Expecting " ^ nonterm))
  let unclosed nonterm  = 
    raise (Expecting ("Unclosed " ^ nonterm))

  exception OutOfBounds of string
  exception VariableNotFound of string
  let out_of_bounds ()  = 
    raise (OutOfBounds ("Out of bounds "))


let variable_not_found () = 
  raise (VariableNotFound ("Variable not found "))
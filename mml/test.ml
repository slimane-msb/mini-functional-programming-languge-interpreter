(* let (mem: (int, string) Hashtbl.t) = Hashtbl.create 16 ;; 
  let new_ptr =
    let cpt = ref 0 in
    fun () -> incr cpt; !cpt
  in
;; *)

module Env = Map.Make(String)


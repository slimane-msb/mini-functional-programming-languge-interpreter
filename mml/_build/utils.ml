(* global variable minimum distance between two words *)
let min_dist = ref 2

(* global variable for the word with the minimum distance *)
let levenshtein_distance s1 s2 =
    let len1 = String.length s1 in
    let len2 = String.length s2 in
    let d = Array.make_matrix (len1 + 1) (len2 + 1) 0 in
    for i = 0 to len1 do
      d.(i).(0) <- i
    done;
    for j = 0 to len2 do
      d.(0).(j) <- j
    done;
    for i = 1 to len1 do
      for j = 1 to len2 do
        let cost = if s1.[i - 1] = s2.[j - 1] then 0 else 1 in
        d.(i).(j) <-
          min (min (d.(i - 1).(j) + 1) (d.(i).(j - 1) + 1))
            (d.(i - 1).(j - 1) + cost)
      done
    done;
    d.(len1).(len2)
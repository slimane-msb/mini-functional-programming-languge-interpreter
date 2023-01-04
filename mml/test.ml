let rec aux (acc :int) (n:int) : int = 
    if n == 0 then acc 
    else aux (acc + n) (n-1) 
  ;;
    aux 0 5
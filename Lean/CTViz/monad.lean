def cons (α : Type) (a : α) (as : List α) : List α :=
  List.cons a as

def x := [1,2.3]
#check x
#check List.cons

#check List.cons 10
#eval List.cons 10 [0,1,2,3]

#check cons Nat

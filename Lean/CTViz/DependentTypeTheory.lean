def cons (α : Type) (a : α) (as : List α) : List α :=
  List.cons a as

#check cons Nat        -- Nat → List Nat → List Nat
#check cons Bool       -- Bool → List Bool → List Bool
#check cons            -- (α : Type) → α → List α → List α

def identity : α → α := fun x => x

#check identity

def β (n : Nat) : Type :=
  match n with
  | 0 => Unit
  | n + 1 => Unit × β n

#eval (() : β 0)
#eval (((),()): β 1)
#eval (((),(),()): β 2)

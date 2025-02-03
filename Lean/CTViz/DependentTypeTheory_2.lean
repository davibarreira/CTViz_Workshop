-- def search {α} (f : Nat → Option α) (start : Nat) : α :=
--   match f start with
--   | .some x => x
--   | .none => search f (start + 1)

def search {α} (f : Nat → Option α) (start : Nat) : Option α :=
  match f start with
  | .some x => .some x
  | .none =>
    match start with
    | 0 => .none
    | n+1 => search f n

#eval search (fun n : Nat => some (toString (n+1))) 4

def f (n : Nat) : Option Nat :=
  if n * n ≤ 121 then .some n else .none

#eval search (fun n => if n * n ≤ 121 then .some n else .none) 0

#eval f 10


def fc (x:Float) (n:Nat) : Float := (n.toFloat) + 2*x
#eval 1 + 0.4
#check 1 + 0.4

#check fc 1





-- def ε {α : Type} (nl : NonEmptyList α) : α :=

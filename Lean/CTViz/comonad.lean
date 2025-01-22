structure NonEmptyList (α : Type) : Type where
  head : α
  tail : List α
deriving Repr

def nl := NonEmptyList.mk 1 [2, 3, 4]

def ε {α : Type} (nl : NonEmptyList α) : α := nl.head

def δ {α : Type} (nl : NonEmptyList α) : NonEmptyList (NonEmptyList α) :=
  NonEmptyList.mk nl []

def tails {α : Type} (l : List α) : List (NonEmptyList α) :=
  match l with
  | [] => []
  | (x :: xs) => NonEmptyList.mk x xs :: tails xs

#eval tails [1,2,3]
#eval tails ([] : List (NonEmptyList Int))
-- def dupl {α : Type} (nl Vj: NonEmptyList α) : NonEmptyList (NonEmptyList α) :=
def emptyNonEmptyListInt : List (NonEmptyList Int) := []
--   NonEmptyList.mk nl (tails nl.tail)

#eval δ nl
  -- match nl where
  --   |

#eval nl.head
#eval ε nl

def nlnl := NonEmptyList.mk (NonEmptyList.mk 1 []) []
#check nlnl
#eval ε nlnl

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


-- Store Comonad
inductive Store (s : Type) (c :Type) where
  | St : (s → c) → s → Store s c

instance : Functor (Store s) where
  map g st := match st with
    | Store.St f h => Store.St (g ∘ f) h

def extract (st : (Store s c)) : c :=
  match st with
    | Store.St f s' => f s'

def duplicate (st : Store s c) : Store s (Store s c) :=
  match st with
  | Store.St f s => Store.St (Store.St f) s


def myst := Store.St (fun x : Int => x + 1) 10


#eval extract myst
#check Store.St (Store.St (fun x : Int => x + 1))
#check Store.St (Store.St (fun x : Int => x + 1)) 10

-- extract :: Store s c -> c
-- extract (St f s) = f s
-- instance : Functor Hom where
--   map f H := Hom.mk (f ∘ H.x)

-- instance Functor (Store s) where
-- fmap g (St f s) = St (g . f) s

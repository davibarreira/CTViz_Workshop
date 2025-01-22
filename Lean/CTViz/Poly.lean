def hello := "world"

#eval hello


inductive Poly
| mk : (A : Type u) → (B : A → Type u) → Poly
-- PFunctor === Poly, one using structure the other inductive
structure PFunctor where
  (A : Type u)
  (B : A → Type u)
/-- Applying `P` to an object of `Type` -/
def PFunctor.Obj (P : PFunctor) (α : Type u)
  := Σ x : P.A, P.B x → α

def ex (P : PFunctor) (obj : PFunctor.Obj P Nat) : P.A × (P.B obj.1 → Nat) :=
  match obj with
  | ⟨x, f⟩ => (x, f)


def bnat : Nat → Type
  | 0 => Bool
  | _ => Nat

def fin (n : Nat) : Type := Fin n

def myPFunctor : PFunctor :=
  { A := Nat, B := fun _ => Bool }

def P : PFunctor :=
  { A := Nat, B := bnat }
def Q : PFunctor :=
  { A := Nat, B := fun n => Fin (n-1) }

def myFin : Fin 10 := ⟨3, by decide⟩


#check PFunctor.Obj myPFunctor Int

/-- Applying `P` to a morphism of `Type` -/
def PFunctor.map (P : PFunctor) (f : α → β) : P.Obj α → P.Obj β
  := fun ⟨a, g⟩ => ⟨a, f ∘ g⟩

def x : P.A := (2 : Nat)
def y : P.B x := (2 : Nat)
def z : P.B (0 : Nat) := (True : Bool)

def w : Q.B (10 : Nat) := ⟨3, by decide⟩

#check P.Obj Nat

def p := (10,2)
#eval p.2

-- def ex : P.Obj Nat := P.A 1


def Ba : Bool → Type
  | false => Empty
  | true => Unit

def F : PFunctor :=
  { A := Bool, B := Ba}

#eval (true : F.A)
#check F.B (false : F.A)
#check Empty → Nat

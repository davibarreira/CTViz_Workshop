structure F (A : Type) where
  x : A
deriving Repr

instance : Functor F where
  map f Fa := F.mk (f Fa.x)


structure Hom (B : Type) where
  x : Nat → B

def g : Hom Int := Hom.mk (fun x : Nat => (x : Int))

instance : Functor Hom where
  map f H := Hom.mk (f ∘ H.x)

def f : Int → String := fun x => toString x

#eval (f ∘ g.x) 10
#eval g.x 10


-- Define the Hom functor Hom(A, -)
def HomFunctor (A : Type) : Type → Type := λ X => A → X

-- Define the action of HomFunctor on morphisms (functions)
def HomFunctor.map {A X Y : Type} (f : X → Y) : HomFunctor A X → HomFunctor A Y :=
  λ g => f ∘ g

-- Make HomFunctor an instance of Functor
instance (A : Type) : Functor (HomFunctor A) where
  map := @HomFunctor.map A

-- def z : HomFunctor Int := (HomFunctor Int).mk
#check HomFunctor Int


inductive G (α : Type) where
  | g : α → G α
deriving Repr

def get {α : Type} (Ga : G α) : α :=
  match Ga with
  | G.g x => x

instance : Functor G where
  map f g := G.g (f (get g))

def gValue : G Int := G.g 10

#eval G.g 10
#eval gValue

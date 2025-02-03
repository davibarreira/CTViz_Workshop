def idf : A → A := fun x => x

structure F (A : Type) where
  x : A
deriving Repr

instance : Functor F where
  map f Fa := F.mk (f Fa.x)

instance [BEq α] : BEq (F α) where
  beq Fa Fb :=  Fa.x == Fb.x

inductive G α where
  | g : α → G α

instance [Repr α] : Repr (G α) where
  reprPrec
    | G.g x, _ => "G.g (" ++ repr x ++ ")"

instance : Functor G where
  map f Ga := match Ga with
    | G.g x => G.g (f x)

instance [BEq α] : BEq (G α) where
  beq
    | G.g x, G.g y => x == y

def get (ga : G α) : α :=
  match ga with
    | G.g x => x

def natFG {α : Type} (f : F α) : G α := G.g f.x

#eval get (natFG (F.mk 10))

#check @F

#eval get (G.g 10)

#check @idf

#eval idf 10


def Fx : F Int := ⟨10⟩

#eval natFG ((fun x => x + 1) <$> Fx)
#eval ((fun x => x + 1) <$> natFG Fx)
#eval natFG ((fun x => x + 1) <$> Fx) == ((fun x => x + 1) <$> natFG Fx)

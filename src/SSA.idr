module SSA

import Data.Vect

%default total

data SSAType =
  SUnit |
  SBool |
  SPtr SSAType |
  SNum Int |
  SStruct (n : Nat ** Vect n SSAType)

VarScope : Type
VarScope = SSAType -> Type

FuncSig : Type
FuncSig = (List SSAType, SSAType)

FuncScope : Type
FuncScope = FuncSig -> Type

data Args : List SSAType -> VarScope -> Type where
  ArgNil : Args [] v
  ArgCons : v p -> Args ps v -> Args (p :: ps) v

data CallSite : SSAType -> FuncScope -> VarScope -> Type where
  MkCallSite : f (argTypes, x) -> Args argTypes v -> CallSite x f v

data Op : FuncScope -> VarScope -> SSAType -> Type where
  Add : v (SNum n) -> v (SNum n) -> Op f v (SNum n)
  Sub : v (SNum n) -> v (SNum n) -> Op f v (SNum n)
  Mul : v (SNum n) -> v (SNum n) -> Op f v (SNum n)

  Cast : v (SPtr a) -> Op f v (SPtr b)
  ArrayOffset : v (SPtr x) -> v (SNum n) -> Op f v (SPtr x)
  FieldOffset : v (SPtr (SStruct (n ** l))) -> Elem x l -> Op f v (SPtr x)

  Call : CallSite x f v -> Op f v x

  Alloca : Int -> Op f v (SPtr x)
  Malloc : Int -> Op f v (SPtr x)
  Free : v (SPtr x) -> Op f v SUnit

  Load : v (SPtr a) -> Op f v a
  Store : v (SPtr a) -> v a -> Op f v SUnit

data Operand : VarScope -> VarScope where
  Var : v a -> Operand v a

  ConstBool : Bool -> Operand v SBool
  ConstUnit : Operand v SUnit

  Field : Operand v (SStruct (n ** l)) -> Elem x l -> Operand v x

data Term : SSAType -> FuncScope -> VarScope -> Type where
  TailCall : CallSite x f v -> Term x f v
  Conditional : v SBool -> CallSite x f v -> CallSite x f v -> Term x f v
  Return : v x -> Term x f v

data Intro : t -> (t -> Type) -> t -> Type where
  IntroBase : a = b -> Intro a v b
  IntroInd : v b -> Intro a v b

introMany : List t -> (t -> Type) -> t -> Type
introMany [] x = x
introMany (t :: ts) x = Intro t (introMany ts x)

data BasicBlock : SSAType -> FuncScope -> VarScope -> Type where
  Operator : Op f v a -> BasicBlock x f (Intro a v) -> BasicBlock x f v
  Terminator : Term x f v -> BasicBlock x f v

Function : VarScope -> FuncSig -> FuncScope -> Type
Function v (ps, ret) f =
  BasicBlock ret f (introMany ps v)

data Program : Vect v FuncSig -> Type where
  MkProgram : Program v

--letRec : (v:VarScope) -> (f:FuncScope) -> (signatures:Vect v FuncSig) -> HVect (map (\sig => HVect (map f signatures) -> Function v f sig) signatures) ->

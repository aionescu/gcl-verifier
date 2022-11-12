module Language.GCL.Syntax.Helpers where

import Data.Fix(Fix(..))

import Language.GCL.Syntax
import Data.Functor.Foldable (cata)

pattern I :: Int -> Expr
pattern I i = Fix (IntLit i)

pattern B :: Bool -> Expr
pattern B b = Fix (BoolLit b)

pattern T :: Expr
pattern T = B True

pattern F :: Expr
pattern F = B False

pattern (:&&) :: Expr -> Expr -> Expr
pattern a :&& b = Fix (Op And a b)

pattern (:||) :: Expr -> Expr -> Expr
pattern a :|| b = Fix (Op Or a b)

pattern (:=>) :: Expr -> Expr -> Expr
pattern a :=> b = Fix (Op Implies a b)

pattern (:==) :: Expr -> Expr -> Expr
pattern a :== b = Fix (Op Eq a b)

pattern (:!=) :: Expr -> Expr -> Expr
pattern a :!= b = Fix (Op Neq a b)

pattern (:<) :: Expr -> Expr -> Expr
pattern a :< b = Fix (Op Lt a b)

pattern (:<=) :: Expr -> Expr -> Expr
pattern a :<= b = Fix (Op Lte a b)

pattern Null' :: Expr
pattern Null' = Fix Null

pattern Not' :: Expr -> Expr
pattern Not' a = Fix (Not a)

pattern Var' :: Id -> Expr
pattern Var' a = Fix (Var a)

pattern Length' :: Id -> Expr
pattern Length' a = Fix (Length a)

pattern Cond' :: Expr -> Expr -> Expr -> Expr
pattern Cond' g t e = Fix (Cond g t e)

pattern RepBy' :: Expr -> Expr -> Expr -> Expr
pattern RepBy' v i e = Fix (RepBy v i e)

pattern Assert' :: Expr -> Stmt
pattern Assert' a = Fix (Assert a)

pattern Assume' :: Expr -> Stmt
pattern Assume' a = Fix (Assume a)

pattern If' :: Expr -> Stmt -> Stmt -> Stmt
pattern If' e s1 s2= Fix (If e s1 s2)

pattern While' :: Expr -> Stmt -> Stmt
pattern While' e s = Fix (While e s)

pattern Skip' :: Stmt
pattern Skip' = Fix Skip

pattern Seq' :: Stmt -> Stmt ->Stmt
pattern Seq' a b = Fix (Seq a b)

pattern Let' :: [Decl] -> Stmt -> Stmt
pattern Let' dc st = Fix (Let dc st)

pattern Assign' :: Id -> Expr -> Stmt
pattern Assign' i e = Fix (Assign i e)

pattern AssignIndex' :: Id -> Expr -> Expr -> Stmt
pattern AssignIndex' i e e2 = Fix (AssignIndex i e e2)

pattern AssignNew' :: Id -> Expr -> Stmt
pattern AssignNew' i e = Fix (AssignNew i e)

pattern AssignVal' :: Id -> Expr -> Stmt
pattern AssignVal' i e = Fix (AssignVal i e)

atoms :: Pred -> Int
atoms = cata \case
  Op o a b
    | o `elem` [And, Or, Implies] -> a + b
  Not b -> b
  Forall _ b -> b
  Exists _ b -> b
  Cond g _ _ -> g
  _ -> 1

mapExprs :: (Expr -> Expr) -> Stmt -> Stmt
mapExprs f = cata \case
  Assume e -> Assume' $ f e
  Assert e -> Assert' $ f e
  Assign v e -> Assign' v $ f e
  AssignIndex v i e -> AssignIndex' v (f i) $ f e
  AssignNew v e -> AssignNew' v $ f e
  AssignVal v e -> AssignVal' v $ f e
  If g t e -> If' (f g) t e
  While g s -> While' (f g) s
  s -> Fix s

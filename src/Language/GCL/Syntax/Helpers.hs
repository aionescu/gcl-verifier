module Language.GCL.Syntax.Helpers where

import Data.Fix(Fix(..))

import Language.GCL.Syntax

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

pattern Not' :: Expr -> Expr
pattern Not' a = Fix (Not a)

pattern IfEq' :: Expr -> Expr -> Expr -> Expr -> Expr
pattern IfEq' a b e1 e2 = Fix (Conditional (Fix (Op Eq a b)) e1 e2)

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

pattern AssignIndex' :: Id -> Expr -> Expr -> Stmt
pattern AssignIndex' i e e2 = Fix (AssignIndex i e e2)

pattern Assign' :: Id -> Expr -> Stmt
pattern Assign' i e = Fix (Assign i e)

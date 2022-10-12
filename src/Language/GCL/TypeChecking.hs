module Language.GCL.TypeChecking(typeCheck) where

import Control.Monad.Except(throwError)
import Control.Monad.Reader(ReaderT, asks, local, runReaderT)
import Data.Bifunctor(first)
import Data.Functor(($>), (<&>), void)
import Data.Functor.Foldable(cata)
import Data.Map.Strict(Map)
import Data.Map.Strict qualified as M
import Data.Text(Text)

import Language.GCL.Syntax
import Language.GCL.Utils(showT)
import Data.Fix (Fix(..))

type Env = Map Id Type
type TC = ReaderT Env (Either Text)

lookupVar :: Id -> TC Type
lookupVar v = asks (M.!? v) >>= \case
  Nothing -> throwError $ "Undeclared variable " <> v
  Just ty -> pure ty

unArray :: Type -> TC Type
unArray (Array a) = pure a
unArray t = throwError $ "Expected array type, found " <> showT t

check :: Type -> TC Type -> TC Type
check expected m = m >>= \t ->
  if t == expected
  then pure t
  else throwError $ "Expected " <> showT expected <> ", found " <> showT t

typeInferExpr :: Expr -> TC Type
typeInferExpr = cata \case
  IntLit{} -> pure Int
  BoolLit{} -> pure Bool
  Var v -> lookupVar v
  Length v -> (lookupVar v >>= unArray) $> Int
  BinOp op a b
    | op `elem` [Add, Sub, Mul, Div] -> check Int a *> check Int b $> Int
    | op `elem` [And, Or, Implies] -> check Bool a *> check Bool b $> Bool
    | op `elem` [Eq, Neq, Lt, Lte, Gt, Gte] -> check Int a *> check Int b $> Bool
    | otherwise -> error "typeInferExpr: Unreachable"
  Negate e -> check Bool e $> Bool
  Subscript v e -> check Int e *> lookupVar v >>= unArray
  Forall v e -> with [Decl v Int] $ check Bool e $> Bool
  Exists v e -> with [Decl v Int] $ check Bool e $> Bool
  Conditional g t e -> check Bool g *> t >>= (`check` e)

typeCheckExpr :: Type -> Expr -> TC ()
typeCheckExpr t e = void $ check t $ typeInferExpr e

with :: [Decl] -> TC a -> TC a
with ds m
  | M.size env /= length ds = throwError "Cannot shadow within the same binding"
  | otherwise = local (env <>) m
  where
    env = M.fromList $ ds <&> \(Decl v t) -> (v, t)

typeCheckStmt :: Stmt -> TC ()
typeCheckStmt = cata \case
  Skip -> pure ()
  Assume e -> void $ typeCheckExpr Bool e
  Assert e -> void $ typeCheckExpr Bool e
  Assign v e -> lookupVar v >>= (`typeCheckExpr` e)
  AssignIndex v i e -> typeCheckExpr Int i *> lookupVar v >>= unArray >>= (`typeCheckExpr` e)
  If g t e -> typeCheckExpr Bool g *> t *> e
  While g s -> typeCheckExpr Bool g *> s
  Seq a b -> a *> b
  Let ds s -> with ds s

typeCheck :: Program -> Either Text Program
typeCheck p@(Program _ i o b) =
  first ("Type error: " <>)
  $ runReaderT (typeCheckStmt (Fix $ Let (o : i) b) $> p) M.empty

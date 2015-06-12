module Text.Parsing.Parser.Token where

import Prelude

import Data.String
import Data.Either
import Data.List (List(..), (:), many, some)

import Control.Monad.State.Class hiding (get)
import Control.Monad.Error
import Control.Monad.Error.Class
import Control.MonadPlus

import Text.Parsing.Parser
import Text.Parsing.Parser.String
import Text.Parsing.Parser.Combinators
import Text.Parsing.Parser.Pos

token :: forall m a. (Monad m) => (a -> Position) -> ParserT (List a) m a
token tokpos = ParserT $ \(PState { input: toks, position: pos }) ->
  return $ case toks of
    Cons x xs -> { consumed: true, input: xs, result: Right x, position: tokpos x }
    _ -> parseFailed toks pos "expected token, met EOF"

when :: forall m a. (Monad m) => (a -> Position) -> (a -> Boolean) -> ParserT (List a) m a
when tokpos f = try $ do
  a <- token tokpos
  guard $ f a
  return a

match :: forall a m. (Monad m, Eq a) => (a -> Position) -> a -> ParserT (List a) m a
match tokpos token = when tokpos (== token)

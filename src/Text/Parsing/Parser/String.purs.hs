module Text.Parsing.Parser.String where

import Prelude

import Data.String
import Data.Either

import Control.Monad.Error
import Control.Monad.Error.Class
import Control.Monad.State.Class

import Data.Foldable
import Data.Monoid

import Text.Parsing.Parser
import Text.Parsing.Parser.Combinators

eof :: forall m. (Monad m) => ParserT String m {}
eof = ParserT $ \s -> 
  return $ case s of
    "" -> { consumed: false, input: s, result: Right {} }
    _ -> { consumed: false, input: s, result: Left (strMsg "Expected EOF") }

string :: forall m. (Monad m) => String -> ParserT String m String
string s = ParserT $ \s'  -> 
  return $ case indexOf s s' of
    0 -> { consumed: true, input: drop (length s) s', result: Right s }
    _ -> { consumed: false, input: s', result: Left (strMsg ("Expected " ++ show s)) }

char :: forall m. (Monad m) => ParserT String m String
char = ParserT $ \s' -> 
  return $ case s' of
    "" -> { consumed: false, input: s', result: Left (strMsg "Unexpected EOF") }
    _ -> { consumed: true, input: drop 1 s', result: Right (charAt 0 s') }

satisfy :: forall m. (Monad m) => (String -> Boolean) -> ParserT String m String
satisfy f = do
  p <- char
  if f p then return p else fail "Character did not satisfy predicate"

whiteSpace :: forall m. (Monad m) => ParserT String m String
whiteSpace = do
  list <- many $ string "\n" <|> string "\r" <|> string " " <|> string "\t"
  return $ foldMap id list


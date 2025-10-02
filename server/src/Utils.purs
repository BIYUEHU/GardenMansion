module Utils
  ( Schema
  , currentDir
  , endsWith
  , filterMap
  , log'
  , pathJoin
  , startsWith
  , validate
  )
  where

import Prelude

import Data.Either (Either(..))
import Data.List (List(..), foldr)
import Data.Maybe (Maybe(..))
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Console (log)
import Simple.JSON (class ReadForeign, readJSON)

foreign import endsWith :: String -> String -> Boolean

foreign import startsWith :: String -> String -> Boolean

filterMap :: forall a b. (a -> Maybe b) -> List a -> List b
filterMap f = foldr (\x acc -> case f x of
    Just y  -> Cons y acc
    Nothing -> acc) Nil

type Schema a = String -> Either String a

validate :: forall a. ReadForeign a => Schema a
validate str = case readJSON str of
    Left err -> Left $ show err
    Right x -> Right x

foreign import currentDir :: String

foreign import pathJoin :: String -> String -> String

log' ∷ ∀ (t24 ∷ Type -> Type). MonadEffect t24 ⇒ String → t24 Unit
log' = liftEffect <<< log

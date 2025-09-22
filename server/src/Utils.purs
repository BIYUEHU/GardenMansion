module Utils
  ( endsWith
  , filterMap
  , startsWith
  )
  where

import Data.List (List(..), foldr)
import Data.Maybe (Maybe(..))

foreign import endsWith :: String -> String -> Boolean

foreign import startsWith :: String -> String -> Boolean


filterMap :: forall a b. (a -> Maybe b) -> List a -> List b
filterMap f = foldr (\x acc -> case f x of
    Just y  -> Cons y acc
    Nothing -> acc) Nil
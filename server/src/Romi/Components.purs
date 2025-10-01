module Romi.Components
  ( AfterComponents
  , AfterHandler
  , BeforeComponents
  , BeforeHandler
  , Component(..)
  , Components
  , Guard
  , Handler(..)
  , Rule(..)
  , checkAfters
  , checkBefores
  )
  where

import Prelude

import Data.Either (Either)
import Data.List (List(..))
import Data.Maybe (Maybe(..))
import Data.String (Pattern(..), contains)
import Romi.Common (Romi)
import Romi.Request (Method, Request)
import Romi.Response (Response)
import Utils (endsWith, startsWith)

data Rule = Any
          | StartWith String
          | EndWith String
          | Contains String
          | Is String
          | Not String

checkRule :: Rule -> String -> Boolean
checkRule Any _ = true
checkRule (StartWith s) path = startsWith s path
checkRule (EndWith s) path = endsWith s path
checkRule (Contains s) path = contains (Pattern s) path
checkRule (Is s) path = s == path
checkRule (Not s) path = not (contains (Pattern s) path)

type BeforeHandler a = Request -> Romi a (Maybe Response)

type AfterHandler a =  Request -> Response -> Romi a Response

type Guard a b = { guard :: Request -> Romi a (Either Response b), handler :: Request -> b -> Romi a Response}

data Handler a = Direct (Request -> Romi a Response) | Guard (forall b. Guard a b)

data Component a = Route Method String (Handler a)
                | Before Rule (BeforeHandler a)
                | After Rule (AfterHandler a)

type Components a = Array (Component a)

type BeforeComponents a =  List { rule :: Rule, components :: BeforeHandler a }

type AfterComponents a = List { rule::Rule,components :: AfterHandler a }

checkBefores :: forall a. BeforeComponents a -> BeforeHandler a
checkBefores components req = check components Nothing
  where
    check :: BeforeComponents a -> Maybe Response -> Romi a (Maybe Response)
    check _ (Just res) = pure $ Just res
    check Nil res = pure res
    check (Cons { rule, components: components' } rest) Nothing
      | checkRule rule (req.path) = do
          res <- components' req
          case res of
            Just res' -> pure $ Just res'
            Nothing -> check rest Nothing
      | otherwise = check rest Nothing


checkAfters :: forall a. AfterComponents a -> AfterHandler a
checkAfters Nil _ res = pure res
checkAfters (Cons { rule, components } rest) req res
  | checkRule rule (req.path) = do
      res' <- components req res
      checkAfters rest req res'
  | otherwise = checkAfters rest req res


module App.Guard where

import Prelude

import App.Auth (parseToken)
import App.Models (users)
import App.Schema (parseReqMessageApi)
import App.Types (GuardState)
import Data.Bifunctor (lmap)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Models (ModelUserSingle, ReqMessageApi)
import Romi.Request (select)
import Romi.Response (errorForbidden, errorSchema)

authFactory :: forall a. GuardState a -> GuardState { dat :: a, user :: ModelUserSingle }
authFactory f req = do
  result <- f req
  case result of
    Left res -> pure $ Left res
    Right dat -> case select req.headers "Authorization" >>= parseToken of
      Just { name, password } -> do
        user <- users.select (\{userName, userPassword, userAlive} -> userName == name && userPassword == password && userAlive)
        pure $ case user of
          Just user' -> Right { dat, user: user' }
          Nothing -> Left $ errorForbidden "Invalid credentials"
      Nothing -> pure $ Left $ errorForbidden "Authorization header not found"

checkCreatingMessage :: GuardState ReqMessageApi
checkCreatingMessage req = pure $ lmap errorSchema $ parseReqMessageApi req.body

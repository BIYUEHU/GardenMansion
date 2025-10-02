module App.Guard where

import Prelude

import App.Schema (parseReqMessageApi)
import App.Types (GuardState, State(..))
import Control.Monad.Reader (ask)
import Data.Bifunctor (lmap, rmap)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Models (ReqMessageApi, ResUserSingle)
import Romi.Response (Response(..), Status(..), errorSchema)

checkCreatingMessage :: GuardState { dat::ReqMessageApi, user :: ResUserSingle }
checkCreatingMessage req = do
  s <- ask
  pure $ case s of
    State { user: Just user } -> rmap (\dat -> { dat, user }) $ lmap errorSchema $ parseReqMessageApi req.body
    _ -> Left $ StatusRes BadRequest

module App.Components where

import Prelude

import App.Types (BeforeHandlerState, State(..))
import Control.Monad.Reader (withReaderT)
import Data.Maybe (Maybe(..))
import Romi.Request (select)
import Utils (log')

logger :: BeforeHandlerState
logger req = do
  log' $ "[" <> show req.method <> "] " <> req.path <> " | Query: " <> show req.query <> " | Body: " <> req.body
  pure Nothing

-- authorization :: BeforeHandlerState
-- authorization req = do
--   case select req.headers "Authorization" of
--     Just token -> withReaderT (\State { db, user } -> State { db, user })
--     Nothing -> pure Nothing

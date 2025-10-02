module App.Handler where

import Prelude

import App.Types (DBKey(..), HandlerState, dbm)
import Data.Maybe (maybe)
import Romi.Response (Response(..))

fetchAllMessages :: HandlerState
fetchAllMessages _ = do
  messages <- dbm.get Messages
  pure $ JsonRes $ (maybe "[]" identity) messages

-- createMessage :: HandlerState
-- createMessage = guarded checkCreatingMessage $ \_ { messageText, messageReplyMessageId } -> do
--   dbm.put Messages $ show { }

fetchAllExpenses :: HandlerState
fetchAllExpenses _ = do
  expenses <- dbm.get Expenses
  pure $ JsonRes $ (maybe "[]" identity) expenses

fetchAllUsers :: HandlerState
fetchAllUsers _ = do
  users <- dbm.get Users
  pure $ JsonRes $ (maybe "[]" identity) users

fetchMeta :: HandlerState
fetchMeta _ = do
  meta <- dbm.get Meta
  pure $ JsonRes $ (maybe "{}" identity) meta

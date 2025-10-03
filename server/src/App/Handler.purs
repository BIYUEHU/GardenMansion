module App.Handler where

import Prelude

import App.Guard (authFactory, checkCreatingMessage)
import App.Models (DBKey(..), dbm, expenses, messages, users)
import App.Types (HandlerState)
import Data.Maybe (maybe)
import Romi.Components (guarded)
import Romi.Response (Response(..), Status(..))

fetchAllMessages :: HandlerState
fetchAllMessages _ = do
  messages <- messages.selectAll
  pure $ JsonRes $ show messages

createMessage :: HandlerState
createMessage = guarded (authFactory checkCreatingMessage) $ \_ { user, dat: { messageText, messageReplyId } } -> do
  messages.insert
    { messageId: 22
    , messageText
    , messageUserId: user.userId
    , messageReplyId
    , messageReleaseTime: ""
    }
  pure $ StatusRes Created

fetchAllExpenses :: HandlerState
fetchAllExpenses _ = do
  expenses <- expenses.selectAll
  pure $ JsonRes $ show expenses

fetchAllUsers :: HandlerState
fetchAllUsers _ = do
  users <- users.selectAll
  pure $ JsonRes $ show users

fetchMeta :: HandlerState
fetchMeta _ = do
  meta <- dbm.get Meta
  pure $ JsonRes $ (maybe "{}" identity) meta

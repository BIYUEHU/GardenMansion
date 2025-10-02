module App.Bootstrap
  ( bootstrap
  )
  where

import Prelude

import App.Components (logger)
import App.Constant (dbDirectory, dbPrefix, defaultModelMeta, defaultServerPort)
import App.Handler (fetchAllExpenses, fetchAllMessages, fetchAllUsers)
import App.Schema (parseModelExpenses, parseModelMessages, parseModelMeta, parseModelUsers)
import App.Types (DBKey(..), State(..), dbm)
import Control.Monad.Reader (runReaderT)
import Data.Either (isLeft)
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Romi.Components (Component(..), Components, Rule(..))
import Romi.Db (DB, dbCreate)
import Romi.Request (Method(..))
import Romi.Server (createServer, listen)
import Utils (log')

dbInit :: Aff DB
dbInit = do
  db <- dbCreate dbDirectory dbPrefix
  runReaderT (do
    dbm.putOrIf Users "[]" $ isLeft <<< parseModelUsers
    dbm.putOrIf Messages "[]" $ isLeft <<< parseModelMessages
    dbm.putOrIf Expenses "[]" $ isLeft <<< parseModelExpenses
    dbm.putOrIf Meta (show defaultModelMeta) $ isLeft <<< parseModelMeta
  ) db
  pure db

components :: Components State
components =
  [ Before Any logger
  , Route GET "/api/messages" fetchAllMessages
  , Route GET "/api/expenses" fetchAllExpenses
  , Route GET "/api/users" fetchAllUsers
  ]

bootstrap :: Aff Unit
bootstrap = do
  db <- dbInit
  log' "starting server..."
  server <- createServer components (State { db, user: Nothing }) Nothing
  liftEffect $ listen server defaultServerPort (log $ "Server is running on http://localhost:" <> show defaultServerPort)

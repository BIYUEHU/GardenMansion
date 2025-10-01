module Main where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Romi.Components (AfterHandler, BeforeHandler, Component(..), Components, Handler(..), Rule(..))
import Romi.Db (DB, dbCreate)
import Romi.Request (Method(..), select)
import Romi.Response (Response(..), Status(..), toResponseRaw)
import Romi.Server (createServer, listen)

logger :: BeforeHandler DB
logger req = do
  liftEffect $ log $ "[" <> show req.method <> "] " <> req.url <> " " <> req.path <> " " <> show req.query <> " " <> req.body
  pure Nothing

gggg :: AfterHandler DB
gggg req res |
  req.path == "/a/hello" = pure $ JsonRes $ show {msg: "Goodbye, World!", raw: (toResponseRaw res).body}
  | otherwise = pure res

helloHandler :: Handler DB
helloHandler = Direct $ \req -> pure $ JsonRes $ show {msg: "Hello, World!", dat: req.method}

set :: Handler DB
set = Guard { guard: \req -> pure $ case select req.query "k" of
              Just k -> case select req.query "v" of
                Just v -> Right 1
                Nothing -> Left $ JsonStatusRes BadRequest "Missing value"
              Nothing -> Left $ JsonStatusRes BadRequest "Missing key"
            , handler: \_ dat -> pure $ JsonRes $ show {msg: "Setting " <> dat.k <> " to " <> dat.v}
      }

components :: Components DB
components =
  [ Before Any logger
  , Route GET "/hello" helloHandler
  , Route GET "/a/hello" helloHandler
  , After (StartWith "/a") gggg
  ]

main :: Effect Unit
main = do
  log "Starting server..."
  launchAff_ do
    db <- dbCreate "./db" "testing"
    server <- createServer components db Nothing
    liftEffect $ listen server 8080 ( do
      log "Server is running on http://localhost:8080"
      pure unit
      )

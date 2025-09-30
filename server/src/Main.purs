module Main where

import Prelude
import Framework (AfterHandler, BeforeHandler, Component(..), Components, Handler(..), Method(..), Response(..), Rule(..), createServer, listen, toResponseRaw)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Console (log)

logger :: BeforeHandler
logger req = do
  log $ "[" <> show req.method <> "] " <> req.url <> " " <> req.path <> " " <> show req.query <> " " <> req.body
  pure Nothing

gggg :: AfterHandler
gggg req res |
  req.path == "/a/hello" = pure $ JsonRes $ show {msg: "Goodbye, World!", raw: (toResponseRaw res).body}
  | otherwise = pure res

helloHandler :: Handler
helloHandler = Direct $ \req -> pure $ JsonRes $ show {msg: "Hello, World!", dat: req.method}

components :: Components
components =
  [ Before Any logger
  , Route GET "/hello" helloHandler
  , Route GET "/a/hello" helloHandler
  , After (StartWith "/a") gggg
  ]

main :: Effect Unit
main = do
  log "Starting server..."
  server <- createServer components Nothing
  listen server 8080 ( do
    log "Server is running on http://localhost:8080"
    pure unit
    )

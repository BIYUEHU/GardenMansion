module App.Constant where

import Prelude

import Models (ModelMeta)
import Utils (currentDir, pathJoin)

defaultServerPort :: Int
defaultServerPort = 8080

defaultModelMeta :: ModelMeta
defaultModelMeta =
  { webUrl: "http://localhost:" <> show defaultServerPort
  , webName: "Garden Mansion"
  , webTitle: "Garden Mansion"
  , webNotice: "Here's a notice for the Garden Mansion"
  , webStartTime: 1
  }

dbDirectory :: String
dbDirectory = pathJoin currentDir "db"

dbPrefix :: String
dbPrefix = "garden_mansion_"


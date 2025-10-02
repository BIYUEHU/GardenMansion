module Romi.Request
  ( Headers
  , Method(..)
  , Query
  , Request
  , parseMethod
  , select
  )
  where

import Prelude

import Data.Array (find)
import Data.Maybe (Maybe)
import Data.Tuple (Tuple(..), snd)

data Method = GET | POST | PUT | DELETE | HEAD | OPTIONS

derive instance Eq Method

instance Show Method where
  show GET = "GET"
  show POST = "POST"
  show PUT = "PUT"
  show DELETE = "DELETE"
  show HEAD = "HEAD"
  show OPTIONS = "OPTIONS"

parseMethod :: String -> Method
parseMethod "GET" = GET
parseMethod "POST" = POST
parseMethod "PUT" = PUT
parseMethod "DELETE" = DELETE
parseMethod "HEAD" = HEAD
parseMethod _ = OPTIONS

type Query = Array (Tuple String String)

type Headers = Array (Tuple String String)

select :: Array (Tuple String String) -> String -> Maybe String
select kvs key = snd <$> find (\(Tuple k _) -> k == key) kvs

type Request =
  { query :: Query
  , headers :: Headers
  , method :: Method
  , path :: String
  , body :: String
  }

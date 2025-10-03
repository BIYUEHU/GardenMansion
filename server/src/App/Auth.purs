module App.Auth
  ( Token
  , generateToken
  , parseToken
  )
  where

import Prelude

import Data.Maybe (Maybe(..))
import Data.String (Pattern(..), split)


foreign import decodeStr :: String -> String

foreign import encodeStr :: String -> String

type Token = { name :: String, password :: String }

parseToken :: String -> Maybe Token
parseToken s = case split (Pattern ":|:") s of
  [name, password] -> Just { name: decodeStr name, password: decodeStr password }
  _ -> Nothing

generateToken :: Token -> String
generateToken { name, password } = encodeStr (name) <> ":|:" <> encodeStr (password)

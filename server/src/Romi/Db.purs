-- Database module based on Idris2 package
module Romi.Db
  ( BatchOp(..)
  , DB
  , dbBatch
  , dbClose
  , dbCreate
  , dbDel
  , dbGet
  , dbPut
  )
  where

import Prelude

import Control.Promise (Promise, toAffE)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (Aff)

data DB

foreign import dbCreatePrim :: String -> String -> Effect (Promise DB)

dbCreate :: String -> String  -> Aff DB
dbCreate name prefix = toAffE $ dbCreatePrim name prefix

foreign import dbGetPrim :: DB -> String -> (String -> Maybe String) ->  Maybe String -> Effect (Promise (Maybe String))

dbGet :: DB -> String -> Aff (Maybe String)
dbGet db key = toAffE $ dbGetPrim db key Just Nothing

foreign import dbPutPrim :: DB -> String -> String -> Effect (Promise Unit)

dbPut :: DB -> String -> String -> Aff Unit
dbPut db key value = toAffE $ dbPutPrim db key value

foreign import dbDelPrim :: DB -> String -> Effect (Promise Unit)

dbDel :: DB -> String -> Aff Unit
dbDel db key = toAffE $ dbDelPrim db key

data BatchOp = Put String String | Del String

data BatchOpPrim

foreign import toBatchOpPutPrim :: String -> String -> BatchOpPrim

foreign import toBatchOpDelPrim :: String -> BatchOpPrim

foreign import dbBatchPrim :: DB -> Array BatchOpPrim -> Effect (Promise Unit)

dbBatch :: DB -> Array BatchOp -> Aff Unit
dbBatch db ops = toAffE $ dbBatchPrim db (map (\x ->
  case x of
    Put k v -> toBatchOpPutPrim k v
    Del k -> toBatchOpDelPrim k
  ) ops)

foreign import dbClosePrim :: DB -> Effect (Promise Unit)

dbClose :: DB -> Aff Unit
dbClose db = toAffE $ dbClosePrim db



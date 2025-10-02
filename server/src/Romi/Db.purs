-- Database module based on Idris2 package
module Romi.Db
  ( BatchOp(..)
  , BatchOpModel(..)
  , DB
  , DBM
  , askDB
  , class HasDB
  , dbBatch
  , dbClose
  , dbCreate
  , dbDel
  , dbDelOrIf
  , dbGet
  , dbPut
  , dbPutOr
  , dbPutOrIf
  , dbmOf
  , getDB
  )
  where

import Prelude

import Control.Monad.Reader (ask)
import Control.Promise (Promise, toAffE)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff.Class (liftAff)
import Romi.Common (Romi)

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

foreign import dbPutOrPrim :: DB -> String -> String -> Effect (Promise Unit)

dbPutOr :: DB -> String -> String -> Aff Unit
dbPutOr db key value = toAffE $ dbPutOrPrim db key value

foreign import dbPutOrIfPrim :: DB -> String -> String -> (String -> Boolean) -> Effect (Promise Unit)

dbPutOrIf :: DB -> String -> String -> (String -> Boolean) -> Aff Unit
dbPutOrIf db key value pred = toAffE $ dbPutOrIfPrim db key value pred

foreign import dbDelPrim :: DB -> String -> Effect (Promise Unit)

dbDel :: DB -> String -> Aff Unit
dbDel db key = toAffE $ dbDelPrim db key

foreign import dbDelOrIfPrim :: DB -> String -> (String -> Boolean) -> Effect (Promise Unit)

dbDelOrIf :: DB -> String -> (String -> Boolean) -> Aff Unit
dbDelOrIf db key pred = toAffE $ dbDelOrIfPrim db key pred

data BatchOp = Put String String | Del String

data BatchOpModel a = PutM a String | DelM a

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

class HasDB a where
  getDB :: a -> Romi a DB

instance HasDB DB where
  getDB = pure

askDB :: forall a. HasDB a => Romi a DB
askDB = ask >>= getDB

type DBM b =
  forall a . HasDB a => Show b =>
    { get :: HasDB a => b -> Romi a (Maybe String)
    , put :: HasDB a => b -> String -> Romi a Unit
    , putOr :: HasDB a => b -> String -> Romi a Unit
    , putOrIf :: HasDB a => b -> String -> (String -> Boolean) -> Romi a Unit
    , del :: HasDB a => b -> Romi a Unit
    , delOrIf :: HasDB a => b -> (String -> Boolean) -> Romi a Unit
    , batch :: HasDB a => Array (BatchOpModel b) -> Romi a Unit
    }

dbmOf :: forall a. DBM a
dbmOf =
  { get: \k -> do
      db <- askDB
      liftAff $ dbGet db $ show k
  , put: \k v -> do
      db <- askDB
      liftAff $ dbPut db (show k) v
  , putOr: \k v -> do
      db <- askDB
      liftAff $ dbPutOr db (show k) v
  , putOrIf: \k v pred -> do
      db <- askDB
      liftAff $ dbPutOrIf db (show k) v pred
  , del: \k -> do
      db <- askDB
      liftAff $ dbDel db $ show k
  , delOrIf: \k pred -> do
      db <- askDB
      liftAff $ dbDelOrIf db (show k) pred
  , batch: \ops -> do
      db <- askDB
      liftAff $ dbBatch db $ map (\x -> case x of
        PutM k v -> Put (show k) v
        DelM k -> Del (show k)
      ) ops
  }

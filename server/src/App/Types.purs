module App.Types where

import Prelude

import Data.Maybe (Maybe)
import Models (ResUserSingle)
import Romi.Components (AfterHandler, BeforeHandler, Handler, Guard)
import Romi.Db (class HasDB, DB, DBM, dbmOf)


data DBKey = Users | Expenses | Messages | Meta

instance Show DBKey where
  show Users = "users"
  show Expenses = "expenses"
  show Messages = "messages"
  show Meta = "meta"

newtype State = State
  { user :: Maybe ResUserSingle
  , db :: DB
  }

instance HasDB State where
  getDB (State { db, user:_ }) = pure db

dbm :: DBM DBKey
dbm = dbmOf

type BeforeHandlerState = BeforeHandler State

type HandlerState = Handler State

type AfterHandlerState = AfterHandler State

type GuardState b = Guard State b

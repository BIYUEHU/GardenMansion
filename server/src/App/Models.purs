module App.Models
  ( DBKey(..)
  , dbm
  , expenses
  , messages
  , users
  )
  where

import Prelude

import App.Schema (parseModelExpenses, parseModelMessages, parseModelUsers)
import App.Types (State)
import Data.Either (Either(..))
import Models (ModelUserSingle, ResMessageSingle, ResExpenseSingle)
import Romi.Db (DBM, ListModel, createModel, dbmOf)

data DBKey = Users | Expenses | Messages | Meta

instance Show DBKey where
  show Users = "users"
  show Expenses = "expenses"
  show Messages = "messages"
  show Meta = "meta"

dbm :: DBM DBKey
dbm = dbmOf

type ListModel' a = ListModel State a

abandon :: forall a b. Either a (Array b) -> Array b
abandon (Left _) = []
abandon (Right xs) = xs

users :: ListModel' ModelUserSingle
users = createModel
  { key: Users
  , decode: parseModelUsers >>> abandon
  , encode: show
  }

messages :: ListModel' ResMessageSingle
messages = createModel
  { key: Messages
  , decode: parseModelMessages >>> abandon
  , encode: show
  }

expenses :: ListModel' ResExpenseSingle
expenses = createModel
  { key: Expenses
  , decode: parseModelExpenses >>> abandon
  , encode: show
  }

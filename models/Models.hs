{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}

{-# HLINT ignore "Use newtype instead of data" #-}
module Models where

-- Types Definition

data ReqMessageApi = ReqMessageApi
  { res_messageText :: String,
    res_messageReplyMessageId :: String
  }

data ResMessageSingle = ResMessageSingle
  { req_messageId :: Int,
    req_messageText :: String,
    req_messageUserId :: Int,
    req_messageReplyId :: Maybe Int,
    req_messageReleaseTime :: String
  }

type ResMessageApi = [ResMessageSingle]

type ModelMessages = [ResMessageSingle]

data ReqExpenseApi = ReqExpenseApi
  { req_expenseUserId :: String,
    req_expenseAmount :: Double,
    req_expenseComment :: String
  }

data ResExpenseSingle = ResExpenseSingle
  { res_expenseId :: Int,
    res_expenseUserId :: String,
    res_expenseAmount :: Double,
    res_expenseComment :: String,
    res_expenseTime :: String
  }

type ResExpenseApi = [ResExpenseSingle]

type ModelExpenses = [ResExpenseSingle]

data ReqLoginApi = ReqLoginApi
  { req_loginUsername :: String,
    req_loginPassword :: String
  }

data ReqInfoRenameApi = ReqInfoRenameApi
  { req_infoUsername :: String
  }

data ReqInfoPasswordApi = ReqInfoPasswordApi
  { req_infoPasswordOld :: String,
    req_infoPasswordNew :: String
  }

data ResInfoApi = ResInfoApi
  { res_infoId :: Int,
    res_infoName :: String,
    res_infoEmail :: String,
    res_infoTime :: Int,
    res_infoAlive :: Bool,
    res_infoAdmin :: Bool
  }

data ReqMetaApi = ReqMetaApi
  { req_webUrl :: String,
    req_webName :: String,
    req_webTitle :: String,
    req_webNotice :: String,
    req_webStartTime :: String
  }

data ResMetaApi = ResMetaApi
  { res_webUrl :: String,
    res_webName :: String,
    res_webTitle :: String,
    res_webNotice :: String,
    res_webStartTime :: Int
  }

type ModelMeta = ResMetaApi

data ReqUserApi = ReqUserApi
  { req_userId :: String,
    req_userAlive :: Bool
  }

data ResUserSingle = ResUserSingle
  { res_userId :: Int,
    res_userName :: String,
    res_userEmail :: String,
    res_userTime :: Int,
    res_userAlive :: Bool,
    res_userAdmin :: Bool
  }

type ResUserApi = [ResUserSingle]

data ReqUserDeleteApi = ReqUserDeleteApi
  { req_deleteUserId :: String
  }

data ReqMessageDeleteApi = ReqMessageDeleteApi
  { req_deleteMessageId :: String
  }

data ReqExpenseDeleteApi = ReqExpenseDeleteApi
  { req_deleteExpenseId :: String
  }

data ModelUserSingle = ModelUserSingle
  { userId :: Int,
    userName :: String,
    userPassword :: String,
    userEmail :: String,
    userTime :: Int,
    userAlive :: Bool,
    userAdmin :: Bool
  }

type ModelUsers = [ModelUserSingle]

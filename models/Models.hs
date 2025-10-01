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

data ReqExpenseApi = ReqExpenseApi
  { req_expenseUsername :: String,
    req_expenseAmount :: Double,
    req_expenseComment :: String
  }

data ResExpenseSingle = ResExpenseSingle
  { res_expenseId :: Int,
    res_expenseUsername :: String,
    res_expenseAmount :: Double,
    res_expenseComment :: String,
    res_expenseTime :: String
  }

type ResExpenseApi = [ResExpenseSingle]

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
  { res_infoUserId :: Int,
    res_infoUsername :: String,
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
    res_webStartTime :: String,
    res_webEndTime :: String
  }

data ReqUserApi = ReqUserApi
  { req_userId :: String,
    req_userAlive :: Bool
  }

data ResUserSingle = ResUserSingle
  { res_userId :: Int,
    res_userUsername :: String,
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

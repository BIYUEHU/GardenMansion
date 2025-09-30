{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}

{-# HLINT ignore "Use newtype instead of data" #-}
module Types where

-- Types Definition

data ReqMessageApi = ReqMessageApi
  { res_messageText :: String,
    res_messageReplyMessageId :: String
  }

data ResMessageSingle = ResMessageSingle
  { req_messageId :: Int,
    req_messageText :: String,
    req_messageUserId :: Int,
    req_messageReplyMessageId :: Maybe Int,
    req_messageReleaseTime :: String
  }

type ResMessageApi = [ResMessageSingle]

data ReqLoginApi = ReqLoginApi
  { req_loginUsername :: String,
    req_loginPassword :: String
  }

data ReqInfoRenameApi = ReqInfoApi
  { req_infoUsername :: String
  }

data ReqInfoPasswordApi = ReqInfoPasswordApi
  { req_infoPasswordOld :: String,
    req_infoPasswordNew :: String
  }

data ResInfoApi = ResInfoApi
  { res_infoUsername :: String,
    res_infoEmail :: String,
    res_infoTime :: Int,
    res_infoAlive :: Bool
  }

data ReqMetaApi = ReqSettingApi
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

module App.Schema where

import Models (ReqMessageApi, ModelMessages, ReqExpenseApi, ModelExpenses, ReqInfoRenameApi, ReqInfoPasswordApi, ReqMetaApi, ModelMeta, ReqUserApi, ReqUserDeleteApi, ReqMessageDeleteApi, ReqExpenseDeleteApi, ModelUsers)
import Utils (Schema, validate)

parseReqMessageApi :: Schema ReqMessageApi
parseReqMessageApi = validate

parseModelMessages :: Schema ModelMessages
parseModelMessages = validate

parseReqExpenseApi :: Schema ReqExpenseApi
parseReqExpenseApi = validate

parseModelExpenses :: Schema ModelExpenses
parseModelExpenses = validate

parseReqInfoRenameApi :: Schema ReqInfoRenameApi
parseReqInfoRenameApi = validate

parseReqInfoPasswordApi :: Schema ReqInfoPasswordApi
parseReqInfoPasswordApi = validate

parseReqMetaApi :: Schema ReqMetaApi
parseReqMetaApi = validate

parseModelMeta :: Schema ModelMeta
parseModelMeta = validate

parseReqUserApi :: Schema ReqUserApi
parseReqUserApi = validate

parseReqUserDeleteApi :: Schema ReqUserDeleteApi
parseReqUserDeleteApi = validate

parseReqMessageDeleteApi :: Schema ReqMessageDeleteApi
parseReqMessageDeleteApi = validate

parseReqExpenseDeleteApi :: Schema ReqExpenseDeleteApi
parseReqExpenseDeleteApi = validate

parseModelUsers :: Schema ModelUsers
parseModelUsers = validate

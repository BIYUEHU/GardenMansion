module Romi.Response
  ( Response(..)
  , ResponsePrim
  , ResponseRaw
  , Status(..)
  , class Responseable
  , setResponse
  , toResponseRaw
  , toResponse
  )
  where

import Prelude

import Data.Tuple (Tuple(..))
import Effect (Effect)
import Romi.Request (Headers)

data ResponsePrim

type ResponseRaw =
  { status :: Int
  , headers :: Headers
  , body :: String
  }

data Status = BadRequest
            | Unauthorized
            | Forbidden
            | NotFound
            | InternalServerError
            | OK
            | Created
            | NoContent
            | Status Int

toInt :: Status -> Int
toInt BadRequest = 400
toInt Unauthorized = 401
toInt Forbidden = 403
toInt NotFound = 404
toInt InternalServerError = 500
toInt OK = 200
toInt Created = 201
toInt NoContent = 204
toInt (Status s) = s

derive instance Eq Status

data Response = JsonRes String
              | HtmlRes String
              | TextRes String
              | StatusRes Status
              | JsonStatusRes Status String
              | HtmlStatusRes Status String
              | TextStatusRes Status String
              | Raw ResponseRaw

toResponseRaw :: Response -> ResponseRaw
toResponseRaw (JsonRes body) = { status: toInt OK, headers: [Tuple "Content-Type" "application/json"], body }
toResponseRaw (HtmlRes body) = { status: toInt OK, headers: [Tuple "Content-Type" "text/html"], body }
toResponseRaw (TextRes body) =  { status: toInt OK, headers: [Tuple "Content-Type" "text/plain"], body }
toResponseRaw (StatusRes status) = { status: toInt status, headers: [], body: "" }
toResponseRaw (JsonStatusRes status body) = { status: toInt status, headers: [Tuple "Content-Type" "application/json"], body }
toResponseRaw (HtmlStatusRes status body) = { status: toInt status, headers: [Tuple "Content-Type" "text/html"], body }
toResponseRaw (TextStatusRes status body) = { status: toInt status, headers: [Tuple "Content-Type" "text/plain"], body }
toResponseRaw (Raw res) = res

derive instance Eq Response

instance Show Response where
  show res = show $ toResponseRaw res

class Responseable a where
  toResponse :: a -> Response

instance Responseable Response where
  toResponse = identity

foreign import setResponsePrim :: ResponsePrim -> Int -> Array (Array String) -> String -> Effect Unit

setResponse :: ResponsePrim -> ResponseRaw -> Effect Unit
setResponse resPrim ({ status, headers, body }) = setResponsePrim resPrim status (map (\(Tuple a b) -> [a, b]) headers) body

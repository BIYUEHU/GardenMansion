module Framework
  ( AfterHandler
  , BeforeHandler
  , Component(..)
  , Components
  , Guard(..)
  , Handler(..)
  , Headers
  , Method(..)
  , Query
  , Request(..)
  , Response(..)
  , ResponseError(..)
  , ResponseRaw
  , Rule(..)
  , Server(..)
  , Status(..)
  , class Responseable
  , close
  , createServer
  , listen
  , toInt
  , toResponse
  , toResponseRaw
  )
  where

import Prelude

import Data.Either (Either(..))
import Data.List (List(..), find)
import Data.List.NonEmpty (fromFoldable)
import Data.List.Types (toList)
import Data.Maybe (Maybe(..))
import Data.String (Pattern(..), contains)
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Utils (endsWith, filterMap, startsWith)

data Method = GET | POST | PUT | DELETE | HEAD | OPTIONS

derive instance Eq Method

instance Show Method where
  show GET = "GET"
  show POST = "POST"
  show PUT = "PUT"
  show DELETE = "DELETE"
  show HEAD = "HEAD"
  show OPTIONS = "OPTIONS"

parseMethod :: String -> Method
parseMethod "GET" = GET
parseMethod "POST" = POST
parseMethod "PUT" = PUT
parseMethod "DELETE" = DELETE
parseMethod "HEAD" = HEAD
parseMethod _ = OPTIONS

type Query = Array (Tuple String String)

type Headers = Array (Tuple String String)

type Request =
  { query :: Query
  , headers :: Headers
  , method :: Method
  , path :: String
  , url :: String
  , body :: String
  }

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

data ResponseError

instance Show ResponseError where
  show _ = "ResponseError"

data Rule = Any
          | StartWith String
          | EndWith String
          | Contains String
          | Is String
          | Not String

checkRule :: Rule -> String -> Boolean
checkRule Any _ = true
checkRule (StartWith s) path = startsWith s path
checkRule (EndWith s) path = endsWith s path
checkRule (Contains s) path = contains (Pattern s) path
checkRule (Is s) path = s == path
checkRule (Not s) path = not (contains (Pattern s) path)

type BeforeHandler = Request -> Effect (Maybe Response)

type AfterHandler = Request -> Response -> Effect Response

type Guard a = { guard :: Request -> Effect (Either ResponseError a), handler :: Request -> a -> Effect Response}

data Handler = Direct (Request -> Effect Response) | Guard (forall a. Guard a)

data Component = Route Method String Handler
                | Before Rule (BeforeHandler)
                | After Rule (AfterHandler)

type Components = Array Component

type BeforeComponents = List { rule :: Rule, components :: BeforeHandler }

type AfterComponents = List { rule::Rule,components :: AfterHandler }

checkBefores :: BeforeComponents -> BeforeHandler
checkBefores coms req = check coms Nothing
  where
    check :: BeforeComponents -> Maybe Response -> Effect (Maybe Response)
    check _ (Just res) = pure $ Just res
    check Nil res = pure res
    check (Cons { rule, components } rest) Nothing
      | checkRule rule (req.path) = do
          res <- components req
          case res of
            Just res' -> pure $ Just res'
            Nothing -> check rest Nothing
      | otherwise = check rest Nothing


checkAfters :: AfterComponents -> AfterHandler
checkAfters Nil _ res = pure res
checkAfters (Cons { rule, components } rest) req res
  | checkRule rule (req.path) = do
      res' <- components req res
      checkAfters rest req res'
  | otherwise = checkAfters rest req res

foreign import setResponsePrim :: ResponsePrim -> Int -> Array (Array String) -> String -> Effect Unit

setResponse :: ResponsePrim -> ResponseRaw -> Effect Unit
setResponse resPrim ({ status, headers, body }) = setResponsePrim resPrim status (map (\(Tuple a b) -> [a, b]) headers) body

data Server

foreign import createServerPrim :: (Request -> ResponsePrim -> Effect Unit) -> (String -> String -> Tuple String String) -> (String -> Method) -> Effect Server

createServer :: Components -> Maybe (Request -> Effect Response) -> Effect Server
createServer coms default = createServerPrim mainHandler  Tuple parseMethod
  where
    components :: List Component
    components = case fromFoldable coms of
      Just x -> toList x
      Nothing -> Nil

    befores :: BeforeComponents
    befores = filterMap (\x ->
          case x of
            Before rule components' -> Just { rule, components: components'}
            _ -> Nothing
        ) $ components

    afters :: AfterComponents
    afters = filterMap (\x ->
            case x of
              After rule components' -> Just { rule, components: components'}
              _ -> Nothing
          ) $ components

    mainHandler :: Request -> ResponsePrim -> Effect Unit
    mainHandler req resPrim = do
      res <- checkBefores befores req
      res' <- if res == Nothing then routes else pure res
      res'' <- case res' of
        Just res'' -> checkAfters afters req res''
        Nothing -> case default of
          Just handler -> handler req
          Nothing -> pure $ Raw { status: 404, headers: [], body: "Not Found" }
      setResponse resPrim $ toResponseRaw res''
      where
        routes :: Effect (Maybe Response)
        routes = case find (\x ->
              case x of
                Route method path _ -> method == req.method && path == req.path
                _ -> false
            ) components of
                Just (Route _ _ (Direct handler)) -> do
                  res <- handler req
                  pure $ Just res
                Just (Route _ _ (Guard guard)) -> do
                  dat <- guard.guard req
                  case dat of
                    Right dat' -> do
                      res <- guard.handler req dat'
                      pure $ Just res
                    Left err -> pure $ Just $ Raw { status: 403, headers: [], body: show err }
                _ -> pure Nothing

foreign import listen :: Server -> Int -> Effect Unit -> Effect Unit

foreign import close :: Server -> Effect Unit

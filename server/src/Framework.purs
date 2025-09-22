module Framework
  ( AfterComponentFunction
  , BeforeComponentFunction
  , Component(..)
  , Handler
  , Headers
  , Method(..)
  , Query
  , Request(..)
  , Response(..)
  , Rule(..)
  , createServer
  )
  where

import Prelude

import Data.Either (Either(..))
import Data.List (List(..), find)
import Data.List.NonEmpty (fromFoldable)
import Data.List.Types (toList)
import Data.Map (Map)
import Data.Map as Map
import Data.Maybe (Maybe(..))
import Data.String (Pattern(..), contains)
import Effect (Effect)
import Utils (endsWith, filterMap, startsWith)

data Method = GET | POST | PUT | DELETE | HEAD | OPTIONS

derive instance Eq Method

parseMethod :: String -> Method
parseMethod "GET" = GET
parseMethod "POST" = POST
parseMethod "PUT" = PUT
parseMethod "DELETE" = DELETE
parseMethod "HEAD" = HEAD
parseMethod _ = OPTIONS

type Query = Map String String

type Headers = Map String String

type Request =
  { query :: Query
  , headers :: Headers
  , method :: Method
  , path :: String
  , body :: String
  }

data ResponsePrim

type Response =
  { status :: Int
  , headers :: Headers
  , body :: String
  }

data ResponseError

instance Show ResponseError where
  show _ = "ResponseError"

data Rule = Any | StartWith String | EndWith String | Contains String | Is String | Not String

checkRule :: Rule -> String -> Boolean
checkRule Any _ = true
checkRule (StartWith s) path = startsWith s path
checkRule (EndWith s) path = endsWith s path
checkRule (Contains s) path = contains (Pattern s) path
checkRule (Is s) path = s == path
checkRule (Not s) path = not (contains (Pattern s) path)

type BeforeComponentFunction = Request -> Effect (Maybe Response)

type AfterComponentFunction = Request -> Response -> Effect Response

type Guard a = { guard :: Request -> Effect (Either ResponseError a), handler :: Request -> a -> Effect Response }

data Handler = Direct (Request -> Effect Response) | Guard (forall a. Guard a)

data Component = Route Method String Handler
  | Before Rule (BeforeComponentFunction)
  | After Rule (AfterComponentFunction)

type BeforeComponents = List { rule :: Rule, components :: BeforeComponentFunction }

type AfterComponents = List { rule::Rule,components :: AfterComponentFunction }

checkBefores :: BeforeComponents -> BeforeComponentFunction
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


checkAfters :: AfterComponents -> AfterComponentFunction
checkAfters Nil _ res = pure res
checkAfters (Cons { rule, components } rest) req res
  | checkRule rule (req.path) = do
      res' <- components req res
      checkAfters rest req res'
  | otherwise = checkAfters rest req res

foreign import setResponsePrim :: ResponsePrim -> Int -> Headers -> String -> Effect Unit

setResponse :: ResponsePrim -> Response -> Effect Unit
setResponse resPrim res = setResponsePrim resPrim res.status res.headers res.body

type ServerOptions = { port :: Int, components :: Array Component, default :: Maybe (Request -> Effect Response) }

foreign import createServerPrim :: (Request -> ResponsePrim -> Effect Unit) -> (String -> Method) -> Effect Unit

createServer ::  ServerOptions -> Effect Unit
createServer options = createServerPrim mainHandler parseMethod
  where
    components :: List Component
    components = case fromFoldable options.components of
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
        Nothing -> case options.default of
          Just handler -> handler req
          Nothing -> pure { status: 404, headers: Map.empty, body: "Not Found" }
      setResponse resPrim res''
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
                    Left err -> pure $ Just { status: 403, headers: Map.empty, body: show err }
                _ -> pure Nothing

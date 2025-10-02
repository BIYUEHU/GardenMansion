module Romi.Server
  ( Server(..)
  , close
  , createServer
  , listen
  )
  where

import Prelude

import Control.Monad.Reader (runReaderT)
import Data.List (List(..), find)
import Data.List.NonEmpty (fromFoldable)
import Data.List.Types (toList)
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Romi.Common (Romi)
import Romi.Components (Component(..), Components, checkAfters, checkBefores)
import Romi.Request (Method, Request, parseMethod)
import Romi.Response (Response(..), ResponsePrim, setResponse, toResponseRaw)
import Utils (filterMap)

data Server

type DefaultHandler a = Maybe (Request -> Romi a Response)

routes :: forall a. List (Component a) -> Request -> Romi a (Maybe Response)
routes components req = case find (\x -> case x of
    Route method path _ -> method == req.method && path == req.path
    _ -> false
  ) components of
    Just (Route _ _ handler) -> do
      res <- handler req
      pure $ Just res
    _ -> pure Nothing

afters :: forall a. List (Component a) -> DefaultHandler a -> Request -> Maybe Response -> Romi a Response
afters components _ req (Just res) = checkAfters (filterMap (\x -> case x of
  After rule components' -> Just { rule, components: components'}
  _ -> Nothing
  ) $ components) req res
afters _ default req Nothing = case default of
  Just handler -> handler req
  Nothing -> pure $ Raw { status: 404, headers: [], body: "Not Found" }

handlerBus :: forall a. List (Component a) -> DefaultHandler a -> Request -> ResponsePrim -> Romi a Unit
handlerBus components default req resPrim = do
      res <- checkBefores (filterMap (\x ->
      case x of
        Before rule components' -> Just { rule, components: components'}
        _ -> Nothing
    ) $ components) req
      res' <- if res == Nothing then routes components req else pure res
      res'' <- afters components default req res'
      liftEffect $ setResponse resPrim $ toResponseRaw res''

foreign import createServerPrim :: (Request -> ResponsePrim -> Effect Unit) -> (String -> String -> Tuple String String) -> (String -> Method) -> Effect Server

createServer :: forall a. Components a -> a -> DefaultHandler a -> Aff Server
createServer coms state default = liftEffect $ createServerPrim (\req resPrim ->
  launchAff_ $ runReaderT (handlerBus (
    case fromFoldable coms of
        Just x -> toList x
        Nothing -> Nil
    ) default req resPrim) state
  ) Tuple parseMethod

foreign import listen :: Server -> Int -> Effect Unit -> Effect Unit

foreign import close :: Server -> Effect Unit

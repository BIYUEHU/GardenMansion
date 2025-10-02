module Main where

import Prelude

import App.Bootstrap (bootstrap)
import Effect (Effect)
import Effect.Aff (launchAff_)

main :: Effect Unit
main = launchAff_ bootstrap

module Romi.Common
  ( Romi
  )
  where

import Control.Monad.Reader (ReaderT)
import Effect.Aff (Aff)

type Romi a = ReaderT a Aff

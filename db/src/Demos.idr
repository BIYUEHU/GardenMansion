module Demos

import Async
import Db

mainAsync : AsyncIO ()
mainAsync =  do
  db <- create "db" "testt"
  a <- get db "a"
  MkAsyncIOFromIO $ printLn a
  put db "a" $ show 10
  a <- get db "a"
  MkAsyncIOFromIO $ printLn a
  batch db [ Put "c" (show 20), Put "b" (show 30), Del "a" ]
  b <- get db "b"
  c <- get db "c"
  MkAsyncIOFromIO $ printLn b
  MkAsyncIOFromIO $ printLn c
  close db


module Main

import Async
import Db
import Exports

main : IO ()
main = do
  exportCommonJs "create" create
  exportCommonJs "get" getExternal
  exportCommonJs "put" put
  exportCommonJs "del" del
  exportCommonJs "batch" batchExternal
  exportCommonJs "close" close

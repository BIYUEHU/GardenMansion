module Db

import Async

public export
data DB = MkDB

public export
%foreign """
node:lambda:(dir, prefix) => async () => new (require('level').Level)(require('path').resolve(__dirname, dir), { prefix })
"""
create : (dir : String) -> (prefixStr: String) -> AsyncIO DB

public export
%foreign """
node:lambda:(db, key, f, v) => async () => {
  const result = await db.get(key);
  if (result === undefined) {
    return v;
  }
  return f(result)
}
"""
getExternal : DB -> (key : String) -> (String -> Maybe String) -> Maybe String -> AsyncIO $ Maybe String

public export
get : DB -> (key : String) -> AsyncIO $ Maybe String
get db key = getExternal db key Just Nothing

public export
%foreign """
node:lambda:(db, key, value) => async () => await db.put(key, value)
"""
put : DB -> (key : String) -> (value : String) -> AsyncIO ()

public export
%foreign """
node:lambda:(db, key) => async () => await db.del(key)
"""
del : DB -> (key : String) -> AsyncIO ()

public export
data BatchOp : Type where
  Put : (key : String) -> (value : String) -> BatchOp
  Del : (key : String) -> BatchOp

public export
data PrimBatchOp = PrivatelyMkPrimBatchOp

public export
%foreign """
javascript:lambda:(k,v) => ({ type: 'put', key: k, value: v })
"""
primPutBatchOp : String -> String -> PrimBatchOp

public export
%foreign """
javascript:lambda:(k) => ({ type: 'del', key: k })
"""
primDelBatchOp : String -> PrimBatchOp

public export
data PrimBatchOps = PrivatelyMkPrimBatchOps

public export
%foreign """
javascript:lambda:(op) => [op]
"""
primCreateBatchOps : PrimBatchOp -> PrimBatchOps

public export
%foreign"""
javascript:lambda:(ops,op) => [...ops, op]
"""
primAddBatchOp : PrimBatchOps -> PrimBatchOp -> PrimBatchOps

public export
%foreign """
node:lambda:(db, ops) => async () => await db.batch(ops)
"""
primBatch : DB -> PrimBatchOps -> AsyncIO ()

public export
batch : DB -> List BatchOp -> AsyncIO ()
batch db ops = primBatch db $ build ops
  where
    trans : BatchOp -> PrimBatchOp
    trans (Put k v) = primPutBatchOp k v
    trans (Del k) = primDelBatchOp k

    build : List BatchOp -> PrimBatchOps
    build [] = primCreateBatchOps $ primDelBatchOp ""
    build [a] = primCreateBatchOps $ trans a
    build (op :: ops) = primAddBatchOp (build ops) $ trans op


public export
data ArrayOps = PrivatelyMkArrayOps

public export
%foreign """
node:lambda:(db, ops) => async () => await db.batch(ops)
"""
batchExternal : DB -> ArrayOps -> AsyncIO ()

public export
%foreign """
node:lambda:(db) => async () => await db.close()
"""
close : DB -> AsyncIO ()

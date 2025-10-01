import DB from '../../../db/build/exec/Main.js'

export const dbCreatePrim = DB.create
export const dbGetPrim = DB.get
export const dbPutPrim = DB.put
export const dbDelPrim = DB.del
export const toBatchOpPutPrim = (k, v) => ({ type: 'put', key: k, value: v })
export const toBatchOpDelPrim = (k) => ({ type: 'del', key: k })
export const dbBatchPrim = DB.batch
export const dbClosePrim = DB.close

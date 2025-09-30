module Main

add : Int -> Int -> Int
add x y = x + y

%foreign "javascript:lambda:(_, name, value) => () => {globalThis[name] = value;}"
exportJs : forall a. String -> a -> IO ()

main : IO ()
main = do
  exportJs "idris_add" add


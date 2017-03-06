module Loader.Host.Main

import Loader.Shared.FFI

main : IO ()
main = do
  Just m <- loadModule "Loader.Object" False | _ => pure ()
  --res <- call "testFn1" (Int -> IO Int) 42
  --printLn res
  putStrLn "Reloading test..."
  Just m' <- reloadModule m | _ => pure ()
  ok <- closeModule m'
  if ok then putStrLn "Closed ok..."
  else putStrLn "Error closing..."

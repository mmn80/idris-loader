module Loader.Host.Main

import Loader.Shared.FFI

main : IO ()
main = do
  hnd <- loadModule "Loader.Object" False
  --res <- call "testFn1" (Int -> IO Int) 42
  --printLn res
  putStrLn "main exit..."

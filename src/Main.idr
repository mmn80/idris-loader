module Main

import System.Dynamic.Loader

%include C "modules.h"
%link C "modules.o"

main : IO ()
main = do
  Just m1 <- loadModule "Module1" ["testFn1"] False | _ => pure ()
  Just m2 <- loadModule "Module2" ["testFn2"] False | _ => pure ()
  Just ptr <- pure (modSymbol m1 "testFn1") | _ => pure ()
  putStrLn "Calling testFn1..."
  vm <- getMyVM
  r <- foreign FFI_C "_testFn1" (Ptr -> Ptr -> Int -> IO String) ptr vm 42
  putStrLn r
  --putStrLn "Reloading test..."
  --Just m' <- reloadModule m | _ => pure ()
  closeModule m2
  closeModule m1
  pure ()

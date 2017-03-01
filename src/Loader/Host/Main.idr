module Loader.Host.Main

import Loader.Shared.FFI

export myMain : IO ()
myMain = do
  loadModule "Object"
  res <- call "testFn1" (Int -> IO Int) 42
  printLn res

exports : FFI_Export FFI_C "Loader/Host/exports.h" []
exports = Fun myMain "myMain" $ End

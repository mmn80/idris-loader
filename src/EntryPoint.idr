module EntryPoint

import Module1

export
myMain : IO ()
myMain = do
  printLn (testFn1 42)

exportMyMain : FFI_Export FFI_C "entryPoint.h" []
exportMyMain = Fun myMain "myMain" $
               End

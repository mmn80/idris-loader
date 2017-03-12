module Module2.Main

export
testFn2 : Int -> IO String
testFn2 x = do
  Right f <- readFile "/home/calin/src/idris-loader/src/Module2/Main.idr" | Left e => pure (show e)
  putStrLn "This is my source:"
  putStrLn f
  pure $ "testFn2: " ++ show x

exports : FFI_Export FFI_C "Module2/exports.h" []
exports = Fun testFn2 "testFn2" $ End

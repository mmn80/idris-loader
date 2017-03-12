module Module2.Main

import Data.Vect

len : Vect n Int -> Int
len {n} _ = cast n

doVect : Int -> String
doVect x = show v ++ "\nlen = " ++ show (len v)
  where v : Vect (cast x) Int
        v = replicate (cast x) 55

export
testFn2 : Int -> IO String
testFn2 x = do
  Right f <- readFile "/home/calin/src/idris-loader/src/Module2/Main.idr" | Left e => pure (show e)
  putStrLn "This is my source:"
  putStrLn f
  pure $ "testFn2: " ++ doVect x

exports : FFI_Export FFI_C "Module2/exports.h" []
exports = Fun testFn2 "testFn2" $ End

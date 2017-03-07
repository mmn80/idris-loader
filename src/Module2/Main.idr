module Module2.Main

export
testFn2 : Int -> String
testFn2 x = "testFn2: " ++ show x

exports : FFI_Export FFI_C "Module2/exports.h" []
exports = Fun testFn2 "testFn2" $ End

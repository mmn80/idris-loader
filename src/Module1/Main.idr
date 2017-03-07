module Module1.Main

import Module1.Mod1

export
testFn1 : Int -> String
testFn1 x = mod2 x ++ ", testFn1: " ++ show x

exports : FFI_Export FFI_C "Module1/exports.h" []
exports = Fun testFn1 "testFn1" $ End

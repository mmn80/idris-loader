module Loader.Object.Main

import Loader.Object.Mod1

export
testFn1 : Int -> String
testFn1 x = testFn2 x ++ ", testFn1: " ++ show x

exports : FFI_Export FFI_C "Loader/Object/exports.h" []
exports = Fun testFn1 "testFn1" $ End

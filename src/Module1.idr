module Module1

import Module2

export
testFn1 : Int -> String
testFn1 x = testFn2 x ++ ", testFn1: " ++ show x

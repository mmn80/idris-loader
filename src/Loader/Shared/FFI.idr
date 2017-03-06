module Loader.Shared.FFI

import System

%include C "dlfcn.h"
%lib     C "dl"

RTLD_LAZY : Int
RTLD_LAZY = 0x1

RTLD_NOW : Int
RTLD_NOW = 0x2

RTLD_LOCAL : Int
RTLD_LOCAL = 0x4

RTLD_GLOBAL : Int
RTLD_GLOBAL = 0x8

RTLD_NOLOAD : Int
RTLD_NOLOAD = 0x10

RTLD_NODELETE : Int
RTLD_NODELETE = 0x80

dlopen : String -> Int -> IO Ptr
dlopen path flags = foreign FFI_C "dlopen" (String -> Int -> IO Ptr) path flags

dlerror : IO String
dlerror = foreign FFI_C "dlerror" (IO String)

dlsym : Ptr -> String -> IO Ptr
dlsym hnd sym = foreign FFI_C "dlsym" (Ptr -> String -> IO Ptr) hnd sym

dlclose : Ptr -> IO Int
dlclose hnd = foreign FFI_C "dlclose" (Ptr -> IO Int) hnd

fileExists : String -> IO Bool
fileExists path = do
  Right f <- openFile path Read | Left err => pure False
  closeFile f
  pure True

export
data Module : Type where
  ModHandle : String -> Ptr -> List (Ptr, Type) ->  Module

modDir : String
modDir = "src/"

strReplace : (Char -> Char) -> String -> String
strReplace f = pack . map f . unpack

modPath : String -> String
modPath mod = (strReplace (\c => if c == '.' then '/' else c) mod) ++ "/"

oName : String
oName = "exports.o"

soName : String
soName = "exports.so"

data SysResult : Type where
  Ok  : SysResult
  Err : Int -> SysResult

sysCmd : String -> IO SysResult
sysCmd cmd = do
  r <- system cmd
  if r == 0 then pure Ok
  else do printLn r; pure (Err r)

buildModule : String -> IO SysResult
buildModule mod = do
  putStrLn $ "Building " ++ mod ++ "..."
  let dir = modPath mod
  let cd = "cd " ++ modDir ++ "; "
  let idCmd = cd ++ "idris " ++ dir ++ "Main.idr --interface --cg-opt=-fPIC -o " ++ dir ++ oName
  Ok <- sysCmd idCmd | r => pure r
  putStrLn $ "Linking " ++ mod ++ "..."
  let ccCmd = cd ++ "cc " ++ dir ++ oName ++ " -shared -fPIC -o " ++ dir ++ soName
  Ok <- sysCmd ccCmd | r => pure r
  pure Ok

export
loadModule : String -> Bool -> IO (Maybe Module)
loadModule mod rebuild = do
  let so = modDir ++ modPath mod ++ soName
  bld <- if rebuild then pure True
         else not <$> fileExists so
  Ok <- if bld then buildModule mod else pure Ok | _ => pure Nothing
  hnd <- dlopen so RTLD_NOW
  if hnd == null
    then do err <- dlerror
            putStrLn err
            pure Nothing
    else do dlerror
            fn <- dlsym hnd "testFn1"
            err <- dlerror
            ok <- nullStr err
            if ok then pure (Just $ ModHandle mod hnd [(fn, Int -> String)])
                  else do putStrLn err; pure Nothing

export
closeModule : Module -> IO Bool
closeModule (ModHandle mod hnd syms) = do
  r <- dlclose hnd
  pure (r == 0)

export
reloadModule : Module -> IO (Maybe Module)
reloadModule (ModHandle mod hnd syms) = do
  r <- dlclose hnd
  if r /= 0 then do
    err <- dlerror
    putStrLn $ "dlclose error " ++ show r
    ok <- nullStr err
    when (not ok) $ putStrLn err
    pure Nothing
  else loadModule mod True

%inline
public export
call : (fname : ffi_fn FFI_C) -> (ty : Type) -> {auto fty : FTy FFI_C [] ty} -> ty
call fname ty = foreign FFI_C fname ty

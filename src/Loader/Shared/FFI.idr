module Loader.Shared.FFI

%access public export

ModuleName : Type
ModuleName = String

loadModule : ModuleName -> IO ()
loadModule mod = do
  printLn $ "Loading module: " ++ mod ++ "..."

%inline
call : (fname : ffi_fn FFI_C) -> (ty : Type) -> {auto fty : FTy FFI_C [] ty} -> ty
call = foreign FFI_C

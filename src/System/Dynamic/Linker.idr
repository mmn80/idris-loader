module System.Dynamic.Linker

%include C "dlfcn.h"
%lib C "dl"
%access public export

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

%inline
dlopen : String -> Int -> IO Ptr
dlopen path flags = foreign FFI_C "dlopen" (String -> Int -> IO Ptr) path flags

%inline
dlerror : IO String
dlerror = do
  e <- foreign FFI_C "dlerror" (IO String)
  n <- nullStr e
  if n then pure "" else pure e

%inline
dlsym : Ptr -> String -> IO Ptr
dlsym hnd sym = foreign FFI_C "dlsym" (Ptr -> String -> IO Ptr) hnd sym

%inline
dlclose : Ptr -> IO Int
dlclose hnd = foreign FFI_C "dlclose" (Ptr -> IO Int) hnd

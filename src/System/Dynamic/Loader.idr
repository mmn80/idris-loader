module System.Dynamic.Loader

import System
import System.Dynamic.Linker

fileExists : String -> IO Bool
fileExists path = do
  Right f <- openFile path Read | Left err => pure False
  closeFile f
  pure True

public export
record Symbol where
  constructor MkSymbol
  name : String
  addr : Ptr

public export
record Module where
  constructor MkModule
  name : String
  handle : Ptr
  symbols : List Symbol

export
modSymbol : Module -> String -> Maybe Ptr
modSymbol mod sn = addr <$> find (\sym => name sym == sn) (symbols mod)

modDir : String
modDir = "src/"

modPath : String -> String
modPath = pack . replaceOn '.' '/' . unpack . (++ "/")

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
loadModule : String -> List String -> Bool -> IO (Maybe Module)
loadModule mod syms rebuild = do
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
            mbs <- for syms $ \sym => do
              fn <- dlsym hnd sym
              err <- dlerror
              if err == "" then pure (Just $ MkSymbol sym fn)
                           else do putStrLn err; pure Nothing
            pure $ Just $ MkModule mod hnd (catMaybes mbs)

export
closeModule : Module -> IO Bool
closeModule mod = do
  r <- dlclose (handle mod)
  if r /= 0 then do
    err <- dlerror
    putStrLn $ "dlclose error " ++ show r ++ ":" ++ err
    pure False
  else pure True

export
reloadModule : Module -> IO (Maybe Module)
reloadModule mod = do
  r <- closeModule mod
  if not r then pure Nothing
  else loadModule (name mod) (name <$> symbols mod) True


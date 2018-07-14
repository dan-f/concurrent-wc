module Lib
  ( getFilesInDir
  ) where

import System.Directory
  ( getCurrentDirectory
  , listDirectory
  )
import System.FilePath.Posix
  ( joinPath
  )
import System.PosixCompat.Files
  ( getFileStatus
  , isRegularFile
  )

getFilesInDir :: Maybe FilePath -> IO [FilePath]
getFilesInDir mPath =
  let locateDir = case mPath of
                    Just path -> return path
                    Nothing -> getCurrentDirectory
  in locateDir >>= listDirectory' >>= onlyRegularFiles

listDirectory' :: FilePath -> IO [FilePath]
listDirectory' path = do
  files <- listDirectory path
  return $ map (\file -> joinPath [path, file]) files

onlyRegularFiles :: [FilePath] -> IO [FilePath]
onlyRegularFiles files = do
  areFiles <- mapM isRegularFile' files
  return $ zip files areFiles
    |> filter (\(_, isFile) -> isFile)
    |> map (\(f, _) -> f)
  where (|>) x f = f x

isRegularFile' :: FilePath -> IO Bool
isRegularFile' path =
  getFileStatus path >>= \status -> return $ isRegularFile status

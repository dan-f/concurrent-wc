module Main where

import Lib

main :: IO ()
main = do
  files <- getFilesInDir $ Just "/Users/dan"
  putStrLn $ show files

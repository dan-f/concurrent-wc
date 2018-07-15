module Main where

import Control.Concurrent
import Data.List
import System.Environment

import Lib

data LineCount = LineCount FilePath Int deriving (Eq)

instance Show LineCount where
  show (LineCount path count) = (leftPad 10 $ show count) ++ " " ++ path

instance Ord LineCount where
  (LineCount _ c1) `compare` (LineCount _ c2) = c1 `compare` c2

leftPad :: Int -> String -> String
leftPad n s =
  let spaces = take (n - (length s)) $ repeat ' '
  in spaces ++ s

head' :: [a] -> Maybe a
head' [] = Nothing
head' (x:xs) = Just x

printLineCounts :: [LineCount] -> IO ()
printLineCounts lcs =
  mapM_ (putStrLn . show) (reverse $ sort lcs)

printTotal :: Int -> IO ()
printTotal total =
  putStrLn $ (leftPad 10 $ show total) ++ " " ++ "[TOTAL]"

countLinesTask :: Chan LineCount -> FilePath -> IO ()
countLinesTask chan path = do
  forkIO $ do
    count <- countLines path
    writeChan chan (LineCount path count)
  return ()

main :: IO ()
main = do
  args <- getArgs
  files <- getFilesInDir $ head' args
  let numFiles = length files
  chan <- newChan
  mapM_ (countLinesTask chan) files
  chanContents <- getChanContents chan
  let lineCounts = take numFiles chanContents
  printLineCounts lineCounts
  let total = foldr (\(LineCount _ count) t -> count + t) 0 lineCounts
  printTotal total

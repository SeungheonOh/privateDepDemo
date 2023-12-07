module Main where

import MyLib (someFunc)

main :: IO ()
main = do
  putStrLn "Hello, Haskell!"

  someFunc

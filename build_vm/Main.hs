module Main where

import Data.Monoid ((<>))

import Control.Exception (handleJust)
import Control.Monad (when, forM_, guard)

import System.Process (rawSystem)
import System.Exit (ExitCode(..))
import System.Directory (removeDirectoryRecursive, createDirectory)
import System.IO.Error (isDoesNotExistError)

buildC :: String -> IO ()
buildC name = do
  putStrLn $ "Building " <> name <> ".c..."
  code <-
    rawSystem "clang" [
      "clib/" <> name <> ".c",
      "-S", "-emit-llvm", "-o",
      "intermediate/" ++ name ++ ".ll"
    ]
  when (code /= ExitSuccess) $
    error $ "clang failed on: " <> name

cSrcs :: [String]
cSrcs = [
    "test"
  ]

main :: IO ()
main = do
  handleJust (guard . isDoesNotExistError) (const $ return ()) $
    removeDirectoryRecursive "intermediate"
  createDirectory "intermediate"
  forM_ cSrcs buildC

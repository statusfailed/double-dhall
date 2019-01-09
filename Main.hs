{-# LANGUAGE OverloadedStrings #-}

-- testing this: https://github.com/dhall-lang/dhall-lang/wiki/How-to-add-a-new-built-in-function

module Main where

import Control.Applicative
import Data.String (IsString, fromString)

import Dhall.Core (Expr(..), ReifiedNormalizer(..))
import qualified Dhall.Core

import qualified Data.Text (Text(..))
import qualified Data.Text.IO
import qualified Dhall as Dhall
import qualified Dhall.Context
import qualified Lens.Family   as Lens
import Data.Functor.Identity (Identity(..))

binaryDoubleType :: Expr s a
binaryDoubleType = Pi "_" Double (Pi "_" Double Double)

-- | Make a normalizer function from a Haskell function and its Dhall name,
-- e.g.
--
-- >>> :t binaryDoubleNormalizer (+) "Double/add"
-- binaryDoubleNormalizer (+) "Double/add" :: Expr s1 a1 -> Maybe (Expr s2 a2)
binaryDoubleNormalizer
  :: (Double -> Double -> Double)
  -> Dhall.Core.Var
  -> Expr s1 a1
  -> Maybe (Expr s2 a2)
binaryDoubleNormalizer
  f name (App (App (Var match) (DoubleLit x)) (DoubleLit y))
  | name == match = Just (DoubleLit (f x y))
  | otherwise = Nothing
binaryDoubleNormalizer _ _ _ = Nothing

doubleFunctions :: IsString s => [(s, Double -> Double -> Double)]
doubleFunctions =
  [ ("Double/add", (+))
  , ("Double/sub", (-))
  , ("Double/mul", (*))
  , ("Double/div", (/))
  ]

-- | A 'Dhall.Context.Context' with double
{-doubleEnrichedContext :: [Dhall.Context.Context a]-}
doubleEnrichedContext = foldl f Dhall.Context.empty doubleFunctions
  where f ctx (name, _) = Dhall.Context.insert name binaryDoubleType ctx

-- utility to try each function in a list of functions until one of them
-- succeeeds.
tryAll :: (Functor t, Foldable t) => t (a -> Maybe b) -> a -> Maybe b
tryAll fs x = foldl (<|>) Nothing $ fmap ($x) fs

doubleNormalizer :: Expr s1 a1 -> Maybe (Expr s2 a2)
doubleNormalizer =
  tryAll [ binaryDoubleNormalizer f n | (n, f) <- doubleFunctions ]

main :: IO ()
main = do
  text <- Data.Text.IO.getContents
  let context     = doubleEnrichedContext
      normalizer  = ReifiedNormalizer $ pure . doubleNormalizer
      addSettings = Lens.set Dhall.normalizer normalizer
                  . Lens.set Dhall.startingContext context
      inputSettings = addSettings Dhall.defaultInputSettings 

  x <- Dhall.inputWithSettings inputSettings Dhall.auto text
  Data.Text.IO.putStrLn x

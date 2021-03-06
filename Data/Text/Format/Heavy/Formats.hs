{-# LANGUAGE OverloadedStrings #-}
-- | This module contains format descriptions for most used variable types.
module Data.Text.Format.Heavy.Formats where

import Data.Default
import qualified Data.Text.Lazy as TL

import Data.Text.Format.Heavy.Types

-- | Alignment of string within specified width
data Align = AlignLeft | AlignRight | AlignCenter
  deriving (Eq, Show)

-- | Whether to show the sign of number
data Sign = Always | OnlyNegative | SpaceForPositive
  deriving (Eq, Show)

-- | Number base
data Radix = Decimal | Hexadecimal
  deriving (Eq, Show)

-- | Supported text conversions
data Conversion =
    UpperCase
  | LowerCase
  | TitleCase
  deriving (Eq, Show)

-- | Generic format description. This is usable for integers, floats and strings.
data GenericFormat = GenericFormat {
    gfFillChar :: Char
  , gfAlign :: Maybe Align
  , gfSign :: Sign
  , gfLeading0x :: Bool
  , gfWidth :: Maybe Int
  , gfPrecision :: Maybe Int
  , gfRadix :: Maybe Radix
  , gfConvert :: Maybe Conversion
  }
  deriving (Eq, Show)

instance Default GenericFormat where
  def = GenericFormat {
          gfFillChar = ' '
        , gfAlign = Nothing
        , gfSign = OnlyNegative
        , gfLeading0x = False
        , gfWidth = Nothing
        , gfPrecision = Nothing
        , gfRadix = Nothing
        , gfConvert = Nothing
        }

data BoolFormat = BoolFormat {
    bfTrue :: TL.Text
  , bfFalse :: TL.Text
  }
  deriving (Eq, Show)

instance Default BoolFormat where
  def = BoolFormat "true" "false"


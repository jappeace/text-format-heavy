{-# LANGUAGE ExistentialQuantification, TypeFamilies, FlexibleContexts, OverloadedStrings, CPP #-}
-- | This module contains basic type definitions
module Data.Text.Format.Heavy.Types where

import Data.Default

#if MIN_VERSION_base(4,9,0)
import Data.Monoid (Monoid)
import Data.Semigroup ((<>))
import qualified Data.Semigroup as Semigroup
#else
import Data.Monoid
#endif

import qualified Data.Text as T
import qualified Data.Text.Lazy as TL
import qualified Data.Text.Lazy.Builder as B

-- | Variable name
type VarName = TL.Text

-- | Variable format in text form. Nothing means default format.
type VarFormat = Maybe TL.Text

-- | String format item.
data FormatItem =
    FString TL.Text        -- ^ Verbatim text
  | FVariable {
      vName :: VarName      -- ^ Variable name
    , vFormat :: VarFormat  -- ^ Variable format
    }
  deriving (Eq)

instance Show FormatItem where
  show (FString text) = TL.unpack text
  show (FVariable name Nothing) = TL.unpack $ "{" <> name <> "}"
  show (FVariable name (Just fmt)) = TL.unpack $ "{" <> name <> ":" <> fmt <> "}"

-- | String format
data Format = Format [FormatItem]
  deriving (Eq)

instance Show Format where
  show (Format lst) = concat $ map show lst

appendFormat :: Format -> Format -> Format
appendFormat (Format xs) (Format ys) = Format (xs ++ ys)


instance Semigroup Format where
  (<>) = appendFormat

instance Monoid Format where
  mempty = Format []

#if MIN_VERSION_base(4,11,0)
  -- starting with base-4.11, mappend definitions are redundant;
#elif MIN_VERSION_base(4,9,0)
  -- this is redundant starting with base-4.11 / GHC 8.4
  mappend = (Semigroup.<>)
#else
  -- prior to GHC 8.0 / base-4.9 where no `Semigroup` class existed
  mappend = appendFormat
#endif

-- | Can be used for different data types describing formats of specific types.
class (Default f, Show f) => IsVarFormat f where
  -- | Left for errors.
  parseVarFormat :: TL.Text -> Either String f

instance IsVarFormat () where
  parseVarFormat "" = Right ()
  parseVarFormat fmt = Left $ "Unsupported format: " ++ TL.unpack fmt

-- | Value that can be formatted to be substituted into format string.
class Formatable a where
  -- | Format variable according to format specification.
  -- This function should usually parse format specification by itself.
  formatVar :: VarFormat                -- ^ Variable format specification in text form. Nothing is for default format.
            -> a                        -- ^ Variable value.
            -> Either String B.Builder  -- ^ Left for errors in variable format syntax, or errors during formatting.

-- | Any variable that can be substituted.
-- This type may be also used to construct heterogeneous lists:
-- @[Variable 1, Variable "x"] :: [Variable]@.
data Variable = forall a. Formatable a => Variable a

instance Show Variable where
  show (Variable v) = either error toString $ formatVar Nothing v
    where
      toString :: B.Builder -> String
      toString b = TL.unpack $ B.toLazyText b

instance Formatable Variable where
  formatVar fmt (Variable x) = formatVar fmt x

-- | Format one variable according to format specification.
formatAnyVar :: VarFormat -> Variable -> Either String B.Builder
formatAnyVar fmt (Variable v) = formatVar fmt v

-- | Data structure that contains some number of variables.
class VarContainer c where
  lookupVar :: VarName -> c -> Maybe Variable

class VarContainer c => ClosedVarContainer c where
  allVarNames :: c -> [VarName]

------------------------------------------------------------------------------


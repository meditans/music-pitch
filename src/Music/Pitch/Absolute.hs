
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE TypeFamilies               #-}

-------------------------------------------------------------------------------------
-- |
-- Copyright   : (c) Hans Hoglund 2012
--
-- License     : BSD-style
--
-- Maintainer  : hans@hanshoglund.se
-- Stability   : experimental
-- Portability : portable
--
-- Absolute pitch representation.
--
-- The canonical pitch representation is frequency in Hertz (Hz).
--
-- For conversion, see 'HasFrequency'.
--
-------------------------------------------------------------------------------------

module Music.Pitch.Absolute (
        -- * Absolute pitch representation
        Hertz(..),
        -- FreqRatio(..),
        -- Octaves,
        Cents,
        Fifths,
        
        -- * HasFrequency class
        HasFrequency(..),
        -- octaves,
        fifths,
        cents,
  ) where

import           Control.Applicative
import           Control.Monad
import           Data.AdditiveGroup
import           Data.AffineSpace
import           Data.Either
import           Data.Maybe
import           Data.Semigroup
import           Data.VectorSpace

import           Music.Pitch.Literal

-- |
-- Absolute frequency in Hertz.
--
newtype Hertz = Hertz { getHertz :: Double }
    deriving (Read, Eq, Enum, Num, Ord, Fractional, Floating, Real, RealFrac)

{-
-- |
-- A ratio between two different (Hertz) frequencies.
--
newtype FreqRatio = FreqRatio { getFreqRatio :: Double }
  deriving (Read, Show, Eq, Enum, Num, Ord, Fractional, Floating, Real, RealFrac)
-}

-- |
-- Number of pure octaves.
--
-- Octaves are a logarithmic representation of frequency such that
--
-- > f * (2/1) = frequency (octaves f + 1)
--
newtype Octaves = Octaves { getOctaves :: Hertz }
  deriving (Read, Show, Eq, Enum, Num, Ord, Fractional, Floating, Real, RealFrac)

-- |
-- Number of pure octaves.
--
-- Cents are a logarithmic representation of frequency such that
--
-- > f * (2/1) = frequency (cents f + 1200)
--
newtype Cents = Cents { getCents :: Hertz }
  deriving (Read, Show, Eq, Enum, Num, Ord, Fractional, Floating, Real, RealFrac)

-- |
-- Number of pure fifths.
--
-- Fifths are a logarithmic representation of frequency.
--
-- > f * (3/2) = frequency (fifths f + 1)
--
newtype Fifths = Fifths { getFifths :: Hertz }
  deriving (Read, Show, Eq, Enum, Num, Ord, Fractional, Floating, Real, RealFrac)


instance Show Hertz where show h = (show (getHertz h)) ++ " Hz"

instance Semigroup Hertz    where (<>) = (*)
instance Semigroup Octaves  where (<>) = (+)
instance Semigroup Fifths   where (<>) = (+)
instance Semigroup Cents    where (<>) = (+)

instance Monoid Hertz       where { mempty  = 1 ; mappend = (*) }
instance Monoid Octaves     where { mempty  = 0 ; mappend = (+) }
instance Monoid Fifths      where { mempty  = 0 ; mappend = (+) }
instance Monoid Cents       where { mempty  = 0 ; mappend = (+) }

instance AffineSpace Hertz where
  type Diff Hertz = Double
  (.-.) f1 f2 = (getHertz f1) / (getHertz f2)
  (.+^) f x = Hertz $ (getHertz f) * x

class HasFrequency a where
  frequency :: a -> Hertz

instance HasFrequency Hertz where
  frequency = id

instance HasFrequency Octaves where
  frequency (Octaves f) = (2/1) ** f

instance HasFrequency Fifths where
  frequency (Fifths f)  =  (3/2) ** f

instance HasFrequency Cents where
  frequency (Cents f)   =  (2/1) ** (f / 1200)

octaves :: HasFrequency a => a -> Octaves
octaves a = Octaves $ logBase (2/1) (frequency a)

fifths :: HasFrequency a => a -> Fifths
fifths a = Fifths $ logBase (3/2) (frequency a)

cents :: HasFrequency a => a -> Cents
cents a = Cents $ logBase (2/1) (frequency a) * 1200

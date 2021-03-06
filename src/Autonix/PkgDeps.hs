{-# LANGUAGE TemplateHaskell #-}

module Autonix.PkgDeps
       ( PkgDeps
       , buildInputs, nativeBuildInputs
       , propagatedBuildInputs, propagatedNativeBuildInputs
       , propagatedUserEnvPkgs
       , module Data.ByteString
       , module Data.Map
       , module Data.Set
       ) where

import Control.Lens
import Control.Monad.State (execState)
import Data.ByteString (ByteString)
import Data.Map (Map)
import Data.Monoid
import Data.Set (Set)
import qualified Data.Set as S

data PkgDeps =
    PkgDeps
    { _buildInputs :: Set ByteString
    , _nativeBuildInputs :: Set ByteString
    , _propagatedBuildInputs :: Set ByteString
    , _propagatedNativeBuildInputs :: Set ByteString
    , _propagatedUserEnvPkgs :: Set ByteString
    }
  deriving (Eq, Ord, Read, Show)
makeLenses ''PkgDeps

instance Monoid PkgDeps where
    mempty =
        PkgDeps
        { _buildInputs = S.empty
        , _nativeBuildInputs = S.empty
        , _propagatedBuildInputs = S.empty
        , _propagatedNativeBuildInputs = S.empty
        , _propagatedUserEnvPkgs = S.empty
        }

    mappend a = execState $ do
        buildInputs %= mappend (a^.buildInputs)
        nativeBuildInputs %= mappend (a^.nativeBuildInputs)
        propagatedBuildInputs %= mappend (a^.propagatedBuildInputs)
        propagatedNativeBuildInputs %= mappend (a^.propagatedNativeBuildInputs)
        propagatedUserEnvPkgs %= mappend (a^.propagatedUserEnvPkgs)

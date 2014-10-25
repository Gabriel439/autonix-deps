{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE OverloadedStrings #-}

module CMake
       ( detectCMake
       , analyzeCMakeDeps
       ) where

import Control.Monad.IO.Class
import Control.Monad.State

import Analyze
import Regex
import Types

detectCMake :: MonadState Deps m => Analyzer m
detectCMake =
    matchFileName "CMakeLists.txt" $ const $ addNativeBuildInput "cmake"

analyzeCMakeDeps :: (MonadIO m, MonadState Deps m) => Analyzer m
analyzeCMakeDeps = matchFileName "CMakeLists.txt" $ \getFile -> do
    contents <- liftIO getFile
    let new = concatMap (take 1 . drop 1) $ match regex contents
        regex = makeRegex "find_package\\([[:space:]]*([^[:space:],$\\)]+)"
    mapM_ addBuildInput new

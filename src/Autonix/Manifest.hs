module Autonix.Manifest (readManifest, readRenames) where

import Control.Applicative
import Control.Error
import Control.Monad (liftM)
import Control.Monad.IO.Class
import Data.ByteString (ByteString)
import qualified Data.ByteString.Char8 as B
import Data.Map (Map)
import qualified Data.Map as M
import Text.XML.Light

type Manifest = [(ByteString, FilePath)]

readManifest :: MonadIO m => FilePath -> m Manifest
readManifest path =
    liftM (fromMaybe $ error "malformed manifest.xml")
    $ liftIO $ runMaybeT $ do
        xml <- MaybeT $ parseXMLDoc <$> B.readFile path
        attrs <-
            MaybeT $ return
            $ if qName (elName xml) == "expr"
              then case headMay (elChildren xml) of
                  Just el | qName (elName el) == "attrs" -> Just el
                  _ -> Nothing
              else Nothing
        return $ attrsToManifest attrs

attrsToManifest :: Element -> Manifest
attrsToManifest = mapMaybe go . filterChildrenName isAttr where
  isAttr name = qName name == "attr"
  go el = do
      name <- findAttr (blank_name { qName = "name" }) el
      child <- headMay $ elChildren el
      value <- findAttr (blank_name { qName = "value"}) child
      return (B.pack name, value)

readRenames :: MonadIO m => Maybe FilePath -> m (Map ByteString ByteString)
readRenames renamesPath = do
    case renamesPath of
        Nothing -> return M.empty
        Just path ->
            liftM (M.fromList . map (toPair . B.words) . B.lines)
            $ liftIO $ B.readFile path
  where
    toPair [old, new] = (old, new)
    toPair _ = error "readRenames: invalid line"

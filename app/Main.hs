module Main where

import Hasql.Connection
import qualified Hasql.Session as H
import Hasql.Query

import Data.Pool

import Network.Wai
import qualified Network.Wai.Handler.Warp as W
import Network.HTTP.Types (status200)

main = do
  let dbUrl = "postgres://postgres@localhost:5432/demo1"
  pool <- createPool (acquire dbUrl)
            (either (const $ return ()) release) 1 1 10

  let port = 3000
  putStrLn $ "Listening on port " ++ show port
  W.run port $ \_ respond -> do
    withResource pool $ \case
      Left err -> error $ show err
      Right c -> H.run sess c
    respond $ responseLBS status200 [] "."

 where
  sess = do
    H.sql "begin isolation level read committed;"
    H.sql "set local role 'j';"
    H.sql "WITH pg_source AS (UPDATE \"public\".\"film\"  SET \"rating\"='1'::unknown  WHERE \"public\".\"film\".\"id\" = '1'::unknown ) SELECT '', 0, '', '';"
    H.sql "commit;"

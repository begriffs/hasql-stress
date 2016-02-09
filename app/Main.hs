module Main where

import qualified Hasql.Connection as H
import qualified Hasql.Session as H
import qualified Hasql.Query as H
import qualified Hasql.Encoders as HE
import qualified Hasql.Decoders as HD

import Data.Int
import Data.Pool

import Network.Wai
import qualified Network.Wai.Handler.Warp as W
import Network.HTTP.Types (status200)

main = do
  let dbUrl = "postgres://postgres@localhost:5432/demo1"
  pool <- createPool (H.acquire dbUrl)
            (either (const $ return ()) H.release) 1 1 10

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
    _ <- H.query () updater
    H.sql "commit;"

updater :: H.Query () Int64
updater =
  H.statement sql HE.unit decoder True
  where
    sql =
      "WITH pg_source AS (UPDATE \"public\".\"film\"  SET \"rating\"='1'::unknown  WHERE \"public\".\"film\".\"id\" = '1'::unknown ) SELECT 1;"
    decoder =
      HD.singleRow (HD.value HD.int8)

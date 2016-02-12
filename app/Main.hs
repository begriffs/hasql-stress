module Main where

import Hasql.Connection
import Hasql.Session hiding (run)
import Hasql.Query

import Network.Wai
import Network.Wai.Handler.Warp
import Network.HTTP.Types (status200)

import Data.Time.Clock.POSIX
import System.Random
import Control.Concurrent
import Control.Monad

import qualified Hasql.Pool as P

main = do
  void . forkIO . forever $ do
      t <- round <$> getPOSIXTime :: IO Integer
      putStrLn $ "alive " ++ show t
      threadDelay 1000000

  pool <- P.acquire (100, 0.5, "postgres://postgres@localhost:5432/demo1")

  let port = 3000
  putStrLn $ "Listening on port " ++ show port
  run port $ \_ respond -> do
    threadDelay =<< getStdRandom (randomR (0,1000000))
    P.use pool sess
    respond $ responseLBS status200 [] "."

 where
  sess = do
    sql "begin isolation level read committed;"
    sql "set local role 'j';"
    sql "WITH pg_source AS (UPDATE \"public\".\"film\"  SET \"rating\"='1'::unknown  WHERE \"public\".\"film\".\"id\" = '1'::unknown ) SELECT '', 0, '', '';"
    sql "commit;"

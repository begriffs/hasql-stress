module Main where

import qualified Control.Concurrent.Thread.Group as TGroup
import Control.Concurrent (threadDelay)
import Control.Monad (replicateM_, void)
import Data.Monoid ((<>))
import Hasql.Connection
import Hasql.Session
import Hasql.Query

import System.Random (getStdRandom, randomR)

import qualified Hasql.Pool as P

main :: IO ()
main = do
  let atOnce = 10
  kids <- TGroup.new
  pool <- P.acquire (atOnce, 10, "postgres://postgres@localhost:5432/demo1")
  replicateM_ atOnce . TGroup.forkIO kids $ do
    threadDelay =<< getStdRandom (randomR (0,1000000))
    void . P.use pool $ inTransaction ReadCommitted sess
  TGroup.wait kids

 where
  sess = do
    sql "WITH pg_source AS (UPDATE \"public\".\"film\"  SET \"rating\"='1'::unknown  WHERE \"public\".\"film\".\"id\" = '1'::unknown ) SELECT '', 0, '', '';"

data Isolation = ReadCommitted | RepeatableRead | Serializable

inTransaction :: Isolation -> Session a -> Session a
inTransaction lvl f = do
  sql $ "begin " <> isolate <> ";"
  r <- f
  sql "commit;"
  return r
 where
  isolate = case lvl of
    ReadCommitted  -> "ISOLATION LEVEL READ COMMITTED"
    RepeatableRead -> "ISOLATION LEVEL REPEATABLE READ"
    Serializable   -> "ISOLATION LEVEL SERIALIZABLE"

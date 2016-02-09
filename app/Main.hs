module Main where

import qualified Control.Concurrent.Thread.Group as TGroup
import Control.Monad (replicateM_, void)
import Hasql.Connection
import Hasql.Session
import Hasql.Query

import qualified Hasql.Pool as P

main :: IO ()
main = do
  let atOnce = 10
  kids <- TGroup.new
  pool <- P.acquire (atOnce, 0.5, "postgres://postgres@localhost:5432/demo1")
  replicateM_ atOnce . TGroup.forkIO kids . void $ P.use pool sess

  TGroup.wait kids
 where
  sess = do
    sql "begin isolation level read committed;"
    sql "set local role 'j';"
    sql "WITH pg_source AS (UPDATE \"public\".\"film\"  SET \"rating\"='1'::unknown  WHERE \"public\".\"film\".\"id\" = '1'::unknown ) SELECT '', 0, '', '';"
    sql "commit;"

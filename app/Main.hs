module Main where

import Control.Monad (void)
import Hasql.Connection
import Hasql.Session
import Hasql.Query

main :: IO ()
main = do
  acquire "postgres://postgres@localhost:5432/demo1" >>= \case
    Left err -> error $ show err
    Right c ->
      void $ run sess c
 where
  sess = do
    sql "begin isolation level read committed;"
    sql "WITH pg_source AS (UPDATE \"public\".\"film\"  SET \"rating\"='1'::unknown  WHERE \"public\".\"film\".\"id\" = '1'::unknown ) SELECT '', 0, '', '';"
    sql "commit;"

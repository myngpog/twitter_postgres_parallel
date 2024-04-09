#!/bin/bash

files=$(find data/*)

echo '================================================================================'
echo 'load denormalized'
echo '================================================================================'
for file in $files; do
    # use SQL's COPY command to load data into pg_denormalized
    time unzip -p "$file" | sed 's/\\u0000//g' | psql postgresql://postgres:pass@localhost:13649/postgres -c "COPY tweets_jsonb (data) FROM STDIN csv quote e'\x01' delimiter e'\x02';"
done

echo '================================================================================'
echo 'load pg_normalized'
echo '================================================================================'
for file in $files; do
    # call the load_tweets.py file to load data into pg_normalized
    time python3 load_tweets.py --db=postgresql://postgres:pass@localhost:13549/postgres --inputs "$file"
done

echo '================================================================================'
echo 'load pg_normalized_batch'
echo '================================================================================'
for file in $files; do
    time python3 -u load_tweets_batch.py --db=postgresql://postgres:pass@localhost:13926/ --inputs $file
done

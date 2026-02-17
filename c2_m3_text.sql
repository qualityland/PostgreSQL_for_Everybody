---------------------------
-- GERNERATION FUNCTIONS --
---------------------------
-- Generation of test data;
--      repeat() - to generate long strings (horizontal)
--      generate_series() - to generate lots of rows (vertical)
--      random() - to make rows unique by generating a float between 0 and 1

-- random numbers
SELECT random(), random(), trunc(random() * 100);

-- longer strings
SELECT repeat('Neon ', 5);

-- series of rows
SELECT generate_series(1, 5);

-- generate a series of longer strings with some random data
SELECT 'https://sql4e.com/neon/' || trunc(random() * 1000000) || repeat('Lemon', 5) || generate_series(1, 5) AS url;



----------------------
-- DATA GERNERATION --
----------------------

-- create table
CREATE TABLE textfun (
    content TEXT
);

-- create index
CREATE INDEX textfun_b ON textfun(content);

-- check sizes
SELECT pg_relation_size('textfun'), pg_indexes_size('textfun');

-- insert data
INSERT INTO textfun
SELECT (CASE WHEN (random() > 0.5)
         THEN 'https://www.pg4e.com/neon/'
         ELSE 'http://www.pg4e.com/LEMONS/'
         END) || generate_series(100000, 200000);


-- check sizes again
SELECT pg_relation_size('textfun'), pg_indexes_size('textfun');


--------------------
-- TEXT FUNCTIONS --
--------------------

-- WHERE Clause Operators:
--------------------------
-- LIKE, ILIKE, NOT LIKE NOT ILIKE
-- SIMILAR TO, NOT SIMILAR TO
-- =, >, <, >=, <=, BETWEEN IN

-- Manipuation of SELECT Results / WHERE Clause:
------------------------------------------------
-- lower(), upper()

-- LIKE
SELECT content FROM textfun WHERE content LIKE '%150000%';
--  http://www.pg4e.com/LEMONS/150000

-- upper
SELECT upper(content) FROM textfun WHERE content LIKE '%150000%';
-- HTTP://WWW.PG4E.COM/LEMONS/150000

-- lower
SELECT lower(content) FROM textfun WHERE content LIKE '%150000%';
-- http://www.pg4e.com/lemons/150000

-- right
SELECT right(content, 4) FROM textfun WHERE content LIKE '%150000%';
-- 0000

-- left
SELECT left(content, 4) FROM textfun WHERE content LIKE '%150000%';
-- http

-- strpos
SELECT strpos(content, 'ttp://') FROM textfun WHERE content LIKE '%150000%';
-- 2

-- substr(str, start, len)
SELECT substr(content, 2, 4) FROM textfun WHERE content LIKE '%150000%';
-- ttp:

-- split_part(str, char, len)
SELECT split_part(content, '/', 4) FROM textfun WHERE content LIKE '%150000%';
-- LEMONS

-- translate(str, from, to)
SELECT translate(content, 'th.p/', 'TH!P') FROM textfun WHERE content LIKE '%150000%';
-- HTTP:www!Pg4e!comLEMONS150000



------------------------------
-- B TREE INDEX PERFORMANCE --
------------------------------

-- LIKE and one wildcard
EXPLAIN ANALYZE SELECT content FROM textfun WHERE content LIKE 'racing%';
-- Planning Time: 0.295 ms
-- Execution Time: 0.030 ms

-- LIKE and two wildcard
EXPLAIN ANALYZE SELECT content FROM textfun WHERE content LIKE '%racing%';
-- Planning Time: 0.081 ms
-- Execution Time: 19.775 ms

-- ILIKE (ignore case) and one wildcard
EXPLAIN ANALYZE SELECT content FROM textfun WHERE content ILIKE 'racing%';
-- Planning Time: 0.098 ms
-- Execution Time: 30.558 ms


-- if you know there is only ONE record, use LIMIT 1 to enhance performance
-- here DB goes on searching after it found 1st occurence
EXPLAIN ANALYZE SELECT content FROM textfun WHERE content LIKE '%150000%';
-- Planning Time: 0.116 ms
-- Execution Time: 20.618 ms

-- DB stops searching as soon as 1st record was found
EXPLAIN ANALYZE SELECT content FROM textfun WHERE content LIKE '%150000%' LIMIT 1;
-- Planning Time: 0.126 ms
-- Execution Time: 12.908 ms


-- IN
EXPLAIN ANALYZE SELECT content FROM textfun WHERE content IN ('http://www.pg4e.com/LEMONS/150000',
                                                              'https://www.pg4e.com/LEMONS/150000');
-- Planning Time: 2.711 ms
-- Execution Time: 0.146 ms


EXPLAIN ANALYZE SELECT content FROM textfun WHERE content
 IN (SELECT content FROM textfun WHERE content LIKE '%150000%%');
 ----------------------------------------------------------------------------------------------------------------------------------
-- Nested Loop  (cost=2084.45..2128.59 rows=10 width=33) (actual time=20.403..20.406 rows=1.00 loops=1)
--   Buffers: shared hit=838
--   ->  HashAggregate  (cost=2084.04..2084.14 rows=10 width=33) (actual time=20.375..20.377 rows=1.00 loops=1)
--         Group Key: textfun_1.content
--         Batches: 1  Memory Usage: 32kB
--         Buffers: shared hit=834
--         ->  Seq Scan on textfun textfun_1  (cost=0.00..2084.01 rows=10 width=33) (actual time=10.667..20.108 rows=1.00 loops=1)
--               Filter: (content ~~ '%150000%%'::text)
--               Rows Removed by Filter: 100000
--               Buffers: shared hit=834
--   ->  Index Only Scan using textfun_b on textfun  (cost=0.42..4.44 rows=1 width=33) (actual time=0.022..0.022 rows=1.00 loops=1)
--         Index Cond: (content = textfun_1.content)
--         Heap Fetches: 0
--         Index Searches: 1
--         Buffers: shared hit=4
-- Planning:
--   Buffers: shared hit=76 read=6
-- Planning Time: 5.360 ms
-- Execution Time: 20.623 ms


--------------------
-- CHARACTER SETS --
--------------------

SELECT ascii('H'), ascii('e'), ascii('l'), chr(72), chr(42);
-- ascii | ascii | ascii | chr | chr 
---------+-------+-------+-----+-----
--    72 |   101 |   108 | H   | *


SELECT chr(72), chr(231), chr(20013);
--  chr | chr | chr 
-- -----+-----+-----
--  H   | ç   | 中

SHOW SERVER_ENCODING;
-- UTF8








-----------------
-- PERFORMANCE --
-----------------

-- How long is a URL?
CREATE TABLE cr1 (
    id SERIAL,
    url VARCHAR(128) unique,
    content TEXT
);

-- insert a too long URL
INSERT INTO cr1(url)
SELECT repeat('Neon', 1000) || generate_series(1, 5000);


-- create table with max URL length 128
CREATE TABLE cr2 (
    id SERIAL,
    url TEXT,
    content TEXT
);

-- insert a too long URL: ERROR
INSERT INTO cr2(url)
SELECT repeat('Neon', 1000) || generate_series(1, 5000);

-- check index size
SELECT pg_relation_size('cr2'), pg_indexes_size('cr2');
-- pg_relation_size | pg_indexes_size
--------------------+-----------------
--           507904 |               0

-- create index on URL
CREATE UNIQUE INDEX cr2_unique ON cr2(url);

-- check index size again
SELECT pg_relation_size('cr2'), pg_indexes_size('cr2');
-- pg_relation_size | pg_indexes_size
--------------------+-----------------
--           507904 |          450560

-- drop index
DROP INDEX cr2_unique;

-- create index using md5 hash
CREATE INDEX cr2_md5 on cr2(md5(url));

-- check index size: smaller!
SELECT pg_relation_size('cr2'), pg_indexes_size('cr2');
-- pg_relation_size | pg_indexes_size
--------------------+-----------------
--           507904 |          311296

-- since index is not on content (but on md5(url)),
-- searching the url will result in full table scan
EXPLAIN SELECT * FROM cr2 WHERE url = 'lemons';
-- Seq Scan

-- but md5(url) would use the index
EXPLAIN SELECT * FROM cr2 WHERE md5(url) = md5('lemons');
-- Index Scan using cr2_md5 on cr2


-- Best Solution: UUID
CREATE TABLE cr3 (
    id SERIAL,
    url TEXT,
    url_md5 UUID UNIQUE,
    content TEXT
);

-- add url to table
INSERT INTO cr3 (url)
SELECT repeat('Neon', 1000) || generate_series(1, 5000);

-- add uuid
UPDATE cr3 SET url_md5 = md5(url)::uuid;

-- check index size
SELECT pg_relation_size('cr3'), pg_indexes_size('cr3');
-- pg_relation_size | pg_indexes_size
--------------------+-----------------
--          1097728 |          368640

-- Fast, using Index
EXPLAIN ANALYZE SELECT * from cr3 WHERE url_md5 = md5('lemons')::uuid;
-- Index Scan using cr3_url_md5_key on cr3
-- Planning Time: 0.110 ms
-- Execution Time: 0.030 ms


-- PostgreSQL Index Types
-------------------------
-- B-Tree: maintains order, usually preferred
--         helps on exact lookup, prefix lookup, <, >, range, sort
-- HASH: smaller, but helps only on exact lookup
--       not recommended before PostgreSQL 10


-- Using a HASH
CREATE TABLE cr4 (
    id SERIAL,
    url TEXT,
    content TEXT
);

-- create HASH index
CREATE INDEX cr4_hash ON cr4 USING hash(url);

-- check index size
SELECT pg_relation_size('cr4'), pg_indexes_size('cr4');
-- pg_relation_size | pg_indexes_size
--------------------+-----------------
--           507904 |          278528

-- Very fast, using Index
EXPLAIN ANALYZE SELECT * from cr4 WHERE url = 'lemons';
-- Bitmap Heap Scan on cr4_hash
-- Planning Time: 0.131 ms
-- Execution Time: 0.045 ms




------------------
-- Assignment 3 --
------------------

CREATE TABLE bigtext (
  content TEXT
);

INSERT INTO bigtext (content) SELECT 'This is record number ' || generate_series(100000,199000) || ' of quite a few text records.';


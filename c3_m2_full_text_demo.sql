
-- https://www.pg4e.com/lectures/05-FullText.sql


------------------------------------------------------------------------------
--               Building an Inverted Index using SQL                       --
------------------------------------------------------------------------------
-- Strings, arrays, and rows

SELECT string_to_array('Hello world', ' ');
SELECT unnest(string_to_array('Hello world', ' '));

-- Inverted string index with SQL

CREATE TABLE docs (id SERIAL, doc TEXT, PRIMARY KEY(id));
INSERT INTO docs (doc) VALUES
('This is SQL and Python and other fun teaching stuff'),
('More people should learn SQL from UMSI'),
('UMSI also teaches Python and also SQL');
SELECT * FROM docs;

--- https://stackoverflow.com/questions/29419993/split-column-into-multiple-rows-in-postgres

--------------- alternative development of inserst statement -----------------
-- develop our insert statement
SELECT id, keywords
FROM docs, string_to_array(docs.doc, ' ') keywords
ORDER BY id;

SELECT id, keyword
FROM docs, unnest(string_to_array(docs.doc, ' ')) keyword
ORDER BY id;

SELECT DISTINCT id, keyword
FROM docs, unnest(string_to_array(docs.doc, ' ')) keyword
ORDER BY id;

INSERT INTO docs_gin (doc_id, keyword)
SELECT DISTINCT id, keyword
FROM docs, unnest(string_to_array(docs.doc, ' ')) keyword
ORDER BY id;
------------------------------------------------------------------------------

-- Break the document column into one row per word + primary key
SELECT id, s.keyword AS keyword
FROM docs AS D, unnest(string_to_array(D.doc, ' ')) s(keyword)
ORDER BY id;

-- Discard duplicate rows
SELECT DISTINCT id, s.keyword AS keyword
FROM docs AS D, unnest(string_to_array(D.doc, ' ')) s(keyword)
ORDER BY id;

CREATE TABLE docs_gin (
  keyword TEXT,
  doc_id INTEGER REFERENCES docs(id) ON DELETE CASCADE
);

-- Insert the keyword / primary key rows into a table
INSERT INTO docs_gin (doc_id, keyword)
SELECT DISTINCT id, s.keyword AS keyword
FROM docs AS D, unnest(string_to_array(D.doc, ' ')) s(keyword)
ORDER BY id;

SELECT * FROM docs_gin ORDER BY doc_id;

-- Find all the distinct documents that match a keyword
SELECT DISTINCT keyword, doc_id FROM docs_gin AS G
WHERE G.keyword = 'UMSI';

-- Find all the distinct documents that match a keyword
SELECT DISTINCT id, doc FROM docs AS D
JOIN docs_gin AS G ON D.id = G.doc_id
WHERE G.keyword = 'UMSI';

-- We can remove duplicates and have more than one keyword
SELECT DISTINCT doc FROM docs AS D
JOIN docs_gin AS G ON D.id = G.doc_id
WHERE G.keyword IN ('fun', 'people');

-- We can handle a phrase
SELECT DISTINCT doc FROM docs AS D
JOIN docs_gin AS G ON D.id = G.doc_id
WHERE G.keyword = ANY(string_to_array('I want to learn', ' '));

-- This can go sideways - (foreshadowing stop words)
SELECT DISTINCT id, doc FROM docs AS D
JOIN docs_gin AS G ON D.id = G.doc_id
WHERE G.keyword = ANY(string_to_array('Search for Lemons and Neons', ' '));

-- docs_gin is purely a text (not language) based Inverted Index
-- PostgreSQL already knows how to do this using the GIN index


------------------------------------------------------------------------------
--        Building an Inverted Index with Stop Words using SQL              --
------------------------------------------------------------------------------

DROP TABLE docs cascade;
CREATE TABLE docs (id SERIAL, doc TEXT, PRIMARY KEY(id));

-- The GIN (General Inverted Index) thinks about columns that contain arrays
-- A GIN needs to know what kind of data will be in the arrays
-- array_ops means that it is expecting text[] (arrays of strings)
-- and WHERE clauses will use array operators (i.e. like <@ )

DROP INDEX gin1;

CREATE INDEX gin1 ON docs USING gin(string_to_array(doc, ' ')  array_ops);

INSERT INTO docs (doc) VALUES
('This is SQL and Python and other fun teaching stuff'),
('More people should learn SQL from UMSI'),
('UMSI also teaches Python and also SQL');

-- Insert enough lines to get PostgreSQL attention
INSERT INTO docs (doc) SELECT 'Neon ' || generate_series(10000,20000);

-- You might need to wait a minute until the index catches up to the inserts

-- The <@ if "is contained within" or "intersection" from set theory
SELECT id, doc FROM docs WHERE '{learn}' <@ string_to_array(doc, ' ');
EXPLAIN SELECT id, doc FROM docs WHERE '{learn}' <@ string_to_array(doc, ' ');

-- Inverted string index with stop words using SQL

-- If we know the documents contain natural language, we can optimize indexes

-- (1) Ignore the case of words in the index and in the query
-- (2) Don't index low-meaning "stop words" that we will ignore
-- if they are in a search query

DROP TABLE docs CASCADE;
CREATE TABLE docs (id SERIAL, doc TEXT, PRIMARY KEY(id));
INSERT INTO docs (doc) VALUES
('This is SQL and Python and other fun teaching stuff'),
('More people should learn SQL from UMSI'),
('UMSI also teaches Python and also SQL');
SELECT * FROM docs;

--- https://stackoverflow.com/questions/29419993/split-column-into-multiple-rows-in-postgres

-- Break the document column into one row per word + primary key
SELECT DISTINCT id, s.keyword AS keyword
FROM docs AS D, unnest(string_to_array(D.doc, ' ')) s(keyword)
ORDER BY id;

-- Lower case it all
SELECT DISTINCT id, s.keyword AS keyword
FROM docs AS D, unnest(string_to_array(lower(D.doc), ' ')) s(keyword)
ORDER BY id;

DROP TABLE docs_gin CASCADE;
CREATE TABLE docs_gin (
  keyword TEXT,
  doc_id INTEGER REFERENCES docs(id) ON DELETE CASCADE
);

DROP TABLE stop_words;
CREATE TABLE stop_words (word TEXT unique);
INSERT INTO stop_words (word) VALUES ('is'), ('this'), ('and');

-- All we do is throw out the words in the stop word list
SELECT DISTINCT id, s.keyword AS keyword
FROM docs AS D, unnest(string_to_array(lower(D.doc), ' ')) s(keyword)
WHERE s.keyword NOT IN (SELECT word FROM stop_words)
ORDER BY id;

-- Put the stop-word free list into the GIN
INSERT INTO docs_gin (doc_id, keyword)
SELECT DISTINCT id, s.keyword AS keyword
FROM docs AS D, unnest(string_to_array(lower(D.doc), ' ')) s(keyword)
WHERE s.keyword NOT IN (SELECT word FROM stop_words)
ORDER BY id;

SELECT * FROM docs_gin;

-- A one word query
SELECT DISTINCT doc FROM docs AS D
JOIN docs_gin AS G ON D.id = G.doc_id
WHERE G.keyword = lower('UMSI');

-- A multi-word query
SELECT DISTINCT doc FROM docs AS D
JOIN docs_gin AS G ON D.id = G.doc_id
WHERE G.keyword =
  ANY(string_to_array(lower('Meet fun people'), ' '));

-- A stop word query - as if it were never there
SELECT DISTINCT doc FROM docs AS D
JOIN docs_gin AS G ON D.id = G.doc_id
WHERE G.keyword = lower('and');

-- Add stemming
-- https://www.pg4e.com/lectures/05-FullText.sql

-- We can make the index even smaller
-- (3) Only store the "stems" of words

-- Our simple approach is to make a "dictionary" of word -> stem

------------------------------------------------------------------------------
--                              add Stemming                                --
------------------------------------------------------------------------------

CREATE TABLE docs_stem (word TEXT, stem TEXT);
INSERT INTO docs_stem (word, stem) VALUES
('teaching', 'teach'), ('teaches', 'teach');

-- Move the initial word extraction into a sub-query
SELECT id, keyword FROM (
SELECT DISTINCT id, s.keyword AS keyword
FROM docs AS D, unnest(string_to_array(lower(D.doc), ' ')) s(keyword)
) AS X;

-- Add the stems as third column (may or may not exist)
SELECT id, keyword, stem FROM (
SELECT DISTINCT id, s.keyword AS keyword
FROM docs AS D, unnest(string_to_array(lower(D.doc), ' ')) s(keyword)
) AS K
LEFT JOIN docs_stem AS S ON K.keyword = S.word;

-- If the stem is there, use it
SELECT id,
CASE WHEN stem IS NOT NULL THEN stem ELSE keyword END AS awesome,
keyword, stem
FROM (
SELECT DISTINCT id, lower(s.keyword) AS keyword
FROM docs AS D, unnest(string_to_array(D.doc, ' ')) s(keyword)
) AS K
LEFT JOIN docs_stem AS S ON K.keyword = S.word;

-- Null Coalescing - return the first non-null in a list
-- x = stem or 'teaching'  # Python
SELECT COALESCE(NULL, NULL, 'umsi');
SELECT COALESCE('umsi', NULL, 'SQL');

-- If the stem is there, use it instead of the keyword
SELECT id, COALESCE(stem, keyword) AS keyword
FROM (
SELECT DISTINCT id, s.keyword AS keyword
FROM docs AS D, unnest(string_to_array(lower(D.doc), ' ')) s(keyword)
) AS K
LEFT JOIN docs_stem AS S ON K.keyword = S.word;

-- Insert only the stems
DELETE FROM docs_gin;

INSERT INTO docs_gin (doc_id, keyword)
SELECT id, COALESCE(stem, keyword)
FROM (
  SELECT DISTINCT id, s.keyword AS keyword
  FROM docs AS D, unnest(string_to_array(lower(D.doc), ' ')) s(keyword)
) AS K
LEFT JOIN docs_stem AS S ON K.keyword = S.word;

SELECT * FROM docs_gin;

-- Lets do stop words and stems...
DELETE FROM docs_gin;

INSERT INTO docs_gin (doc_id, keyword)
SELECT id, COALESCE(stem, keyword)
FROM (
  SELECT DISTINCT id, s.keyword AS keyword
  FROM docs AS D, unnest(string_to_array(lower(D.doc), ' ')) s(keyword)
  WHERE s.keyword NOT IN (SELECT word FROM stop_words)
) AS K
LEFT JOIN docs_stem AS S ON K.keyword = S.word;

SELECT * FROM docs_gin;

-- Lets do some queries
SELECT COALESCE((SELECT stem FROM docs_stem WHERE word=lower('SQL')), lower('SQL'));

-- Handling the stems in queries.  Use the keyword if there is no stem
SELECT DISTINCT id, doc FROM docs AS D
JOIN docs_gin AS G ON D.id = G.doc_id
WHERE G.keyword = COALESCE((SELECT stem FROM docs_stem WHERE word=lower('SQL')), lower('SQL'));

-- Prefer the stem over the actual keyword
SELECT COALESCE((SELECT stem FROM docs_stem WHERE word=lower('teaching')), lower('teaching'));

SELECT DISTINCT id, doc FROM docs AS D
JOIN docs_gin AS G ON D.id = G.doc_id
WHERE G.keyword = COALESCE((SELECT stem FROM docs_stem WHERE word=lower('teaching')), lower('teaching'));

-- The technical term for converting search terms to their stems is called "conflation"
-- from https://en.wikipedia.org/wiki/Stemming

------------------------------------------------------------------------------
--                            Start Assignment                              --
------------------------------------------------------------------------------


-- Build an Inverted Index using SQL

CREATE TABLE docs01 (id SERIAL, doc TEXT, PRIMARY KEY(id));

CREATE TABLE invert01 (
  keyword TEXT,
  doc_id INTEGER REFERENCES docs01(id) ON DELETE CASCADE
);

INSERT INTO docs01 (doc) VALUES
('I hate you Python'),
('if you come out of there I would teach you a lesson'),
('There is little to be gained by arguing with Python It is just a tool'),
('It has no emotions and it is happy and ready to serve you whenever you'),
('need it Its error messages sound harsh but they are just Pythons call'),
('for help It has looked at what you typed and it simply cannot'),
('understand what you have entered'),
('Python is much more like a dog loving you unconditionally having a few'),
('key words that it understands looking you with a sweet look on its face'),
('understands When Python says SyntaxError invalid syntax it is');

INSERT INTO invert01 (keyword, doc_id)
SELECT DISTINCT keyword, id
FROM docs01, unnest(string_to_array(lower(docs01.doc), ' ')) keyword
ORDER BY keyword;


-- Building an Inverted Index with Stop Words using SQL

CREATE TABLE docs02 (id SERIAL, doc TEXT, PRIMARY KEY(id));

CREATE TABLE invert02 (
  keyword TEXT,
  doc_id INTEGER REFERENCES docs02(id) ON DELETE CASCADE
);

INSERT INTO docs02 (doc) VALUES
('I hate you Python'),
('if you come out of there I would teach you a lesson'),
('There is little to be gained by arguing with Python It is just a tool'),
('It has no emotions and it is happy and ready to serve you whenever you'),
('need it Its error messages sound harsh but they are just Pythons call'),
('for help It has looked at what you typed and it simply cannot'),
('understand what you have entered'),
('Python is much more like a dog loving you unconditionally having a few'),
('key words that it understands looking you with a sweet look on its face'),
('understands When Python says SyntaxError invalid syntax it is');

CREATE TABLE stop_words (word TEXT unique);

INSERT INTO stop_words (word) VALUES 
('i'), ('a'), ('about'), ('an'), ('are'), ('as'), ('at'), ('be'), 
('by'), ('com'), ('for'), ('from'), ('how'), ('in'), ('is'), ('it'), ('of'), 
('on'), ('or'), ('that'), ('the'), ('this'), ('to'), ('was'), ('what'), 
('when'), ('where'), ('who'), ('will'), ('with');

INSERT INTO invert02 (keyword, doc_id)
SELECT DISTINCT s.keyword AS keyword, id
FROM docs02, unnest(string_to_array(lower(docs02.doc), ' ')) s(keyword)
WHERE s.keyword NOT IN (SELECT word FROM stop_words)
ORDER BY keyword;



------------------------------------------------------------------------------
--                             End Assignment                               --
------------------------------------------------------------------------------



-- Using PostgreSQL built-in features (much easier and more efficient)
-- https://www.pg4e.com/lectures/05-FullText.sql

-- ts_vector is an special "array" of stemmed words, passed throug a stop-word
-- filter + positions within the document
SELECT to_tsvector('english', 'This is SQL and Python and other fun teaching stuff');
SELECT to_tsvector('english', 'More people should learn SQL from UMSI');
SELECT to_tsvector('english', 'UMSI also teaches Python and also SQL');

-- ts_query is an "array" of lower case, stemmed words with
-- stop words removed plus logical operators & = and, ! = not, | = or
SELECT to_tsquery('english', 'teaching');
SELECT to_tsquery('english', 'teaches');
SELECT to_tsquery('english', 'and');
SELECT to_tsquery('english', 'SQL');
SELECT to_tsquery('english', 'Teach | teaches | teaching | and | the | if');

-- Plaintext just pulls out the keywords
SELECT plainto_tsquery('english', 'SQL Python');
SELECT plainto_tsquery('english', 'Teach teaches teaching and the if');

-- A phrase is words that come in order
SELECT phraseto_tsquery('english', 'SQL Python');

-- Websearch is in PostgreSQL >= 11 and a bit like
-- https://www.google.com/advanced_search
SELECT websearch_to_tsquery('english', 'SQL -not Python');

SELECT to_tsquery('english', 'teaching') @@
  to_tsvector('english', 'UMSI also teaches Python and also SQL');

------------------------------------------------------------------------------
--          Building a tsvector based GIN Index in PostgreSQL               --
------------------------------------------------------------------------------

-- Lets do an english language inverted index using a tsvector index.
-- https://www.pg4e.com/lectures/05-FullText.sql

DROP TABLE docs cascade;
DROP INDEX gin1;

CREATE TABLE docs (id SERIAL, doc TEXT, PRIMARY KEY(id));
CREATE INDEX gin1 ON docs USING gin(to_tsvector('english', doc));

INSERT INTO docs (doc) VALUES
('This is SQL and Python and other fun teaching stuff'),
('More people should learn SQL from UMSI'),
('UMSI also teaches Python and also SQL');

-- Filler rows
INSERT INTO docs (doc) SELECT 'Neon ' || generate_series(10000,20000);


SELECT id, doc FROM docs WHERE
    to_tsquery('english', 'learn') @@ to_tsvector('english', doc);

EXPLAIN SELECT id, doc FROM docs WHERE
    to_tsquery('english', 'learn') @@ to_tsvector('english', doc);


-- Check the operation types for the various indexes

-- SELECT version();   -- PostgreSQL 9.6.7
-- https://habr.com/en/company/postgrespro/blog/448746/

SELECT version();

SELECT am.amname AS index_method, opc.opcname AS opclass_name
    FROM pg_am am, pg_opclass opc
    WHERE opc.opcmethod = am.oid
    ORDER BY index_method, opclass_name;

------------------------------------------------------------------------------
--                            Start Assignment                              --
------------------------------------------------------------------------------
CREATE TABLE docs (id SERIAL, doc TEXT, PRIMARY KEY(id));
CREATE INDEX gin1 ON docs USING gin(to_tsvector('english', doc));

INSERT INTO docs (doc) VALUES
('This is SQL and Python and other fun teaching stuff'),
('More people should learn SQL from UMSI'),
('UMSI also teaches Python and also SQL');

-- query and explain
SELECT id, doc FROM docs03 WHERE '{unconditionally}' <@ string_to_array(lower(doc), ' ');
EXPLAIN SELECT id, doc FROM docs03 WHERE '{unconditionally}' <@ string_to_array(lower(doc), ' ');

-- 1. create table
CREATE TABLE docs03 (id SERIAL, doc TEXT, PRIMARY KEY(id));
-- 2. create GIN
CREATE INDEX array03 ON docs03 USING gin(string_to_array(lower(doc), ' '));
CREATE INDEX array03 ON docs03 USING gin(to_tsvector('english', doc));
-- 3. insert docs
INSERT INTO docs03 (doc) VALUES
('I hate you Python'),
('if you come out of there I would teach you a lesson'),
('There is little to be gained by arguing with Python It is just a tool'),
('It has no emotions and it is happy and ready to serve you whenever you'),
('need it Its error messages sound harsh but they are just Pythons call'),
('for help It has looked at what you typed and it simply cannot'),
('understand what you have entered'),
('Python is much more like a dog loving you unconditionally having a few'),
('key words that it understands looking you with a sweet look on its face'),
('understands When Python says SyntaxError invalid syntax it is');
-- 4. filler rows
INSERT INTO docs03 (doc) SELECT 'Neon ' || generate_series(10000,20000);
-- 5. explain
EXPLAIN SELECT id, doc FROM docs03 WHERE '{unconditionally}' <@ string_to_array(lower(doc), ' ');


-- 1. create table & index
CREATE TABLE docs03 (id SERIAL, doc TEXT, PRIMARY KEY(id));
CREATE INDEX fulltext03 ON docs03 USING gin(to_tsvector('english', doc));
-- 2. insert docs
INSERT INTO docs03 (doc) VALUES
('I hate you Python'),
('if you come out of there I would teach you a lesson'),
('There is little to be gained by arguing with Python It is just a tool'),
('It has no emotions and it is happy and ready to serve you whenever you'),
('need it Its error messages sound harsh but they are just Pythons call'),
('for help It has looked at what you typed and it simply cannot'),
('understand what you have entered'),
('Python is much more like a dog loving you unconditionally having a few'),
('key words that it understands looking you with a sweet look on its face'),
('understands When Python says SyntaxError invalid syntax it is');
-- 3. filler rows
INSERT INTO docs03 (doc) SELECT 'Neon ' || generate_series(10000,20000);
-- 5. explain
SELECT id, doc FROM docs03 WHERE to_tsquery('english', 'unconditionally') @@ to_tsvector('english', doc);
EXPLAIN SELECT id, doc FROM docs03 WHERE to_tsquery('english', 'unconditionally') @@ to_tsvector('english', doc);


-- end here

CREATE TABLE docs (id SERIAL, doc TEXT, PRIMARY KEY(id));
CREATE INDEX gin1 ON docs USING gist(to_tsvector('english', doc));

INSERT INTO docs (doc) VALUES
('This is SQL and Python and other fun teaching stuff'),
('More people should learn SQL from UMSI'),
('UMSI also teaches Python and also SQL');
------------------------------------------------------------------------------
--                             End Assignment                               --
------------------------------------------------------------------------------


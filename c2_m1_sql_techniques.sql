-------------------------------------
-- CREATE TABLE with some mistakes --
-------------------------------------
-- setup some tables
CREATE TABLE account (
    id SERIAL,
    email VARCHAR(128) UNIQUE,
    created_at DATE NOT NULL DEFAULT NOW(),
    updated_at DATE NOT NULL DEFAULT NOW(),
    PRIMARY KEY(id)
);

CREATE TABLE post (
    id SERIAL,
    title VARCHAR(128) UNIQUE NOT NULL,
    content VARCHAR(1024), -- will extend with ALTER
    account_id INTEGER REFERENCES account(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY(id)
);

CREATE TABLE comment (
    id SERIAL,
    content TEXT NOT NULL,  
    account_id INTEGER REFERENCES account(id) ON DELETE CASCADE,
    post_id INTEGER REFERENCES post(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY(id)
);

CREATE TABLE fav (
    id SERIAL,
    oops TEXT, -- will remove later with ALTER
    post_id INTEGER REFERENCES post(id) ON DELETE CASCADE,
    account_id INTEGER REFERENCES account(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(post_id, account_id),
    PRIMARY KEY(id)
);

----------------
-- ALTER TABLE--
----------------
-- remove the accidentally left in column
ALTER TABLE fav DROP COLUMN oops;
-- add a column for the stars of favorite posts
ALTER TABLE fav ADD COLUMN howmuch INTEGER;
-- extend content (from varchar to text)
ALTER TABLE post ALTER COLUMN content TYPE TEXT;

--------------------------------
-- READING COMMANDS FROM FILE --
--------------------------------
-- see here:
-- https://www.pg4e.com/lectures/03-Techniques-Load.sql
-- discuss=> \i 03-Techniques-Load.sql
-- DELETE 4
-- ALTER SEQUENCE
-- ALTER SEQUENCE
-- ALTER SEQUENCE
-- ALTER SEQUENCE
-- INSERT 0 3
-- INSERT 0 3
-- INSERT 0 5
-- ...


-----------
-- DATES --
-----------

-- CAVE!
-- create timestamp can be defined in CREATE TABLE statement
-- created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

-- but update mechanism has to implemented in STORED PROCEDURE
-- updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

-- show current time in different time zones
SELECT NOW(), NOW() AT TIME ZONE 'UTC', NOW() AT TIME ZONE 'HST';

--  show list of time zones
SELECT * FROM pg_timezone_names;

-- find time zone for a region
SELECT * FROM pg_timezone_names WHERE name LIKE '%Hawaii%';

-- casting dates and time
SELECT NOW()::DATE, CAST(NOW() AS DATE), CAST(NOW() AS TIME);

-- date interval arithmetic
SELECT NOW(), NOW() - INTERVAL '2 days', (NOW() - INTERVAL '2 days')::DATE;

-- using date_trunc()
SELECT id, content, created_at FROM comment
    WHERE created_at >= DATE_TRUNC('day', NOW())
      AND created_at < DATE_TRUNC('day', NOW() + INTERVAL '1 day');

-- CAVE! Performance Issue: Full Table Scan
SELECT id, content, created_at FROM comment
    WHERE created_at::DATE = NOW()::DATE;

-- fast:
SELECT id, content, created_at FROM comment
    WHERE created_at >= DATE_TRUNC('day', NOW())
      AND created_at < DATE_TRUNC('day', NOW() + INTERVAL '1 day');


--------------
-- DISTINCT --
--------------
-- distinct on single column
SELECT DISTINCT model FROM racing;
-- tolerate duplicate makers, but be distinct on model column
SELECT DISTINCT ON (model) make, model FROM racing;

--------------
-- GROUP BY --
--------------
SELECT COUNT(abbrev), abbrev
FROM pg_timezone_names
GROUP BY abbrev;

-- where clause for aggregate functions is HAVING
SELECT COUNT(abbrev) AS ct , abbrev
FROM pg_timezone_names
WHERE is_dst = 'f' -- daylight saving time = false
GROUP BY abbrev
HAVING COUNT(abbrev) > 10
ORDER BY ct DESC;

SELECT COUNT(abbrev) AS ct , abbrev
FROM pg_timezone_names
WHERE is_dst = 't' -- daylight saving time = true
GROUP BY abbrev
HAVING COUNT(abbrev) > 3
ORDER BY ct DESC;


-------------------
-- DISTINCT DEMO --
-------------------
-- every maker only once
SELECT DISTINCT make FROM racing;

-- distict combinantions of maker & model
SELECT DISTINCT make, model FROM racing;

-- if only the most recent model should show up...
SELECT make, model, year FROM racing ORDER BY model, year DESC;
-- use DISTINCT ON (model)
SELECT DISTINCT ON (model) make, model, year FROM racing ORDER BY model, year DESC;


-------------------
-- GROUP BY DEMO --
-------------------
SELECT *
  FROM pg_timezone_names
 LIMIT 20;

SELECT COUNT(*)
  FROM pg_timezone_names;

SELECT DISTINCT is_dst
  FROM pg_timezone_names;

SELECT COUNT(is_dst), is_dst
  FROM pg_timezone_names
 GROUP BY is_dst;

SELECT COUNT(abbrev), abbrev
  FROM pg_timezone_names
 GROUP BY abbrev;

-- WHERE is before GROUP BY, while HAVING is after GROUP BY
SELECT COUNT(abbrev) AS ct, abbrev
  FROM pg_timezone_names
 WHERE is_dst = 't'
 GROUP BY abbrev
HAVING COUNT(abbrev) > 10;

-- count timeszones with same abbrevation but without daylight-saving-time
-- having count greater than ten
SELECT COUNT(abbrev) AS ct, abbrev
  FROM pg_timezone_names
 WHERE is_dst = 'f'
 GROUP BY abbrev
HAVING COUNT(abbrev) > 10;

SELECT COUNT(abbrev) AS ct, abbrev
  FROM pg_timezone_names
 WHERE is_dst = 'f'
 GROUP BY abbrev
HAVING COUNT(abbrev) > 10
 ORDER BY ct DESC;

-- without sub-queries it would look like that
SELECT ct, abbrev
  FROM
  (SELECT COUNT(abbrev) AS ct, abbrev
     FROM pg_timezone_names
    WHERE is_dst = 'f'
    GROUP BY abbrev) AS zap
 WHERE ct > 10
 ORDER BY ct DESC;



SELECT COUNT(abbrev) AS ct, abbrev
  FROM pg_timezone_names
  GROUP BY abbrev
HAVING COUNT(abbrev) > 10;

SELECT COUNT(abbrev) AS ct, abbrev
  FROM pg_timezone_names
  GROUP BY abbrev
HAVING COUNT(abbrev) > 10
 ORDER BY COUNT(abbrev) DESC;

-- without sub-queries it would look like that
SELECT ct, abbrev
  FROM
  (SELECT COUNT(abbrev) AS ct, abbrev
     FROM pg_timezone_names
    WHERE is_dst = 't'
    GROUP BY abbrev) AS zap
 WHERE ct > 10;

SELECT ct, abbrev
  FROM
  (SELECT COUNT(abbrev) AS ct, abbrev
     FROM pg_timezone_names
    WHERE is_dst = 'f'
    GROUP BY abbrev) AS zap
 WHERE ct > 10;



-----------------
-- SUB QUERIES --
-----------------

SELECT *
  FROM account
 WHERE email = 'ed@umich.edu';

SELECT content
  FROM comment
 WHERE account_id = 1;

-- using sub-queries, you tell the DB what to do
SELECT content
  FROM comment
 WHERE account_id = (SELECT id FROM account WHERE email = 'ed@umich.edu');

-- while here the DB can optimize the query on its own
SELECT content
  FROM comment
  JOIN account ON comment.account_id = account.id
 WHERE account.email = 'ed@umich.edu';

-- HAVING is sort of sub-query that allows DB to optimize
SELECT COUNT(abbrev) AS ct, abbrev
  FROM pg_timezone_names
 WHERE is_dst = 'f'
 GROUP BY abbrev
HAVING COUNT(abbrev) > 10
 ORDER BY ct DESC;

-- without sub-queries it would look like that
SELECT ct, abbrev
  FROM
  (SELECT COUNT(abbrev) AS ct, abbrev
     FROM pg_timezone_names
    WHERE is_dst = 'f'
    GROUP BY abbrev) AS zap
 WHERE ct > 10
 ORDER BY ct DESC;



-----------------
-- CONCURRENCY --
-----------------
\c discuss

-- doing this twice will return an ERROR
-- since there is a UNIQUE constraint on (post_id, account_id)
INSERT INTO fav (post_id, account_id, howmuch)
  VALUES (1,1,1)
RETURNING *;

-- update works
UPDATE fav SET howmuch=howmuch+1
  WHERE post_id = 1 AND account_id = 1
RETURNING *;

-- Solution: ON CONFLICT
--   - first try an INSERT
--   - ON CONFLICT (uniqueness) go on with an UPDATE
INSERT INTO fav (post_id, account_id, howmuch)
  VALUES (1,1,1)
  ON CONFLICT (post_id, account_id) 
  DO UPDATE SET howmuch = fav.howmuch + 1
RETURNING *;



------------------
-- TRANSACTIONS --
------------------

-- start with BEGIN
BEGIN;
SELECT howmuch FROM fav WHERE account_id = 1 AND post_id = 1 FOR UPDATE OF fav;
-- time passes... 
UPDATE fav SET howmuch = 999 WHERE account_id = 1 AND post_id = 1;
SELECT howmuch FROM fav WHERE account_id = 1 AND post_id = 1;
ROLLBACK;
-- end with either ROLLBACK or COMMIT

SELECT howmuch FROM fav WHERE account_id = 1 AND post_id = 1;

BEGIN;
SELECT howmuch FROM fav WHERE account_id = 1 AND post_id = 1 FOR UPDATE OF fav;
-- time passes... 
UPDATE fav SET howmuch = 999 WHERE account_id = 1 AND post_id = 1;
SELECT howmuch FROM fav WHERE account_id = 1 AND post_id = 1;
COMMIT;

SELECT howmuch FROM fav WHERE account_id = 1 AND post_id = 1;



-----------------------
-- STORED PROCEDURES --
-----------------------

-- reusable code running inside of DB server
-- use 'plpgsql', but there are other languages...
-- unsually not portable between RDBMSs
-- goal: fewer SQL statements, fewer round-trips (client/server)
-- good reasons for stored procedures:
--    - major performance problem
--    - harder to test / modify
--    - no DB portability
--    - some rule that must be enforced


-- Problem to solve:
--    fav.updated_at should be updated (not only on INSERT)
CREATE TABLE fav (
  id SERIAL,
  oops TEXT,  -- Will remove later with ALTER
  post_id INTEGER REFERENCES post(id) ON DELETE CASCADE,
  account_id INTEGER REFERENCES account(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(post_id, account_id),
  PRIMARY KEY(id)
);

-- can also be solved using SQL:
-- UPDATE statement has to be modified from:
UPDATE fav SET howmuch = howmuch + 1
  WHERE post_id = 1 AND account_id = 1
RETURNING *;
-- to:
UPDATE fav SET howmuch = howmuch + 1, updated_at = NOW()
  WHERE post_id = 1 AND account_id = 1
RETURNING *;


-- STORED PROCEDURE solution looks like this:


-- create a function / stored procedure
CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- then use the function / stored procedure triggered by certain events:
-- update on post
CREATE TRIGGER set_timestamp
BEFORE UPDATE ON post
FOR EACH ROW
EXECUTE PROCEDURE trigger_set_timestamp();

-- update on fav
CREATE TRIGGER set_timestamp
BEFORE UPDATE ON fav
FOR EACH ROW
EXECUTE PROCEDURE trigger_set_timestamp();

-- update on comment
CREATE TRIGGER set_timestamp
BEFORE UPDATE ON comment
FOR EACH ROW
EXECUTE PROCEDURE trigger_set_timestamp();

------------------------
-- Assignment 1 Start --
------------------------
-- Host:     pg.pg4e.com 
-- Port:     5432 
-- Database: pg4e_7b5789290e 
-- User:     pg4e_7b5789290e 
-- Password:  (hide/show copy) 
-----------------------------------------------------------------
-- connect string:
-- psql -h pg.pg4e.com -p 5432 -U pg4e_7b5789290e pg4e_7b5789290e
-----------------------------------------------------------------
-- 1. create table pg4e_debug:
CREATE TABLE pg4e_debug (
  id SERIAL,
  query VARCHAR(4096),
  result VARCHAR(4096),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(id)
);

SELECT query, result, created_at FROM pg4e_debug;

-- 2. create table pg4e_result:
CREATE TABLE pg4e_result (
  id SERIAL,
  link_id INTEGER UNIQUE,
  score FLOAT,
  title VARCHAR(4096),
  note VARCHAR(4096),
  debug_log VARCHAR(8192),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP
);

-- 3. alter table pg4e_debug add column 'neon217' as e.g. as INTEGER
ALTER TABLE pg4e_debug ADD COLUMN neon217 INTEGER;
-- auto-grader will run:
SELECT neon217 FROM pg4e_debug LIMIT 1;

-- 4. Find distinct values in the state column of the taxdata table in ascending order.
--    Your query should only return these five rows (i.e. inclide a LIMIT clause).
SELECT DISTINCT state FROM taxdata ORDER BY state LIMIT 5;

-- 5. Create a table, and add a stored procedure to it.
CREATE TABLE keyvalue ( 
  id SERIAL,
  key VARCHAR(128) UNIQUE,
  value VARCHAR(128) UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY(id)
);

-- Add a stored procedure so that every time a record is updated, the updated_at
-- variable is automatically set to the current time.
CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- then use the function / stored procedure triggered by certain events:
-- update on keyvalue
CREATE TRIGGER set_timestamp
BEFORE UPDATE ON keyvalue
FOR EACH ROW
EXECUTE PROCEDURE trigger_set_timestamp();

-- insert
INSERT INTO keyvalue (key, value) VALUES ('a', 'auto'), ('b', 'beta'), ('g', 'gamma');
-- check
UPDATE keyvalue SET key = 'a', value = 'alpha'
  WHERE key = 'a'
RETURNING *;

----------------------
-- Assignment 1 End --
----------------------





--- Load a CSV file and automatically normalize into one-to-many

-- Download 
-- wget https://www.pg4e.com/lectures/03-Techniques.csv

-- x,y
-- Zap,A
-- Zip,A
-- One,B
-- Two,B

DROP TABLE IF EXISTS xy_raw;
DROP TABLE IF EXISTS y;
DROP TABLE IF EXISTS xy;

CREATE TABLE xy_raw(x TEXT, y TEXT, y_id INTEGER);
CREATE TABLE y (id SERIAL, PRIMARY KEY(id), y TEXT);
CREATE TABLE xy(id SERIAL, PRIMARY KEY(id), x TEXT, y_id INTEGER, UNIQUE(x,y_id));

\d xy_raw
\d+ y

\copy xy_raw(x,y) FROM '03-Techniques.csv' WITH DELIMITER ',' CSV;

SELECT DISTINCT y from xy_raw;

INSERT INTO y (y) SELECT DISTINCT y FROM xy_raw;

UPDATE xy_raw SET y_id = (SELECT y.id FROM y WHERE y.y = xy_raw.y);

SELECT * FROM xy_raw;

INSERT INTO xy (x, y_id) SELECT x, y_id FROM xy_raw;

SELECT * FROM xy JOIN y ON xy.y_id = y.id;

ALTER TABLE xy_raw DROP COLUMN y;

DROP TABLE xy_raw;


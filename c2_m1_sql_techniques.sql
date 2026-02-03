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

-- https://www.pg4e.com/lectures/03-Techniques-Load.sql

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

-- WHERE is before GROUP BY, HAVING is after GROUP BY
SELECT COUNT(abbrev) AS ct, abbrev
  FROM pg_timezone_names
 WHERE is_dst = 't'
 GROUP BY abbrev
HAVING COUNT(abbrev) > 10;

SELECT COUNT(abbrev) AS ct, abbrev
  FROM pg_timezone_names
  GROUP BY abbrev
HAVING COUNT(abbrev) > 10;

SELECT COUNT(abbrev) AS ct, abbrev
  FROM pg_timezone_names
  GROUP BY abbrev
HAVING COUNT(abbrev) > 10
 ORDER BY COUNT(abbrev) DESC;

SELECT ct, abbrev
  FROM
  (SELECT COUNT(abbrev) AS ct, abbrev
     FROM pg_timezone_names
    WHERE is_dst = 't'
    GROUP BY abbrev) AS zap
 WHERE ct > 10;

-----------------
-- SUB QUERIES --
-----------------


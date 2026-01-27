------------------
-- CREATE TABLE--
------------------
CREATE TABLE users (
    name VARCHAR(128),
    email VARCHAR(128)
);

-- display table users
-- people=> \d+ users


------------
-- INSERT --
------------
INSERT INTO users (name, email) VALUES ('Chuck', 'csev@umich.edu');
INSERT INTO users (name, email) VALUES ('Somesh', 'somesh@umich.edu');
INSERT INTO users (name, email) VALUES ('Caitlin', 'cait@umich.edu');
INSERT INTO users (name, email) VALUES ('Ted', 'ted@umich.edu');
INSERT INTO users (name, email) VALUES ('Sally', 'sally@umich.edu');


------------
-- DELETE --
------------
DELETE FROM users WHERE email = 'ted@umich.edu';

-- !!! CAVE: delete ALL records !!!
DELETE FROM users;


------------
-- UPDATE --
------------
UPDATE users SET name = 'Charles' WHERE email = 'csev@umich.edu';

-- !!! CAVE: update ALL rows !!!
UPDATE users SET name = 'Charles';


------------
-- SELECT --
------------
SELECT * FROM users;

SELECT * FROM users WHERE email = 'csev@umich.edu';


--------------
-- ORDER BY --
--------------
SELECT * FROM users ORDER BY email;

-- descendent
SELECT * FROM users ORDER BY email DESC;


----------
-- LIKE --
----------
-- !!! CAVE: embedded in wildcards % - forces full table scan !!!
SELECT * FROM users WHERE name LIKE '%e%';


-----------
-- LIMIT --
-----------
-- limit to the first 2 records
SELECT * FROM users ORDER BY email LIMIT 2;

-- skip the 1st record, then limit to only 2 records
SELECT * FROM users ORDER BY email OFFSET 1 LIMIT 2;
-- offset starts at row 0, so OFFSET 1 is the 2nd row


-----------
-- COUNT --
-----------
SELECT COUNT(*) FROM users;

-- be more specific
SELECT COUNT(*) FROM users WHERE email = 'csev@umich.edu';



------------------
-- CREATE TABLE --
------------------
CREATE TABLE penguins(
    id SERIAL PRIMARY KEY,
    species VARCHAR (30),
    island VARCHAR (30),
    bill_length_mm NUMERIC,
    bill_depth_mm NUMERIC,
    flipper_length_mm INTEGER,
    body_mass_g INTEGER,
    sex VARCHAR (6),
    year INTEGER);

-----------------
-- IMPORT DATA --
-----------------
COPY penguins(
species,
island,
bill_length_mm,
bill_depth_mm,
flipper_length_mm,
body_mass_g,
sex,
year
)
FROM '/tmp/penguins.csv'
WITH (
FORMAT csv,
NULL 'NA',
-- DELIMITER ',',
--CSV HEADER,
HEADER
);


----------------
-- DATA TYPES --
----------------

-- Strings (have character sets):
--   VARCHAR(n) - variable length
--   CHAR(n) - fixed space (e.g. sha256sum, ISBN-10)
--   TEXT - varying length, not used with indexing or sorting
-- Binary types:
--   BYTEA(n) - up to 255 bytes, small images, not indexed or sorted
-- Integer
--   SMALLINT (-32'768, +32'768)
--   INTEGER (2 billion)
--   BIGINT (10**18)
-- Floating Point
--   REAL(32-bit)
--   DOUBLE PRECISION (64-bit)
--   NUMERIC(accuracy, decimal) with specified accuracy and digits after the decimal point
-- Dates
--   TIMESTAMP, YYYY-MM-DD HH:MM:SS
--   DATE, YYYY-MM-DD
--   TIME, HH:MM:SS
--   NOW(), built-in PostgreSQL function
-- AUTO_INCREMENT fields
--   SERIAL


-------------
-- INDEXES --
-------------
-- B-Trees
--   balanced; levels os smaller fractions of the whole data
-- Hashes
--   
-- re-create table with index and logical key UNIQUE
DROP TABLE users;

CREATE TABLE users (
    name VARCHAR(128),
    email VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

-- re-enter data
INSERT INTO users (name, email) VALUES ('Chuck', 'csev@umich.edu');
INSERT INTO users (name, email) VALUES ('Somesh', 'somesh@umich.edu');
INSERT INTO users (name, email) VALUES ('Caitlin', 'cait@umich.edu');
INSERT INTO users (name, email) VALUES ('Ted', 'ted@umich.edu');
INSERT INTO users (name, email) VALUES ('Sally', 'sally@umich.edu');

----------------------
-- Assignment 1 Start --
----------------------
CREATE TABLE automagic (
    id SERIAL,
    name VARCHAR(32) NOT NULL,
    height REAL NOT NULL
);

--------------------
-- Assignment 1 End --
--------------------


----------------------
-- Assignment 2 Start --
----------------------
-- download csv file
wget https://www.pg4e.com/tools/sql/library.csv
curl -O https://www.pg4e.com/tools/sql/library.csv

-- connect to remote DB
psql -h pg.pg4e.com -p 5432 -U pg4e_42afb3a20d pg4e_42afb3a20d

-- create table
CREATE TABLE track_raw
 (title TEXT, artist TEXT, album TEXT,
  count INTEGER, rating INTEGER, len INTEGER);

-- load data (psql command)
\copy track_raw(title,artist,album,count,rating,len) FROM 'library.csv' WITH DELIMITER ',' CSV;

-- check results
SELECT title, album FROM track_raw ORDER BY title LIMIT 3;
SELECT COUNT(*) FROM track_raw;
--------------------
-- Assignment 2 End --
--------------------
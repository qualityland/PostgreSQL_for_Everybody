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



----------------
-- DATA TYPES --
----------------

-- Strings (have character sets):
--   VARCHAR(n) - variable
--   CHAR(n) - fixed space (e.g. sha256sum, ISBN-10)
--   TEXT - varying length, not used with indexing or sorting
-- Binary types:
--   BYTEA(n) - up to 255 bytes
-- Numeric fields
-- AUTO_INCREMENT fields
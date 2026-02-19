-------------------------
-- Regular Expressions --
-------------------------

-- text based programming language
-- clever wildcard strings for matching and parsing strings
-- widely available
--   Unix commands like grep
--   virtually every programming language
--   subtle differences acros implementations
-- PostgreSQL uses the POSIX variant


-- Quick Guide
--------------
-- ^        beginning of line
-- $        end of line
-- .        any character
-- *        repeats a character zero or more times
-- *?       repeats a character zero or more times (non-greedy)
-- +        repeats a character one or more times
-- +?       repeats a character one or more times (non-greedy)
-- [aeiou]  single character in the listed set
-- [^XYZ]   single character NOT in the listed set
-- [a-z0-9] the set of characters can include a range
-- (        indicates where string extraction is to start
-- )        indicates where string extraction is to end


-- PostgreSQL WHERE Clause Operators
------------------------------------
-- ~    matches
-- ~*   matches (case insensitive)
-- !~   does NOT match
-- !~*  does NOT match (case insensitive)
-- different than LIKE it matches anywhere
--      tweet ~ 'UMSI'
--      tweet LIKE '%UMSI%'


-- create table
CREATE TABLE em (
    id SERIAL,
    PRIMARY KEY(id),
    email TEXT
);

-- insert data
INSERT INTO em (email) VALUES ('csev@umich.edu');
INSERT INTO em (email) VALUES ('coleen@umich.edu');
INSERT INTO em (email) VALUES ('sally@uiuc.edu');
INSERT INTO em (email) VALUES ('ted79@umuc.edu');
INSERT INTO em (email) VALUES ('glenn1@apple.com');
INSERT INTO em (email) VALUES ('nbody@apple.com');

-- contains umich
SELECT email FROM em WHERE email ~ 'umich';
-- starts with c
SELECT email FROM em WHERE email ~ '^c';
-- starts with g, n or t
SELECT email FROM em WHERE email ~ '^[gnt]';
-- has one digit
SELECT email FROM em WHERE email ~ '[0-9]';
-- has two digits
SELECT email FROM em WHERE email ~ '[0-9][0-9]';



-------------------------------
-- Using Regular Expressions --
-------------------------------

-- which numbers are hidden in email addresses
SELECT substring(email FROM '[0-9]+') AS numbers FROM em WHERE email ~ '[0-9]+';

-- extract domains from email addresses
SELECT substring(email FROM '.+@(.+)$') AS domain FROM em;

-- extract distinct domains from email addresses
SELECT DISTINCT substring(email FROM '.+@(.+)$') AS domain FROM em;

-- count occurence of email domains
SELECT
    substring(email FROM '.+@(.+)$') AS domain,
    count(substring(email FROM '.+@(.+)$'))
  FROM em
 GROUP BY domain;



-- create table
CREATE TABLE tw (
    id SERIAL,
    PRIMARY KEY(id),
    tweet TEXT
);

-- insert data
INSERT INTO tw (tweet) VALUES ('This is #SQL and #FUN stuff');
INSERT INTO tw (tweet) VALUES ('More people should learn #SQL from #UMSI');
INSERT INTO tw (tweet) VALUES ('#UMSI also teaches #PYTHON');

-- simple match
SELECT id, tweet FROM tw WHERE tweet ~ '#SQL';

-- extract all hash tags (also multiple in same tweet)
SELECT regexp_matches(tweet, '#([A-Za-z0-9_]+)', 'g') FROM tw;

-- extract distinct hash tags (also multiple in same tweet)
SELECT DISTINCT regexp_matches(tweet, '#([A-Za-z0-9_]+)', 'g') FROM tw;

-- which ID used which hash tag
SELECT id, regexp_matches(tweet, '#([A-Za-z0-9_]+)', 'g') FROM tw;




---------------
-- MBOX DEMO --
---------------
-- https://www.pg4e.com/lectures/mbox-short.txt

-- create table
CREATE TABLE mbox (line TEXT);

-- read in file
\copy mbox FROM './data/mbox-short.txt' WITH DELIMITER E'\007';

-- get the lines with email addresses
SELECT line FROM mbox WHERE line ~ '^From ';

-- get the email addresses
SELECT substring(line, ' (.+@[^ ]+) ') FROM mbox WHERE line ~ '^From ';

-- count messages by email address
SELECT substring(line, ' (.+@[^ ]+) ') AS email,
       count(substring(line, ' (.+@[^ ]+) '))
  FROM mbox
 WHERE line ~ '^From '
 GROUP BY email
 ORDER BY count(substring(line, ' (.+@[^ ]+) ')) DESC;

-- bad subselect
 SELECT email, count(email) FROM
 (SELECT substring(line, ' (.+@[^ ]+) ') AS email
    FROM mbox
   WHERE line ~ '^From '
) AS badsub
GROUP BY email
ORDER BY count(email) DESC;


----------------
-- REGEX DEMO --
----------------

-- create table
CREATE TABLE em (
    id SERIAL,
    PRIMARY KEY(id),
    email TEXT
);

-- insert data
INSERT INTO em (email) VALUES ('csev@umich.edu');
INSERT INTO em (email) VALUES ('coleen@umich.edu');
INSERT INTO em (email) VALUES ('sally@uiuc.edu');
INSERT INTO em (email) VALUES ('ted79@umuc.edu');
INSERT INTO em (email) VALUES ('glenn1@apple.com');
INSERT INTO em (email) VALUES ('nbody@apple.com');

-- simple pattern matching in where clause
SELECT email FROM em WHERE email ~ 'umich';
SELECT email FROM em WHERE email ~ '^c';
SELECT email FROM em WHERE email ~ 'edu$';
SELECT email FROM em WHERE email ~ '^[gnt]';
SELECT email FROM em WHERE email ~ '[0-9]';
SELECT email FROM em WHERE email ~ '[0-9][0-9]';
SELECT email FROM em WHERE email ~ '[0-9]+';
SELECT email FROM em WHERE email ~ '[0-9]{2,}';

-- extract numbers
SELECT substring(email FROM '[0-9]+') FROM em WHERE email ~ '[0-9]';

-- use parentheses to extract parts of the pattern
SELECT substring(email FROM '.+@(.+)$') FROM em;

-- remove duplicate domains
SELECT DISTINCT substring(email FROM '.+@(.+)$') FROM em;

-- count domain occurances
SELECT substring(email FROM '.+@(.+)$') AS domain,
       count(substring(email FROM '.+@(.+)$'))
  FROM em
 GROUP BY domain
 ORDER BY count(substring(email FROM '.+@(.+)$')) DESC;

-- substring in where clause
SELECT * FROM em WHERE substring(email FROM '.+@(.+)$') = 'umich.edu';

-- 
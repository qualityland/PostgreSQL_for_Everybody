-- Coursera Specialization: PostgreSQL for Everybody
-- Course 1: Database Design and Basic SQL in PostgreSQL
-- by: Dr. Charles Severance (Dr. Chuck)

-------------------------
-- Connect to Database --
-------------------------
-- as Super User (on shell)
-- $ psql -U postgres


-- show available Databases
-- # \l


-----------------
-- CREATE USER --
-----------------
CREATE USER pg4e WITH PASSWORD 'secret';


---------------------
-- CREATE DATABASE --
---------------------
CREATE DATABASE people WITH OWNER 'pg4e';


-- show databases
--# \l


-- exit PostgreSQL psql
-- # \q


---------------------------------------
-- Connect to DB people as User pg4e --
---------------------------------------
-- $ psql people pg4e

-- display tables
-- people=> \dt

-- exit
-- people=> \q



------------------
-- CREATE TABLE --
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

-- delete all records from a table
DELETE FROM users;


----------------------
-- Assignment Start --
----------------------
-- Host:     pg.pg4e.com 
-- Port:     5432 
-- Database: pg4e_42afb3a20d 
-- User:     pg4e_42afb3a20d 

-- connect string:
-- $ psql -h pg.pg4e.com -p 5432 -U pg4e_42afb3a20d pg4e_42afb3a20d

CREATE TABLE pg4e_debug (
  id SERIAL,
  query VARCHAR(4096),
  result VARCHAR(4096),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(id)
);

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

--------------------
-- Assignment End --
--------------------



------------------
-- CREATE TABLE --
------------------
CREATE TABLE ages ( 
  name VARCHAR(128), 
  age INTEGER
);


------------
-- INSERT --
------------
DELETE FROM ages;
INSERT INTO ages (name, age) VALUES ('Amnah', 22);
INSERT INTO ages (name, age) VALUES ('Deon', 19);
INSERT INTO ages (name, age) VALUES ('Fiza', 15);
INSERT INTO ages (name, age) VALUES ('Izabella', 25);
INSERT INTO ages (name, age) VALUES ('Jema', 34);

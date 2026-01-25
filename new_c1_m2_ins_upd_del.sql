--------------------
-- Create a Table --
--------------------
CREATE TABLE users (
    name VARCHAR(128),
    email VARCHAR(128)
);

-- display table users
-- people=> \d+ users

--------------------------------
-- Insert Values into a Table --
--------------------------------
INSERT INTO users (name, email) VALUES ('Chuck', 'csev@umich.edu');
INSERT INTO users (name, email) VALUES ('Somesh', 'somesh@umich.edu');
INSERT INTO users (name, email) VALUES ('Caitlin', 'cait@umich.edu');
INSERT INTO users (name, email) VALUES ('Ted', 'ted@umich.edu');
INSERT INTO users (name, email) VALUES ('Sally', 'sally@umich.edu');


---------------------------------
-- Delete Records from a Table --
---------------------------------
DELETE FROM users WHERE email = 'ted@umich.edu';

-- delete ALL records from a table
DELETE FROM users;


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




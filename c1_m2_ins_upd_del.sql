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



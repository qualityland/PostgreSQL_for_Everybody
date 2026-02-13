-------------------
-- PARSING FILES --
-------------------

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

-- raw data table
CREATE TABLE xy_raw(
  x TEXT,
  y TEXT,
  y_id INTEGER
);

-- y table
CREATE TABLE y (
  id SERIAL,
  y TEXT,
  PRIMARY KEY(id)
);

-- xy table (x records, referencing y)
CREATE TABLE xy (
  id SERIAL,
  x TEXT,
  y_id INTEGER REFERENCES y(id) ON DELETE CASCADE,
  PRIMARY KEY(id),
  UNIQUE(x,y_id)
);

-- show tables
\d xy_raw
\d+ y
\d xy

-- parse the file and load into table xy_raw
\copy xy_raw(x, y) FROM 'xy_raw.csv' WITH DELIMITER ',' CSV;


-------------------
-- NORMALIZATION --
-------------------
-- show y values
SELECT DISTINCT y from xy_raw;

-- insert y values into y table
INSERT INTO y (y) SELECT DISTINCT y FROM xy_raw;

-- insert y.id into xy_raw table
UPDATE xy_raw SET y_id = (SELECT y.id FROM y WHERE y.y = xy_raw.y);

-- show xy_raw (with y IDs)
SELECT * FROM xy_raw;

-- insert x and references to y into xy
INSERT INTO xy (x, y_id) SELECT x, y_id FROM xy_raw;

-- show joined tables
SELECT * FROM xy JOIN y ON xy.y_id = y.id;

-- show joined tables in same format as raw csv file
SELECT xy.id AS id,
       x,
       y
  FROM xy
  JOIN y ON xy.y_id = y.id;

-- ???
ALTER TABLE xy_raw DROP COLUMN y;

-- xy_raw table no longer needed
DROP TABLE xy_raw;


---------------------
-- RUNNING SCRIPTS --
---------------------

-- empty xy_raw table
DELETE FROM xy_raw;

-- load raw data
\copy xy_raw(x, y) FROM 'xy_raw.csv' WITH DELIMITER ',' CSV;

-- run script
\i c2_m2_script.sql



------------------------
-- Assignment 1 Start --
------------------------
-- create tables
CREATE TABLE album (
  id SERIAL,
  title VARCHAR(128) UNIQUE,
  PRIMARY KEY(id)
);

CREATE TABLE track (
    id SERIAL,
    title VARCHAR(128),
    len INTEGER, rating INTEGER, count INTEGER,
    album_id INTEGER REFERENCES album(id) ON DELETE CASCADE,
    UNIQUE(title, album_id),
    PRIMARY KEY(id)
);

DROP TABLE IF EXISTS track_raw;

CREATE TABLE track_raw
 (title TEXT, artist TEXT, album TEXT, album_id INTEGER,
  count INTEGER, rating INTEGER, len INTEGER);

-- load data into track_raw
\copy track_raw(title, artist, album, count, rating, len) FROM 'track_raw.csv' WITH DELIMITER ',' CSV;

-- insert album.title into album table
INSERT INTO album (title) SELECT DISTINCT album FROM track_raw;

-- update track_raw and insert album.id into track_raw.album_id
UPDATE track_raw SET album_id = (SELECT album.id FROM album WHERE album.title = track_raw.album);

-- insert intro track data from track_raw including album_id
INSERT INTO track (title, len, rating, count, album_id) SELECT title, len, rating, count, album_id FROM track_raw;

-- select with join
SELECT track.title, album.title
    FROM track
    JOIN album ON track.album_id = album.id
    ORDER BY track.title LIMIT 3;

----------------------
-- Assignment 1 End --
----------------------



------------------------
-- Assignment 2 Start --
------------------------
-- create tables
DROP TABLE unesco_raw;

CREATE TABLE unesco_raw (
  name TEXT,
  description TEXT,
  justification TEXT,
  year INTEGER,
  longitude FLOAT,
  latitude FLOAT,
  area_hectares FLOAT,
  category TEXT,
  category_id INTEGER,
  state TEXT,
  state_id INTEGER,
  region TEXT,
  region_id INTEGER,
  iso TEXT,
  iso_id INTEGER
);

CREATE TABLE category (
  id SERIAL,
  name VARCHAR(128) UNIQUE,
  PRIMARY KEY(id)
);
-- more tables needed...

-- state
CREATE TABLE state (
  id SERIAL,
  name VARCHAR(128) UNIQUE,
  PRIMARY KEY(id)
);
-- region
CREATE TABLE region (
  id SERIAL,
  name VARCHAR(128) UNIQUE,
  PRIMARY KEY(id)
);
-- iso
CREATE TABLE iso (
  id SERIAL,
  name VARCHAR(128) UNIQUE,
  PRIMARY KEY(id)
);

-- load data
\copy unesco_raw(name,description,justification,year,longitude,latitude,area_hectares,category,state,region,iso) FROM 'whc-sites-2018-small.csv' WITH DELIMITER ',' CSV HEADER;

-- 
-- populate lookup tables
INSERT INTO category (name) SELECT DISTINCT category FROM unesco_raw;
INSERT INTO state (name) SELECT DISTINCT state FROM unesco_raw;
INSERT INTO region (name) SELECT DISTINCT region FROM unesco_raw;
INSERT INTO iso (name) SELECT DISTINCT iso FROM unesco_raw;

-- link IDs to lookup tables
UPDATE unesco_raw SET category_id = (SELECT category.id FROM category WHERE category.name = unesco_raw.category);
UPDATE unesco_raw SET state_id = (SELECT state.id FROM state WHERE state.name = unesco_raw.state);
UPDATE unesco_raw SET region_id = (SELECT region.id FROM region WHERE region.name = unesco_raw.region);
UPDATE unesco_raw SET iso_id = (SELECT iso.id FROM iso WHERE iso.name = unesco_raw.iso);

-- create unesco table
CREATE TABLE unesco (
  id SERIAL,
  name TEXT,
  description TEXT,
  justification TEXT,
  year INTEGER,
  longitude FLOAT,
  latitude FLOAT,
  area_hectares FLOAT,
  category_id INTEGER REFERENCES category(id) ON DELETE CASCADE,
  state_id INTEGER REFERENCES state(id) ON DELETE CASCADE,
  region_id INTEGER REFERENCES region(id) ON DELETE CASCADE,
  iso_id INTEGER REFERENCES iso(id) ON DELETE CASCADE
);

-- populate unesco table from unesco_raw
INSERT INTO unesco (
  name,
  description,
  justification,
  year,
  longitude,
  latitude,
  area_hectares,
  category_id,
  state_id,
  region_id,
  iso_id
  ) SELECT name, description, justification, year, longitude, latitude, area_hectares, category_id, state_id, region_id, iso_id FROM unesco_raw;

-- check
SELECT unesco.name, year, category.name, state.name, region.name, iso.name
  FROM unesco
  JOIN category ON unesco.category_id = category.id
  JOIN iso ON unesco.iso_id = iso.id
  JOIN state ON unesco.state_id = state.id
  JOIN region ON unesco.region_id = region.id
  ORDER BY state.name, unesco.name
  LIMIT 3;


----------------------
-- Assignment 2 End --
----------------------






------------------------
-- Assignment 3 Start --
------------------------
-- check
SELECT track.title, album.title, artist.name
FROM track
JOIN album ON track.album_id = album.id
JOIN tracktoartist ON track.id = tracktoartist.track_id
JOIN artist ON tracktoartist.artist_id = artist.id
ORDER BY track.title
LIMIT 3;

-- script
DROP TABLE album CASCADE;
CREATE TABLE album (
    id SERIAL,
    title VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

DROP TABLE track CASCADE;
CREATE TABLE track (
    id SERIAL,
    title TEXT, 
    artist TEXT, 
    album TEXT, 
    album_id INTEGER REFERENCES album(id) ON DELETE CASCADE,
    count INTEGER, 
    rating INTEGER, 
    len INTEGER,
    PRIMARY KEY(id)
);

DROP TABLE artist CASCADE;
CREATE TABLE artist (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

DROP TABLE tracktoartist CASCADE;
CREATE TABLE tracktoartist (
    id SERIAL,
    track VARCHAR(128),
    track_id INTEGER REFERENCES track(id) ON DELETE CASCADE,
    artist VARCHAR(128),
    artist_id INTEGER REFERENCES artist(id) ON DELETE CASCADE,
    PRIMARY KEY(id)
);

\copy track(title,artist,album,count,rating,len) FROM 'library.csv' WITH DELIMITER ',' CSV;

INSERT INTO album (title) SELECT DISTINCT album FROM track;
UPDATE track SET album_id = (SELECT album.id FROM album WHERE album.title = track.album);

INSERT INTO tracktoartist (track, artist) SELECT DISTINCT title, artist from track;

INSERT INTO artist (name) SELECT DISTINCT artist FROM track;

UPDATE tracktoartist SET track_id = (SELECT track.id FROM track WHERE track.title = tracktoartist.track);
UPDATE tracktoartist SET artist_id = (SELECT artist.id FROM artist WHERE artist.name = tracktoartist.artist);

-- We are now done with these text fields
ALTER TABLE track DROP COLUMN album;
ALTER TABLE track DROP COLUMN artist;
ALTER TABLE tracktoartist DROP COLUMN track;
ALTER TABLE tracktoartist DROP COLUMN artist;

SELECT track.title, album.title, artist.name
FROM track
JOIN album ON track.album_id = album.id
JOIN tracktoartist ON track.id = tracktoartist.track_id
JOIN artist ON tracktoartist.artist_id = artist.id
LIMIT 3;

----------------------
-- Assignment 3 End --
----------------------

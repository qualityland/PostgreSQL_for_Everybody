-- connect to postgres DB as user postgres
sudo  -u postgres psql postgres
-- crete DB
CREATE DATABASE music WITH OWNER 'pg4e' ENCODING 'UTF8';

-- connect to music DB as user pg4e
psql -U pg4e music

-- create tables
CREATE TABLE artist (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    PRIMARY KEY (id)
);

CREATE TABLE album (
    id SERIAL,
    title VARCHAR(128) UNIQUE,
    artist_id INTEGER REFERENCES artist(id) ON DELETE CASCADE,
    PRIMARY KEY (id)
);

CREATE TABLE genre (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

CREATE TABLE track (
    id SERIAL,
    title VARCHAR(128),
    len INTEGER,
    rating INTEGER,
    count INTEGER,
    album_id INTEGER REFERENCES album(id) ON DELETE CASCADE,
    genre_id INTEGER REFERENCES genre(id) ON DELETE CASCADE,
    UNIQUE(title, album_id),
    PRIMARY KEY(id)
);

-- insert artists
INSERT INTO artist (name) VALUES ('Led Zeppelin');
INSERT INTO artist (name) VALUES ('AC/DC');
-- check
SELECT * FROM artist;

-- insert albums
INSERT INTO album(title, artist_id) VALUES ('Who Made Who', 2);
INSERT INTO album(title, artist_id) VALUES ('IV', 1);
-- check
SELECT * FROM album;

-- insert genres
INSERT INTO genre(name) VALUES ('Rock');
INSERT INTO genre(name) VALUES ('Metal');
-- check
SELECT * FROM genre;

-- insert tracks
INSERT INTO track(title, rating, len, count, album_id, genre_id)
    VALUES ('Black Dog', 5, 297, 0, 2, 1);
INSERT INTO track(title, rating, len, count, album_id, genre_id)
    VALUES ('Stairway', 5, 482, 0, 2, 1);
INSERT INTO track(title, rating, len, count, album_id, genre_id)
    VALUES ('About to Rock', 5, 313, 0, 1, 2);
INSERT INTO track(title, rating, len, count, album_id, genre_id)
    VALUES ('Who Made Who', 5, 207, 0, 1, 2);
-- check
SELECT * FROM track;


----------------
-- INNER JOIN --
----------------

SELECT album.title AS album, artist.name AS artist
    FROM album JOIN artist
    ON album.artist_id = artist.id;

SELECT *
    FROM album JOIN artist
    ON album.artist_id = artist.id;

SELECT
    track.title AS track,
    artist.name AS artist,
    album.title AS album,
    genre.name AS genre
FROM track
    JOIN genre ON track.genre_id = genre.id
    JOIN album ON track.album_id = album.id
    JOIN artist ON album.artist_id = artist.id;


----------------
-- CROSS JOIN --
----------------
-- cartesian product
-- (joins all records from table 1 with the ones from table 2)
SELECT *
    FROM track CROSS JOIN genre;



----------------------
-- ON DELTE CASCADE --
----------------------
DELETE FROM genre WHERE name = 'Metal';



------------------------
-- Assignment 1 Start --
------------------------
CREATE TABLE make (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

CREATE TABLE model (
  id SERIAL,
  name VARCHAR(128),
  make_id INTEGER REFERENCES make(id) ON DELETE CASCADE,
  PRIMARY KEY(id)
);

-- insert makers
INSERT INTO make(name) VALUES ('Honda');
INSERT INTO make(name) VALUES ('Mazda');
-- insert models
INSERT INTO model(name, make_id) VALUES ('Pilot 2WD', 1);
INSERT INTO model(name, make_id) VALUES ('Pilot 4WD', 1);
INSERT INTO model(name, make_id) VALUES ('Pilot AWD', 1);
INSERT INTO model(name, make_id) VALUES ('B3000 (FFV) Ethanol 2WD', 2);
INSERT INTO model(name, make_id) VALUES ('B3000 2WD', 2);
-- check
SELECT make.name AS make, model.name AS model
    FROM model
    JOIN make ON model.make_id = make.id
    ORDER BY make.name LIMIT 5;
----------------------
-- Assignment 1 End --
----------------------
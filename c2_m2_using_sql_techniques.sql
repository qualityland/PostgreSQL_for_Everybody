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

CREATE TABLE xy_raw(
  x TEXT,
  y TEXT,
  y_id INTEGER
);


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


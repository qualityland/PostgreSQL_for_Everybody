-- drop tables
DROP TABLE IF EXISTS xy;
DROP TABLE IF EXISTS y;
-- create tables
CREATE TABLE y (
  id SERIAL,
  y TEXT,
  PRIMARY KEY(id)
);
CREATE TABLE xy (
  id SERIAL,
  x TEXT,
  y_id INTEGER REFERENCES y(id) ON DELETE CASCADE,
  PRIMARY KEY(id),
  UNIQUE(x,y_id)
);
-- normalization
INSERT INTO y (y) SELECT DISTINCT y FROM xy_raw;
UPDATE xy_raw SET y_id = (SELECT y.id FROM y WHERE y.y = xy_raw.y);
INSERT INTO xy (x, y_id) SELECT x, y_id FROM xy_raw;
-- show joined tables in same format as raw csv file
SELECT xy.id AS id,
       x,
       y
  FROM xy
  JOIN y ON xy.y_id = y.id;

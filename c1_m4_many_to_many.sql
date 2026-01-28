------------------------------
-- Many-to-Many Data Models --
------------------------------
-- create tables
CREATE TABLE student (
    id SERIAL,
    name VARCHAR(128),
    email VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

CREATE TABLE course (
    id SERIAL,
    title VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

CREATE TABLE member (
    student_id INTEGER REFERENCES student(id) ON DELETE CASCADE,
    course_id INTEGER REFERENCES course(id) ON DELETE CASCADE,
    role INTEGER,
    PRIMARY KEY (student_id, course_id)
);

-- insert students
INSERT INTO student (name, email) VALUES ('Jane', 'jane@tsugi.org');
INSERT INTO student (name, email) VALUES ('Ed', 'ed@tsugi.org');
INSERT INTO student (name, email) VALUES ('Sue', 'sue@tsugi.org');
SELECT * FROM student;
-- insert courses
INSERT INTO course (title) VALUES ('Python');
INSERT INTO course (title) VALUES ('SQL');
INSERT INTO course (title) VALUES ('PHP');
SELECT * FROM course;
-- insert course members
INSERT INTO member (student_id, course_id, role) VALUES (1, 1, 1);
INSERT INTO member (student_id, course_id, role) VALUES (2, 1, 0);
INSERT INTO member (student_id, course_id, role) VALUES (3, 1, 0);

INSERT INTO member (student_id, course_id, role) VALUES (1, 2, 0);
INSERT INTO member (student_id, course_id, role) VALUES (2, 2, 1);

INSERT INTO member (student_id, course_id, role) VALUES (2, 3, 1);
INSERT INTO member (student_id, course_id, role) VALUES (3, 3, 0);

-- check joined tables
SELECT student.name, member.role, course.title
FROM student
    JOIN member ON member.student_id = student.id
    JOIN course ON member.course_id = course.id
    ORDER BY course.title, member.role DESC, student.name;


-------------------------------
-- Many-to-One Relationships --
-- Musical Tracks Example    --
-------------------------------
-- artists
CREATE TABLE artist (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);
-- albums
CREATE TABLE album (
    id SERIAL,
    title VARCHAR(128) UNIQUE,
    artist_id INTEGER REFERENCES artist(id) ON DELETE CASCADE,
    PRIMARY KEY(id)
);
-- genres
CREATE TABLE genre (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);
-- tracks
CREATE TABLE track (
    id SERIAL,
    title VARCHAR(128),
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
-- insert genres
INSERT INTO genre(name) VALUES ('Rock');
INSERT INTO genre(name) VALUES ('Metal');
-- insert tracks
INSERT INTO track(title, rating, len, count, album_id, genre_id)
    VALUES ('Black Dog', 5, 297, 0, 2, 1);
INSERT INTO track(title, rating, len, count, album_id, genre_id)
    VALUES ('Stairway', 5, 482, 0, 2, 1);
INSERT INTO track(title, rating, len, count, album_id, genre_id)
    VALUES ('About to Rock', 5, 313, 0, 1, 2);
INSERT INTO track(title, rating, len, count, album_id, genre_id)
    VALUES ('Who Made Who', 5, 207, 0, 1, 2);
-- check artists and albums
SELECT album.title, artist.name
FROM album
JOIN artist ON album.artist_id = artist.id;
-- check artists and albums (incl IDs)
SELECT album.title, album.artist_id, artist.id, artist.name
FROM album
INNER JOIN artist ON album.artist_id = artist.id;
-- cross join
SELECT track.title, track.genre_id, genre.id, genre.name
FROM track
CROSS JOIN genre;
-- 
SELECT
    track.title AS track,
    artist.name AS artist,
    album.title AS album,
    genre.name AS genre
FROM track
JOIN genre ON track.genre_id = genre.id
JOIN album ON track.album_id = album.id
JOIN artist ON album.artist_id = artist.id;



------------------------
-- Assignment 1 Start --
------------------------
CREATE TABLE student (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

DROP TABLE course CASCADE;
CREATE TABLE course (
    id SERIAL,
    title VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

DROP TABLE roster CASCADE;
CREATE TABLE roster (
    id SERIAL,
    student_id INTEGER REFERENCES student(id) ON DELETE CASCADE,
    course_id INTEGER REFERENCES course(id) ON DELETE CASCADE,
    role INTEGER,
    UNIQUE(student_id, course_id),
    PRIMARY KEY (id)
);

Marcy, si106, Instructor
Chin, si106, Learner
Estella, si106, Learner
Fauve, si106, Learner
Ikechukwu, si106, Learner
Kristopher, si110, Instructor
Inka, si110, Learner
Lincoln, si110, Learner
Oluwafemi, si110, Learner
Priya, si110, Learner
Reiss, si206, Instructor
Alisa, si206, Learner
Cejay, si206, Learner
Rhya, si206, Learner
Zarran, si206, Learner

-- si106
INSERT INTO student (name) VALUES ('Marcy');
INSERT INTO student (name) VALUES ('Chin');
INSERT INTO student (name) VALUES ('Estella');
INSERT INTO student (name) VALUES ('Fauve');
INSERT INTO student (name) VALUES ('Ikechukwu');
-- si110
INSERT INTO student (name) VALUES ('Kristopher');
INSERT INTO student (name) VALUES ('Inka');
INSERT INTO student (name) VALUES ('Lincoln');
INSERT INTO student (name) VALUES ('Oluwafemi');
INSERT INTO student (name) VALUES ('Priya');
-- si206
INSERT INTO student (name) VALUES ('Reiss');
INSERT INTO student (name) VALUES ('Alisa');
INSERT INTO student (name) VALUES ('Cejay');
INSERT INTO student (name) VALUES ('Rhya');
INSERT INTO student (name) VALUES ('Zarran');
-- courses
INSERT INTO course (title) VALUES ('si106');
INSERT INTO course (title) VALUES ('si110');
INSERT INTO course (title) VALUES ('si206');
-- roster
INSERT INTO roster (student_id, course_id, role) VALUES (1, 1, 1);
INSERT INTO roster (student_id, course_id, role) VALUES (2, 1, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (3, 1, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (4, 1, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (5, 1, 0);

INSERT INTO roster (student_id, course_id, role) VALUES (6, 2, 1);
INSERT INTO roster (student_id, course_id, role) VALUES (7, 2, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (8, 2, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (9, 2, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (10, 2, 0);

INSERT INTO roster (student_id, course_id, role) VALUES (11, 3, 1);
INSERT INTO roster (student_id, course_id, role) VALUES (12, 3, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (13, 3, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (14, 3, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (15, 3, 0);

SELECT student.name, course.title, roster.role
    FROM student 
    JOIN roster ON student.id = roster.student_id
    JOIN course ON roster.course_id = course.id
    ORDER BY course.title, roster.role DESC, student.name;

----------------------
-- Assignment 1 End --
----------------------
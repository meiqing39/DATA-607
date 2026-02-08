DROP TABLE IF EXISTS ratings;
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS reviewers;


CREATE TABLE reviewers(
reviewer_id SERIAL PRIMARY KEY,
name VARCHAR(255) NOT NULL);

CREATE TABLE movies(
movie_id SERIAL PRIMARY KEY,
title VARCHAR(255) NOT NULL);

CREATE TABLE ratings(
rating_id SERIAL PRIMARY KEY,
movie_id INT REFERENCES movies(movie_id),
reviewer_id INT REFERENCES reviewers(reviewer_id),
rating INT CHECK (rating>= 1 AND rating <= 5));

INSERT INTO movies (title) VALUES
	('The Substance'),
	('Nosferatu'),
    ('Frankenstein'),
    ('28 Years Later'),
    ('Sinners'),
    ('The Conjuring: Last Rites');

INSERT INTO reviewers(name) VALUES
	('Liz'),
	('Jed'),
	('Brenda'),
	('Jamie'),
	('Justice'); 

-- Liz is a huge horror fan (Rates everything high)
INSERT INTO ratings (reviewer_id, movie_id, rating) VALUES 
    (1, 1, 5), -- The Substance
    (1, 2, 5), -- Nosferatu
    (1, 4, 5); -- 28 Years Later

-- Jed only cares about Ryan Coogler movies
INSERT INTO ratings (reviewer_id, movie_id, rating) VALUES 
    (2, 5, 5), -- Sinners
    (2, 1, 3); -- The Substance (thought it was okay)

-- Brenda hates remakes/sequels (Low ratings for sequels)
INSERT INTO ratings (reviewer_id, movie_id, rating) VALUES 
    (3, 4, 2), -- 28 Years Later
    (3, 6, 1), -- Conjuring 4
    (3, 2, 4); -- Nosferatu (Exception)

-- Jamie hasn't seen trailers for half of them (Missing data!)
INSERT INTO ratings (reviewer_id, movie_id, rating) VALUES 
    (4, 1, 4), 
    (4, 3, 5); -- Frankenstein

-- Justice is just hype for everything
INSERT INTO ratings (reviewer_id, movie_id, rating) VALUES 
    (5, 1, 5), (5, 2, 5), (5, 3, 5), (5, 4, 5), (5, 5, 5), (5, 6, 5);
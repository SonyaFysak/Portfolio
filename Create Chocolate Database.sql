CREATE DATABASE chocolate;

use chocolate;

CREATE TABLE chocolate_rating (
	id INT UNIQUE PRIMARY KEY,
	ref INT,
    company_manufacturer VARCHAR(255),
    company_location VARCHAR(255),
    review_date INT,
    country_of_bean_origin VARCHAR(255),
    specific_bean_origin_or_bar_name VARCHAR(255),
    cocoa_percent VARCHAR(255),
    ingredients VARCHAR(255),
    most_memorable_characteristics VARCHAR(255),
    rating INT
);

SELECT * FROM chocolate_rating;

CREATE TABLE chocolate_ingredients
(
	id INT UNIQUE PRIMARY KEY,
    cocoa_percent VARCHAR(255),
    ingredients VARCHAR(255),
    rating INT
);

SELECT * FROM chocolate_ingredients;

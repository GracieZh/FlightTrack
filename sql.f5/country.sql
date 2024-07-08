\echo '-------- creating tables for feature 5 --------';

SET CLIENT_ENCODING TO 'utf8';

CREATE TABLE airports (
    ident VARCHAR(7),
    type VARCHAR(15),
    name VARCHAR(128),
    elevation_ft INT,
    continent  VARCHAR(2),
    iso_country VARCHAR(2),
    iso_region VARCHAR(7),
    municipality VARCHAR(64),
    gps_code VARCHAR(5),
    iata_code VARCHAR(5),
    local_code VARCHAR(7),
    coordinates VARCHAR(48)
);

COPY airports FROM 'C:\projects\cs338-proj\dbproj\datasets\airport-codes.csv' CSV HEADER;

CREATE TABLE country (
    name VARCHAR(48),
    a2 VARCHAR(2),
    a3 VARCHAR(3),
    uncode INT
);

COPY country FROM 'C:\projects\cs338-proj\dbproj\datasets\countrycode.csv' CSV HEADER;


CREATE TABLE usstate (
id INT,
state VARCHAR(20),
abbreviation VARCHAR(8),
code VARCHAR(2)   
);

COPY usstate FROM 'C:\projects\cs338-proj\dbproj\datasets\usstate.csv' CSV HEADER;
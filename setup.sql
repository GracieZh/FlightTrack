CREATE DATABASE appdb;

-- Setting up table to import csv data from Kaggle dataset
--   Kaggle data: https://www.kaggle.com/datasets/deepankurk/flight-take-off-data-jfk-airport

CREATE TABLE jfk_data (
  month INT,
  day_of_month INT,
  day_of_week INT,
  carrier_code VARCHAR(3),
  tail_num VARCHAR(7),
  dest VARCHAR(4),
  dep_delay INT,
  crs_elapsed_time INT,
  distance INT,
  crs_dep_time INT,
  dep_time INT,
  crs_arr_time INT,
  temp INT,
  dew VARCHAR(5),
  humidity INT,
  wind_direction VARCHAR(5),
  wind_speed INT,
  wind_gust INT,
  pressure float4,
  condition VARCHAR(50),
  sch_dep INT,
  sch_arr INT,
  taxi_out INT
);

COPY jfk_data
FROM 'C:\projects\cs338-proj\dataset\jfk_airport.csv' 
DELIMITER ',' 
CSV HEADER;

-- Setting up flight table 

CREATE TABLE flight (
  id INT 
    GENERATED ALWAYS AS IDENTITY 
    PRIMARY KEY,
  month INT,
  day_of_month INT,
  day_of_week INT,
  carrier_code VARCHAR(3),
  tail_num VARCHAR(7),
  scheduled_journey_time INT,  
  distance INT,
  scheduled_departure_time INT,
  departure_time INT,
  departure_delay INT,
  scheduled_arrival_time INT,
  taxi_out INT,
  captain_ssn INT,
  departure_airport_code VARCHAR(25),
  arrival_airport_code VARCHAR(25)
);

INSERT INTO flight(
  month, day_of_month, day_of_week, arrival_airport_code, carrier_code, tail_num, 
  scheduled_journey_time, distance, scheduled_departure_time, departure_time, 
  departure_delay, scheduled_arrival_time, taxi_out
)
SELECT month, day_of_month, day_of_week, dest, carrier_code, tail_num,
  crs_elapsed_time, distance, crs_dep_time, dep_time, 
  dep_delay, crs_arr_time, taxi_out
FROM jfk_data;

-- Setting up weather_condition table 

CREATE TABLE weather_condition (
  id INT PRIMARY KEY
    REFERENCES flight(id)
    ON DELETE CASCADE,
  temperature INT,
  dew_point VARCHAR(5),
  humidity INT,
  wind_dir VARCHAR(5),
  wind_speed INT,
  wind_gust INT,
  pressure float4,
  condition VARCHAR(50)
);

ALTER TABLE jfk_data ADD COLUMN id SERIAL PRIMARY KEY;

INSERT INTO weather_condition(
  id, temperature, dew_point, humidity, wind_dir, 
  wind_speed, wind_gust, pressure, condition
)
SELECT id, temp, dew, humidity, wind_direction, wind_speed, wind_gust, pressure, condition
FROM jfk_data;

DROP TABLE jfk_data;

-- Setting up Airline table to import airlines data obtained the following Wikipedia page
--    https://en.wikipedia.org/wiki/List_of_airline_codes

CREATE TABLE airline (
    IATA VARCHAR(5),
    ICAO VARCHAR(7),
    Airline VARCHAR(128),
    CallSign VARCHAR(128),
    Region VARCHAR(128),
    Comments VARCHAR(256)
);

COPY airline
FROM 'C:\projects\cs338-proj\dataset\airlines_with_iata.csv' 
DELIMITER ',' 
CSV HEADER
ENCODING 'windows-1251';

ALTER TABLE airline RENAME COLUMN IATA TO Airline_id; 
ALTER TABLE airline RENAME COLUMN Region TO Country; 
ALTER TABLE airline RENAME COLUMN Airline TO Name;

ALTER TABLE airline DROP COLUMN ICAO;
ALTER TABLE airline DROP COLUMN CallSign;
ALTER TABLE airline DROP COLUMN Comments;

ALTER TABLE airline ADD PRIMARY KEY (Airline_id);

-- ===================================
-- =========== SAMPLE DATA ===========
-- ===================================

-- Flight
CREATE TABLE sample_flight (
  id INT 
    GENERATED ALWAYS AS IDENTITY 
    PRIMARY KEY,
  month INT,
  day_of_month INT,
  day_of_week INT,
  carrier_code VARCHAR(3),
  tail_num VARCHAR(7),
  scheduled_journey_time INT,  
  distance INT,
  scheduled_departure_time INT,
  departure_time INT,
  departure_delay INT,
  scheduled_arrival_time INT,
  taxi_out INT,
  captain_ssn INT,
  departure_airport_code VARCHAR(25),
  arrival_airport_code VARCHAR(25)
);

INSERT INTO sample_flight(
  month, day_of_month, day_of_week, arrival_airport_code, carrier_code, tail_num, 
  scheduled_journey_time, distance, scheduled_departure_time, departure_time, 
  departure_delay, scheduled_arrival_time, taxi_out
)
SELECT month, day_of_month, day_of_week, arrival_airport_code, carrier_code, tail_num, 
  scheduled_journey_time, distance, scheduled_departure_time, departure_time, 
  departure_delay, scheduled_arrival_time, taxi_out
FROM flight
LIMIT 5;

UPDATE sample_flight
SET departure_airport_code = (CASE (random()*5)::INT WHEN 0 THEN 'LAX' 
                                                     WHEN 1 THEN 'JFK' 
                                                     WHEN 2 THEN 'PHX' 
                                                     WHEN 3 THEN 'SJU' 
                                                     WHEN 4 THEN 'ATL' 
                              END);

UPDATE sample_flight
SET captain_ssn = floor(random() * 900000000 + 100000000)::bigint;


-- Airline
CREATE TABLE sample_airline (
    Airline_id VARCHAR(5),
    Name VARCHAR(128),
    Country VARCHAR(128)
);

INSERT INTO sample_airline(
  Airline_id, Name, Country
)
SELECT Airline_id, Name, Country
FROM airline
LIMIT 5;

-- Aircraft
CREATE TABLE sample_aircraft (
  tail_no VARCHAR(7),
  model VARCHAR(25),
  capacity INT,
  number_of_seats INT,
  airline_id VARCHAR(3)
);

COPY sample_aircraft
FROM 'C:\projects\cs338-proj\dataset\sample_aircraft.csv' 
DELIMITER ',' 
CSV HEADER;
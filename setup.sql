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
LIMIT 20;

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

-- Airport
CREATE TABLE sample_airport (
  code VARCHAR(4),
  name VARCHAR(100),
  city VARCHAR(50),
  country VARCHAR(25),
  number_of_runways INT
);

COPY sample_airport
FROM 'C:\projects\cs338-proj\dataset\sample_airport.csv' 
DELIMITER ',' 
CSV HEADER;

-- Departs_from
CREATE TABLE sample_departs_from (
  flight_id INT PRIMARY KEY,
  airport_code VARCHAR(4),
  departure_time INT,
  departure_delay INT
);

COPY sample_departs_from
FROM 'C:\projects\cs338-proj\dataset\sample_departs_from.csv' 
DELIMITER ',' 
CSV HEADER;

ALTER TABLE sample_departs_from
ADD CONSTRAINT fk_flight_id 
FOREIGN KEY (flight_id) 
REFERENCES sample_flight (id) 
ON DELETE CASCADE;

-- Arrives_at
CREATE TABLE sample_arrives_at (
  flight_id INT PRIMARY KEY,
  airport_code VARCHAR(4),
  arrival_time INT
);

COPY sample_arrives_at
FROM 'C:\projects\cs338-proj\dataset\sample_arrives_at.csv' 
DELIMITER ',' 
CSV HEADER;

ALTER TABLE sample_arrives_at
ADD CONSTRAINT fk_flight_id 
FOREIGN KEY (flight_id) 
REFERENCES sample_flight (id) 
ON DELETE CASCADE;

-- Weather_condition
CREATE TABLE sample_weather_condition (
  flight_id INT PRIMARY KEY,
  temperature INT,
  dew_point VARCHAR(5),
  humidity INT,
  wind_dir VARCHAR(5),
  wind_speed INT,
  wind_gust INT,
  pressure float4,
  condition VARCHAR(50)
);

INSERT INTO sample_weather_condition(
  flight_id, temperature, dew_point, humidity, wind_dir, 
  wind_speed, wind_gust, pressure, condition
)
SELECT id, temperature, dew_point, humidity, wind_dir, 
       wind_speed, wind_gust, pressure, condition
FROM weather_condition
LIMIT 20;

ALTER TABLE sample_weather_condition
ADD CONSTRAINT fk_flight_id 
FOREIGN KEY (flight_id) 
REFERENCES sample_flight (id) 
ON DELETE CASCADE;

-- Boarding_ticket
CREATE TABLE sample_boarding_ticket (
  ticket_number INT,
  seat_no INT,
  fair INT,
  class VARCHAR(50),
  flight_id INT
);

COPY sample_boarding_ticket
FROM 'C:\projects\cs338-proj\dataset\sample_boarding_ticket.csv' 
DELIMITER ',' 
CSV HEADER;

-- User
CREATE TABLE sample_user (
  ssn INT PRIMARY KEY,
  fname VARCHAR(50),
  lname VARCHAR(50),
  bdate VARCHAR(11),
  email VARCHAR(100),
  address VARCHAR(100),
  sex VARCHAR(50)
);

COPY sample_user
FROM 'C:\projects\cs338-proj\dataset\sample_user.csv' 
DELIMITER ',' 
CSV HEADER;

-- Phone numbers
CREATE TABLE sample_phonenumbers (
  ssn INT,
  phone_number VARCHAR(13)
);

ALTER TABLE sample_phonenumbers ADD PRIMARY KEY (ssn, phone_number);

COPY sample_phonenumbers
FROM 'C:\projects\cs338-proj\dataset\sample_phonenumbers.csv' 
DELIMITER ',' 
CSV HEADER;

ALTER TABLE sample_phonenumbers
ADD CONSTRAINT fk_ssn 
FOREIGN KEY (ssn) 
REFERENCES sample_user (ssn) 
ON DELETE CASCADE;

-- Passenger
CREATE TABLE sample_passenger (
  ssn INT,
  ticket_no VARCHAR(13)
);

ALTER TABLE sample_passenger ADD PRIMARY KEY (ssn);

COPY sample_passenger
FROM 'C:\projects\cs338-proj\dataset\sample_passenger.csv' 
DELIMITER ',' 
CSV HEADER;

ALTER TABLE sample_passenger
ADD CONSTRAINT fk_ssn 
FOREIGN KEY (ssn) 
REFERENCES sample_user (ssn) 
ON DELETE CASCADE;

-- Flight_crew
CREATE TABLE sample_flight_crew (
  ssn INT PRIMARY KEY
);

COPY sample_flight_crew
FROM 'C:\projects\cs338-proj\dataset\sample_flight_crew.csv' 
DELIMITER ',' 
CSV HEADER;

ALTER TABLE sample_flight_crew
ADD CONSTRAINT fk_ssn 
FOREIGN KEY (ssn) 
REFERENCES sample_user (ssn) 
ON DELETE CASCADE;

-- Pilot
CREATE TABLE sample_pilot (
  ssn INT PRIMARY KEY,
  flight_hours INT,
  liscence_number INT
);

COPY sample_pilot
FROM 'C:\projects\cs338-proj\dataset\sample_pilot.csv' 
DELIMITER ',' 
CSV HEADER;

ALTER TABLE sample_pilot
ADD CONSTRAINT fk_ssn 
FOREIGN KEY (ssn) 
REFERENCES sample_user (ssn) 
ON DELETE CASCADE;


-- Attendant
CREATE TABLE sample_attendant (
  ssn INT PRIMARY KEY,
  plane_section INT,
  supper_ssn INT
);

COPY sample_attendant
FROM 'C:\projects\cs338-proj\dataset\sample_attendant.csv' 
DELIMITER ',' 
CSV HEADER;

ALTER TABLE sample_attendant
ADD CONSTRAINT fk_ssn 
FOREIGN KEY (ssn) 
REFERENCES sample_user (ssn) 
ON DELETE CASCADE;

-- Captain
CREATE TABLE sample_captain (
  ssn INT PRIMARY KEY
);

COPY sample_captain
FROM 'C:\projects\cs338-proj\dataset\sample_captain.csv' 
DELIMITER ',' 
CSV HEADER;

ALTER TABLE sample_captain
ADD CONSTRAINT fk_ssn 
FOREIGN KEY (ssn) 
REFERENCES sample_user (ssn) 
ON DELETE CASCADE;

-- First_officer
CREATE TABLE sample_first_officer (
  ssn INT PRIMARY KEY
);

COPY sample_first_officer
FROM 'C:\projects\cs338-proj\dataset\sample_first_officer.csv' 
DELIMITER ',' 
CSV HEADER;

ALTER TABLE sample_first_officer
ADD CONSTRAINT fk_ssn 
FOREIGN KEY (ssn) 
REFERENCES sample_user (ssn) 
ON DELETE CASCADE;

-- Flight_crew_log
CREATE TABLE sample_flight_crew_log (
  flight_id INT,
  crew_ssn INT
);

COPY sample_flight_crew_log
FROM 'C:\projects\cs338-proj\dataset\sample_flight_crew_log.csv' 
DELIMITER ',' 
CSV HEADER;

ALTER TABLE sample_flight_crew_log
ADD CONSTRAINT fk_crew_ssn 
FOREIGN KEY (crew_ssn) 
REFERENCES sample_flight_crew (ssn) 
ON DELETE CASCADE;

ALTER TABLE sample_flight_crew_log ADD PRIMARY KEY (flight_id, crew_ssn);
\set ON_ERROR_STOP on

------------------------------------------------------
-- if there is an error, after you fix it, run the following:
--
-- \c postgres
-- drop database appdb;
-- create database appdb;
-- \c appdb;
------------------------------------------------------

-- Check if the current database is 'appdb'
DO $$
BEGIN
    IF current_database() != 'appdb' THEN
        RAISE EXCEPTION 'Current database is not appdb. Exiting...';
    END IF;
END $$;

-- Check if the table 'flight' exists
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables 
               WHERE table_schema = 'public' AND table_name = 'flight') THEN
        RAISE EXCEPTION 'Table flight already exists. Exiting...';
    END IF;
END $$;

SET CLIENT_ENCODING TO 'utf8';

\echo '-------- creating tables related to flights --------'

-- Setting up table to import csv data from Kaggle dataset
--   Kaggle data: https://www.kaggle.com/datasets/deepankurk/flight-take-off-data-jfk-airport

DROP TABLE IF EXISTS jfk_data;
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
FROM 'C:\projects\cs338-proj\dbproj\datasets\jfk_airport.csv' 
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
FROM 'C:\projects\cs338-proj\dbproj\datasets\airlines_with_iata.csv' 
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

\echo '-------- CREATING SAMPLE TABLES --------';

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
FROM 'C:\projects\cs338-proj\dbproj\datasets\sample_aircraft.csv' 
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
FROM 'C:\projects\cs338-proj\dbproj\datasets\sample_airport.csv' 
DELIMITER ',' 
CSV HEADER;

-- Departs_from
CREATE TABLE sample_departs_from (
  flight_id INT PRIMARY KEY,
  airport_code VARCHAR(4),
  departure_time INT,
  departure_delay INT,
  FOREIGN KEY (flight_id) REFERENCES sample_flight(id) ON DELETE CASCADE
);

COPY sample_departs_from
FROM 'C:\projects\cs338-proj\dbproj\datasets\sample_departs_from.csv' 
DELIMITER ',' 
CSV HEADER;

-- Arrives_at
CREATE TABLE sample_arrives_at (
  flight_id INT PRIMARY KEY,
  airport_code VARCHAR(4),
  arrival_time INT,
  FOREIGN KEY (flight_id) REFERENCES sample_flight(id) ON DELETE CASCADE
);

COPY sample_arrives_at
FROM 'C:\projects\cs338-proj\dbproj\datasets\sample_arrives_at.csv' 
DELIMITER ',' 
CSV HEADER;

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
  condition VARCHAR(50),
  FOREIGN KEY (flight_id) REFERENCES sample_flight(id) ON DELETE CASCADE
);

INSERT INTO sample_weather_condition(
  flight_id, temperature, dew_point, humidity, wind_dir, 
  wind_speed, wind_gust, pressure, condition
)
SELECT id, temperature, dew_point, humidity, wind_dir, 
       wind_speed, wind_gust, pressure, condition
FROM weather_condition
LIMIT 20;


-- Boarding_ticket
CREATE TABLE sample_boarding_ticket (
  ticket_number INT,
  seat_no INT,
  fair INT,
  class VARCHAR(50),
  flight_id INT
);

COPY sample_boarding_ticket
FROM 'C:\projects\cs338-proj\dbproj\datasets\sample_boarding_ticket.csv' 
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
FROM 'C:\projects\cs338-proj\dbproj\datasets\sample_user.csv' 
DELIMITER ',' 
CSV HEADER;

-- Phone numbers
CREATE TABLE sample_phonenumbers (
  ssn INT,
  phone_number VARCHAR(13),
  FOREIGN KEY (ssn) REFERENCES sample_user(ssn) ON DELETE CASCADE
);

ALTER TABLE sample_phonenumbers ADD PRIMARY KEY (ssn, phone_number);

COPY sample_phonenumbers
FROM 'C:\projects\cs338-proj\dbproj\datasets\sample_phonenumbers.csv' 
DELIMITER ',' 
CSV HEADER;

-- Passenger
CREATE TABLE sample_passenger (
  ssn INT PRIMARY KEY,
  ticket_no VARCHAR(13),
  FOREIGN KEY (ssn) REFERENCES sample_user(ssn) ON DELETE CASCADE
);

COPY sample_passenger
FROM 'C:\projects\cs338-proj\dbproj\datasets\sample_passenger.csv' 
DELIMITER ',' 
CSV HEADER;

-- Flight_crew
CREATE TABLE sample_flight_crew (
  ssn INT PRIMARY KEY,
  FOREIGN KEY (ssn) REFERENCES sample_user(ssn) ON DELETE CASCADE
);

COPY sample_flight_crew
FROM 'C:\projects\cs338-proj\dbproj\datasets\sample_flight_crew.csv' 
DELIMITER ',' 
CSV HEADER;

-- Pilot
CREATE TABLE sample_pilot (
  ssn INT PRIMARY KEY,
  flight_hours INT,
  liscence_number BIGINT,
  FOREIGN KEY (ssn) REFERENCES sample_user(ssn) ON DELETE CASCADE
);

COPY sample_pilot
FROM 'C:\projects\cs338-proj\dbproj\datasets\sample_pilot.csv' 
DELIMITER ',' 
CSV HEADER;


-- Attendant
CREATE TABLE sample_attendant (
  ssn INT PRIMARY KEY,
  plane_section VARCHAR(7),
  supper_ssn INT,
  FOREIGN KEY (ssn) REFERENCES sample_user(ssn) ON DELETE CASCADE
);

COPY sample_attendant
FROM 'C:\projects\cs338-proj\dbproj\datasets\sample_attendant.csv' 
DELIMITER ',' 
CSV HEADER;

-- Captain
CREATE TABLE sample_captain (
  ssn INT PRIMARY KEY,
  FOREIGN KEY (ssn) REFERENCES sample_user(ssn) ON DELETE CASCADE
);

COPY sample_captain
FROM 'C:\projects\cs338-proj\dbproj\datasets\sample_captain.csv' 
DELIMITER ',' 
CSV HEADER;

-- First_officer
CREATE TABLE sample_first_officer (
  ssn INT PRIMARY KEY,
  FOREIGN KEY (ssn) REFERENCES sample_user(ssn) ON DELETE CASCADE
);

COPY sample_first_officer
FROM 'C:\projects\cs338-proj\dbproj\datasets\sample_first_officer.csv' 
DELIMITER ',' 
CSV HEADER;

-- Flight_crew_log
CREATE TABLE sample_flight_crew_log (
  flight_id INT,
  crew_ssn INT,
  FOREIGN KEY (flight_id) REFERENCES sample_flight(id) ON DELETE CASCADE,
  FOREIGN KEY (crew_ssn) REFERENCES sample_user(ssn) ON DELETE CASCADE,
  PRIMARY KEY (flight_id, crew_ssn)
);

COPY sample_flight_crew_log
FROM 'C:\projects\cs338-proj\dbproj\datasets\sample_flight_crew_log.csv' 
DELIMITER ',' 
CSV HEADER;


\echo '-------- Feature 1 --------';

\i C:/projects/cs338-proj/dbproj/sql.f1/test_flight.sql

\echo '-------- Feature 5 --------';

\i C:/projects/cs338-proj/dbproj/sql.f5/country.sql

\echo '-------- Feature 6 --------';

\i C:/projects/cs338-proj/dbproj/sql.f6/setup_names.sql
\i C:/projects/cs338-proj/dbproj/sql.f6/create_users.sql
\i C:/projects/cs338-proj/dbproj/sql.f6/create_tickets.sql
\i C:/projects/cs338-proj/dbproj/sql.f6/assign_crew.sql
\i C:/projects/cs338-proj/dbproj/sql.f6/assign_tickets.sql

\echo '-------- Done --------';
-- Print all table information, indices, stored procedures, and stored functions

\dt
SELECT tablename, indexname, indexdef FROM pg_indexes WHERE schemaname = 'public' ORDER BY tablename, indexname;
\df




-- \i C:/projects/cs338-proj/dbproj/setup.sql

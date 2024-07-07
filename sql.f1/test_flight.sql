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

DROP TABLE IF EXISTS flight_test_YMD;
CREATE TABLE IF NOT EXISTS flight_test_YMD (
  id INT 
    GENERATED ALWAYS AS IDENTITY 
    PRIMARY KEY,
  year INT,
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

INSERT INTO flight_test_YMD (
    year, month, day_of_month, day_of_week, arrival_airport_code, carrier_code, tail_num, 
    scheduled_journey_time, distance, scheduled_departure_time, departure_time, 
    departure_delay, scheduled_arrival_time, taxi_out
)
SELECT 
    CASE
        WHEN month = 12 THEN 2019
        WHEN month = 11 THEN 2019
        WHEN month = 1 THEN 2020
        ELSE NULL -- there are no other months in the jfk dataset
    END::INT AS year, month, day_of_month,
    day_of_week, dest, carrier_code, tail_num,
    crs_elapsed_time, distance, crs_dep_time, dep_time, 
    dep_delay, crs_arr_time, taxi_out
FROM jfk_data;        


DROP TABLE IF EXISTS flight_test_int;
CREATE TABLE IF NOT EXISTS flight_test_int (
  id INT 
    GENERATED ALWAYS AS IDENTITY 
    PRIMARY KEY,
  ymd INT,
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

INSERT INTO flight_test_int (
    ymd, day_of_week, arrival_airport_code, carrier_code, tail_num, 
    scheduled_journey_time, distance, scheduled_departure_time, departure_time, 
    departure_delay, scheduled_arrival_time, taxi_out
)
SELECT 
    CASE
        WHEN month = 12 THEN 2019*10000+month*100+day_of_month
        WHEN month = 11 THEN 2019*10000+month*100+day_of_month
        WHEN month = 1 THEN 2020*10000+month*100+day_of_month
        ELSE NULL -- there are no other months in the jfk dataset
    END::INT AS ymd,
    day_of_week, dest, carrier_code, tail_num,
    crs_elapsed_time, distance, crs_dep_time, dep_time, 
    dep_delay, crs_arr_time, taxi_out
FROM jfk_data;        


DROP TABLE IF EXISTS flight_test_date;
CREATE TABLE IF NOT EXISTS flight_test_date (
  id INT 
    GENERATED ALWAYS AS IDENTITY 
    PRIMARY KEY,
  date DATE,
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

INSERT INTO flight_test_date (
    date, day_of_week, arrival_airport_code, carrier_code, tail_num, 
    scheduled_journey_time, distance, scheduled_departure_time, departure_time, 
    departure_delay, scheduled_arrival_time, taxi_out
)
SELECT 
    CASE
        WHEN month = 12 THEN '2019-12-' || LPAD(day_of_month::text, 2, '0')
        WHEN month = 11 THEN '2019-11-' || LPAD(day_of_month::text, 2, '0')
        WHEN month = 1 THEN '2020-01-' || LPAD(day_of_month::text, 2, '0')
        ELSE NULL -- or handle other months as appropriate
    END::DATE AS date,
    day_of_week, dest, carrier_code, tail_num,
    crs_elapsed_time, distance, crs_dep_time, dep_time, 
    dep_delay, crs_arr_time, taxi_out
FROM jfk_data;

DROP TABLE jfk_data;

-- \i C:/projects/cs338-proj/dbproj/sql.f1/test_flight.sql
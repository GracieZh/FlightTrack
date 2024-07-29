--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
SELECT pg_stat_statements_reset();
--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------
DROP INDEX IF EXISTS idx_flight_1;
DROP INDEX IF EXISTS idx_flight_5;
DROP INDEX IF EXISTS idx_weather_condition_1; 
--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------
WITH test_NO_INDEX_flight_with_weather AS (
        SELECT carrier_code, departure_delay, temperature AS param
        FROM flight JOIN weather_condition ON flight.id = weather_condition.id
        WHERE carrier_code IN ('YX') AND wind_dir IN ('S', 'SSW', 'SW', 'WSW')),
        y_ranges AS ( SELECT MIN(param) AS y_min, MAX(param) AS y_max FROM test_NO_INDEX_flight_with_weather),
        y_intervals AS (
        SELECT ROUND(y_min + (y_max - y_min) * 1.0/6 * n,2) AS lower_bound,
                ROUND(y_min + (y_max - y_min) * 1.0/6 * (n + 1),2) AS upper_bound
        FROM generate_series(0, 5) AS n CROSS JOIN y_ranges ),
        delay_intervals AS (SELECT * FROM ( VALUES (1, -10000, 0.00),(2, 0.00,  10.00),(3, 10.00, 30.00),
                (4, 30.00, 60.00),(5, 60.00, 100000.00)) AS tmp(value, lower_bound, upper_bound)),
        delays AS (
        SELECT departure_delay, d.value AS x_value, y.lower_bound AS y_value FROM test_NO_INDEX_flight_with_weather f
        JOIN delay_intervals d ON f.departure_delay > d.lower_bound AND f.departure_delay <= d.upper_bound
        JOIN y_intervals y ON f.param >= y.lower_bound AND f.param < y.upper_bound)
        SELECT x_value, y_value, COUNT(*) AS num_of_flights
        FROM delays GROUP BY x_value,y_value ORDER BY x_value,y_value;
WITH test_NO_INDEX_flight_with_weather AS (
        SELECT carrier_code, departure_delay, temperature AS param
        FROM flight JOIN weather_condition ON flight.id = weather_condition.id
        WHERE carrier_code IN ('YX') AND wind_dir IN ('S', 'SSW', 'SW', 'WSW')),
        y_ranges AS ( SELECT MIN(param) AS y_min, MAX(param) AS y_max FROM test_NO_INDEX_flight_with_weather),
        y_intervals AS (
        SELECT ROUND(y_min + (y_max - y_min) * 1.0/6 * n,2) AS lower_bound,
                ROUND(y_min + (y_max - y_min) * 1.0/6 * (n + 1),2) AS upper_bound
        FROM generate_series(0, 5) AS n CROSS JOIN y_ranges ),
        delay_intervals AS (SELECT * FROM ( VALUES (1, -10000, 0.00),(2, 0.00,  10.00),(3, 10.00, 30.00),
                (4, 30.00, 60.00),(5, 60.00, 100000.00)) AS tmp(value, lower_bound, upper_bound)),
        delays AS (
        SELECT departure_delay, d.value AS x_value, y.lower_bound AS y_value FROM test_NO_INDEX_flight_with_weather f
        JOIN delay_intervals d ON f.departure_delay > d.lower_bound AND f.departure_delay <= d.upper_bound
        JOIN y_intervals y ON f.param >= y.lower_bound AND f.param < y.upper_bound)
        SELECT x_value, y_value, COUNT(*) AS num_of_flights
        FROM delays GROUP BY x_value,y_value ORDER BY x_value,y_value;
WITH test_NO_INDEX_flight_with_weather AS (
        SELECT carrier_code, departure_delay, temperature AS param
        FROM flight JOIN weather_condition ON flight.id = weather_condition.id
        WHERE carrier_code IN ('YX') AND wind_dir IN ('S', 'SSW', 'SW', 'WSW')),
        y_ranges AS ( SELECT MIN(param) AS y_min, MAX(param) AS y_max FROM test_NO_INDEX_flight_with_weather),
        y_intervals AS (
        SELECT ROUND(y_min + (y_max - y_min) * 1.0/6 * n,2) AS lower_bound,
                ROUND(y_min + (y_max - y_min) * 1.0/6 * (n + 1),2) AS upper_bound
        FROM generate_series(0, 5) AS n CROSS JOIN y_ranges ),
        delay_intervals AS (SELECT * FROM ( VALUES (1, -10000, 0.00),(2, 0.00,  10.00),(3, 10.00, 30.00),
                (4, 30.00, 60.00),(5, 60.00, 100000.00)) AS tmp(value, lower_bound, upper_bound)),
        delays AS (
        SELECT departure_delay, d.value AS x_value, y.lower_bound AS y_value FROM test_NO_INDEX_flight_with_weather f
        JOIN delay_intervals d ON f.departure_delay > d.lower_bound AND f.departure_delay <= d.upper_bound
        JOIN y_intervals y ON f.param >= y.lower_bound AND f.param < y.upper_bound)
        SELECT x_value, y_value, COUNT(*) AS num_of_flights
        FROM delays GROUP BY x_value,y_value ORDER BY x_value,y_value;
WITH test_NO_INDEX_flight_with_weather AS (
        SELECT carrier_code, departure_delay, temperature AS param
        FROM flight JOIN weather_condition ON flight.id = weather_condition.id
        WHERE carrier_code IN ('YX') AND wind_dir IN ('S', 'SSW', 'SW', 'WSW')),
        y_ranges AS ( SELECT MIN(param) AS y_min, MAX(param) AS y_max FROM test_NO_INDEX_flight_with_weather),
        y_intervals AS (
        SELECT ROUND(y_min + (y_max - y_min) * 1.0/6 * n,2) AS lower_bound,
                ROUND(y_min + (y_max - y_min) * 1.0/6 * (n + 1),2) AS upper_bound
        FROM generate_series(0, 5) AS n CROSS JOIN y_ranges ),
        delay_intervals AS (SELECT * FROM ( VALUES (1, -10000, 0.00),(2, 0.00,  10.00),(3, 10.00, 30.00),
                (4, 30.00, 60.00),(5, 60.00, 100000.00)) AS tmp(value, lower_bound, upper_bound)),
        delays AS (
        SELECT departure_delay, d.value AS x_value, y.lower_bound AS y_value FROM test_NO_INDEX_flight_with_weather f
        JOIN delay_intervals d ON f.departure_delay > d.lower_bound AND f.departure_delay <= d.upper_bound
        JOIN y_intervals y ON f.param >= y.lower_bound AND f.param < y.upper_bound)
        SELECT x_value, y_value, COUNT(*) AS num_of_flights
        FROM delays GROUP BY x_value,y_value ORDER BY x_value,y_value;
WITH test_NO_INDEX_flight_with_weather AS (
        SELECT carrier_code, departure_delay, temperature AS param
        FROM flight JOIN weather_condition ON flight.id = weather_condition.id
        WHERE carrier_code IN ('YX') AND wind_dir IN ('S', 'SSW', 'SW', 'WSW')),
        y_ranges AS ( SELECT MIN(param) AS y_min, MAX(param) AS y_max FROM test_NO_INDEX_flight_with_weather),
        y_intervals AS (
        SELECT ROUND(y_min + (y_max - y_min) * 1.0/6 * n,2) AS lower_bound,
                ROUND(y_min + (y_max - y_min) * 1.0/6 * (n + 1),2) AS upper_bound
        FROM generate_series(0, 5) AS n CROSS JOIN y_ranges ),
        delay_intervals AS (SELECT * FROM ( VALUES (1, -10000, 0.00),(2, 0.00,  10.00),(3, 10.00, 30.00),
                (4, 30.00, 60.00),(5, 60.00, 100000.00)) AS tmp(value, lower_bound, upper_bound)),
        delays AS (
        SELECT departure_delay, d.value AS x_value, y.lower_bound AS y_value FROM test_NO_INDEX_flight_with_weather f
        JOIN delay_intervals d ON f.departure_delay > d.lower_bound AND f.departure_delay <= d.upper_bound
        JOIN y_intervals y ON f.param >= y.lower_bound AND f.param < y.upper_bound)
        SELECT x_value, y_value, COUNT(*) AS num_of_flights
        FROM delays GROUP BY x_value,y_value ORDER BY x_value,y_value;
--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------
CREATE INDEX idx_flight_1 ON flight (carrier_code); 
CREATE INDEX idx_flight_5 ON flight (departure_delay); 
CREATE INDEX idx_weather_condition_1 ON weather_condition (wind_dir); 
--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------
WITH test_WITH_INDEX_flight_with_weather AS (
        SELECT carrier_code, departure_delay, temperature AS param
        FROM flight JOIN weather_condition ON flight.id = weather_condition.id
        WHERE carrier_code IN ('YX') AND wind_dir IN ('S', 'SSW', 'SW', 'WSW')),
        y_ranges AS ( SELECT MIN(param) AS y_min, MAX(param) AS y_max FROM test_WITH_INDEX_flight_with_weather),
        y_intervals AS (
        SELECT ROUND(y_min + (y_max - y_min) * 1.0/6 * n,2) AS lower_bound,
                ROUND(y_min + (y_max - y_min) * 1.0/6 * (n + 1),2) AS upper_bound
        FROM generate_series(0, 5) AS n CROSS JOIN y_ranges ),
        delay_intervals AS (SELECT * FROM ( VALUES (1, -10000, 0.00),(2, 0.00,  10.00),(3, 10.00, 30.00),
                (4, 30.00, 60.00),(5, 60.00, 100000.00)) AS tmp(value, lower_bound, upper_bound)),
        delays AS (
        SELECT departure_delay, d.value AS x_value, y.lower_bound AS y_value FROM test_WITH_INDEX_flight_with_weather f
        JOIN delay_intervals d ON f.departure_delay > d.lower_bound AND f.departure_delay <= d.upper_bound
        JOIN y_intervals y ON f.param >= y.lower_bound AND f.param < y.upper_bound)
        SELECT x_value, y_value, COUNT(*) AS num_of_flights
        FROM delays GROUP BY x_value,y_value ORDER BY x_value,y_value;
WITH test_WITH_INDEX_flight_with_weather AS (
        SELECT carrier_code, departure_delay, temperature AS param
        FROM flight JOIN weather_condition ON flight.id = weather_condition.id
        WHERE carrier_code IN ('YX') AND wind_dir IN ('S', 'SSW', 'SW', 'WSW')),
        y_ranges AS ( SELECT MIN(param) AS y_min, MAX(param) AS y_max FROM test_WITH_INDEX_flight_with_weather),
        y_intervals AS (
        SELECT ROUND(y_min + (y_max - y_min) * 1.0/6 * n,2) AS lower_bound,
                ROUND(y_min + (y_max - y_min) * 1.0/6 * (n + 1),2) AS upper_bound
        FROM generate_series(0, 5) AS n CROSS JOIN y_ranges ),
        delay_intervals AS (SELECT * FROM ( VALUES (1, -10000, 0.00),(2, 0.00,  10.00),(3, 10.00, 30.00),
                (4, 30.00, 60.00),(5, 60.00, 100000.00)) AS tmp(value, lower_bound, upper_bound)),
        delays AS (
        SELECT departure_delay, d.value AS x_value, y.lower_bound AS y_value FROM test_WITH_INDEX_flight_with_weather f
        JOIN delay_intervals d ON f.departure_delay > d.lower_bound AND f.departure_delay <= d.upper_bound
        JOIN y_intervals y ON f.param >= y.lower_bound AND f.param < y.upper_bound)
        SELECT x_value, y_value, COUNT(*) AS num_of_flights
        FROM delays GROUP BY x_value,y_value ORDER BY x_value,y_value;
WITH test_WITH_INDEX_flight_with_weather AS (
        SELECT carrier_code, departure_delay, temperature AS param
        FROM flight JOIN weather_condition ON flight.id = weather_condition.id
        WHERE carrier_code IN ('YX') AND wind_dir IN ('S', 'SSW', 'SW', 'WSW')),
        y_ranges AS ( SELECT MIN(param) AS y_min, MAX(param) AS y_max FROM test_WITH_INDEX_flight_with_weather),
        y_intervals AS (
        SELECT ROUND(y_min + (y_max - y_min) * 1.0/6 * n,2) AS lower_bound,
                ROUND(y_min + (y_max - y_min) * 1.0/6 * (n + 1),2) AS upper_bound
        FROM generate_series(0, 5) AS n CROSS JOIN y_ranges ),
        delay_intervals AS (SELECT * FROM ( VALUES (1, -10000, 0.00),(2, 0.00,  10.00),(3, 10.00, 30.00),
                (4, 30.00, 60.00),(5, 60.00, 100000.00)) AS tmp(value, lower_bound, upper_bound)),
        delays AS (
        SELECT departure_delay, d.value AS x_value, y.lower_bound AS y_value FROM test_WITH_INDEX_flight_with_weather f
        JOIN delay_intervals d ON f.departure_delay > d.lower_bound AND f.departure_delay <= d.upper_bound
        JOIN y_intervals y ON f.param >= y.lower_bound AND f.param < y.upper_bound)
        SELECT x_value, y_value, COUNT(*) AS num_of_flights
        FROM delays GROUP BY x_value,y_value ORDER BY x_value,y_value;
WITH test_WITH_INDEX_flight_with_weather AS (
        SELECT carrier_code, departure_delay, temperature AS param
        FROM flight JOIN weather_condition ON flight.id = weather_condition.id
        WHERE carrier_code IN ('YX') AND wind_dir IN ('S', 'SSW', 'SW', 'WSW')),
        y_ranges AS ( SELECT MIN(param) AS y_min, MAX(param) AS y_max FROM test_WITH_INDEX_flight_with_weather),
        y_intervals AS (
        SELECT ROUND(y_min + (y_max - y_min) * 1.0/6 * n,2) AS lower_bound,
                ROUND(y_min + (y_max - y_min) * 1.0/6 * (n + 1),2) AS upper_bound
        FROM generate_series(0, 5) AS n CROSS JOIN y_ranges ),
        delay_intervals AS (SELECT * FROM ( VALUES (1, -10000, 0.00),(2, 0.00,  10.00),(3, 10.00, 30.00),
                (4, 30.00, 60.00),(5, 60.00, 100000.00)) AS tmp(value, lower_bound, upper_bound)),
        delays AS (
        SELECT departure_delay, d.value AS x_value, y.lower_bound AS y_value FROM test_WITH_INDEX_flight_with_weather f
        JOIN delay_intervals d ON f.departure_delay > d.lower_bound AND f.departure_delay <= d.upper_bound
        JOIN y_intervals y ON f.param >= y.lower_bound AND f.param < y.upper_bound)
        SELECT x_value, y_value, COUNT(*) AS num_of_flights
        FROM delays GROUP BY x_value,y_value ORDER BY x_value,y_value;
WITH test_WITH_INDEX_flight_with_weather AS (
        SELECT carrier_code, departure_delay, temperature AS param
        FROM flight JOIN weather_condition ON flight.id = weather_condition.id
        WHERE carrier_code IN ('YX') AND wind_dir IN ('S', 'SSW', 'SW', 'WSW')),
        y_ranges AS ( SELECT MIN(param) AS y_min, MAX(param) AS y_max FROM test_WITH_INDEX_flight_with_weather),
        y_intervals AS (
        SELECT ROUND(y_min + (y_max - y_min) * 1.0/6 * n,2) AS lower_bound,
                ROUND(y_min + (y_max - y_min) * 1.0/6 * (n + 1),2) AS upper_bound
        FROM generate_series(0, 5) AS n CROSS JOIN y_ranges ),
        delay_intervals AS (SELECT * FROM ( VALUES (1, -10000, 0.00),(2, 0.00,  10.00),(3, 10.00, 30.00),
                (4, 30.00, 60.00),(5, 60.00, 100000.00)) AS tmp(value, lower_bound, upper_bound)),
        delays AS (
        SELECT departure_delay, d.value AS x_value, y.lower_bound AS y_value FROM test_WITH_INDEX_flight_with_weather f
        JOIN delay_intervals d ON f.departure_delay > d.lower_bound AND f.departure_delay <= d.upper_bound
        JOIN y_intervals y ON f.param >= y.lower_bound AND f.param < y.upper_bound)
        SELECT x_value, y_value, COUNT(*) AS num_of_flights
        FROM delays GROUP BY x_value,y_value ORDER BY x_value,y_value;
--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------
SELECT ROUND(total_exec_time::numeric,3) as total_time, calls, ROUND(mean_exec_time::numeric,3) as avg_time, 
        ROUND(min_exec_time::numeric,3) as min_time, ROUND(max_exec_time::numeric,3) as max_time, query
        FROM pg_stat_statements WHERE query like '%%test%%';

DROP EXTENSION pg_stat_statements;

-- .\psql.exe -U postgres -h localhost -d appdb -W -f C:/projects/cs338-proj/dbproj/test_scripts/test_production_ff5.sql > C:/projects/cs338-proj/dbproj/test_scripts/test_production_ff5.out


CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

DROP INDEX IF EXISTS idx_flight_1;
DROP INDEX IF EXISTS idx_flight_test_YMD_1;
DROP INDEX IF EXISTS idx_flight_test_int_1;
DROP INDEX IF EXISTS idx_flight_test_date_1;
DROP INDEX IF EXISTS idx_airline_1;

SELECT pg_stat_statements_reset();

SELECT
    month, day_of_month, carrier_code, airline.name, tail_num, arrival_airport_code, departure_delay
FROM
    flight
JOIN
    airline ON flight.carrier_code = airline.airline_id
WHERE
(
    CASE
        WHEN month > 10 THEN (month - 10) * 100 + day_of_month
        ELSE (month + 3) * 100 + day_of_month
    END
) BETWEEN
(
    CASE
        WHEN 1 > 10 THEN (1 - 10) * 100 + 1
        ELSE (1 + 3) * 100 + 1
    END
)
AND
(
    CASE
        WHEN 1 > 10 THEN (1 - 10) * 100 + 1
        ELSE (1 + 3) * 100 + 1
    END
)
AND
    carrier_code IN ('HA', 'YX')
ORDER BY
    departure_delay DESC
FETCH FIRST
    10 ROWS ONLY;

SELECT
    ymd, carrier_code, airline.name, tail_num, arrival_airport_code, departure_delay
FROM
    flight_test_int f
JOIN
    airline ON f.carrier_code = airline.airline_id
WHERE
    ymd
BETWEEN
    20200101
AND
    20200101
AND
    carrier_code IN ('HA', 'YX')
ORDER BY
    departure_delay DESC
FETCH FIRST
    10 ROWS ONLY;


SELECT
    month, day_of_month, carrier_code, airline.name, tail_num, arrival_airport_code, departure_delay
FROM
    flight_test_YMD f
JOIN
    airline ON f.carrier_code = airline.airline_id
WHERE
    year * 10000 + month * 100 + day_of_month
BETWEEN
    20200101
AND
    20200101
AND
    carrier_code IN ('HA', 'YX')
ORDER BY
    departure_delay DESC
FETCH FIRST
    10 ROWS ONLY;


SELECT
    date, carrier_code, airline.name, tail_num, arrival_airport_code, departure_delay
FROM
    flight_test_date f
JOIN
    airline ON f.carrier_code = airline.airline_id
WHERE
    date
BETWEEN
    '2020-01-01'
AND
    '2020-01-01'
AND
    carrier_code IN ('HA', 'YX')
ORDER BY
    departure_delay DESC
FETCH FIRST
    10 ROWS ONLY;     

\echo ' -------- performance without index --------'
SELECT ROUND(total_exec_time::numeric,3) as total_time, calls, ROUND(mean_exec_time::numeric,3) as avg_time, ROUND(min_exec_time::numeric,3) as min_time, ROUND(max_exec_time::numeric,3) as max_time
        FROM pg_stat_statements
        WHERE query like '%%carrier_code%%';

CREATE INDEX idx_flight_1 ON flight (carrier_code);
CREATE INDEX idx_flight_test_YMD_1 ON flight_test_YMD (carrier_code);
CREATE INDEX idx_flight_test_int_1 ON flight_test_int (carrier_code);
CREATE INDEX idx_flight_test_date_1 ON flight_test_date (carrier_code);
CREATE INDEX idx_airline_1 ON airline (airline_id);

SELECT pg_stat_statements_reset();

SELECT
    month, day_of_month, carrier_code, airline.name, tail_num, arrival_airport_code, departure_delay
FROM
    flight
JOIN
    airline ON flight.carrier_code = airline.airline_id
WHERE
(
    CASE
        WHEN month > 10 THEN (month - 10) * 100 + day_of_month
        ELSE (month + 3) * 100 + day_of_month
    END
) BETWEEN
(
    CASE
        WHEN 1 > 10 THEN (1 - 10) * 100 + 1
        ELSE (1 + 3) * 100 + 1
    END
)
AND
(
    CASE
        WHEN 1 > 10 THEN (1 - 10) * 100 + 1
        ELSE (1 + 3) * 100 + 1
    END
)
AND
    carrier_code IN ('HA', 'YX')
ORDER BY
    departure_delay DESC
FETCH FIRST
    10 ROWS ONLY;

SELECT
    ymd, carrier_code, airline.name, tail_num, arrival_airport_code, departure_delay
FROM
    flight_test_int f
JOIN
    airline ON f.carrier_code = airline.airline_id
WHERE
    ymd
BETWEEN
    20200101
AND
    20200101
AND
    carrier_code IN ('HA', 'YX')
ORDER BY
    departure_delay DESC
FETCH FIRST
    10 ROWS ONLY;


SELECT
    month, day_of_month, carrier_code, airline.name, tail_num, arrival_airport_code, departure_delay
FROM
    flight_test_YMD f
JOIN
    airline ON f.carrier_code = airline.airline_id
WHERE
    year * 10000 + month * 100 + day_of_month
BETWEEN
    20200101
AND
    20200101
AND
    carrier_code IN ('HA', 'YX')
ORDER BY
    departure_delay DESC
FETCH FIRST
    10 ROWS ONLY;


SELECT
    date, carrier_code, airline.name, tail_num, arrival_airport_code, departure_delay
FROM
    flight_test_date f
JOIN
    airline ON f.carrier_code = airline.airline_id
WHERE
    date
BETWEEN
    '2020-01-01'
AND
    '2020-01-01'
AND
    carrier_code IN ('HA', 'YX')
ORDER BY
    departure_delay DESC
FETCH FIRST
    10 ROWS ONLY;     

\echo ' -------- performance with index --------'
SELECT ROUND(total_exec_time::numeric,3) as total_time, calls, ROUND(mean_exec_time::numeric,3) as avg_time, ROUND(min_exec_time::numeric,3) as min_time, ROUND(max_exec_time::numeric,3) as max_time
        FROM pg_stat_statements
        WHERE query like '%%carrier_code%%';

DROP EXTENSION pg_stat_statements;

-- psql.exe -U postgres -h localhost -d appdb -W -f C:/projects/cs338-proj/dbproj/test_scripts/test_production_f1.sql > C:/projects/cs338-proj/dbproj/test_scripts/test_production_f1.out

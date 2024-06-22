-- =========
-- Feature 1
-- =========

-- Obtain the carriers for the user to select from
SELECT DISTINCT
    sample_flight.carrier_code AS airline_id,
    airline.name
FROM
    sample_flight
JOIN
    airline ON sample_flight.carrier_code = airline.airline_id
ORDER BY
    airline_id;

-- Obtain the data for the user selected carriers to be shown in a table in the UI

-- Going to hard code variables for the sake of testing
-- Postgres syntax for declaring variables
\set test_from_month 11
\set test_from_day 1
\set test_to_month 1
\set test_to_day 15

SELECT  
    month, day_of_month, carrier_code, airline.name, tail_num, arrival_airport_code, departure_delay
FROM
    sample_flight
JOIN
    airline ON sample_flight.carrier_code = airline.airline_id
WHERE
(
    CASE
        WHEN month > 10 THEN (month - 10) * 100 + day_of_month
        ELSE (month + 3) * 100 + day_of_month
    END
) BETWEEN
(
    CASE
        WHEN :'test_from_month' > 10 THEN (:'test_from_month' - 10) * 100 + :'test_from_day'
        ELSE (:'test_from_month' + 3) * 100 + :'test_from_day'
    END
)
AND
(
    CASE
        WHEN :'test_to_month' > 10 THEN (:'test_to_month' - 10) * 100 + :'test_to_day'
        ELSE (:'test_to_month' + 3) * 100 + :'test_to_day'
    END
)
AND
    carrier_code IN ('B6','DL','AA')
ORDER BY
    departure_delay DESC
FETCH FIRST
    10 ROWS ONLY;

-- =========
-- Feature 2
-- =========

WITH total_count AS (
    SELECT COUNT(*) AS total FROM sample_flight
)
SELECT
    carrier_code,
    COUNT(*) AS c,
    ROUND((COUNT(*) * 100.0 / (SELECT total FROM total_count)), 1) AS percentage
FROM
    sample_flight
GROUP BY
    carrier_code
ORDER BY
    c DESC;

-- =========
-- Feature 3
-- =========

WITH delay_stats AS (
    SELECT
        carrier_code,
        COUNT(*) AS total_flights,
        COUNT(CASE WHEN departure_delay > 0 THEN 1 END) AS num_of_delay,
        MIN(departure_delay) AS min_delay,
        MAX(departure_delay) AS max_delay,
        AVG(departure_delay) AS avg_delay
    FROM
        sample_flight
    GROUP BY
        carrier_code
)
SELECT
    carrier_code,
    total_flights,
    num_of_delay,
    ROUND(100.0 * num_of_delay / total_flights, 2) AS percent_of_delay,
    min_delay,
    max_delay,
    ROUND(avg_delay, 2) AS avg_delay
FROM
    delay_stats;

-- =========
-- Feature 4
-- =========

SELECT
    carrier_code,
    COUNT(CASE WHEN departure_delay <= 0 THEN 1 END) AS "0",
    COUNT(CASE WHEN departure_delay > 0 AND departure_delay <= 10 THEN 1 END) AS "10",
    COUNT(CASE WHEN departure_delay > 10 AND departure_delay <= 30 THEN 1 END) AS "30",
    COUNT(CASE WHEN departure_delay > 30 AND departure_delay <= 60 THEN 1 END) AS "60",
    COUNT(CASE WHEN departure_delay > 60 THEN 1 END) AS "61"
FROM
    sample_flight
WHERE
    carrier_code IN ('B6','DL','AA')
GROUP BY
    carrier_code
ORDER BY
    carrier_code;
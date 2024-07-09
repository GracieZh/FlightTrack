CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
SELECT pg_stat_statements_reset();

\set test_from_month 11
\set test_from_day 1
\set test_to_month 1
\set test_to_day 15

SET work_mem = '64kB';

WITH delay_stats AS (
    SELECT 
        carrier_code,
        COUNT(*) AS total_flights,
        COUNT(CASE WHEN departure_delay > 0 THEN 1 END) AS num_of_delay,
        MIN(departure_delay) AS min_delay,
        MAX(departure_delay) AS max_delay,
        AVG(departure_delay) AS avg_delay
    FROM 
        flight
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



SELECT ROUND(total_exec_time::numeric,3) as total_time, calls, ROUND(mean_exec_time::numeric,3) as avg_time, ROUND(min_exec_time::numeric,3) as min_time, ROUND(max_exec_time::numeric,3) as max_time
        FROM pg_stat_statements
        WHERE query like '%%carrier_code%%';


SELECT pg_stat_statements_reset();


SET work_mem = '4MB';

WITH delay_stats AS (
    SELECT 
        carrier_code,
        COUNT(*) AS total_flights,
        COUNT(CASE WHEN departure_delay > 0 THEN 1 END) AS num_of_delay,
        MIN(departure_delay) AS min_delay,
        MAX(departure_delay) AS max_delay,
        AVG(departure_delay) AS avg_delay
    FROM 
        flight
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




SELECT ROUND(total_exec_time::numeric,3) as total_time, calls, ROUND(mean_exec_time::numeric,3) as avg_time, ROUND(min_exec_time::numeric,3) as min_time, ROUND(max_exec_time::numeric,3) as max_time
        FROM pg_stat_statements
        WHERE query like '%%carrier_code%%';

DROP EXTENSION pg_stat_statements;


-- psql.exe -U postgres -h localhost -d appdb -W -f C:/projects/cs338-proj/dbproj/test_scripts/test_production_f3.sql > C:/projects/cs338-proj/dbproj/test_scripts/test_production_f3.out

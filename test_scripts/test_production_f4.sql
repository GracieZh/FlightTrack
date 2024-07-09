CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

DROP INDEX IF EXISTS idx_flight_1;
DROP INDEX IF EXISTS idx_flight_5;

SELECT pg_stat_statements_reset();

SELECT 
    carrier_code,
    COUNT(CASE WHEN departure_delay <= 0 THEN 1 END) AS "0",
    COUNT(CASE WHEN departure_delay > 0 AND departure_delay <= 10 THEN 1 END) AS "10",
    COUNT(CASE WHEN departure_delay > 10 AND departure_delay <= 30 THEN 1 END) AS "30",
    COUNT(CASE WHEN departure_delay > 30 AND departure_delay <= 60 THEN 1 END) AS "60",
    COUNT(CASE WHEN departure_delay > 60 THEN 1 END) AS "61"
FROM 
    flight
WHERE 
    carrier_code IN ('B6','DL','AA')
GROUP BY 
    carrier_code
ORDER BY 
    carrier_code;




SELECT ROUND(total_exec_time::numeric,3) as total_time, calls, ROUND(mean_exec_time::numeric,3) as avg_time, ROUND(min_exec_time::numeric,3) as min_time, ROUND(max_exec_time::numeric,3) as max_time
        FROM pg_stat_statements
        WHERE query like '%%carrier_code%%';

CREATE INDEX idx_flight_1 ON flight (carrier_code); 
CREATE INDEX idx_flight_5 ON flight (departure_delay); 

SELECT pg_stat_statements_reset();


SELECT 
    carrier_code,
    COUNT(CASE WHEN departure_delay <= 0 THEN 1 END) AS "0",
    COUNT(CASE WHEN departure_delay > 0 AND departure_delay <= 10 THEN 1 END) AS "10",
    COUNT(CASE WHEN departure_delay > 10 AND departure_delay <= 30 THEN 1 END) AS "30",
    COUNT(CASE WHEN departure_delay > 30 AND departure_delay <= 60 THEN 1 END) AS "60",
    COUNT(CASE WHEN departure_delay > 60 THEN 1 END) AS "61"
FROM 
    flight
WHERE 
    carrier_code IN ('B6','DL','AA')
GROUP BY 
    carrier_code
ORDER BY 
    carrier_code;




SELECT ROUND(total_exec_time::numeric,3) as total_time, calls, ROUND(mean_exec_time::numeric,3) as avg_time, ROUND(min_exec_time::numeric,3) as min_time, ROUND(max_exec_time::numeric,3) as max_time
        FROM pg_stat_statements
        WHERE query like '%%carrier_code%%';

DROP EXTENSION pg_stat_statements;


-- psql.exe -U postgres -h localhost -d appdb -W -f C:/projects/cs338-proj/dbproj/test_scripts/test_production_f4.sql > C:/projects/cs338-proj/dbproj/test_scripts/test_production_f4.out

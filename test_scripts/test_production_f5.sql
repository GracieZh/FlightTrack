WITH dest AS (
    SELECT DISTINCT
        a.iso_country cid,
        c.name cname,
        a.iso_region as region,
        SUBSTRING(a.iso_region, 4,10) AS sid
    FROM
        flight f
    JOIN
        airports a
    ON
        f.arrival_airport_code = a.iata_code
    JOIN
        country c
    ON
        a.iso_country = c.a2
    WHERE
        a.iso_country = 'US'
)
SELECT
    cid, cname, region, sid, s.state
FROM
    dest d
LEFT JOIN -- left join b/c there's flights for multiple countries and we only have region data for the US. If we used inner join, we wouldn't be able to select data from non-US countries.
    usstate s
ON
    d.sid = s.code
ORDER BY
    region;


WITH dest AS (
    SELECT DISTINCT
        a.iso_country cid,
        c.name cname,
        a.iso_region as region,
        SUBSTRING(a.iso_region, 4,10) AS sid,
        a.municipality AS city
    FROM
        flight f
    JOIN
        airports a
    ON
        f.arrival_airport_code = a.iata_code
    JOIN
        country c
    ON
        a.iso_country = c.a2
    WHERE
        a.iso_region = 'US-CA'
)
SELECT
    cid, cname, region, sid, s.state, city
FROM
    dest d
LEFT JOIN
    usstate s
ON
    d.sid = s.code
ORDER BY
    city;


WITH dest AS (
    SELECT
        DISTINCT tail_num,
        arrival_airport_code dst,
        a.iso_country cid,
        c.name cname,
        a.iso_region as region,
        SUBSTRING(a.iso_region, 4,10) AS sid,
        municipality AS city,
        day_of_week
    FROM
        flight f
    JOIN
        airports a
    ON
        f.arrival_airport_code = a.iata_code
    JOIN
        country c
    ON
        a.iso_country = c.a2
    WHERE
        a.iso_region = 'US-CA' AND  municipality = 'Ontario'
)
SELECT
    cid, cname, region, sid, s.state, city, tail_num, dst, day_of_week
FROM
    dest d
LEFT JOIN  -- some places don't have state names. we don't want to lose entries
    usstate s
ON
    d.sid = s.code
ORDER BY
    city;

SELECT
    day_of_week as dw,
    count(*) as c
FROM
    flight f
JOIN
    airports a
ON
    f.arrival_airport_code = a.iata_code
WHERE
    a.iso_region = 'US-CA' AND  municipality = 'Ontario'
GROUP BY
    day_of_week;

SELECT
    tail_num,
    arrival_airport_code dst,
    a.name as aname,
    municipality AS city,
    month,
    day_of_month,
    day_of_week
FROM
    flight f
JOIN
    airports a
ON
    f.arrival_airport_code = a.iata_code
WHERE
    tail_num = 'N603JB';

\echo ' -------- performance tuning --------'

---------------
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
------------------
DROP INDEX IF EXISTS idx_airports_1; 
DROP INDEX IF EXISTS idx_airports_2; 
DROP INDEX IF EXISTS idx_airports_3; 
DROP INDEX IF EXISTS idx_country_1; 
DROP INDEX IF EXISTS idx_usstate_1; 

SELECT pg_stat_statements_reset();

SELECT day_of_week as dw, count(*) as c FROM flight f JOIN airports a ON f.arrival_airport_code = a.iata_code
WHERE a.iso_region = 'US-CA' AND  municipality = 'Ontario' GROUP BY day_of_week;

SELECT day_of_week as dw, count(*) as c FROM flight f JOIN airports a ON f.arrival_airport_code = a.iata_code
WHERE a.iso_region = 'US-CA' AND  municipality = 'Ontario' GROUP BY day_of_week;

SELECT day_of_week as dw, count(*) as c FROM flight f JOIN airports a ON f.arrival_airport_code = a.iata_code
WHERE a.iso_region = 'US-CA' AND  municipality = 'Ontario' GROUP BY day_of_week;

SELECT day_of_week as dw, count(*) as c FROM flight f JOIN airports a ON f.arrival_airport_code = a.iata_code
WHERE a.iso_region = 'US-CA' AND  municipality = 'Ontario' GROUP BY day_of_week;

\echo ' -------- performance without index --------'
SELECT ROUND(total_exec_time::numeric,3) as total_time, calls, ROUND(mean_exec_time::numeric,3) as avg_time, ROUND(min_exec_time::numeric,3) as min_time, ROUND(max_exec_time::numeric,3) as max_time
        FROM pg_stat_statements WHERE query like '%%iso_region%%';
----------------
CREATE INDEX idx_airports_1 ON airports (iso_region); 
CREATE INDEX idx_airports_2 ON airports (municipality); 
CREATE INDEX idx_airports_3 ON airports (iata_code); 
CREATE INDEX idx_country_1 ON country (a2); 
CREATE INDEX idx_usstate_1 ON usstate (code); 

SELECT pg_stat_statements_reset();

SELECT day_of_week as dw, count(*) as c FROM flight f JOIN airports a ON f.arrival_airport_code = a.iata_code
WHERE a.iso_region = 'US-CA' AND  municipality = 'Ontario' GROUP BY day_of_week;

SELECT day_of_week as dw, count(*) as c FROM flight f JOIN airports a ON f.arrival_airport_code = a.iata_code
WHERE a.iso_region = 'US-CA' AND  municipality = 'Ontario' GROUP BY day_of_week;

SELECT day_of_week as dw, count(*) as c FROM flight f JOIN airports a ON f.arrival_airport_code = a.iata_code
WHERE a.iso_region = 'US-CA' AND  municipality = 'Ontario' GROUP BY day_of_week;

SELECT day_of_week as dw, count(*) as c FROM flight f JOIN airports a ON f.arrival_airport_code = a.iata_code
WHERE a.iso_region = 'US-CA' AND  municipality = 'Ontario' GROUP BY day_of_week;

\echo ' -------- performance with index --------'
SELECT ROUND(total_exec_time::numeric,3) as total_time, calls, ROUND(mean_exec_time::numeric,3) as avg_time, ROUND(min_exec_time::numeric,3) as min_time, ROUND(max_exec_time::numeric,3) as max_time
        FROM pg_stat_statements WHERE query like '%%iso_region%%';
----------------
DROP EXTENSION pg_stat_statements;

-- psql.exe -U postgres -h localhost -d appdb -W -f C:/projects/cs338-proj/dbproj/test_scripts/test_production_f5.sql > C:/projects/cs338-proj/dbproj/test_scripts/test_production_f5.out

----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
SELECT pg_stat_statements_reset();
----------------------------------------------------------------------------------------------
WITH topvalues AS (
        SELECT user_id, SUM(distance) distance, SUM(fare) fare, COUNT(*) tickets
        FROM flight f 
        JOIN boarding_tickets b on f.id = b.flight_id 
        JOIN passengers p on b.ticket_id = p.ticket_id 
        GROUP BY user_id) 
    SELECT fname, lname, ssn, tickets, fare, distance 
    FROM topvalues 
    JOIN users on user_id = ssn
    ORDER BY tickets DESC LIMIT 10;

SELECT fname, lname, ssn, count(*) tickets, sum(fare) fare, sum(distance) distance
    FROM flight f 
    JOIN boarding_tickets b on f.id = b.flight_id 
    JOIN passengers p on b.ticket_id = p.ticket_id 
    JOIN users on user_id = ssn
    GROUP BY fname, lname, ssn
    ORDER BY tickets DESC LIMIT 10;
----------------------------------------------------------------------------------------------
WITH topvalues AS (
        SELECT user_id, SUM(distance) distance, SUM(fare) fare, COUNT(*) tickets
        FROM flight f 
        JOIN boarding_tickets b on f.id = b.flight_id 
        JOIN passengers p on b.ticket_id = p.ticket_id 
        GROUP BY user_id) 
    SELECT fname, lname, ssn, tickets, fare, distance 
    FROM topvalues 
    JOIN users on user_id = ssn
    ORDER BY tickets DESC LIMIT 10;

SELECT fname, lname, ssn, count(*) tickets, sum(fare) fare, sum(distance) distance
    FROM flight f 
    JOIN boarding_tickets b on f.id = b.flight_id 
    JOIN passengers p on b.ticket_id = p.ticket_id 
    JOIN users on user_id = ssn
    GROUP BY fname, lname, ssn
    ORDER BY tickets DESC LIMIT 10;
----------------------------------------------------------------------------------------------
WITH topvalues AS (
        SELECT user_id, SUM(distance) distance, SUM(fare) fare, COUNT(*) tickets
        FROM flight f 
        JOIN boarding_tickets b on f.id = b.flight_id 
        JOIN passengers p on b.ticket_id = p.ticket_id 
        GROUP BY user_id) 
    SELECT fname, lname, ssn, tickets, fare, distance 
    FROM topvalues 
    JOIN users on user_id = ssn
    ORDER BY tickets DESC LIMIT 10;

SELECT fname, lname, ssn, count(*) tickets, sum(fare) fare, sum(distance) distance
    FROM flight f 
    JOIN boarding_tickets b on f.id = b.flight_id 
    JOIN passengers p on b.ticket_id = p.ticket_id 
    JOIN users on user_id = ssn
    GROUP BY fname, lname, ssn
    ORDER BY tickets DESC LIMIT 10;
----------------------------------------------------------------------------------------------
WITH topvalues AS (
        SELECT user_id, SUM(distance) distance, SUM(fare) fare, COUNT(*) tickets
        FROM flight f 
        JOIN boarding_tickets b on f.id = b.flight_id 
        JOIN passengers p on b.ticket_id = p.ticket_id 
        GROUP BY user_id) 
    SELECT fname, lname, ssn, tickets, fare, distance 
    FROM topvalues 
    JOIN users on user_id = ssn
    ORDER BY tickets DESC LIMIT 10;

SELECT fname, lname, ssn, count(*) tickets, sum(fare) fare, sum(distance) distance
    FROM flight f 
    JOIN boarding_tickets b on f.id = b.flight_id 
    JOIN passengers p on b.ticket_id = p.ticket_id 
    JOIN users on user_id = ssn
    GROUP BY fname, lname, ssn
    ORDER BY tickets DESC LIMIT 10;
----------------------------------------------------------------------------------------------
WITH topvalues AS (
        SELECT user_id, SUM(distance) distance, SUM(fare) fare, COUNT(*) tickets
        FROM flight f 
        JOIN boarding_tickets b on f.id = b.flight_id 
        JOIN passengers p on b.ticket_id = p.ticket_id 
        GROUP BY user_id) 
    SELECT fname, lname, ssn, tickets, fare, distance 
    FROM topvalues 
    JOIN users on user_id = ssn
    ORDER BY tickets DESC LIMIT 10;

SELECT fname, lname, ssn, count(*) tickets, sum(fare) fare, sum(distance) distance
    FROM flight f 
    JOIN boarding_tickets b on f.id = b.flight_id 
    JOIN passengers p on b.ticket_id = p.ticket_id 
    JOIN users on user_id = ssn
    GROUP BY fname, lname, ssn
    ORDER BY tickets DESC LIMIT 10;
----------------------------------------------------------------------------------------------

SELECT 
        ROUND(total_exec_time::numeric,3) as total_time, 
        calls, 
        ROUND(mean_exec_time::numeric,3) as avg_time, 
        ROUND(min_exec_time::numeric,3) as min_time, 
        ROUND(max_exec_time::numeric,3) as max_time,
        query
    FROM pg_stat_statements
    WHERE query like '%%tickets%%';

DROP EXTENSION pg_stat_statements;

-- .\psql.exe -U postgres -h localhost -d appdb -W -f C:/projects/cs338-proj/dbproj/test_scripts/test_production_ff1.sql > C:/projects/cs338-proj/dbproj/test_scripts/test_production_ff1.out

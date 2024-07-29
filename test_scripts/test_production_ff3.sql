DROP VIEW IF EXISTS passenger_travel_history;

CREATE VIEW passenger_travel_history AS
        SELECT user_id, flight_id, fname, lname, tail_num, arrival_airport_code, municipality, iso_region
        FROM passengers p
        JOIN boarding_tickets b ON p.ticket_id = b.ticket_id
        JOIN users u ON u.ssn = p.user_id
        JOIN flight f ON f.id = b.flight_id
        JOIN airports a ON a.iata_code = f.arrival_airport_code;

-------------------- example name file a passenger --------------------
\set fname Justice
\set lname PRINCE
-------------------- please replace the above name with a one from your own database

-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
SELECT pg_stat_statements_reset();
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
SELECT user_id, flight_id, fname, lname, tail_num, arrival_airport_code, municipality, iso_region
FROM passenger_travel_history p WHERE fname=:'fname' and lname=:'lname' ORDER BY flight_id;

SELECT user_id, flight_id, fname, lname, tail_num, arrival_airport_code, municipality, iso_region
FROM passengers p JOIN boarding_tickets b ON p.ticket_id = b.ticket_id JOIN users u ON u.ssn = p.user_id 
JOIN flight f ON f.id = b.flight_id JOIN airports a ON a.iata_code = f.arrival_airport_code
WHERE fname=:'fname' and lname=:'lname' ORDER BY flight_id;
-----------------------------------------------------------------------------------------------------------
SELECT user_id, flight_id, fname, lname, tail_num, arrival_airport_code, municipality, iso_region
FROM passenger_travel_history p WHERE fname=:'fname' and lname=:'lname' ORDER BY flight_id;

SELECT user_id, flight_id, fname, lname, tail_num, arrival_airport_code, municipality, iso_region
FROM passengers p JOIN boarding_tickets b ON p.ticket_id = b.ticket_id JOIN users u ON u.ssn = p.user_id 
JOIN flight f ON f.id = b.flight_id JOIN airports a ON a.iata_code = f.arrival_airport_code
WHERE fname=:'fname' and lname=:'lname' ORDER BY flight_id;
-----------------------------------------------------------------------------------------------------------
SELECT user_id, flight_id, fname, lname, tail_num, arrival_airport_code, municipality, iso_region
FROM passenger_travel_history p WHERE fname=:'fname' and lname=:'lname' ORDER BY flight_id;

SELECT user_id, flight_id, fname, lname, tail_num, arrival_airport_code, municipality, iso_region
FROM passengers p JOIN boarding_tickets b ON p.ticket_id = b.ticket_id JOIN users u ON u.ssn = p.user_id 
JOIN flight f ON f.id = b.flight_id JOIN airports a ON a.iata_code = f.arrival_airport_code
WHERE fname=:'fname' and lname=:'lname' ORDER BY flight_id;
-----------------------------------------------------------------------------------------------------------
SELECT user_id, flight_id, fname, lname, tail_num, arrival_airport_code, municipality, iso_region
FROM passenger_travel_history p WHERE fname=:'fname' and lname=:'lname' ORDER BY flight_id;

SELECT user_id, flight_id, fname, lname, tail_num, arrival_airport_code, municipality, iso_region
FROM passengers p JOIN boarding_tickets b ON p.ticket_id = b.ticket_id JOIN users u ON u.ssn = p.user_id 
JOIN flight f ON f.id = b.flight_id JOIN airports a ON a.iata_code = f.arrival_airport_code
WHERE fname=:'fname' and lname=:'lname' ORDER BY flight_id;
-----------------------------------------------------------------------------------------------------------
SELECT user_id, flight_id, fname, lname, tail_num, arrival_airport_code, municipality, iso_region
FROM passenger_travel_history p WHERE fname=:'fname' and lname=:'lname' ORDER BY flight_id;

SELECT user_id, flight_id, fname, lname, tail_num, arrival_airport_code, municipality, iso_region
FROM passengers p JOIN boarding_tickets b ON p.ticket_id = b.ticket_id JOIN users u ON u.ssn = p.user_id 
JOIN flight f ON f.id = b.flight_id JOIN airports a ON a.iata_code = f.arrival_airport_code
WHERE fname=:'fname' and lname=:'lname' ORDER BY flight_id;


-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
SELECT ROUND(total_exec_time::numeric,3) as total_time, calls, ROUND(mean_exec_time::numeric,3) as avg_time, 
        ROUND(min_exec_time::numeric,3) as min_time, ROUND(max_exec_time::numeric,3) as max_time, query
        FROM pg_stat_statements WHERE query like '%%flight%%';
DROP EXTENSION pg_stat_statements;

-- .\psql.exe -U postgres -h localhost -d appdb -W -f C:/projects/cs338-proj/dbproj/test_scripts/test_production_ff3.sql > C:/projects/cs338-proj/dbproj/test_scripts/test_production_ff3.out

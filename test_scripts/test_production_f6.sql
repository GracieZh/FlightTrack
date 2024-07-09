\echo ' -------- test generate users ----------'

DROP SEQUENCE IF EXISTS pk_sequence_for_users;
CREATE SEQUENCE pk_sequence_for_users START 111111111 INCREMENT BY 567;
DROP TABLE IF EXISTS users_gen;
CREATE TABLE users_gen (
    ssn INTEGER PRIMARY KEY,
    fname VARCHAR(50),
    lname VARCHAR(50),
    bdate VARCHAR(11),
    email VARCHAR(100),
    address VARCHAR(50),
    gender VARCHAR(1)
);

CREATE TRIGGER before_insert_trigger
BEFORE INSERT ON users_gen
FOR EACH ROW
EXECUTE FUNCTION insert_with_reverse_pk();

SELECT count(*) from users_gen;

CALL generate_random_users(1000);

SELECT count(*) from users_gen;
SELECT * from users_gen ORDER BY random() LIMIT 10;

\echo ' -------- test generate tickets ----------'

DROP TABLE IF EXISTS flight_crew_log;
DROP TABLE IF EXISTS passengers;
DROP TABLE IF EXISTS boarding_tickets;

CREATE TABLE IF NOT EXISTS boarding_tickets (
   ticket_id SERIAL PRIMARY KEY,
   flight_id INTEGER,
   seat_no INTEGER,
   fare DECIMAL(9,2),
   class TEXT
);

SELECT count(*) from boarding_tickets;
SELECT generate_tickets(100,10,5,3,2);
SELECT count(*) from boarding_tickets;
SELECT * from boarding_tickets ORDER BY random() LIMIT 10;

\echo ' -------- test assign crew to flight ----------'

CREATE TABLE IF NOT EXISTS flight_crew_log (
    tail_num VARCHAR(7),
    user_id INTEGER,
    FOREIGN KEY (user_id) REFERENCES users(ssn) ON DELETE CASCADE,
    PRIMARY KEY (tail_num, user_id)
);

SELECT count(*) from flight_crew_log;
SELECT assign_crew_to_flights(100,3);
SELECT count(*) from flight_crew_log;
SELECT * from flight_crew_log ORDER BY random() LIMIT 10;

\echo ' -------- test assign tickets to passengers ----------'

CREATE TABLE IF NOT EXISTS passengers (
    ticket_id INTEGER PRIMARY KEY,
    user_id INTEGER,
    FOREIGN KEY (user_id) REFERENCES users(ssn) ON DELETE CASCADE,
    FOREIGN KEY (ticket_id) REFERENCES boarding_tickets(ticket_id) ON DELETE CASCADE
);


SELECT count(*) from passengers;
SELECT assign_tickets(90);
SELECT count(*) from passengers;
SELECT * from passengers ORDER BY random() LIMIT 10;

\echo ' -------- performance turning assign tickets to passengers ----------'

CREATE OR REPLACE FUNCTION assign_tickets_no_index(pt INTEGER)
RETURNS INTEGER AS $$
DECLARE
    ticket RECORD;
    user_ids INTEGER[];
    ticket_ids INTEGER[];
    random_index INTEGER;
    number_of_passengers INTEGER;
    total_tickets INTEGER;
    limit_tickets INTEGER;
    flightid INTEGER;
    max_attempts INTEGER;
    successful_inserts INTEGER;
BEGIN
    -- Calculate the total number of tickets in the boarding_tickets table
    SELECT count(*) INTO total_tickets FROM boarding_tickets;

    -- Calculate the limit based on the percentage pt
    limit_tickets := (total_tickets * pt) / 100;

    -- Select random pt percentage of ticket IDs
    SELECT array_agg(ticket_id) INTO ticket_ids
    FROM (SELECT ticket_id FROM boarding_tickets ORDER BY random() LIMIT limit_tickets);

    -- Calculate the number of passengers as 60% of the number of selected tickets
    -- passenger number < ticket number allows a passenger to have more chance to have multiple tickets 
    --   for different flights
    number_of_passengers := limit_tickets * 6 / 10;
    IF number_of_passengers < 1 THEN
        number_of_passengers := 1;
    END IF;

    -- Select user IDs excluding those already in flight_crew_log
    SELECT array_agg(ssn) INTO user_ids
    FROM (
        SELECT ssn FROM users WHERE ssn NOT IN (SELECT user_id FROM flight_crew_log)
        ORDER BY random() LIMIT number_of_passengers
    );

    -- Create a temporary table to store assigned passengers
    CREATE TEMP TABLE temp_passengers (ticket_id INTEGER, user_id INTEGER, flight_id INTEGER);
    -- CREATE INDEX idx_temp_passengers_user_id ON temp_passengers (user_id);     ------------ remove this index for perfomance tuning
    -- CREATE INDEX idx_temp_passengers_flight_id ON temp_passengers (flight_id); ------------ remove this index for perfomance tuning   

    -- Loop through each ticket ID and assign a random user ID
    FOR idx IN 1..array_length(ticket_ids, 1) LOOP
        SELECT flight_id INTO flightid FROM boarding_tickets WHERE ticket_id = ticket_ids[idx];

        -- A passenger can only have one ticket per flight
        FOR attempt IN 1..array_length(user_ids, 1) LOOP
            random_index := floor(random() * array_length(user_ids, 1)) + 1;
            -- Check if a passenger has a ticket for a flight already; if not, then insert
            IF NOT EXISTS (SELECT 1 FROM temp_passengers WHERE user_id = user_ids[random_index] AND flight_id = flightid) THEN
                INSERT INTO temp_passengers (ticket_id, user_id, flight_id)
                VALUES (ticket_ids[idx], user_ids[random_index], flightid);
                EXIT;
            END IF;
        END LOOP;
    END LOOP;

    -- Insert from temporary table into final passengers table
    INSERT INTO passengers (ticket_id, user_id) SELECT ticket_id, user_id FROM temp_passengers;

    -- Count the number of rows inserted into temp_passengers
    SELECT COUNT(*) INTO successful_inserts FROM temp_passengers;

    -- Drop temporary table
    DROP TABLE temp_passengers;

    -- Return the number of successful inserts
    RETURN successful_inserts;
END;
$$ LANGUAGE plpgsql;
---------------------------------------

CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
SELECT pg_stat_statements_reset();
DO $$
BEGIN
    FOR i IN 1..10 LOOP
        DELETE FROM passengers; 
        PERFORM assign_tickets(90);
    END LOOP;
END $$;
DO $$
BEGIN
    FOR i IN 1..10 LOOP
        DELETE FROM passengers; 
        PERFORM assign_tickets_no_index(90);
    END LOOP;
END $$;

SELECT ROUND(total_exec_time::numeric,3) as total_time, calls, ROUND(mean_exec_time::numeric,3) as avg_time, ROUND(min_exec_time::numeric,3) as min_time, ROUND(max_exec_time::numeric,3) as max_time, query
        FROM pg_stat_statements WHERE query like '%assign_tickets%';

DROP EXTENSION pg_stat_statements;


-- psql.exe -U postgres -h localhost -d appdb -W -f C:/projects/cs338-proj/dbproj/test_scripts/test_production_f6.sql > C:/projects/cs338-proj/dbproj/test_scripts/test_production_f6.out

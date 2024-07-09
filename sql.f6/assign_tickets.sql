\echo '-------- assign tickets for feature 6 --------';

CREATE OR REPLACE FUNCTION assign_tickets(pt INTEGER)
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
    CREATE INDEX idx_temp_passengers_user_id ON temp_passengers (user_id);
    CREATE INDEX idx_temp_passengers_flight_id ON temp_passengers (flight_id);    

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


-- \i C:/projects/cs338-proj/dbproj/sql.f6/assign_tickets.sql

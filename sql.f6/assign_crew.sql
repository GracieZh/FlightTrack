CREATE OR REPLACE FUNCTION assign_crew_to_flights(nf INTEGER, nu INTEGER)
RETURNS INTEGER AS $$
DECLARE
    flight RECORD;
    user_ids INTEGER[];
    tail_numbers TEXT[];
    i INTEGER;
    j INTEGER;
BEGIN
    SELECT array_agg(DISTINCT tail_num)
    INTO tail_numbers
    FROM flight 
    WHERE id in (
        SELECT DISTINCT flight_id
        FROM boarding_tickets
    ) LIMIT nf;

    SELECT array_agg(ssn)
    INTO user_ids
    FROM (
        SELECT ssn FROM users ORDER BY random() LIMIT (nu * nf)
    );    
    
    -- Assign nu users to each selected flight
    i := 1;
    FOR idx IN 1..array_length(tail_numbers, 1) LOOP
        FOR j IN 1..nu LOOP
            -- Insert into flight_crew_log
            INSERT INTO flight_crew_log (tail_num, user_id)
            VALUES (tail_numbers[idx], user_ids[i]);
            i := i + 1;

            IF i > array_length(user_ids, 1) THEN
                EXIT;
            END IF;    
        END LOOP;
        IF i > array_length(user_ids, 1) THEN
            EXIT;
        END IF;    
    END LOOP;
    return i - 1;
END;
$$ LANGUAGE plpgsql;

-- \i C:/projects/cs338-proj/dbproj/sql.f6/assign_crew.sql
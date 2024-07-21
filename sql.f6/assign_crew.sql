\echo '-------- assign crew for feature 6 --------';

CREATE OR REPLACE FUNCTION assign_crew_to_flights(nf INTEGER, ncc INTEGER, ncf INTEGER, ncp INTEGER, nca INTEGER)
RETURNS INTEGER AS $$
DECLARE
    flight RECORD;
    user_ids INTEGER[];
    tail_numbers TEXT[];
    ncm INTEGER;
    i INTEGER;
    j INTEGER;
    user_count INTEGER;
BEGIN
    SELECT array_agg(DISTINCT tail_num)
    INTO tail_numbers
    FROM flight 
    WHERE id in (
        SELECT DISTINCT flight_id
        FROM boarding_tickets
    ) LIMIT nf;

    ncm := ncc + ncf + ncp + nca;

    SELECT array_agg(ssn)
    INTO user_ids
    FROM (
        SELECT ssn FROM users ORDER BY random() LIMIT (ncm * nf)
    );    
    
    user_count := array_length(user_ids, 1);

    -- Assign nu users to each selected flight
    i := 1;
    FOR idx IN 1..array_length(tail_numbers, 1) LOOP
        FOR j IN 1..ncm LOOP
            -- Insert into flight_crew_log
            INSERT INTO flight_crew_log (tail_num, user_id)
            VALUES (tail_numbers[idx], user_ids[i]);

            IF j < 1 + ncc THEN
                INSERT INTO captain (ssn) VALUES (user_ids[i]);
            ELSEIF j < 1 + ncc + ncf THEN
                INSERT INTO first_officer (ssn) VALUES (user_ids[i]);
            END IF;

            IF j < 1 + ncc + ncf + ncp THEN
                INSERT INTO pilot (ssn) VALUES (user_ids[i]);
            ELSE
                INSERT INTO attendant (ssn) VALUES (user_ids[i]);
            END IF;

            i := i + 1;

            IF i > user_count THEN
                EXIT;
            END IF;
        END LOOP;
        IF i > user_count THEN
            EXIT;
        END IF;    
    END LOOP;
    return i - 1;
END;
$$ LANGUAGE plpgsql;

-- \i C:/projects/cs338-proj/dbproj/sql.f6/assign_crew.sql
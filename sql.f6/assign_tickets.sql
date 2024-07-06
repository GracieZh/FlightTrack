
CREATE OR REPLACE FUNCTION assign_tickets(pt INTEGER)
RETURNS INTEGER AS $$
DECLARE
    ticket RECORD;
    user_ids INTEGER[];
    ticket_ids INTEGER[];
    i INTEGER;
    j INTEGER;
BEGIN
    SELECT array_agg(DISTINCT ticket_id)
    INTO ticket_ids
    FROM boarding_tickets;

    SELECT array_agg(ssn)
    INTO user_ids
    FROM (
        SELECT ssn FROM users WHERE ssn not in (
            SELECT user_id FROM flight_crew_log -- passenger cannot be part of flight crew
        )
        ORDER BY random() LIMIT (array_length(ticket_ids, 1)) -- this number of users will be enough to assign to the tickets available
    );    
    
    i := 1;
    FOR idx IN 1..array_length(ticket_ids, 1) LOOP
        INSERT INTO passengers (ticket_id, user_id)
        VALUES (ticket_ids[idx], user_ids[i]);
        i := i + 1;
        IF i > array_length(user_ids, 1) THEN
            EXIT;
        END IF;    
    END LOOP;
    return i - 1; -- number of tickets assigned to passengers
END;
$$ LANGUAGE plpgsql;


-- \i C:/projects/cs338-proj/dbproj/sql.f6/assign_tickets.sql

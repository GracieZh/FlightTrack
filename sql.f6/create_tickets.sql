-- Drop the tickets table if exists
DROP TABLE IF EXISTS boarding_tickets;

-- Create the tickets table if not exists
CREATE TABLE IF NOT EXISTS boarding_tickets (
    ticket_id SERIAL PRIMARY KEY,
    flight_id INTEGER,
    seat_no INTEGER,
    class TEXT
);

-- Create a function to generate tickets
CREATE OR REPLACE FUNCTION generate_tickets(
    number_of_flights INTEGER,
    n1 INTEGER, -- Number of economy tickets to generate per flight
    n2 INTEGER, -- Number of premium economy tickets to generate per flight
    n3 INTEGER, -- Number of business class tickets to generate per flight
    n4 INTEGER  -- Number of first class tickets to generate per flight
    )
RETURNS INTEGER AS $$
DECLARE
    rec RECORD;
BEGIN
    -- Loop through each flight
    FOR rec IN SELECT id FROM flight LIMIT number_of_flights LOOP
        -- Generate economy tickets
        FOR i IN 1..n1 LOOP
            INSERT INTO boarding_tickets (flight_id, seat_no, class)
            VALUES (rec.id, i+n2+n3+n4, 'economy');
        END LOOP;
        
        -- Generate premium economy tickets
        FOR i IN 1..n2 LOOP
            INSERT INTO boarding_tickets (flight_id, seat_no, class)
            VALUES (rec.id, i+n3+n4, 'premium economy');
        END LOOP;
        
        -- Generate business class tickets
        FOR i IN 1..n3 LOOP
            INSERT INTO boarding_tickets (flight_id, seat_no, class)
            VALUES (rec.id, i+n4, 'business');
        END LOOP;
        
        -- Generate first class tickets
        FOR i IN 1..n4 LOOP
            INSERT INTO boarding_tickets (flight_id, seat_no, class)
            VALUES (rec.id, i, 'first class');
        END LOOP;
    END LOOP;
    RETURN number_of_flights * (n1+n2+n3+n4);
END;
$$ LANGUAGE plpgsql;

-- \i C:/projects/cs338-proj/dbproj/sql.f6/create_tickets.sql
-- \df
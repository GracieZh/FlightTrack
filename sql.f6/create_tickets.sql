-- Drop the tickets table if exists
DROP TABLE IF EXISTS boarding_tickets;

-- Create the tickets table if not exists
CREATE TABLE IF NOT EXISTS boarding_tickets (
    ticket_id SERIAL PRIMARY KEY,
    flight_id INTEGER,
    seat_no INTEGER,
    fare DECIMAL(9,2),
    class TEXT
);

-- Function to generate random fare
CREATE OR REPLACE FUNCTION generate_random_fare(distance INTEGER, flight_class TEXT)
RETURNS REAL AS $$
DECLARE
    base_price_per_km REAL := 0.1;
    class_multiplier REAL;
    random_factor REAL := (0.85 + random() * 0.3); -- Random factor between 0.85 and 1.15
    base_price REAL;
    final_price REAL;
BEGIN
    CASE flight_class
        WHEN 'economy' THEN class_multiplier := 1.0;
        WHEN 'premium economy' THEN class_multiplier := 1.5;
        WHEN 'business' THEN class_multiplier := 2.5;
        WHEN 'first class' THEN class_multiplier := 4.0;
        ELSE RAISE EXCEPTION 'Invalid flight class';
    END CASE;
    
    base_price := distance * base_price_per_km;
    final_price := base_price * class_multiplier * random_factor;
    
    RETURN round(final_price::numeric, 2)::real;
END;
$$ LANGUAGE plpgsql;

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
    class TEXT;
BEGIN
    -- Loop through each flight
    FOR rec IN SELECT id, distance FROM flight LIMIT number_of_flights LOOP
        -- Generate economy tickets
        class = 'economy';
        FOR i IN 1..n1 LOOP
            INSERT INTO boarding_tickets (flight_id, seat_no, class, fare)
            VALUES (rec.id, i+n2+n3+n4, class, generate_random_fare(rec.distance, class));
        END LOOP;
        
        -- Generate premium economy tickets
        class = 'premium economy';
        FOR i IN 1..n2 LOOP
            INSERT INTO boarding_tickets (flight_id, seat_no, class, fare)
            VALUES (rec.id, i+n3+n4, class, generate_random_fare(rec.distance, class));
        END LOOP;
        
        -- Generate business class tickets
        class = 'business';
        FOR i IN 1..n3 LOOP
            INSERT INTO boarding_tickets (flight_id, seat_no, class, fare)
            VALUES (rec.id, i+n4, class, generate_random_fare(rec.distance, class));
        END LOOP;
        
        -- Generate first class tickets
        class = 'first class';
        FOR i IN 1..n4 LOOP
            INSERT INTO boarding_tickets (flight_id, seat_no, class, fare)
            VALUES (rec.id, i, class, generate_random_fare(rec.distance, class));
        END LOOP;
    END LOOP;
    RETURN number_of_flights * (n1+n2+n3+n4);
END;
$$ LANGUAGE plpgsql;

-- \i C:/projects/cs338-proj/dbproj/sql.f6/create_tickets.sql
-- \df
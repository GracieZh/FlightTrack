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

CREATE OR REPLACE FUNCTION insert_with_reverse_pk()
RETURNS TRIGGER AS $$
DECLARE
    nextv INTEGER;
BEGIN
    nextv := CAST(nextval('pk_sequence_for_users') AS INTEGER);
    IF nextv % 10 = 0 THEN
        nextv := CAST(nextval('pk_sequence_for_users') AS INTEGER);
    END IF;
    NEW.ssn := CAST(
        CONCAT(
            SUBSTRING(CAST(nextv AS VARCHAR) FROM 9 FOR 1),
            SUBSTRING(CAST(nextv AS VARCHAR) FROM 7 FOR 1),
            SUBSTRING(CAST(nextv AS VARCHAR) FROM 5 FOR 1),
            SUBSTRING(CAST(nextv AS VARCHAR) FROM 3 FOR 1),
            SUBSTRING(CAST(nextv AS VARCHAR) FROM 1 FOR 1),
            SUBSTRING(CAST(nextv AS VARCHAR) FROM 2 FOR 1),
            SUBSTRING(CAST(nextv AS VARCHAR) FROM 4 FOR 1),
            SUBSTRING(CAST(nextv AS VARCHAR) FROM 6 FOR 1),
            SUBSTRING(CAST(nextv AS VARCHAR) FROM 8 FOR 1)
        ) AS INTEGER);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_trigger
BEFORE INSERT ON users_gen
FOR EACH ROW
EXECUTE FUNCTION insert_with_reverse_pk();

CREATE OR REPLACE PROCEDURE generate_random_users(nu INT)
LANGUAGE plpgsql AS $$
DECLARE
    name_count INT;
    street_count INT;
    i INT;
    random_boy INT;
    random_girl INT;
    random_last INT;
    random_address INT;
    first_name TEXT;
    last_name TEXT;
    gender TEXT;
    street_ TEXT;
    address TEXT;
    dob DATE;
    email TEXT;
    num INT;
BEGIN
    SELECT COUNT(*) INTO name_count FROM names;
    SELECT COUNT(*) INTO street_count FROM streets;

    FOR ii IN 1..nu LOOP

        -- Randomly select gender
        IF random() < 0.5 THEN
            -- Male
            gender := 'M';
            random_boy := floor(random() * name_count);
            SELECT boy INTO first_name FROM names OFFSET random_boy LIMIT 1;
        ELSE
            -- Female
            gender := 'F';
            random_girl := floor(random() * name_count);
            SELECT girl INTO first_name FROM names OFFSET random_girl LIMIT 1;
        END IF;

        -- Randomly select last name and address

        random_last := floor(random() * name_count);
        SELECT last INTO last_name FROM names OFFSET random_last LIMIT 1;

        random_address := floor(random() * street_count);
        SELECT street INTO street_ FROM streets OFFSET random_address LIMIT 1;

        email := first_name || '.' || last_name || '@cs338.uw';

        dob := (DATE '1960-01-01' + (random() * (DATE '2004-01-01' - DATE '1960-01-01'))::int);

        num := ((random() * 1000 + 1)::int);
        address = CAST(num as VARCHAR) || ' ' ||street_;

        -- Insert the generated user record into the users_gen table
        INSERT INTO users_gen ( fname, lname, bdate, email, address, gender)
        VALUES ( first_name, last_name, dob, email, address, gender);
    END LOOP;

END;
$$;

-- CALL generate_random_users(100);

-- \i C:/projects/cs338-proj/dbproj/sql.f6/create_users.sql
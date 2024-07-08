-- Connect to the postgres database to run this:
-- psql -U your_username -d postgres

\set ON_ERROR_STOP on

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_database WHERE datname = 'appdb') THEN
        IF EXISTS (SELECT 1 FROM pg_database WHERE datname = 'appdb_saved') THEN
            RAISE EXCEPTION 'Both appdb and appdb_saved exist, quitting...';
            RETURN;
        ELSE
            EXECUTE 'ALTER DATABASE appdb RENAME TO appdb_saved;';
        END IF;
    END IF;
END $$;

-- Now create the new database separately.
-- \c to switch to the new database after creation.
CREATE DATABASE appdb;

-- \i C:/projects/cs338-proj/dbproj/create_database.sql
\echo '-------- set names for feature 6 --------';

-- Drop the table streets
DROP TABLE IF EXISTS streets;

-- Create the table streets
CREATE TABLE IF NOT EXISTS streets (
    street TEXT
);

-- Import data from CSV file into the table streets
COPY streets (street)
FROM 'C:/projects/cs338-proj/dbproj/datasets/address.txt'
WITH (FORMAT csv, HEADER, ENCODING 'UTF8');

-- Drop the table names
DROP TABLE IF EXISTS names;

-- Create the table names
CREATE TABLE IF NOT EXISTS names (
    boy TEXT,
    girl TEXT,
    last TEXT
);

-- Create a temporary table for each CSV file
CREATE TEMP TABLE temp_boys (
    boy TEXT
);

CREATE TEMP TABLE temp_girls (
    girl TEXT
);

CREATE TEMP TABLE temp_last (
    last TEXT
);

-- Import data from each CSV file into the corresponding temporary table
COPY temp_boys (boy)
FROM 'C:/projects/cs338-proj/dbproj/datasets/top1000boynames.txt'
WITH (FORMAT csv, HEADER, ENCODING 'UTF8');

COPY temp_girls (girl)
FROM 'C:/projects/cs338-proj/dbproj/datasets/top1000girlnames.txt'
WITH (FORMAT csv, HEADER, ENCODING 'UTF8');

COPY temp_last (last)
FROM 'C:/projects/cs338-proj/dbproj/datasets/top1000lastnames.txt'
WITH (FORMAT csv, HEADER, ENCODING 'UTF8');

-- Insert data from the temporary tables into the target table
-- Assuming the target table 'names' has columns: boy, girl, last
INSERT INTO names (boy, girl, last)
SELECT temp_boys.boy, temp_girls.girl, temp_last.last
FROM temp_boys, temp_girls, temp_last
WHERE temp_boys.ctid = temp_girls.ctid AND temp_girls.ctid = temp_last.ctid;

-- Drop the temporary tables
DROP TABLE temp_boys;
DROP TABLE temp_girls;
DROP TABLE temp_last;


-- \i C:/projects/cs338-proj/dbproj/sql.f6/setup_names.sql

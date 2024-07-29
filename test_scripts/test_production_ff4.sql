DROP VIEW IF EXISTS crew_with_title;

CREATE VIEW crew_with_title AS SELECT tail_num, t.ssn, title, fname, lname
        FROM (
                SELECT  tail_num,  ssn,  'captain' AS title FROM  captain JOIN  flight_crew_log ON ssn = user_id
                UNION
                SELECT  tail_num,  ssn,  'first officer' AS title FROM  first_officer JOIN  flight_crew_log ON ssn = user_id
                UNION
                SELECT  tail_num,  user_id,  'pilot' AS title FROM  pilot JOIN  flight_crew_log ON ssn = user_id
                        WHERE  ssn NOT IN (SELECT DISTINCT ssn FROM captain) AND ssn NOT IN (SELECT DISTINCT ssn FROM first_officer)
                UNION
                SELECT  tail_num,  ssn,  'attendant' AS title FROM  attendant JOIN  flight_crew_log ON ssn = user_id
        ) as t
        JOIN ( SELECT ssn, fname, lname FROM users ) as u ON t.ssn = u.ssn;

-------------------- example name file a crew member --------------------
\set fname Scarlett
\set lname PAGE
-------------------- please replace the above name with a one from your own database

--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
SELECT pg_stat_statements_reset();
--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------
SELECT ssn, fname, lname, title, tail_num FROM crew_with_title
    WHERE tail_num IN ( SELECT tail_num FROM flight_crew_log WHERE user_id IN ( 
        SELECT ssn FROM users WHERE fname=:'fname' AND lname=:'lname' ) LIMIT 1) ORDER BY title, lname, fname;

WITH crew AS (
        SELECT tail_num, user_id FROM flight_crew_log WHERE tail_num IN (
            SELECT tail_num FROM flight_crew_log 
            WHERE user_id IN ( 
                SELECT ssn FROM users WHERE fname=:'fname' AND lname=:'lname' ) LIMIT 1)),
    captain_ AS (SELECT ssn, 'captain' AS title FROM captain WHERE ssn IN (SELECT user_id FROM crew)),
    firstofficer_ AS ( SELECT ssn, 'first_officer' AS title FROM first_officer WHERE ssn IN (SELECT user_id FROM crew)),
    attendant_ AS (SELECT ssn, 'attendant' AS title FROM attendant WHERE ssn IN (SELECT user_id FROM crew)),
    pilot_ AS (SELECT ssn, 'pilot' AS title FROM pilot WHERE ssn IN (SELECT user_id FROM crew) 
        AND ssn NOT IN (SELECT ssn FROM captain) AND ssn NOT IN (SELECT ssn FROM first_officer)),
    crewwithtitle AS (
        SELECT ssn, title FROM captain_ UNION SELECT ssn, title FROM firstofficer_ 
        UNION SELECT ssn, title FROM pilot_ UNION SELECT ssn, title FROM attendant_ )
    SELECT u.ssn, u.fname, u.lname, j.title, (SELECT tail_num FROM crew c WHERE u.ssn = c.user_id LIMIT 1) AS tail_num
        FROM users u JOIN crewwithtitle j ON u.ssn = j.ssn ORDER BY title, lname, fname;
--------------------------------------------------------------------------------------------------------------------------
SELECT ssn, fname, lname, title, tail_num FROM crew_with_title
    WHERE tail_num IN ( SELECT tail_num FROM flight_crew_log WHERE user_id IN ( 
        SELECT ssn FROM users WHERE fname=:'fname' AND lname=:'lname' ) LIMIT 1) ORDER BY title, lname, fname;

WITH crew AS (
        SELECT tail_num, user_id FROM flight_crew_log WHERE tail_num IN (
            SELECT tail_num FROM flight_crew_log 
            WHERE user_id IN ( 
                SELECT ssn FROM users WHERE fname=:'fname' AND lname=:'lname' ) LIMIT 1)),
    captain_ AS (SELECT ssn, 'captain' AS title FROM captain WHERE ssn IN (SELECT user_id FROM crew)),
    firstofficer_ AS ( SELECT ssn, 'first_officer' AS title FROM first_officer WHERE ssn IN (SELECT user_id FROM crew)),
    attendant_ AS (SELECT ssn, 'attendant' AS title FROM attendant WHERE ssn IN (SELECT user_id FROM crew)),
    pilot_ AS (SELECT ssn, 'pilot' AS title FROM pilot WHERE ssn IN (SELECT user_id FROM crew) 
        AND ssn NOT IN (SELECT ssn FROM captain) AND ssn NOT IN (SELECT ssn FROM first_officer)),
    crewwithtitle AS (
        SELECT ssn, title FROM captain_ UNION SELECT ssn, title FROM firstofficer_ 
        UNION SELECT ssn, title FROM pilot_ UNION SELECT ssn, title FROM attendant_ )
    SELECT u.ssn, u.fname, u.lname, j.title, (SELECT tail_num FROM crew c WHERE u.ssn = c.user_id LIMIT 1) AS tail_num
        FROM users u JOIN crewwithtitle j ON u.ssn = j.ssn ORDER BY title, lname, fname;
--------------------------------------------------------------------------------------------------------------------------
SELECT ssn, fname, lname, title, tail_num FROM crew_with_title
    WHERE tail_num IN ( SELECT tail_num FROM flight_crew_log WHERE user_id IN ( 
        SELECT ssn FROM users WHERE fname=:'fname' AND lname=:'lname' ) LIMIT 1) ORDER BY title, lname, fname;

WITH crew AS (
        SELECT tail_num, user_id FROM flight_crew_log WHERE tail_num IN (
            SELECT tail_num FROM flight_crew_log 
            WHERE user_id IN ( 
                SELECT ssn FROM users WHERE fname=:'fname' AND lname=:'lname' ) LIMIT 1)),
    captain_ AS (SELECT ssn, 'captain' AS title FROM captain WHERE ssn IN (SELECT user_id FROM crew)),
    firstofficer_ AS ( SELECT ssn, 'first_officer' AS title FROM first_officer WHERE ssn IN (SELECT user_id FROM crew)),
    attendant_ AS (SELECT ssn, 'attendant' AS title FROM attendant WHERE ssn IN (SELECT user_id FROM crew)),
    pilot_ AS (SELECT ssn, 'pilot' AS title FROM pilot WHERE ssn IN (SELECT user_id FROM crew) 
        AND ssn NOT IN (SELECT ssn FROM captain) AND ssn NOT IN (SELECT ssn FROM first_officer)),
    crewwithtitle AS (
        SELECT ssn, title FROM captain_ UNION SELECT ssn, title FROM firstofficer_ 
        UNION SELECT ssn, title FROM pilot_ UNION SELECT ssn, title FROM attendant_ )
    SELECT u.ssn, u.fname, u.lname, j.title, (SELECT tail_num FROM crew c WHERE u.ssn = c.user_id LIMIT 1) AS tail_num
        FROM users u JOIN crewwithtitle j ON u.ssn = j.ssn ORDER BY title, lname, fname;
--------------------------------------------------------------------------------------------------------------------------
SELECT ssn, fname, lname, title, tail_num FROM crew_with_title
    WHERE tail_num IN ( SELECT tail_num FROM flight_crew_log WHERE user_id IN ( 
        SELECT ssn FROM users WHERE fname=:'fname' AND lname=:'lname' ) LIMIT 1) ORDER BY title, lname, fname;

WITH crew AS (
        SELECT tail_num, user_id FROM flight_crew_log WHERE tail_num IN (
            SELECT tail_num FROM flight_crew_log 
            WHERE user_id IN ( 
                SELECT ssn FROM users WHERE fname=:'fname' AND lname=:'lname' ) LIMIT 1)),
    captain_ AS (SELECT ssn, 'captain' AS title FROM captain WHERE ssn IN (SELECT user_id FROM crew)),
    firstofficer_ AS ( SELECT ssn, 'first_officer' AS title FROM first_officer WHERE ssn IN (SELECT user_id FROM crew)),
    attendant_ AS (SELECT ssn, 'attendant' AS title FROM attendant WHERE ssn IN (SELECT user_id FROM crew)),
    pilot_ AS (SELECT ssn, 'pilot' AS title FROM pilot WHERE ssn IN (SELECT user_id FROM crew) 
        AND ssn NOT IN (SELECT ssn FROM captain) AND ssn NOT IN (SELECT ssn FROM first_officer)),
    crewwithtitle AS (
        SELECT ssn, title FROM captain_ UNION SELECT ssn, title FROM firstofficer_ 
        UNION SELECT ssn, title FROM pilot_ UNION SELECT ssn, title FROM attendant_ )
    SELECT u.ssn, u.fname, u.lname, j.title, (SELECT tail_num FROM crew c WHERE u.ssn = c.user_id LIMIT 1) AS tail_num
        FROM users u JOIN crewwithtitle j ON u.ssn = j.ssn ORDER BY title, lname, fname;
--------------------------------------------------------------------------------------------------------------------------
SELECT ssn, fname, lname, title, tail_num FROM crew_with_title
    WHERE tail_num IN ( SELECT tail_num FROM flight_crew_log WHERE user_id IN ( 
        SELECT ssn FROM users WHERE fname=:'fname' AND lname=:'lname' ) LIMIT 1) ORDER BY title, lname, fname;

WITH crew AS (
        SELECT tail_num, user_id FROM flight_crew_log WHERE tail_num IN (
            SELECT tail_num FROM flight_crew_log 
            WHERE user_id IN ( 
                SELECT ssn FROM users WHERE fname=:'fname' AND lname=:'lname' ) LIMIT 1)),
    captain_ AS (SELECT ssn, 'captain' AS title FROM captain WHERE ssn IN (SELECT user_id FROM crew)),
    firstofficer_ AS ( SELECT ssn, 'first_officer' AS title FROM first_officer WHERE ssn IN (SELECT user_id FROM crew)),
    attendant_ AS (SELECT ssn, 'attendant' AS title FROM attendant WHERE ssn IN (SELECT user_id FROM crew)),
    pilot_ AS (SELECT ssn, 'pilot' AS title FROM pilot WHERE ssn IN (SELECT user_id FROM crew) 
        AND ssn NOT IN (SELECT ssn FROM captain) AND ssn NOT IN (SELECT ssn FROM first_officer)),
    crewwithtitle AS (
        SELECT ssn, title FROM captain_ UNION SELECT ssn, title FROM firstofficer_ 
        UNION SELECT ssn, title FROM pilot_ UNION SELECT ssn, title FROM attendant_ )
    SELECT u.ssn, u.fname, u.lname, j.title, (SELECT tail_num FROM crew c WHERE u.ssn = c.user_id LIMIT 1) AS tail_num
        FROM users u JOIN crewwithtitle j ON u.ssn = j.ssn ORDER BY title, lname, fname;
--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------
SELECT ROUND(total_exec_time::numeric,3) as total_time, calls, ROUND(mean_exec_time::numeric,3) as avg_time, 
        ROUND(min_exec_time::numeric,3) as min_time, ROUND(max_exec_time::numeric,3) as max_time, query
        FROM pg_stat_statements
        WHERE query like '%%tail_num%%';
DROP EXTENSION pg_stat_statements;

-- .\psql.exe -U postgres -h localhost -d appdb -W -f C:/projects/cs338-proj/dbproj/test_scripts/test_production_ff4.sql > C:/projects/cs338-proj/dbproj/test_scripts/test_production_ff4.out

-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
SELECT pg_stat_statements_reset();
-----------------------------------------------------------------------------------------------------------
WITH fbu AS (
        SELECT flight_id, user_id FROM boarding_tickets b 
        JOIN passengers p ON b.ticket_id = p.ticket_id ),
        uc AS (
                SELECT p1.user_id AS user1, p2.user_id AS user2,
                array_agg(DISTINCT tail_num ORDER BY tail_num ) as flights FROM fbu p1
                JOIN fbu p2 ON p1.flight_id = p2.flight_id AND p1.user_id < p2.user_id
                JOIN flight f ON p1.flight_id = f.id GROUP BY p1.user_id, p2.user_id ),
        fusers as (
                SELECT user1, u1.fname || ' ' || u1.lname, user2, u2.fname || ' ' || u2.lname,
                flights, array_length(flights, 1) AS flight_count
                FROM uc JOIN users u1 ON user1 = u1.ssn JOIN users u2 ON user2 = u2.ssn
                ORDER BY flight_count DESC )
        SELECT * FROM fusers WHERE flight_count > 1 LIMIT 20;

WITH fbu AS (
        SELECT flight_id, user_id FROM boarding_tickets b
        JOIN passengers p ON b.ticket_id = p.ticket_id ),
        uc AS (
                SELECT p1.user_id AS user1, p2.user_id AS user2,
                array_agg(DISTINCT tail_num ORDER BY tail_num ) as flights
                FROM fbu p1 JOIN fbu p2 ON p1.flight_id = p2.flight_id AND p1.user_id < p2.user_id
                JOIN flight f ON p1.flight_id = f.id GROUP BY p1.user_id, p2.user_id ),
        fusers as (
                SELECT user1, (SELECT fname || ' ' || lname FROM users WHERE uc.user1 = users.ssn) as name1,
                user2, (SELECT fname || ' ' || lname FROM users WHERE uc.user2 = users.ssn) as name2,
                flights, array_length(flights, 1) AS flight_count FROM uc ORDER BY flight_count DESC)
        SELECT * FROM fusers WHERE flight_count > 1 LIMIT 20;
-----------------------------------------------------------------------------------------------------------
WITH fbu AS (
        SELECT flight_id, user_id FROM boarding_tickets b 
        JOIN passengers p ON b.ticket_id = p.ticket_id ),
        uc AS (
                SELECT p1.user_id AS user1, p2.user_id AS user2,
                array_agg(DISTINCT tail_num ORDER BY tail_num ) as flights FROM fbu p1
                JOIN fbu p2 ON p1.flight_id = p2.flight_id AND p1.user_id < p2.user_id
                JOIN flight f ON p1.flight_id = f.id GROUP BY p1.user_id, p2.user_id ),
        fusers as (
                SELECT user1, u1.fname || ' ' || u1.lname, user2, u2.fname || ' ' || u2.lname,
                flights, array_length(flights, 1) AS flight_count
                FROM uc JOIN users u1 ON user1 = u1.ssn JOIN users u2 ON user2 = u2.ssn
                ORDER BY flight_count DESC )
        SELECT * FROM fusers WHERE flight_count > 1 LIMIT 20;

WITH fbu AS (
        SELECT flight_id, user_id FROM boarding_tickets b
        JOIN passengers p ON b.ticket_id = p.ticket_id ),
        uc AS (
                SELECT p1.user_id AS user1, p2.user_id AS user2,
                array_agg(DISTINCT tail_num ORDER BY tail_num ) as flights
                FROM fbu p1 JOIN fbu p2 ON p1.flight_id = p2.flight_id AND p1.user_id < p2.user_id
                JOIN flight f ON p1.flight_id = f.id GROUP BY p1.user_id, p2.user_id ),
        fusers as (
                SELECT user1, (SELECT fname || ' ' || lname FROM users WHERE uc.user1 = users.ssn) as name1,
                user2, (SELECT fname || ' ' || lname FROM users WHERE uc.user2 = users.ssn) as name2,
                flights, array_length(flights, 1) AS flight_count FROM uc ORDER BY flight_count DESC)
        SELECT * FROM fusers WHERE flight_count > 1 LIMIT 20;
-----------------------------------------------------------------------------------------------------------
WITH fbu AS (
        SELECT flight_id, user_id FROM boarding_tickets b 
        JOIN passengers p ON b.ticket_id = p.ticket_id ),
        uc AS (
                SELECT p1.user_id AS user1, p2.user_id AS user2,
                array_agg(DISTINCT tail_num ORDER BY tail_num ) as flights FROM fbu p1
                JOIN fbu p2 ON p1.flight_id = p2.flight_id AND p1.user_id < p2.user_id
                JOIN flight f ON p1.flight_id = f.id GROUP BY p1.user_id, p2.user_id ),
        fusers as (
                SELECT user1, u1.fname || ' ' || u1.lname, user2, u2.fname || ' ' || u2.lname,
                flights, array_length(flights, 1) AS flight_count
                FROM uc JOIN users u1 ON user1 = u1.ssn JOIN users u2 ON user2 = u2.ssn
                ORDER BY flight_count DESC )
        SELECT * FROM fusers WHERE flight_count > 1 LIMIT 20;

WITH fbu AS (
        SELECT flight_id, user_id FROM boarding_tickets b
        JOIN passengers p ON b.ticket_id = p.ticket_id ),
        uc AS (
                SELECT p1.user_id AS user1, p2.user_id AS user2,
                array_agg(DISTINCT tail_num ORDER BY tail_num ) as flights
                FROM fbu p1 JOIN fbu p2 ON p1.flight_id = p2.flight_id AND p1.user_id < p2.user_id
                JOIN flight f ON p1.flight_id = f.id GROUP BY p1.user_id, p2.user_id ),
        fusers as (
                SELECT user1, (SELECT fname || ' ' || lname FROM users WHERE uc.user1 = users.ssn) as name1,
                user2, (SELECT fname || ' ' || lname FROM users WHERE uc.user2 = users.ssn) as name2,
                flights, array_length(flights, 1) AS flight_count FROM uc ORDER BY flight_count DESC)
        SELECT * FROM fusers WHERE flight_count > 1 LIMIT 20;
-----------------------------------------------------------------------------------------------------------
WITH fbu AS (
        SELECT flight_id, user_id FROM boarding_tickets b 
        JOIN passengers p ON b.ticket_id = p.ticket_id ),
        uc AS (
                SELECT p1.user_id AS user1, p2.user_id AS user2,
                array_agg(DISTINCT tail_num ORDER BY tail_num ) as flights FROM fbu p1
                JOIN fbu p2 ON p1.flight_id = p2.flight_id AND p1.user_id < p2.user_id
                JOIN flight f ON p1.flight_id = f.id GROUP BY p1.user_id, p2.user_id ),
        fusers as (
                SELECT user1, u1.fname || ' ' || u1.lname, user2, u2.fname || ' ' || u2.lname,
                flights, array_length(flights, 1) AS flight_count
                FROM uc JOIN users u1 ON user1 = u1.ssn JOIN users u2 ON user2 = u2.ssn
                ORDER BY flight_count DESC )
        SELECT * FROM fusers WHERE flight_count > 1 LIMIT 20;

WITH fbu AS (
        SELECT flight_id, user_id FROM boarding_tickets b
        JOIN passengers p ON b.ticket_id = p.ticket_id ),
        uc AS (
                SELECT p1.user_id AS user1, p2.user_id AS user2,
                array_agg(DISTINCT tail_num ORDER BY tail_num ) as flights
                FROM fbu p1 JOIN fbu p2 ON p1.flight_id = p2.flight_id AND p1.user_id < p2.user_id
                JOIN flight f ON p1.flight_id = f.id GROUP BY p1.user_id, p2.user_id ),
        fusers as (
                SELECT user1, (SELECT fname || ' ' || lname FROM users WHERE uc.user1 = users.ssn) as name1,
                user2, (SELECT fname || ' ' || lname FROM users WHERE uc.user2 = users.ssn) as name2,
                flights, array_length(flights, 1) AS flight_count FROM uc ORDER BY flight_count DESC)
        SELECT * FROM fusers WHERE flight_count > 1 LIMIT 20;
-----------------------------------------------------------------------------------------------------------
WITH fbu AS (
        SELECT flight_id, user_id FROM boarding_tickets b 
        JOIN passengers p ON b.ticket_id = p.ticket_id ),
        uc AS (
                SELECT p1.user_id AS user1, p2.user_id AS user2,
                array_agg(DISTINCT tail_num ORDER BY tail_num ) as flights FROM fbu p1
                JOIN fbu p2 ON p1.flight_id = p2.flight_id AND p1.user_id < p2.user_id
                JOIN flight f ON p1.flight_id = f.id GROUP BY p1.user_id, p2.user_id ),
        fusers as (
                SELECT user1, u1.fname || ' ' || u1.lname, user2, u2.fname || ' ' || u2.lname,
                flights, array_length(flights, 1) AS flight_count
                FROM uc JOIN users u1 ON user1 = u1.ssn JOIN users u2 ON user2 = u2.ssn
                ORDER BY flight_count DESC )
        SELECT * FROM fusers WHERE flight_count > 1 LIMIT 20;

WITH fbu AS (
        SELECT flight_id, user_id FROM boarding_tickets b
        JOIN passengers p ON b.ticket_id = p.ticket_id ),
        uc AS (
                SELECT p1.user_id AS user1, p2.user_id AS user2,
                array_agg(DISTINCT tail_num ORDER BY tail_num ) as flights
                FROM fbu p1 JOIN fbu p2 ON p1.flight_id = p2.flight_id AND p1.user_id < p2.user_id
                JOIN flight f ON p1.flight_id = f.id GROUP BY p1.user_id, p2.user_id ),
        fusers as (
                SELECT user1, (SELECT fname || ' ' || lname FROM users WHERE uc.user1 = users.ssn) as name1,
                user2, (SELECT fname || ' ' || lname FROM users WHERE uc.user2 = users.ssn) as name2,
                flights, array_length(flights, 1) AS flight_count FROM uc ORDER BY flight_count DESC)
        SELECT * FROM fusers WHERE flight_count > 1 LIMIT 20;

-------------------------------------------------------------
SELECT ROUND(total_exec_time::numeric,3) as total_time, calls, ROUND(mean_exec_time::numeric,3) as avg_time, 
        ROUND(min_exec_time::numeric,3) as min_time, ROUND(max_exec_time::numeric,3) as max_time, query
        FROM pg_stat_statements
        WHERE query like '%%flight%%';

DROP EXTENSION pg_stat_statements;

-- .\psql.exe -U postgres -h localhost -d appdb -W -f C:/projects/cs338-proj/dbproj/test_scripts/test_production_ff2.sql > C:/projects/cs338-proj/dbproj/test_scripts/test_production_ff2.out

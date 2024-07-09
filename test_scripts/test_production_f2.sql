CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
SELECT pg_stat_statements_reset();
SET max_parallel_workers_per_gather = 1;

   WITH total_count AS (
       SELECT
           COUNT(*) AS total
       FROM
           flight
       WHERE

   (
       CASE
           WHEN month > 10 THEN (month - 10) * 100 + day_of_month
           ELSE (month + 3) * 100 + day_of_month
       END
   ) BETWEEN
   (
       CASE
           WHEN 1 > 10 THEN (1 - 10) * 100 + 1
           ELSE (1 + 3) * 100 + 1
       END
   )
   AND
   (
       CASE
           WHEN 1 > 10 THEN (1 - 10) * 100 + 5
           ELSE (1 + 3) * 100 + 5
       END
   )

   )
   SELECT
       carrier_code,
       COUNT(*) AS c,
       ROUND((COUNT(*) * 100.0 / (SELECT total FROM total_count)), 1) AS percentage
   FROM
       flight
   WHERE

   (
       CASE
           WHEN month > 10 THEN (month - 10) * 100 + day_of_month
           ELSE (month + 3) * 100 + day_of_month
       END
   ) BETWEEN
   (
       CASE
           WHEN 1 > 10 THEN (1 - 10) * 100 + 1
           ELSE (1 + 3) * 100 + 1
       END
   )
   AND
   (
       CASE
           WHEN 1 > 10 THEN (1 - 10) * 100 + 5
           ELSE (1 + 3) * 100 + 5
       END
   )

   GROUP BY
       carrier_code
   ORDER BY
       c DESC;





WITH total_count AS (
    SELECT
        COUNT(*) AS total
    FROM
        flight
    WHERE

(
    CASE
        WHEN month > 10 THEN (month - 10) * 100 + day_of_month
        ELSE (month + 3) * 100 + day_of_month
    END
) BETWEEN
(
    CASE
        WHEN 1 > 10 THEN (1 - 10) * 100 + 1
        ELSE (1 + 3) * 100 + 1
    END
)
AND
(
    CASE
        WHEN 1 > 10 THEN (1 - 10) * 100 + 5
        ELSE (1 + 3) * 100 + 5
    END
)

)
SELECT
    carrier_code,
    COUNT(*) AS c,
    ROUND((COUNT(*) * 100.0 / (SELECT total FROM total_count)), 1) AS percentage
FROM
    flight
WHERE

(
    CASE
        WHEN month > 10 THEN (month - 10) * 100 + day_of_month
        ELSE (month + 3) * 100 + day_of_month
    END
) BETWEEN
(
    CASE
        WHEN 1 > 10 THEN (1 - 10) * 100 + 1
        ELSE (1 + 3) * 100 + 1
    END
)
AND
(
    CASE
        WHEN 1 > 10 THEN (1 - 10) * 100 + 5
        ELSE (1 + 3) * 100 + 5
    END
)

GROUP BY
    carrier_code
ORDER BY
    c DESC;

SELECT ROUND(total_exec_time::numeric,3) as total_time, calls, ROUND(mean_exec_time::numeric,3) as avg_time, ROUND(min_exec_time::numeric,3) as min_time, ROUND(max_exec_time::numeric,3) as max_time
        FROM pg_stat_statements
        WHERE query like '%%carrier_code%%';


SELECT pg_stat_statements_reset();
SET max_parallel_workers_per_gather = 4;

   WITH total_count AS (
       SELECT
           COUNT(*) AS total
       FROM
           flight
       WHERE

   (
       CASE
           WHEN month > 10 THEN (month - 10) * 100 + day_of_month
           ELSE (month + 3) * 100 + day_of_month
       END
   ) BETWEEN
   (
       CASE
           WHEN 1 > 10 THEN (1 - 10) * 100 + 1
           ELSE (1 + 3) * 100 + 1
       END
   )
   AND
   (
       CASE
           WHEN 1 > 10 THEN (1 - 10) * 100 + 5
           ELSE (1 + 3) * 100 + 5
       END
   )

   )
   SELECT
       carrier_code,
       COUNT(*) AS c,
       ROUND((COUNT(*) * 100.0 / (SELECT total FROM total_count)), 1) AS percentage
   FROM
       flight
   WHERE

   (
       CASE
           WHEN month > 10 THEN (month - 10) * 100 + day_of_month
           ELSE (month + 3) * 100 + day_of_month
       END
   ) BETWEEN
   (
       CASE
           WHEN 1 > 10 THEN (1 - 10) * 100 + 1
           ELSE (1 + 3) * 100 + 1
       END
   )
   AND
   (
       CASE
           WHEN 1 > 10 THEN (1 - 10) * 100 + 5
           ELSE (1 + 3) * 100 + 5
       END
   )

   GROUP BY
       carrier_code
   ORDER BY
       c DESC;





WITH total_count AS (
    SELECT
        COUNT(*) AS total
    FROM
        flight
    WHERE

(
    CASE
        WHEN month > 10 THEN (month - 10) * 100 + day_of_month
        ELSE (month + 3) * 100 + day_of_month
    END
) BETWEEN
(
    CASE
        WHEN 1 > 10 THEN (1 - 10) * 100 + 1
        ELSE (1 + 3) * 100 + 1
    END
)
AND
(
    CASE
        WHEN 1 > 10 THEN (1 - 10) * 100 + 5
        ELSE (1 + 3) * 100 + 5
    END
)

)
SELECT
    carrier_code,
    COUNT(*) AS c,
    ROUND((COUNT(*) * 100.0 / (SELECT total FROM total_count)), 1) AS percentage
FROM
    flight
WHERE

(
    CASE
        WHEN month > 10 THEN (month - 10) * 100 + day_of_month
        ELSE (month + 3) * 100 + day_of_month
    END
) BETWEEN
(
    CASE
        WHEN 1 > 10 THEN (1 - 10) * 100 + 1
        ELSE (1 + 3) * 100 + 1
    END
)
AND
(
    CASE
        WHEN 1 > 10 THEN (1 - 10) * 100 + 5
        ELSE (1 + 3) * 100 + 5
    END
)

GROUP BY
    carrier_code
ORDER BY
    c DESC;

SELECT ROUND(total_exec_time::numeric,3) as total_time, calls, ROUND(mean_exec_time::numeric,3) as avg_time, ROUND(min_exec_time::numeric,3) as min_time, ROUND(max_exec_time::numeric,3) as max_time
        FROM pg_stat_statements
        WHERE query like '%%carrier_code%%';


DROP EXTENSION pg_stat_statements;

-- psql.exe -U postgres -h localhost -d appdb -W -f C:/projects/cs338-proj/dbproj/test_scripts/test_production_f2.sql > C:/projects/cs338-proj/dbproj/test_scripts/test_production_f2.out

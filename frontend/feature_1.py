from flask import render_template, request
from conn import get_conn
from psycopg2 import Error
import matplotlib.pyplot as plt
#import re

# Feature 1

# This function is for obtain a list of carriers for users to select in the UI
def get_carriers(conn, carrier_codes):
    cur = conn.cursor()
    cur.execute(
        """
            SELECT DISTINCT 
                flight.carrier_code AS airline_id,
                airline.name
            FROM 
                flight
            JOIN 
                airline ON flight.carrier_code = airline.airline_id
            ORDER BY 
                airline_id;
        """
        )
    rows = cur.fetchall()
    print("===>",rows)
    carriers = []
    for row in rows:
        carriers.append({
            "id": row[0],
            "name": row[1],
            "checked": True if row[0] in carrier_codes else False # for displaying user's previous selections
        })
    cur.close()
    return carriers

def run_query_and_retrieve_execution_time(conn, cursor, query, rounds):

    # Clear previous stats
    cursor.execute("SELECT pg_stat_statements_reset();")
    conn.commit()

    # Run the query and get the result
    for _ in range(rounds):
        cursor.execute(query)
        _ = cursor.fetchall()

    # Retrieve the execution time for the query
    cursor.execute("""
        SELECT ROUND(total_exec_time::numeric,3), calls, ROUND(mean_exec_time::numeric,3), ROUND(min_exec_time::numeric,3), ROUND(max_exec_time::numeric,3)
        FROM pg_stat_statements
        WHERE calls = %s
    """, (rounds,))
    #    WHERE query = %s; -- this method did not work
    #""", (query,))
    execution_stats = cursor.fetchone()

    # if execution_stats:
    #     total_time1, calls1, mean_time1, min_time1, max_time1 = execution_stats
    #     print(f"Execution Time Stats for Query 1:\nTotal Time: {total_time1} ms\nCalls: {calls1}\nMean Time: {mean_time1} ms\nMin Time: {min_time1} ms\nMax Time: {max_time1} ms")
    # else:
    #     print("No execution statistics found for the query.")
    print("stat", execution_stats)

    return execution_stats


def perfomance_tuning(conn, rounds, query1, query2, query3, query4, labels, stmts1, stmts2):

    cursor = conn.cursor()

    # Enable the pg_stat_statements extension
    cursor.execute("CREATE EXTENSION IF NOT EXISTS pg_stat_statements;")
    conn.commit()    

    cursor.execute(stmts1) # drop all indices
    conn.commit()    

    execution_stats1 = (labels[0],) + run_query_and_retrieve_execution_time(conn, cursor, query1, rounds)
    execution_stats2 = (labels[1],) + run_query_and_retrieve_execution_time(conn, cursor, query2, rounds)
    execution_stats3 = (labels[2],) + run_query_and_retrieve_execution_time(conn, cursor, query3, rounds)
    execution_stats4 = (labels[3],) + run_query_and_retrieve_execution_time(conn, cursor, query4, rounds)

    cursor.execute(stmts2) # create indices
    conn.commit()    

    execution_stats5 = (labels[4],) + run_query_and_retrieve_execution_time(conn, cursor, query1, rounds)
    execution_stats6 = (labels[5],) + run_query_and_retrieve_execution_time(conn, cursor, query2, rounds)
    execution_stats7 = (labels[6],) + run_query_and_retrieve_execution_time(conn, cursor, query3, rounds)
    execution_stats8 = (labels[7],) + run_query_and_retrieve_execution_time(conn, cursor, query4, rounds)

    # Drop the pg_stat_statements extension
    cursor.execute("DROP EXTENSION pg_stat_statements;")
    conn.commit()

    # Close the connection
    cursor.close()
    conn.close()

    return [execution_stats1, execution_stats2, execution_stats3, execution_stats4, execution_stats5, execution_stats6, execution_stats7, execution_stats8]


def flights_search():

    # extract parameters from URL
    carrier_codes = request.args.getlist('c')
    carrier_codes_str = "({})".format(", ".join(["'{}'".format(code) for code in carrier_codes]))

    from_month = request.args.get('fm')
    to_month = request.args.get('tm')
    from_day = request.args.get('fd')
    to_day = request.args.get('td')

    # example: ?fm=11&fd=1&tm=12&td=31&c=9E&c=AA&c=AS&c=B6&c=DL

    action = request.args.get('action')

    # query database
    # query airline_id and name for list of carriers with checkboxes:
    try:
        conn = get_conn()
        carriers = get_carriers(conn, carrier_codes)
    except Error as e:
        print("error:", e)
        #return jsonify({"error": f"Database error: {e}"}), 500
        return f"Error {e}"
    
    flights = []
    stats = [] # to store data for performance tuning

    # query flights: 

    if from_month != None and len(carrier_codes) > 0:
        query = f"""
                    SELECT  
                        month, day_of_month, carrier_code, airline.name, tail_num, arrival_airport_code, departure_delay
                    FROM 
                        flight
                    JOIN 
                        airline ON flight.carrier_code = airline.airline_id
                    WHERE 
                    (
                        CASE
                            WHEN month > 10 THEN (month - 10) * 100 + day_of_month
                            ELSE (month + 3) * 100 + day_of_month
                        END
                    ) BETWEEN 
                    (
                        CASE
                            WHEN {from_month} > 10 THEN ({from_month} - 10) * 100 + {from_day}
                            ELSE ({from_month} + 3) * 100 + {from_day}
                        END
                    )
                    AND
                    (
                        CASE
                            WHEN {to_month} > 10 THEN ({to_month} - 10) * 100 + {to_day}
                            ELSE ({to_month} + 3) * 100 + {to_day}
                        END
                    ) 
                    AND 
                        carrier_code IN {carrier_codes_str}
                    ORDER BY 
                        departure_delay DESC
                    FETCH FIRST 
                        10 ROWS ONLY;
                """
        
        from_ymd = (2019*10000 + int(from_month)*100 + int(from_day)) if int(from_month)>10 else (2020*10000 + int(from_month)*100 + int(from_day))
        to_ymd   = (2019*10000 + int(to_month)*100 + int(to_day)) if int(to_month)>10 else (2020*10000 + int(to_month)*100 + int(to_day))

        query2 = f"""
                    SELECT  
                        ymd, carrier_code, airline.name, tail_num, arrival_airport_code, departure_delay
                    FROM 
                        flight_test_int f
                    JOIN 
                        airline ON f.carrier_code = airline.airline_id
                    WHERE 
                        ymd
                    BETWEEN 
                        {from_ymd}
                    AND
                        {to_ymd}
                    AND 
                        carrier_code IN {carrier_codes_str}
                    ORDER BY 
                        departure_delay DESC
                    FETCH FIRST 
                        10 ROWS ONLY;
                """

        query3 = f"""
                    SELECT  
                        month, day_of_month, carrier_code, airline.name, tail_num, arrival_airport_code, departure_delay
                    FROM 
                        flight_test_YMD f
                    JOIN 
                        airline ON f.carrier_code = airline.airline_id
                    WHERE 
                        year * 10000 + month * 100 + day_of_month
                    BETWEEN 
                        {from_ymd}
                    AND
                        {to_ymd}
                    AND 
                        carrier_code IN {carrier_codes_str}
                    ORDER BY 
                        departure_delay DESC
                    FETCH FIRST 
                        10 ROWS ONLY;
                """


        from_date = ('2019-%02d-%02d' % (int(from_month), int(from_day))) if int(from_month) >10 else ('2020-%02d-%02d' % (int(from_month), int(from_day)))
        to_date = ('2019-%02d-%02d' % (int(to_month), int(to_day))) if int(to_month) >10 else ('2020-%02d-%02d' % (int(to_month), int(to_day)))

        query4 = f"""
                    SELECT  
                        date, carrier_code, airline.name, tail_num, arrival_airport_code, departure_delay
                    FROM 
                        flight_test_date f
                    JOIN 
                        airline ON f.carrier_code = airline.airline_id
                    WHERE 
                        date 
                    BETWEEN 
                        '{from_date}' 
                    AND 
                        '{to_date}'
                    AND 
                        carrier_code IN {carrier_codes_str}
                    ORDER BY 
                        departure_delay DESC
                    FETCH FIRST 
                        10 ROWS ONLY;
                """

        print("query2:", query2)
        print("query3:", query3)

        try:
            # For showing the top 10 delayed flights
            cur = conn.cursor()
            cur.execute(query)
            flights = cur.fetchall()
            print("===>",flights)
            cur.close()

            # performance turning 
            if action == "Perfomance Tuning":
                stats = perfomance_tuning(conn, 100, query, query2, query3, query4, 
                                          ["M D", "YMD_int", "Y M D", "Date", "M D with index", 
                                           "YMD_int with index", "Y M D with index", "Date with index"],
                                          """
                                          DROP INDEX IF EXISTS idx_flight_1;
                                          DROP INDEX IF EXISTS idx_flight_test_YMD_1;
                                          DROP INDEX IF EXISTS idx_flight_test_int_1;
                                          DROP INDEX IF EXISTS idx_flight_test_date_1;
                                          DROP INDEX IF EXISTS idx_airline_1;
                                          """,
                                          """
                                          CREATE INDEX idx_flight_1 ON flight (carrier_code);
                                          CREATE INDEX idx_flight_test_YMD_1 ON flight_test_YMD (carrier_code);
                                          CREATE INDEX idx_flight_test_int_1 ON flight_test_int (carrier_code);
                                          CREATE INDEX idx_flight_test_date_1 ON flight_test_date (carrier_code);
                                          CREATE INDEX idx_airline_1 ON airline (airline_id);
                                          """
                                          )


        except Error as e:
            print("error:", e)
            #return jsonify({"error": f"Database error: {e}"}), 500
            return f"Error {e}"

    if from_month:
        fromto = [from_month, int(from_day), to_month, int(to_day)] # for displaying previously selected dates in the UI
    else:
        fromto = ['11', 1, '1', 31] # default selected dates

    # Present data
    return render_template('f1_search.html', carriers=carriers, flights=flights, stats=stats, fromto=fromto)


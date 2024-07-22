from flask import render_template, request
from conn import get_conn
from psycopg2 import Error
from feature_1 import run_query_and_retrieve_execution_time

def perfomance_tuning(conn, rounds, query1, query2, labels):

    cursor = conn.cursor()

    # Enable the pg_stat_statements extension
    cursor.execute("CREATE EXTENSION IF NOT EXISTS pg_stat_statements;")
    conn.commit()    

    execution_stats1 = (labels[0],) + run_query_and_retrieve_execution_time(conn, cursor, query1, rounds)
    execution_stats2 = (labels[1],) + run_query_and_retrieve_execution_time(conn, cursor, query2, rounds)

    # Drop the pg_stat_statements extension (optional)
    cursor.execute("DROP EXTENSION pg_stat_statements;")
    conn.commit()

    # Close the connection
    cursor.close()

    return [execution_stats1, execution_stats2]


def advanced_search():

    submit = request.args.get('submit')

    query_main = """
            WITH topvalues AS (
                SELECT 
                    user_id, SUM(distance) distance, SUM(fare) fare, COUNT(*) tickets
                FROM 
                    flight f 
                JOIN 
                    boarding_tickets b on f.id = b.flight_id 
                JOIN 
                    passengers p on b.ticket_id = p.ticket_id 
                GROUP BY 
                    user_id 
            ) 
            SELECT 
                fname, lname, ssn, tickets, fare, distance 
            FROM
                topvalues
            JOIN
                users on user_id = ssn
        """
    
    query_top_num_ticket_buyer = query_main + "ORDER BY tickets DESC LIMIT 10"
    query_top_ticket_spender = query_main + "ORDER BY fare DESC LIMIT 10"
    query_top_distance_traveler = query_main + "ORDER BY distance DESC LIMIT 10"

    caption = "Search result"
    if(submit == "Highest Number of Tickets Bought") or submit == "Performance Tuning":
        query = query_top_num_ticket_buyer
        caption = "Highest Number of Tickets Bought"
    elif(submit == "Highest Ticket Spending"):
        query = query_top_ticket_spender
        caption = submit
    elif(submit == "Longest Distance Travelled"):
        query = query_top_distance_traveler
        caption = submit
    else:
        query = None

    rows = []
    performance = []
    query_compare = """
            SELECT 
                fname, lname, ssn, count(*) tickets, sum(fare) fare, sum(distance) distance
            FROM 
                flight f 
            JOIN 
                boarding_tickets b on f.id = b.flight_id 
            JOIN 
                passengers p on b.ticket_id = p.ticket_id 
            JOIN
                users on user_id = ssn
            GROUP BY 
                fname, lname, ssn
            ORDER BY tickets DESC 
            LIMIT 10;
        """

    if query != None:
        try:
            conn = get_conn()
            cur = conn.cursor()
            cur.execute(query)
            rows = cur.fetchall()
            print("===>",rows)

            if submit == "Performance Tuning":
                performance = perfomance_tuning(conn, 100, query_compare, query, ["JOIN only","CTE"])
        except Error as e:
            print("error:", e)
            #return jsonify({"error": f"Database error: {e}"}), 500
            return f"Error {e}"

    return render_template('ff1_advanced_search.html', rows=rows, stats=performance, caption=caption)

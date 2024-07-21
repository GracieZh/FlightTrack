from flask import render_template, request
from conn import get_conn
from psycopg2 import Error

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


    if(submit == "Highest Number of Tickets Bought"):
        query = query_top_num_ticket_buyer
    elif(submit == "Highest Ticket Spending"):
        query = query_top_ticket_spender
    elif(submit == "Longest Distance Travelled"):
        query = query_top_distance_traveler
    else:
        query = None

    rows = []
    performance = []

    if query != None:
        try:
            conn = get_conn()
            cur = conn.cursor()
            cur.execute(query)
            rows = cur.fetchall()
            print("===>",rows)

        except Error as e:
            print("error:", e)
            #return jsonify({"error": f"Database error: {e}"}), 500
            return f"Error {e}"

    return render_template('ff1_advanced_search.html', rows=rows, stats=performance)

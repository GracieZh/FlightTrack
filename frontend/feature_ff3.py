from flask import render_template, request
from conn import get_conn
from psycopg2 import Error

def advanced_search_3():

    fname = request.args.get('fname')
    lname = request.args.get('lname')

    rows = []
    performance = []

    if fname != None and len(fname)>0 and len(lname)>0:
        try:

            conn = get_conn()
            cur = conn.cursor()
            query = f"""
                SELECT user_id, flight_id, fname, lname, tail_num, arrival_airport_code, municipality, iso_region
                FROM passengers p
                JOIN boarding_tickets b ON p.ticket_id = b.ticket_id
                JOIN users u ON u.ssn = p.user_id
                JOIN flight f ON f.id = b.flight_id
                JOIN airports a ON a.iata_code = f.arrival_airport_code
                WHERE fname='{fname}' and lname='{lname}'
                ORDER BY flight_id
                ;
                """
            cur.execute(query)
            rows = cur.fetchall()
            print("===>",rows)

        except Error as e:
            print("error:", e)
            #return jsonify({"error": f"Database error: {e}"}), 500
            return f"Error {e}"

    return render_template('ff3_advanced_search.html', rows=rows, stats=performance)

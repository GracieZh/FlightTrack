from flask import render_template, request
from conn import get_conn
from psycopg2 import Error
from feature_ff1 import perfomance_tuning

def advanced_search_3():

    submit = request.args.get('submit')
    fname = request.args.get('fname')
    lname = request.args.get('lname')

    rows = []
    performance = []

    if fname != None and len(fname)>0 and len(lname)>0:
        try:
            conn = get_conn()
            cur = conn.cursor()

            query = """
                DROP VIEW IF EXISTS passenger_travel_history;

                CREATE VIEW passenger_travel_history AS
                SELECT user_id, flight_id, fname, lname, tail_num, arrival_airport_code, municipality, iso_region
                FROM passengers p
                JOIN boarding_tickets b ON p.ticket_id = b.ticket_id
                JOIN users u ON u.ssn = p.user_id
                JOIN flight f ON f.id = b.flight_id
                JOIN airports a ON a.iata_code = f.arrival_airport_code;
                """
            cur.execute(query)
            conn.commit()

            query = f"""
                SELECT user_id, flight_id, fname, lname, tail_num, arrival_airport_code, municipality, iso_region
                FROM passenger_travel_history p
                WHERE fname='{fname}' and lname='{lname}'
                ORDER BY flight_id
                ;
                """
            
            cur.execute(query)
            rows = cur.fetchall()
            print("===>",rows)

            if submit == "Performance Tuning":

                query_test = f"""
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

                performance = perfomance_tuning(conn, 100, query_test, query, ["JOIN", "VIEW"])
        except Error as e:
            print("error:", e)
            #return jsonify({"error": f"Database error: {e}"}), 500
            return f"Error {e}"

    return render_template('ff3_advanced_search.html', rows=rows, stats=performance, name=['' if fname is None else fname, '' if lname is None else lname])

from flask import render_template, request
from conn import get_conn
from psycopg2 import Error

def flights_search():

    # extract parameters from URL

    carrier_codes = request.args.getlist('c')
    carrier_codes_str = "({})".format(", ".join(["'{}'".format(code) for code in carrier_codes]))

    from_month = request.args.get('fm')
    to_month = request.args.get('tm')
    from_day = request.args.get('fd')
    to_day = request.args.get('td')

    # exampel: ?fm=11&fd=1&tm=12&td=31&c=9E&c=AA&c=AS&c=B6&c=DL

    # query database

    # query airline_id and name for pull-down menu:

    try:
        conn = get_conn()
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
                "name": row[1]
            })
        cur.close()
    except Error as e:
        print("error:", e)
        #return jsonify({"error": f"Database error: {e}"}), 500
        return f"Error {e}"
    
    flights = []

    if from_month != None:
        try:
            cur = conn.cursor()
            cur.execute(f"""
                    SELECT  
                        month, day_of_month, carrier_code, airline.name, tail_num, destination, departure_delay
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
                )
            flights = cur.fetchall()
            print("===>",flights)
            cur.close()
        except Error as e:
            print("error:", e)
            #return jsonify({"error": f"Database error: {e}"}), 500
            return f"Error {e}"


    # Present data
    return render_template('flights_search.html', carriers=carriers, flights=flights)


def flights_search_by_person():

    # query database
    
    flights = []
    # Present data
    return render_template('flights_search_by_person.html', rows=flights)
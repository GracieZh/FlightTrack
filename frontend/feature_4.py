from flask import render_template, request
from conn import get_conn
from psycopg2 import Error
import matplotlib.pyplot as plt
import numpy as np
from feature_1 import get_carriers
from feature_2 import perfomance_tuning

# Feature 4:

def stats_carrier_performance_compare():

    # query database

    carrier_codes = request.args.getlist('c')   # Extract the list of values for the 'c' parameter 
    action = request.args.get('action')

    stats = []
    performance = []

    # query airline_id and name for list of carrier code with checkboxes:

    try:
        conn = get_conn()
        carriers = get_carriers(conn, carrier_codes)
    except Error as e:
        print("error:", e)
        #return jsonify({"error": f"Database error: {e}"}), 500
        return f"Error {e}"


    if len(carrier_codes) > 0:
        try:
            carrier_codes_str = "({})".format(", ".join(["'{}'".format(code) for code in carrier_codes]))
            
            query = f"""
                SELECT 
                    carrier_code,
                    COUNT(CASE WHEN departure_delay <= 0 THEN 1 END) AS "0",
                    COUNT(CASE WHEN departure_delay > 0 AND departure_delay <= 10 THEN 1 END) AS "10",
                    COUNT(CASE WHEN departure_delay > 10 AND departure_delay <= 30 THEN 1 END) AS "30",
                    COUNT(CASE WHEN departure_delay > 30 AND departure_delay <= 60 THEN 1 END) AS "60",
                    COUNT(CASE WHEN departure_delay > 60 THEN 1 END) AS "61"
                FROM 
                    flight
                WHERE 
                    carrier_code IN {carrier_codes_str}
                GROUP BY 
                    carrier_code
                ORDER BY 
                    carrier_code;
            """

            conn = get_conn()
            cur = conn.cursor()
            cur.execute(query)
            rows = cur.fetchall()
            print("===>",rows)
            for row in rows:
                stats.append({
                    "carrier_code": row[0],
                    "0": row[1],
                    "10": row[2],
                    "30": row[3],
                    "60": row[4],
                    "61": row[5]
                })

            if action == "Performance Tuning":
                performance = perfomance_tuning(conn, 100, query, ["No Index","With Index"],
                    '''
                    DROP INDEX IF EXISTS idx_flight_1;
                    DROP INDEX IF EXISTS idx_flight_5;
                    '''
                    ,
                    '''
                    CREATE INDEX idx_flight_1 ON flight (carrier_code); 
                    CREATE INDEX idx_flight_5 ON flight (departure_delay); 
                    '''
                )

        except Error as e:
            print("error:", e)
            #return jsonify({"error": f"Database error: {e}"}), 500
            return f"Error {e}"
    
        # present data
        print("-------------------")
        print(stats)
        print("-------------------")

        labels = tuple(value['carrier_code'] for value in stats)

        bars = {
            'On time': tuple(stat['0'] for stat in stats),
            '<10 min': tuple(stat['10'] for stat in stats),
            '(10,30]': tuple(stat['30'] for stat in stats),
            '(30,60]': tuple(stat['60'] for stat in stats),
            '>60': tuple(stat['61'] for stat in stats),
        }    

        x = np.arange(len(labels))  # the label locations
        width = 0.16  # the width of the bars
        multiplier = 0

        fig, ax = plt.subplots(layout='constrained')

        for attribute, measurement in bars.items():
            offset = width * multiplier
            rects = ax.bar(x + offset, measurement, width, label=attribute)
            ax.bar_label(rects, padding=3)
            multiplier += 1

        # Add some text for labels, title and custom x-axis tick labels, etc.
        ax.set_ylabel('Number of flights')
        ax.set_title('Carrier delay distribution')
        ax.set_xticks(x + width, labels)
        ax.legend(loc='upper right', ncols=3)

        #plt.show()    
        plt.savefig('images/stats_carrier_performance_compare.png')

    return render_template('f4_carrier_performance_compare.html', carriers=carriers, stats=performance, rows=stats)





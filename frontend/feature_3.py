from flask import render_template, request
from conn import get_conn
from psycopg2 import Error
import math
from feature_2 import perfomance_tuning

# Feature 3

def stats_carrier_performance():

    from_month = request.args.get('fm')
    to_month = request.args.get('tm')
    from_day = request.args.get('fd')
    to_day = request.args.get('td')

    action = request.args.get('action')

    stats = []
    performance = []

    # query database

    if from_month != None:
        try:
            condition = f"""
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
                """

            query = f"""
                    WITH delay_stats AS (
                        SELECT 
                            carrier_code,
                            COUNT(*) AS total_flights,
                            COUNT(CASE WHEN departure_delay > 0 THEN 1 END) AS num_of_delay,
                            MIN(departure_delay) AS min_delay,
                            MAX(departure_delay) AS max_delay,
                            AVG(departure_delay) AS avg_delay
                        FROM 
                            flight
                        WHERE
                            {condition}
                        GROUP BY 
                            carrier_code
                    )
                    SELECT 
                        carrier_code,
                        total_flights,
                        num_of_delay,
                        ROUND(100.0 * num_of_delay / total_flights, 2) AS percent_of_delay,
                        min_delay,
                        max_delay,
                        ROUND(avg_delay, 2) AS avg_delay
                    FROM 
                        delay_stats;
                """

            conn = get_conn()
            cur = conn.cursor()
            cur.execute(query)
            rows = cur.fetchall()
            print("===>",rows)
            stats = []
            for row in rows:
                stats.append({
                    "carrier_code": row[0],
                    "total_flights": row[1],
                    "num_of_delay": row[2],
                    "percent_of_delay": row[3],
                    "min_delay": row[4],
                    "max_delay": row[5],
                    "avg_delay": row[6]
                })

            if action == "Perfomance Tuning":
                performance = perfomance_tuning(conn, 100, query, ["64k work mem","4M work mem"],
                    "SET work_mem = '64kB';",
                    "SET work_mem = '4MB';"
                )

        except Error as e:
            print("error:", e)
            #return jsonify({"error": f"Database error: {e}"}), 500
            return f"Error {e}"
        
        # present data

        print("-------------------")
        print(stats)
        print("-------------------")
        
        # Function to calculate log value based on the sign of v
        def calculate_log_value(v):
            if v >= 0:
                return round(math.log(v + 1), 2)
            else:
                return round(-math.log(-v + 1), 2)

        # Iterate through each dictionary in data and append log values
        for item in stats:
            item['log_mind'] = calculate_log_value(item['min_delay'])
            item['log_maxd'] = calculate_log_value(item['max_delay'])
            item['log_avgd'] = calculate_log_value(item['avg_delay'])

        print(stats)
        print("============")

    if from_month:
        fromto = [from_month, int(from_day), to_month, int(to_day)]
    else:
        fromto = ['11', 1, '1', 31]
    return render_template('f3_carrier_delay.html', rows=stats, stats=performance, fromto=fromto)


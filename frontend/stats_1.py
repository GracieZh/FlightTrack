from flask import render_template
from conn import get_conn
from psycopg2 import Error
import math

import matplotlib.pyplot as plt

def stats_carriercode():

    # query database
    try:
        conn = get_conn()
        cur = conn.cursor()
        cur.execute(
            """
                WITH total_count AS (
                    SELECT COUNT(*) AS total FROM flight
                )
                SELECT 
                    carrier_code, 
                    COUNT(*) AS c,
                    ROUND((COUNT(*) * 100.0 / (SELECT total FROM total_count)), 1) AS percentage
                FROM 
                    flight
                GROUP BY 
                    carrier_code
                ORDER BY 
                    c DESC;
            """
            )
        rows = cur.fetchall()
        print("===>",rows)
        stats = []
        for row in rows:
            stats.append({
                "carrier_code": row[0],
                "count": row[1],
                "percentage": row[2]
            })
    except Error as e:
        print("error:", e)
        #return jsonify({"error": f"Database error: {e}"}), 500
        return f"Error {e}"
    
    # Present data
    # Extracting data for the pie chart
    labels = [entry['carrier_code'] for entry in stats]
    sizes = [float(entry['percentage']) for entry in stats]

    plt.figure(figsize=(8, 8))
    plt.pie(sizes, labels=labels, autopct='%1.1f%%', startangle=140)
    plt.title('Carrier Code Distribution')
    plt.savefig('images/stats_carriercode.png')
    return render_template('stats_carriercode.html', rows=stats)



def stats_carrier_performance():
    # query database

    try:
        conn = get_conn()
        cur = conn.cursor()
        cur.execute(
            """
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
            )
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

    return render_template('stats_carrier_delay.html', rows=stats)



from flask import render_template
from conn import get_conn
from psycopg2 import Error

import matplotlib.pyplot as plt
import numpy as np

def stats_carriercode():

    # query database
    try:
        conn = get_conn()
        cur = conn.cursor()
        cur.execute(
            """
                WITH total_count AS (
                    SELECT COUNT(*) AS total FROM jfk_data
                )
                SELECT 
                    carrier_code, 
                    COUNT(*) AS c,
                    ROUND((COUNT(*) * 100.0 / (SELECT total FROM total_count)), 1) AS percentage
                FROM 
                    jfk_data
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

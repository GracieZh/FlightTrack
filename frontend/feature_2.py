from flask import render_template, request
from conn import get_conn
from psycopg2 import Error
import matplotlib.pyplot as plt
from feature_1 import run_query_and_retrieve_execution_time

def perfomance_tuning(conn, rounds, query, labels, stmt1, stmt2):

    cursor = conn.cursor()

    # Enable the pg_stat_statements extension
    cursor.execute("CREATE EXTENSION IF NOT EXISTS pg_stat_statements;")
    conn.commit()    

    cursor.execute(stmt1) # drop indices
    conn.commit()

    execution_stats1 = (labels[0],) + run_query_and_retrieve_execution_time(conn, cursor, query, rounds)

    cursor.execute(stmt2) # create indices
    conn.commit()

    execution_stats2 = (labels[1],) + run_query_and_retrieve_execution_time(conn, cursor, query, rounds)

    # Drop the pg_stat_statements extension (optional)
    cursor.execute("DROP EXTENSION pg_stat_statements;")
    conn.commit()

    # Close the connection
    cursor.close()

    return [execution_stats1, execution_stats2]


def stats_carriercode():

    from_month = request.args.get('fm')
    to_month = request.args.get('tm')
    from_day = request.args.get('fd')
    to_day = request.args.get('td')

    action = request.args.get('action')

    stats = []
    performance = []

    # query database
    if from_month:
        try:
            conn = get_conn()
            cur = conn.cursor()

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
                    WITH total_count AS (
                        SELECT 
                            COUNT(*) AS total 
                        FROM 
                            flight
                        WHERE 
                            {condition}
                    )
                    SELECT 
                        carrier_code, 
                        COUNT(*) AS c,
                        ROUND((COUNT(*) * 100.0 / (SELECT total FROM total_count)), 1) AS percentage
                    FROM 
                        flight
                    WHERE 
                        {condition}    
                    GROUP BY 
                        carrier_code
                    ORDER BY 
                        c DESC;
                """
            print("query", query)

            cur.execute(query)
            rows = cur.fetchall()
            print("===>",rows)
            for row in rows:
                stats.append({
                    "carrier_code": row[0],
                    "count": row[1],
                    "percentage": row[2]
                })

            if action == "Perfomance Tuning":
                performance = perfomance_tuning(conn, 100, query, 
                    ["max 1 parallel workers per gather","max 4 parallel workers per gather"],
                    "SET max_parallel_workers_per_gather = 1",
                    "SET max_parallel_workers_per_gather = 4"
                )

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

    if from_month:
        fromto = [from_month, int(from_day), to_month, int(to_day)]
    else:
        fromto = ['11', 1, '1', 31]
    return render_template('f2_carriercode.html', rows=stats, stats=performance, fromto=fromto)
    

from flask import render_template, request
from conn import get_conn
from psycopg2 import Error
import matplotlib.pyplot as plt
from matplotlib.colors import Normalize, ListedColormap
import numpy as np
import math
from feature_1 import get_carriers
from feature_2 import perfomance_tuning

# Fancy feature 5: 
def stats_taxiout():

    # nt=5&c=AA&c=AS&p=temperature

    carrier_codes = request.args.getlist('c')
    carrier_codes_str = "({})".format(", ".join(["'{}'".format(code) for code in carrier_codes]))
    wind_dirs = request.args.getlist('wdir')
    wind_dirs_str = "({})".format(", ".join(["'{}'".format(wd) for wd in wind_dirs]))
    nt = request.args.get('nt', type=int)
    parameter = request.args.get('p')

    action = request.args.get('action')

    # query database

    try:
        conn = get_conn()
        carriers = get_carriers(conn, carrier_codes)
    except Error as e:
        print("error:", e)
        #return jsonify({"error": f"Database error: {e}"}), 500
        return f"Error {e}"

    x = []
    y = []
    u = []
    performance = []

    if nt != None and len(carrier_codes) > 0:
        try:
            conn = get_conn()
            cur = conn.cursor()
            condition = f"carrier_code IN {carrier_codes_str} AND wind_dir IN {wind_dirs_str}"

            # param can be one of:    taxi_out, temperature, humidity, wind_speed, wind_gust

            query =  f"""
                    WITH flight_with_weather AS (
                        SELECT 
                            carrier_code, departure_delay, {parameter} AS param
                        FROM 
                            flight
                        JOIN 
                            weather_condition ON flight.id = weather_condition.id
                        WHERE 
                            {condition}
                    ),
                    tranges AS (
                        SELECT 
                            MIN(param) AS min_tout,
                            MAX(param) AS max_tout
                        FROM 
                            flight_with_weather
                    ),
                    tintervals AS (
                        SELECT 
                            ROUND(min_tout + (max_tout - min_tout) * 1.0/{nt-1} * n,2) AS lower_bound,
                            ROUND(min_tout + (max_tout - min_tout) * 1.0/{nt-1} * (n + 1),2) AS upper_bound
                        FROM 
                            generate_series(0, {nt-1}) AS n
                        CROSS JOIN 
                            tranges
                    ),
                    dintervals AS (
                        SELECT * FROM (
                            VALUES
                                (1, -10000, 0.00),
                                (2, 0.00,  10.00),
                                (3, 10.00, 30.00),
                                (4, 30.00, 60.00),
                                (5, 60.00, 100000.00)
                        ) AS tmp(value, lower_bound, upper_bound)
                    ),
                    delays AS (
                        SELECT 
                            departure_delay,
                            d.value AS d_value,
                            t.lower_bound AS t_range_lower_bound
                        FROM 
                            flight_with_weather f
                        JOIN 
                            dintervals d ON f.departure_delay > d.lower_bound AND f.departure_delay <= d.upper_bound
                        JOIN 
                            tintervals t ON f.param >= t.lower_bound AND f.param < t.upper_bound
                    )
                    SELECT 
                        d_value,
                        t_range_lower_bound,
                        COUNT(*) AS num_delays
                    FROM 
                        delays
                    GROUP BY 
                        d_value,t_range_lower_bound
                    ORDER BY 
                        d_value,t_range_lower_bound;
                """
            print("query:\n", query)
            cur.execute(query)
            rows = cur.fetchall()
            print("===>",rows)
            stats = []
            for row in rows:
                stats.append({
                    "x": row[0],
                    "y": row[1],
                    "c": row[2],
                })

            if action == "Perfomance Tuning":
                performance = perfomance_tuning(conn, 10, query, ["No Index","With Index"],
                    '''
                    DROP INDEX IF EXISTS idx_flight_1;
                    DROP INDEX IF EXISTS idx_flight_5;
                    DROP INDEX IF EXISTS idx_weather_condition_1; 
                    '''
                    ,
                    '''
                    CREATE INDEX idx_flight_1 ON flight (carrier_code); 
                    CREATE INDEX idx_flight_5 ON flight (departure_delay); 
                    CREATE INDEX idx_weather_condition_1 ON weather_condition (wind_dir); 
                    '''
                )

        except Error as e:
            print("error:", e)
            #return jsonify({"error": f"Database error: {e}"}), 500
            return f"Error {e}"
    
        # present data

        print("-------------------")

        print(stats)
        print("============")

        # Extract unique values for X and Y, convert them to integers
        x = sorted(set(int(item[0]) for item in rows)) # d_value {1,2,3,4,5}; 1: on time, 2: < 10min, etc.
        y = sorted(set(int(item[1]) for item in rows))[::-1] # t_range_lower_bound
        # [::-1] get rid of the last one

        print("X:", x)
        print("Y:", y)

        # Create an empty matrix V
        u = [[0 for _ in range(len(y))] for _ in range(len(x))]


        # Populate the matrix V with the values from data
        for x_, y_, value in rows:
            i = x.index(int(x_))
            j = y.index(int(y_))
            u[i][j] = value

        xx = []
        yy = []
        top = []

        for row in rows:
            xx.append(int(row[0]))
            yy.append(int(row[1]))
            top.append(math.log(row[2]))
        
        bottom = np.zeros_like(top)

        print("xx:", xx)
        print("yy:", yy)
        print("V:", top)
        print("0:", bottom)

        fig = plt.figure(figsize=(6, 6))
        ax1 = fig.add_subplot(111, projection='3d')

        width = math.fabs(y[0]-y[1]) * 1 / 5
        depth = math.fabs(x[0]-x[1]) * 1 / 5
        
        colors_list = ['Magenta', 'blue', 'Lime', 'green', 'red'] # Define discrete colors
        cmap = ListedColormap(colors_list)
        norm = Normalize(vmin=min(xx), vmax=max(xx))  # Normalize the data to [0, 1] for the colormap
        colors = cmap(norm(xx))  # Generate colors

        ax1.set_xlabel(parameter)
        ax1.set_ylabel('delay')
        ax1.set_zlabel("log ( number of flights )")       

        ax1.set_yticks( [1,2,3,4,5], labels=['On time', '<10', '(10,30]', '(30,60]', '>1h']) 

        ax1.bar3d(yy, xx, bottom, width, depth, top, color=colors, shade=False)
        ax1.view_init(20, 60)
        plt.savefig('images/stats_taxiout.png')
        # plt.show()

    delay_labels = {1: "On time",
            2: "< 10 min]",
            3: "(10, 30 min]",
            4: "(30, 60 min]",
            5: "> 1 hour"
            }

    wdirs = { 
        'E':'', 'ESE':'', 'SE':'', 'SSE':'',
        'S':'', 'SSW':'', 'SW':'', 'WSW':'',
        'W':'', 'WNW':'', 'NW':'', 'NNW':'',
        'N':'', 'NNE':'', 'NE':'', 'ENE':'',
        'VAR':'','CALM':''
    }
    for wd in wind_dirs:
        wdirs[wd] = 'checked'

    return render_template('ff5_relations.html', carriers=carriers, p=parameter, dl=delay_labels, x=x, y=y, v=u, nt=nt, stats=performance, wdirs=wdirs)

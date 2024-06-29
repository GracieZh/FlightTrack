from flask import render_template, request
from conn import get_conn
from psycopg2 import Error
import matplotlib.pyplot as plt

# Feature 5: 
# users can explore flight schedules visually to see frequency and trends over time

def get_country_code(conn):

    query = """
            SELECT DISTINCT 
                a.iso_country,
                c.name 
            FROM 
                flight f 
            JOIN 
                airports a 
            ON 
                f.arrival_airport_code = a.iata_code
            JOIN 
                country c 
            ON 
                a.iso_country = c.a2;    
        """

    cur = conn.cursor()
    cur.execute(query)
    rows = cur.fetchall()
    print("get_country_code ===>",rows)
    countries = []
    for row in rows:
        countries.append({
            "id": row[0],
            "name": row[1]
        })
    cur.close()
    return countries

def get_state_code(conn, country):

    query = f"""
        WITH dest AS (
            SELECT DISTINCT 
                a.iso_country cid,
                c.name cname,
                a.iso_region as region,
                SUBSTRING(a.iso_region, 4,10) AS sid
            FROM 
                flight f 
            JOIN 
                airports a 
            ON 
                f.arrival_airport_code = a.iata_code
            JOIN 
                country c
            ON 
                a.iso_country = c.a2
            WHERE
                a.iso_country = '{country}'
        )
        SELECT 
            cid, cname, region, sid, s.state
        FROM 
            dest d
        LEFT JOIN -- left join b/c there's flights for multiple countries and we only have region data for the US. If we used inner join, we wouldn't be able to select data from non-US countries.
            usstate s 
        ON 
            d.sid = s.code
        ORDER BY
            region
        """

    cur = conn.cursor()
    cur.execute(query)
    rows = cur.fetchall()
    print("get_state_code ===>",rows)
    states = []
    for row in rows:
        states.append({
            "cid": row[0],
            "name": row[1],
            "region": row[2],
            "sid": row[3],
            "state": row[4]
        })
    cur.close()
    return states

def get_cities(conn, region):

    query = f"""
        WITH dest AS (
            SELECT DISTINCT 
                a.iso_country cid,
                c.name cname,
                a.iso_region as region,
                SUBSTRING(a.iso_region, 4,10) AS sid,
                a.municipality AS city
            FROM 
                flight f 
            JOIN 
                airports a 
            ON 
                f.arrival_airport_code = a.iata_code
            JOIN 
                country c
            ON 
                a.iso_country = c.a2
            WHERE
                a.iso_region = '{region}'
        )
        SELECT 
            cid, cname, region, sid, s.state, city
        FROM 
            dest d
        LEFT JOIN
            usstate s 
        ON 
            d.sid = s.code
        ORDER BY
            city
        """

    cur = conn.cursor()
    cur.execute(query)
    rows = cur.fetchall()
    print("get_cities ===>",rows)
    cities = []
    for row in rows:
        cities.append({
            "cid": row[0],
            "name": row[1],
            "region": row[2],
            "sid": row[3],
            "state": row[4],
            "city": row[5]
        })
    cur.close()
    return cities

def get_flights(conn, region, city):
    query = f"""
        WITH dest AS (
            SELECT 
                DISTINCT tail_num,
                arrival_airport_code dst,
                a.iso_country cid,
                c.name cname,
                a.iso_region as region,
                SUBSTRING(a.iso_region, 4,10) AS sid,
                municipality AS city,
                day_of_week
            FROM 
                flight f 
            JOIN 
                airports a 
            ON 
                f.arrival_airport_code = a.iata_code
            JOIN 
                country c
            ON 
                a.iso_country = c.a2
            WHERE
                a.iso_region = '{region}' AND  municipality = '{city}'
        )
        SELECT 
            cid, cname, region, sid, s.state, city, tail_num, dst, day_of_week
        FROM 
            dest d
        LEFT JOIN  -- some places don't have state names. we don't want to lose entries
            usstate s 
        ON 
            d.sid = s.code
        ORDER BY
            city
        """

    cur = conn.cursor()
    cur.execute(query)
    rows = cur.fetchall()
    # print("get_flights ===>",rows)
    flights = []
    for row in rows:
        flights.append({
            "cid": row[0],
            "name": row[1],
            "region": row[2],
            "sid": row[3],
            "state": row[4],
            "city": row[5],
            "tn": row[6],
            "dst": row[7],
            "wday": row[8]
        })
    cur.close()
    return flights

def get_flight_group(conn, region, city):
    query = f"""
        SELECT 
            day_of_week as dw,
            count(*) as c
        FROM 
            flight f 
        JOIN 
            airports a 
        ON 
            f.arrival_airport_code = a.iata_code
        WHERE
            a.iso_region = '{region}' AND  municipality = '{city}'
        GROUP BY
            day_of_week
        """

    cur = conn.cursor()
    cur.execute(query)
    rows = cur.fetchall()
    # print("get_flights ===>",rows)
    gflight = {"wday":[], "num":[]}
    for row in rows:
        gflight["wday"].append(row[0])
        gflight["num"].append(row[1])
    cur.close()
    return gflight

def get_flights_by_tail_num(conn, tn):
    query = f"""
            SELECT 
                tail_num,
                arrival_airport_code dst,
                a.name as aname,
                municipality AS city,
                month,
                day_of_month,
                day_of_week
            FROM 
                flight f 
            JOIN 
                airports a 
            ON 
                f.arrival_airport_code = a.iata_code
            WHERE
                tail_num = '{tn}'
        """

    cur = conn.cursor()
    cur.execute(query)
    rows = cur.fetchall()
    # print("get_flights ===>",rows)
    flights = []
    for row in rows:
        flights.append({
            "tn": row[0],
            "dst": row[1],
            "aname": row[2],
            "city": row[3],
            "month": row[4],
            "day": row[5],
            "wday": row[6]
        })
    cur.close()
    return flights

def flights_schedule():

    country = request.args.get('country')
    region = request.args.get('region')
    city = request.args.get('city')
    tn = request.args.get('tn')
    print("country:", country)
    print("region:", region)

    countries = []
    states = []
    cities = []
    flights = []    
    gflights = {}   # flight number group by day of week
    tflights = []  # flights with same tail_num

    # query database
    try:
        conn = get_conn()
        countries = get_country_code(conn)
        if country != None:
            states = get_state_code(conn, country)
        if region != None:
            cities = get_cities(conn, region)
        if city != None:
            flights = get_flights(conn, region, city)
            gflights = get_flight_group(conn, region, city)
        if tn != None:
            tflights = get_flights_by_tail_num(conn, tn)

    except Error as e:
        print("error:", e)
        #return jsonify({"error": f"Database error: {e}"}), 500
        return f"Error {e}"

    # Present data

    print("gflights")
    if(len(gflights)>0):
        fig, ax = plt.subplots()

        bar_container = ax.bar(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],gflights["num"])
        #ax.xticks(range(1,8), ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'])
        ax.bar_label(bar_container, fmt='{:,.0f}')
        ax.set(ylabel='number of flights', title='Flight distribution')

        # plt.show()
        plt.savefig('images/flights_schedule.png')

    return render_template('f5_flights_schedule.html', countries=countries, states=states, cities=cities, flights=flights, tflights=tflights, gflights=gflights)



def flights_search_by_person():

    # query database
    
    flights = []
    # Present data
    return render_template('flights_search_by_person.html', rows=flights)
from flask import render_template, request
from conn import get_conn
from psycopg2 import Error

def advanced_search_4():

    submit = request.args.get('submit')
    fname = request.args.get('fname')
    lname = request.args.get('lname')

    # ?fname=Makai&lname=MAXWELL&submit=Search+crew

    captains = []
    crew = []
    performance = []

    if submit == "View Captains":
        try:
            conn = get_conn()
            cur = conn.cursor()
            cur.execute("SELECT fname, lname FROM users WHERE ssn IN (SELECT ssn FROM captain) LIMIT 50;")
            rows = cur.fetchall()
            print("===>",captains)
            for row in rows:
                captains.append({
                    "fname": row[0],
                    "lname": row[1],
                })

        except Error as e:
            print("error:", e)
            return f"Error {e}"
          
    # if :
    if (submit == "Search Crew" or submit == "Performance Tuning") and len(fname) > 0 and len(lname) >  0:
        query = f"""
            WITH crew AS (
                SELECT tail_num, user_id 
                FROM flight_crew_log 
                WHERE tail_num IN (
                    SELECT tail_num 
                    FROM flight_crew_log 
                    WHERE user_id IN ( 
                        SELECT ssn FROM users WHERE fname='{fname}' AND lname='{lname}' 
                    ) 
                    LIMIT 1
                )
            ),
            captain_ AS (
                SELECT ssn, 'captain' AS title 
                FROM captain 
                WHERE ssn IN (SELECT user_id FROM crew)
            ),
            firstofficer_ AS (
                SELECT ssn, 'first_officer' AS title 
                FROM first_officer 
                WHERE ssn IN (SELECT user_id FROM crew)
            ),
            attendant_ AS (
                SELECT ssn, 'attendant' AS title 
                FROM attendant 
                WHERE ssn IN (SELECT user_id FROM crew)
            ),
            pilot_ AS (
                SELECT ssn, 'pilot' AS title 
                FROM pilot 
                WHERE ssn IN (SELECT user_id FROM crew) 
                AND ssn NOT IN (SELECT ssn FROM captain) 
                AND ssn NOT IN (SELECT ssn FROM first_officer)
            ),
            crewwithtitle AS (
                SELECT ssn, title FROM captain_ 
                UNION
                SELECT ssn, title FROM firstofficer_ 
                UNION
                SELECT ssn, title FROM pilot_ 
                UNION
                SELECT ssn, title FROM attendant_
            )
            SELECT 
                u.ssn, 
                u.fname, 
                u.lname, 
                j.title, 
                (SELECT tail_num FROM crew c WHERE u.ssn = c.user_id LIMIT 1) AS tail_num
            FROM users u
            JOIN crewwithtitle j ON u.ssn = j.ssn
            ORDER BY title;
            """
        try:
            conn = get_conn()
            cur = conn.cursor()
            cur.execute(query)
            crew = cur.fetchall()
            print("===>",crew)
        except Error as e:
            print("error:", e)
            return f"Error {e}"
          
    return render_template('ff4_advanced_search.html', captains=captains, crew=crew, stats=performance, name=['' if fname is None else fname, '' if lname is None else lname])

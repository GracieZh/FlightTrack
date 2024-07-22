from flask import render_template, request
from conn import get_conn
from psycopg2 import Error
from feature_ff1 import perfomance_tuning

def get_login_users():
    try:
        conn = get_conn()
        cur = conn.cursor()
        cur.execute("""
                        (SELECT user_id, password, 'admin', '' FROM user_login WHERE is_admin=1 and is_crew_member=0 LIMIT 1)
                        UNION
                        (SELECT user_id, password, '', 'crew member' FROM user_login WHERE is_admin=0 and is_crew_member=1 LIMIT 1)
                        UNION
                        (SELECT user_id, password, 'admin', 'crew member' FROM user_login WHERE is_admin=1 and is_crew_member=1 LIMIT 1)
                        UNION
                        (SELECT user_id, password, '', '' FROM user_login WHERE is_admin=0 and is_crew_member=0 LIMIT 1)
                        ;
                    """)
        rows = cur.fetchall()
        print("===>",rows)
        return rows

    except Error as e:
        print("error:", e)
        return []
    


def generate_login_accounts():
    try:
        conn = get_conn()
        cur = conn.cursor()
        cur.execute("""
            DROP TABLE IF EXISTS user_login;
            CREATE TABLE IF NOT EXISTS user_login (
                user_id        INTEGER,
                password       VARCHAR(50),
                is_admin       INTEGER NOT NULL DEFAULT 0,
                is_crew_member INTEGER NOT NULL DEFAULT 0,
                FOREIGN KEY (user_id) REFERENCES users(ssn) ON DELETE CASCADE,
                PRIMARY KEY (user_id)
            );
            """
            )
        conn.commit()

        # Select 8 random users from the "users" table and add grant them 4 different combination of privileges
        cur.execute("""
                INSERT INTO user_login (user_id, password, is_admin, is_crew_member)
                WITH user_count AS (
                    SELECT COUNT(*) AS cnt FROM users
                ),
                random_offsets AS (
                    SELECT (1 + floor(random() * cnt)::int) AS random_offset,
                    row_number
                    FROM generate_series(1, 8) as row_number, user_count
                ),
                user_privilege AS (
                    SELECT unnest(ARRAY[1, 1, 0, 0, 1, 1, 0, 0]) AS is_admin,
                           unnest(ARRAY[0, 0, 1, 1, 1, 1, 0, 0]) AS is_crew,
                           generate_series(1, 8) AS row_number
                )
                SELECT
                    (SELECT ssn FROM users OFFSET random_offsets.random_offset LIMIT 1),
                    'password' AS password,
                    user_privilege.is_admin,
                    user_privilege.is_crew
                FROM random_offsets
                JOIN user_privilege ON random_offsets.row_number = user_privilege.row_number;
                """)
        conn.commit()

    except Error as e:
        print("error:", e)
        return f"Error {e}"

    userinfo = {"id":"", "admin":0, "crew":0, "message":None}
    return render_template('ff4_advanced_search.html', captains=[], crew=[], stats=[], name=[], login_users=get_login_users(), userinfo=userinfo)

def login():
    uid = request.args.get('uid')
    pw = request.args.get('pw')
    userinfo = {"id":"", "admin":0, "crew":0, "message":None}
    if uid and len(uid)>0 and len(pw)>0:
        try:
            conn = get_conn()
            cur = conn.cursor()
            cur.execute("SELECT user_id, is_admin, is_crew_member FROM user_login WHERE user_id=%s and password=%s",(uid,pw))
            user = cur.fetchone()
            print("===>",user)
            if not user:
                userinfo["message"] = "Invalid user_id or password"
            else:
                userinfo["id"] = user[0]
                userinfo["admin"] = user[1]
                userinfo["crew"] = user[2]
        except Error as e:
            print("Error:", e)  # Print the error message
            print("Error code:", e.pgcode)  # Print the PostgreSQL error code
            if(e.pgcode == '22P02'): # Edge case: user id is not the correct type
                userinfo["message"] = "Invalid user_id: user_id must be a number"
            else:                
                print("Error details:", e.pgerror)  # Print the detailed error message
                print("Error number:", e.diag.message_primary)  # Print the error number (if available)
                return f"Error {e.pgcode} {e}"
    return userinfo

def get_user_info():
    uid = request.args.get('uid')
    userinfo = {"id":"", "admin":0, "crew":0, "message":None}
    if uid and len(uid)>0:
        try:
            conn = get_conn()
            cur = conn.cursor()
            cur.execute("SELECT user_id, is_admin, is_crew_member FROM user_login WHERE user_id=%s ",(uid,))
            user = cur.fetchone()
            print("===>",user)
            if not user:
                userinfo["message"] = "Invalid user_id or password"
            else:
                userinfo["id"] = user[0]
                userinfo["admin"] = user[1]
                userinfo["crew"] = user[2]
        except Error as e:
            print("Error:", e)  # Print the error message
            print("Error code:", e.pgcode)  # Print the PostgreSQL error code
            if(e.pgcode == '22P02'):
                userinfo["message"] = "Invalid user_id: user_id must be a number"
            else:                
                print("Error details:", e.pgerror)  # Print the detailed error message
                print("Error number:", e.diag.message_primary)  # Print the error number (if available)
                # return f"Error {e.pgcode} {e}"
            
    return userinfo

def advanced_search_4():

    submit = request.args.get('submit')

    if submit=="Generate login accounts":
        return generate_login_accounts()

    if submit=='Login':
        userinfo = login()
    else:
        userinfo = get_user_info()

    fname = request.args.get('fname')
    lname = request.args.get('lname')

    # ?fname=Makai&lname=MAXWELL&submit=Search+crew

    captains = []
    crew = []
    performance = []

    login_users = get_login_users()
    print("login_users", login_users)

    if submit == "View Captains":
        if userinfo["admin"] == 0:
            userinfo["message"]="This feature needs admin's privilege."
        else:
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

    if submit == "Search Crew" or submit == "Performance Tuning":
        if userinfo["crew"] == 0:
            userinfo["message"]="This feature needs crew's privilege."
        elif len(fname) > 0 and len(lname) > 0:
            stmt_create_view = """
                DROP VIEW IF EXISTS crew_with_title;

                CREATE VIEW crew_with_title AS
                SELECT tail_num, t.ssn, title, fname, lname
                FROM (
                    SELECT 
                        tail_num, 
                        ssn, 
                        'captain' AS title
                    FROM 
                        captain
                    JOIN 
                        flight_crew_log ON ssn = user_id
                    UNION
                    SELECT 
                        tail_num, 
                        ssn, 
                        'first officer' AS title
                    FROM 
                        first_officer
                    JOIN 
                        flight_crew_log ON ssn = user_id
                    UNION
                    SELECT 
                        tail_num, 
                        user_id, 
                        'pilot' AS title
                    FROM 
                        pilot
                    JOIN 
                        flight_crew_log ON ssn = user_id
                    WHERE 
                        ssn NOT IN (SELECT DISTINCT ssn FROM captain)
                    AND
                        ssn NOT IN (SELECT DISTINCT ssn FROM first_officer)
                    UNION
                    SELECT 
                        tail_num, 
                        ssn, 
                        'attendant' AS title
                    FROM 
                        attendant
                    JOIN 
                        flight_crew_log ON ssn = user_id
                ) as t
                JOIN (
                    SELECT ssn, fname, lname FROM users
                ) as u
                ON t.ssn = u.ssn;
                """
            
            query = f"""
                SELECT 
                    ssn, 
                    fname, 
                    lname, 
                    title, 
                    tail_num
                FROM 
                    crew_with_title
                WHERE tail_num IN (
                    SELECT tail_num 
                    FROM flight_crew_log 
                    WHERE user_id IN ( 
                        SELECT ssn FROM users WHERE fname='{fname}' AND lname='{lname}' 
                    ) 
                    LIMIT 1
                )
                ORDER BY title;
                """    

            query_test = f"""
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
                cur.execute(stmt_create_view)
                conn.commit()

                cur.execute(query)
                crew = cur.fetchall()
                print("===>",crew)
            except Error as e:
                print("error:", e)
                return f"Error {e}"
            
            if submit == "Performance Tuning":
                performance = perfomance_tuning(conn, 100, query_test, query, ["JOIN", "VIEW"])

    print("userinfo", userinfo)

    return render_template('ff4_advanced_search.html', captains=captains, crew=crew, stats=performance
        , name=['' if fname is None else fname, '' if lname is None else lname], login_users=login_users, userinfo=userinfo)

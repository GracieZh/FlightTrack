from flask import render_template, request
from conn import get_conn
from psycopg2 import Error

def advanced_search_2():

    submit = request.args.get('submit')

    query = []
    n = 7
    for i in range(2,n):
        k = i-2
        query.append("""
                WITH fbu AS (
                    SELECT 
                        flight_id, user_id 
                    FROM 
                        boarding_tickets b 
                    JOIN 
                        passengers p ON b.ticket_id = p.ticket_id
                ),
                uc AS (
                SELECT
                    p1.user_id AS user1,"""
        )
        for j in range(1,i):
            query[k] += f"""
                    p{j+1}.user_id AS user{j+1},"""
        query[k] += """
                    array_agg(DISTINCT tail_num ORDER BY tail_num ) as flights
                FROM
                    fbu p1"""
        for j in range(1, i):
            query[k] += f"""
                JOIN
                    fbu p{j+1} ON p1.flight_id = p{j+1}.flight_id AND p{j}.user_id < p{j+1}.user_id"""
        query[k] += """
                JOIN
                    flight f ON p1.flight_id = f.id
                GROUP BY
                    p1.user_id"""
        for j in range(1, i):
            query[k] += f", p{j+1}.user_id"
        query[k] += """
                ),
                fusers as (
                SELECT
                    user1, 
                    (SELECT fname || ' ' || lname FROM users WHERE uc.user1 = users.ssn) as name1,"""
        for j in range(1, i):
            query[k] += f"""
                    user{j+1},
                    (SELECT fname || ' ' || lname FROM users WHERE uc.user{j+1} = users.ssn) as name{j+1},"""

        query[k] += """
                    flights,
                    array_length(flights, 1) AS flight_count
                FROM
                    uc
                ORDER BY
                    flight_count DESC
                )
                SELECT 
                    *
                FROM 
                    fusers 
                WHERE
                    flight_count > 1
                LIMIT 
                    20;
                """

    for i in range(2,n):
        k = i-2
        print("query", i, query[k])

    results = []
    performance = []

    if submit != None:
        try:
            conn = get_conn()
            cur = conn.cursor()
            for i in range(2,n):
                k = i-2
                cur.execute(query[k])
                results.append(())
                results[k] = cur.fetchall()
                print("===> result", k,results[k])

        except Error as e:
            print("error:", e)
            #return jsonify({"error": f"Database error: {e}"}), 500
            return f"Error {e}"

    return render_template('ff2_advanced_search.html', results=results, stats=performance)

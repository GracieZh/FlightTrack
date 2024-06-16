from flask import render_template
from conn import get_conn

def user_list():

    # query database
    try:
        conn = get_conn()
        cur = conn.cursor()
        cur.execute("SELECT * FROM users")
        rows = cur.fetchall()
        print("===>",rows)
        users = []
        for row in rows:
            users.append({
                "id": row[0],
                "fullname": row[1],
                "username": row[2],
                "password": row[3]
            })
    except Error as e:
        print("error:", e)
        # return jsonify({"error": f"Database error: {e}"}), 500
        return f"Error {e}"

    return render_template('user_list.html', messages=users)

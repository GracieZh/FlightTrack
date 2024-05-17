from flask import Flask, jsonify
from psycopg2 import connect, Error
from flask_cors import CORS

app = Flask(__name__)
cors = CORS(app, resources={r"*": {"origins": "http://localhost:8080"}})

# Connects to local Postgres database
try:
    conn = connect(
        dbname="appdb",
        user="postgres",
        password="password",
        host="localhost",
        port="5432"
    )
except Error as e:
    print(f"Error connecting to the database: {e}")
    exit(1)

# Handles GET request for userlist
@app.route('/api/userlist', methods=['GET'])
def get_userlist():
    try:
        cur = conn.cursor()
        cur.execute("SELECT * FROM users")
        rows = cur.fetchall()
        print("===>",rows)
        user_list = []
        for row in rows:
            user_list.append({
                "id": row[0],
                "fullname": row[1],
                "username": row[2],
                "password": row[3]
            })
        return jsonify(user_list)
    except Error as e:
        return jsonify({"error": f"Database error: {e}"}), 500


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
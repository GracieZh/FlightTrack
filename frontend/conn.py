from psycopg2 import connect

def get_conn():
    conn = connect(
        dbname="appdb",
        user="postgres",
        password="password",
        host="localhost",
        port="5432"
    )
    return conn

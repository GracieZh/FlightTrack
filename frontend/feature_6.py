from flask import render_template, request
from conn import get_conn
from psycopg2 import Error
import random
from datetime import datetime, timedelta

def get_random_users(conn, number):
    try:
        cur = conn.cursor()
        cur.execute(f"SELECT * FROM users_gen order by random() limit {number};")
        users = cur.fetchall()
        cur.execute(f"SELECT count(*) FROM users_gen;")
        rows = cur.fetchall()
        n = int(rows[0][0])
        cur.close()

        return n, users
    except Error as e:
        print("Error", e)
        return 0, []

def create_user_table(conn, cur):
    # drop table
    cur.execute("DROP TABLE IF EXISTS users_gen;")
    conn.commit() 

    # create table
    cur = conn.cursor()
    cur.execute("""
                    CREATE TABLE users_gen (
                        ssn INTEGER PRIMARY KEY,
                        fname VARCHAR(50),
                        lname VARCHAR(50),
                        bdate VARCHAR(11),
                        email VARCHAR(100),
                        address VARCHAR(50),
                        gender VARCHAR(1)
                    );
                """)
    conn.commit() 


def generate_users(number):
    print("generate_users", number)
    try:
        conn = get_conn()
        cur = conn.cursor()

        task["total"] = number
        task["done"] = 1

        create_user_table(conn, cur)

        cur.execute("SELECT count(*) FROM names;")
        rows = cur.fetchone()
        name_count = rows[0]
        print("name_count", rows, name_count)

        cur.execute("SELECT count(*) FROM streets;")
        rows = cur.fetchone()
        street_count = rows[0]
        print("street_count", rows, street_count)

        def random_date(start_year, end_year):
            start_date = datetime(start_year, 1, 1)
            end_date = datetime(end_year, 12, 31)
            delta = end_date - start_date
            random_days = random.randint(0, delta.days)
            return start_date + timedelta(days=random_days)

        for i in range(0,number):
            task["done"] = i

            # Randomly select gender
            if random.random() < 0.5:
                gender = 'M'
                random_boy = random.randint(0, name_count-1)
                cur.execute("SELECT boy FROM names OFFSET %s LIMIT 1;", (random_boy,))
                rows = cur.fetchone()
                first_name = rows[0]
            else:
                gender = 'F'
                random_girl = random.randint(0, name_count-1)
                cur.execute("SELECT girl FROM names OFFSET %s LIMIT 1;", (random_girl,))
                rows = cur.fetchone()
                first_name = rows[0]

            # Randomly select last name and address

            random_last = random.randint(0, name_count-1)
            cur.execute("SELECT last FROM names OFFSET %s LIMIT 1;", (random_last,))
            rows = cur.fetchone()
            last_name = rows[0]

            random_address = random.randint(0, street_count-1)
            cur.execute("SELECT street FROM streets OFFSET %s LIMIT 1;", (random_address,))
            rows = cur.fetchone()
            street = rows[0]

            email = first_name + '.' + last_name + '@cs338.uw';

            date = random_date(1960, 2003) # can't be too young or too old
            dob = date.strftime('%Y-%m-%d') 


            num = random.randint(1, 1000)
            address = str(num) + ' ' + street

            # Insert the generated user record into the users_gen table

            for _ in range(100):
                ssn = random.randint(111111111,999999999)
                try:
                    cur.execute("INSERT INTO users_gen ( ssn, fname, lname, bdate, email, address, gender) VALUES (%s,%s,%s,%s,%s,%s,%s);",
                        (ssn, first_name, last_name, dob, email, address, gender))
                    conn.commit()
                except Error as e:
                    conn.rollback()  # Rollback on error #important for [1356] ERROR:  duplicate key value violates unique constraint "users_pkey"  
                    # if duplicate key then continue
                    #print("%d, %s, %s, %s, %s, %s, %s, %s, %s, %s, %3d%03d9999" % (ssn, bdate, firstname, lastname, 'M' if gender==1 else 'F', door, row['street'], row['type'], city, prov, phonearea, phonenum))
                    #print("Error", e)
                    continue
                break

        cur.close()
        # result["nusers"], result["users"] = get_random_users(conn, 16)
        # print("result:", result)
        conn.close()
        task["done"] = task["total"]
        print("generate_users done")

    except Error as e:
        print("error:", e)
        # return jsonify({"error": f"Database error: {e}"}), 500
        return f"Error {e}"


from threading import Thread
import time

task = {"total":100, "done":1}

def generate_users_with_stored_procedure_and_trigger(number):
    print("generate_users_with_stored_procedure_and_trigger", number)
    try:
        conn = get_conn()
        cur = conn.cursor()

        task["total"] = number
        task["done"] = 1

        step = (999999999 - 111111111) // number - 2
        if step % 5 == 0:
            step -= 2
        if step % 2 == 0:
            step -= 1
        if step <= 0:
            step = 1

        cur.execute("DROP SEQUENCE IF EXISTS pk_sequence_for_users;")
        conn.commit() 

        cur.execute('CREATE SEQUENCE pk_sequence_for_users START 111111111 INCREMENT BY %s', (step,))
        conn.commit() 

        create_user_table(conn, cur)

        # create trigger
        cur.execute("""
            CREATE TRIGGER before_insert_trigger
            BEFORE INSERT ON users_gen
            FOR EACH ROW
            EXECUTE FUNCTION insert_with_reverse_pk();
            """)
        conn.commit() 

        for i in range(0,number,100):
            cur.execute("CALL generate_random_users(%s);", (100,))
            conn.commit()
            task["done"] = i

        cur.close()
        conn.close()
        task["done"] = task["total"]

        print("generate_users_with_stored_procedure_and_trigger done")

    except Error as e:
        print("error:", e)
        # return jsonify({"error": f"Database error: {e}"}), 500
        return f"Error {e}"
    
def get_progress():
    return f'{{"done": {task["done"]}, "total": {task["total"]}, "status": "ok"}}'


def user_gen():
    # generate tickets
    # ?nf=10&ce=10&cp=5&cb=3&cf=2

    req = request.args.get('req')
    if req == "progress":
        return get_progress()

    action = request.args.get('action')
    number = request.args.get('nu', type=int) # gen user
    
    result = {"users":[], "nusers":0, "gen_users":0, "tuning":[], "ticket_created":0, "crew_member_assigned":0, "tickets_assigned":0}

    # query database

    print("number = ", number)

    if number != None and number > 0 and number < 10000001:
        if action == "Perfomance Tuning":
            if number < 10001:
                a = time.time()
                generate_users(number)
                b = time.time()
                generate_users_with_stored_procedure_and_trigger(number)
                c = time.time()
                d1 = "%.2f" % ((b-a)*1000)
                d2 = "%.2f" % ((c-b)*1000)
                print( f"time diff is {d1} {d2}")
                result["tuning"] = [number,d1,d2]
        else:
            thread = Thread(target=generate_users_with_stored_procedure_and_trigger, args=(number,))
            thread.start()
            result["gen_users"] = 1

    nf = request.args.get('nf', type=int)  # number of flights
    ce = request.args.get('ce', type=int)  # number of economy class tickets per flight
    cp = request.args.get('cp', type=int)  # number of premium economy class tickets per flight
    cb = request.args.get('cb', type=int)  # number of business class tickets per flight
    cf = request.args.get('cf', type=int)  # number of first class tickets per flight

    # nf != None means the 'Generate' button was clicked and there's a value for nf
    # nf > 0 because tickets must be generated for at least one flight
    # ce + cp + cb + cf > 0 because each flight must have at least one ticket generated
    if nf != None and nf > 0 and ce + cp + cb + cf > 0:
        try:
            conn = get_conn()
            cur = conn.cursor()
            cur.execute("SELECT generate_tickets(%s,%s,%s,%s,%s);", (nf, ce, cp, cb, cf))
            rows = cur.fetchone()
            conn.commit()
            cur.close()
            conn.close()
            print("gen tickets ===>",rows)
            result["ticket_created"] = rows[0]
        except Error as e:
            print("error:", e)
            # return jsonify({"error": f"Database error: {e}"}), 500
            return f"Error {e}"

    # assign crew to flight 
    # ?nfc=10&ncm=10
    nfc = request.args.get('nfc', type=int) # Number of flights for assigning crew
    ncm = request.args.get('ncm', type=int) # Number of crew members for each flight

    if nfc != None and nfc > 0 and ncm > 0:
        try:
            conn = get_conn()
            cur = conn.cursor()
            cur.execute("DROP TABLE IF EXISTS flight_crew_log;")
            conn.commit() 
            cur.execute("""
                            CREATE TABLE IF NOT EXISTS flight_crew_log (
                                tail_num VARCHAR(7),
                                user_id INTEGER
                            );
                        """)
            conn.commit() 
            cur.execute("SELECT assign_crew_to_flights(%s,%s);", (nfc, ncm))
            rows = cur.fetchone() # function returns number of inserted crew members
            conn.commit()
            cur.close()
            conn.close()
            print("assign crew ===>",rows)
            result["crew_member_assigned"] = rows[0]
        except Error as e:
            print("error:", e)
            # return jsonify({"error": f"Database error: {e}"}), 500
            return f"Error {e}"

    # assign ticket to passenger
    # ?pt=100
    pt = request.args.get('pt', type=int) # percentage of tickets sold to passengers

    if pt != None and pt > 0:
        try:
            conn = get_conn()
            cur = conn.cursor()
            cur.execute("DROP TABLE IF EXISTS passengers;")
            conn.commit() 
            cur.execute("""
                            CREATE TABLE IF NOT EXISTS passengers (
                                ticket_id INTEGER,
                                user_id INTEGER
                            );
                        """)
            conn.commit() 
            cur.execute("SELECT assign_tickets(%s);", (pt,))
            rows = cur.fetchone()
            conn.commit()
            cur.close()
            conn.close()
            print("assign tickets ===>",rows)
            result["tickets_assigned"] = rows[0]
        except Error as e:
            print("error:", e)
            # return jsonify({"error": f"Database error: {e}"}), 500
            return f"Error {e}"

    return render_template('f6_gen_users.html', result=result)


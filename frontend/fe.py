
from flask import Flask, render_template, send_file, request
from feature_1 import flights_search
from feature_2 import stats_carriercode
from feature_3 import stats_carrier_performance
from feature_4 import stats_carrier_performance_compare
from feature_5 import flights_schedule
from feature_6 import user_gen
from users_1 import user_list

app = Flask(__name__)

@app.route('/css/<path:filename>')
def get_css(filename):
    return send_file('templates/'+filename, mimetype='text/css')

@app.route('/js/<path:filename>')
def get_js(filename):
    return send_file('templates/'+filename, mimetype='text/javascript')

@app.route('/png/<path:filename>')
def get_png(filename):
    return send_file('images/'+filename, mimetype='image/png')

@app.route('/')
def home():
    return render_template('home.html')

# Feature 1: display a graph of which flights cause the most delays based on selectable factors like airline carrier, time of day, etc.
@app.route('/flights/search')
def handle_flights_search():
    return flights_search()

# Feature 2:
@app.route('/stats/carriercode')
def handle_stats_carriercode():
    return stats_carriercode()

#Feature 3:  carrier performance
@app.route('/stats/carrierperformance')
def handle_stats_carrier_performance():
    return stats_carrier_performance()

#Feature 4:  compare carrier performance
@app.route('/stats/performancecompare')
def handle_carrier_performance_compare():
    return stats_carrier_performance_compare()

# Feature 5: 
# users can explore flight schedules visually to see frequency and trends over time
@app.route('/flights/schedule')
def handle_flights_schedule():
    return flights_schedule()

# Feature 6: 
@app.route('/user/gentickets')
def handle_user_gen():
    return user_gen()

@app.route('/user/list')
def handle_user_list():
    return user_list()

@app.route('/<path:path>')
def index(path):
    print("path:", path)
    return f"The path you entered is: {path}"

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080, debug=True)

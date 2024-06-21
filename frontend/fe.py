
from flask import Flask, render_template, send_file, request
from stats_1 import stats_carriercode, stats_carrier_performance, stats_carrier_performance_compare
from users_1 import user_list
from flights_1 import flights_search

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

@app.route('/stats/carriercode')
def handle_stats_carriercode():
    return stats_carriercode()

@app.route('/stats/carrierperformance')
def handle_stats_carrier_performance():
    carrier_codes = request.args.getlist('c')   # Extract the list of values for the 'c' parameter 
    if len(carrier_codes) == 0:
        return stats_carrier_performance()
    else:
        return stats_carrier_performance_compare(carrier_codes)

@app.route('/flights/search')
def handle_flights_search():
    return flights_search()

@app.route('/user/list')
def handle_user_list():
    return user_list()

@app.route('/<path:path>')
def index(path):
    print("path:", path)
    return f"The path you entered is: {path}"


if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080, debug=True)

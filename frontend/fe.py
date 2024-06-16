
from flask import Flask, render_template, send_file
import json
import urllib.request
from stats_1 import stats_carriercode
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

@app.route('/stats/carriercode')
def handle_stats_carriercode():
    return stats_carriercode()

@app.route('/user/list')
def handle_user_list():
    return user_list()

@app.route('/<path:path>')
def index(path):
    print("path:", path)
    return f"The path you entered is: {path}"


if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080, debug=True)

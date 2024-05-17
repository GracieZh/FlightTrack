
from flask import Flask, render_template, send_file
import json
import urllib.request

app = Flask(__name__)

@app.route('/css/<path:filename>')
def get_css(filename):
    return send_file('templates/'+filename, mimetype='text/css')

@app.route('/')
def index():
    webURL = urllib.request.urlopen("http://localhost:5000/api/userlist")
    data = webURL.read()
    # print(data)
    encoding = webURL.info().get_content_charset('utf-8')
    users = json.loads(data.decode(encoding))
    # print("json", users)
    return render_template('index.html', messages=users)

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080, debug=True)

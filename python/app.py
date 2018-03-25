from flask import Flask
# from flask import send_file
from flask import jsonify
# from flask.ext.statsd import FlaskStatsd
# from time import sleep

import json

app = Flask(__name__)
# FlaskStatsd(app=app, host='graphite', port=8125, prefix='python')

# static_dir = '../store/static/files'

# resources_file = "../store/resources.json"

# with open(resources_file) as f:
#     resource_data = json.load(f)

@app.route("/")
def root():
    return 'Hi, Im root'

# @app.route("/static/<string:filename>")
# def serve_static(filename):
#     return send_file('{}/{}'.format(static_dir, filename))

# @app.route("/resources/<int:resource_id>")
# def get_resource(resource_id):
#     return jsonify(resource_data[resource_id])

# @app.route("/sleep")
# def slow():
#     sleep(0.5)
#     return jsonify({'slept': 500})

# @app.route("/heavy")
# def heavy():
#     print 'serving heavy'
#     for i in xrange(40000000):
#         pass
#     print 'about to answer', i
#     return jsonify({'loops': i})

if __name__ == "__main__":
    app.run()

from flask import Flask, jsonify
from time import sleep

app = Flask(__name__)


@app.route("/")
def root():
    return "Hi, I'm root"


@app.route("/sleep")
@app.route("/sleep/<int:id>")
def slow(id=None):
    sleep(0.1)
    return jsonify({'id': id})


if __name__ == "__main__":
    app.run()

from flask import Flask, jsonify
from datetime import datetime

app = Flask(__name__)

todos = [
    {"id": 1, "title": "Learn Docker"},
    {"id": 2, "title": "Learn Flask"},
]


@app.route("/")
def home():
    return "Hello from VPS!"


@app.route("/time")
def time():
    return str(datetime.now())


@app.route("/todos")
def get_todos():
    return jsonify(todos)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

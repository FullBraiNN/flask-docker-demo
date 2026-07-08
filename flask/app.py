from flask import Flask, jsonify, request
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


@app.route("/todos", methods=["POST"])
def create_todo():
    data = request.get_json()

    todo = {
        "id": len(todos) + 1,
        "title": data["title"]
    }

    todos.append(todo)

    return jsonify(todo), 201


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

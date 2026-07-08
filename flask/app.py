from flask import Flask, jsonify, request
from datetime import datetime
import psycopg2

app = Flask(__name__)

def get_db_connection():
    conn = psycopg2.connect(
        host="postgres",
        database="todo_db",
        user="todo_user",
        password="secret123"
    )

    return conn

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

@app.route("/todos/<int:todo_id>")
def get_todo(todo_id):
    for todo in todos:
        if todo["id"] == todo_id:
            return jsonify(todo)

    return jsonify({"error": "Todo not found"}), 404

@app.route("/todos", methods=["POST"])
def create_todo():
    data = request.get_json()

    todo = {
        "id": len(todos) + 1,
        "title": data["title"]
    }

    todos.append(todo)

    return jsonify(todo), 201

@app.route("/todos/<int:todo_id>", methods=["DELETE"])
def delete_todo(todo_id):
    for todo in todos:
        if todo["id"] == todo_id:
            todos.remove(todo)
            return jsonify({"message": "Todo deleted"})

    return jsonify({"error": "Todo not found"}), 404

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

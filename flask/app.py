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
    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("SELECT id, title FROM todos;")

    rows = cur.fetchall()

    cur.close()
    conn.close()

    todos = []

    for row in rows:
        todos.append({
            "id": row[0],
            "title": row[1]
        })

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

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute(
        "INSERT INTO todos (title) VALUES (%s) RETURNING id;",
        (data["title"],)
    )

    todo_id = cur.fetchone()[0]

    conn.commit()

    cur.close()
    conn.close()

    todo = {
        "id": todo_id,
        "title": data["title"]
    }

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

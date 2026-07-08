from datetime import datetime
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Hello from Docker and it's working on your VPS!"

@app.route("/time")
def time():
    return str(datetime.now())

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

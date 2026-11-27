from flask import Flask
from redis import Redis

app = Flask(__name__)

redis_client = Redis(host="redis", port=6379)

@app.route("/count")
def count():
    visits = redis_client.incr("visits")
    return f"Visit count: {visits}"

@app.route("/")
def home():
    return "Hello from my Docker assignment!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
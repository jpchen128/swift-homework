import time
import random
from flask import Flask, Response
import argparse

app = Flask(__name__)

@app.route('/')
def stream_data():
    def generate():
        with open(args.source, 'r') as file:
            lines = file.readlines()

        while True:
            random_line = random.choice(lines)
            yield "{}\n".format(random_line.strip())
            time.sleep(1 / args.rate)
    return Response(generate(), mimetype='text/plain')

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Run the Flask server with a specified port.')
    parser.add_argument('--port', type=int, default=5000, help='The port number to run the server on.')
    parser.add_argument('--rate', type=int, default=1, help='The number of data strings to send in 1 second.')
    parser.add_argument('--source', type=str, help='The source data file to stream.')

    args = parser.parse_args()

    app.run(debug=True, port=args.port)

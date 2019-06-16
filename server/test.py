gitfrom flask import Flask, jsonify, make_response, abort
import time


app = Flask(__name__)
UNKNOWN_FOLDER = 'unknown'
KNOWN_FOLDER = 'known'


@app.route('/', methods=['GET', 'POST'])
def parse_request():
    return jsonify({'user_name': 'user', 'phone_number': '79991234567', 'orders': [{'id': 'id', 'date': time.time(), 'order_name': 'order'}, {'id': 'id', 'date': time.time(), 'order_name': 'order'}]})


@app.route('/auth', methods=['GET', 'POST'])
def parse_request1():
    return jsonify({'user_name': 'user', 'phone_number': '79991234567', 'orders': [{'id': 'id', 'date': time.time(), 'order_name': 'order'}, {'id': 'id', 'date': time.time(), 'order_name': 'order'}]})


@app.route('/registration', methods=['GET', 'POST'])
def parse_request2():
    abort(200)


@app.route('/order', methods=['GET', 'POST'])
def parse_request3():
    abort(200)


@app.errorhandler(500)
def not_complete():
    return make_response(jsonify({'error': 'authentication error'}), 500)


@app.errorhandler(400)
def not_complete():
    return make_response(jsonify({'error': 'request not complete'}), 400)


@app.errorhandler(404)
def not_found():
    return make_response(jsonify({'error': 'Not found'}), 404)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80, debug=False)

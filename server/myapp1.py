from flask import Flask, request, jsonify, make_response, abort
import face_recognition
import os
import json
import mysql.connector
import time


def get_img_lsts(unknown, known, unknown_dir, known_dir):
    for i in range(len(unknown)):
        unknown[i] = unknown_dir + '/' + unknown[i]
    for i in range(len(known)):
        known[i] = known_dir + '/' + known[i]
    known_images = []
    unknown_images = []
    for img in known:
        known_images.append(face_recognition.load_image_file(img))

    for img in unknown:
        unknown_images.append(face_recognition.load_image_file(img))

    return unknown_images, known_images


def recognise(unknown_img, known_img):
    unknown_encoding = face_recognition.face_encodings(unknown_img)[0]
    biden_encoding = face_recognition.face_encodings(known_img)[0]
    res = face_recognition.compare_faces([biden_encoding], unknown_encoding)
    for img in res:
        if img:
            return True
        else:
            return False


def recognise_user(unknown_img_lst, known_img_lst, known_images, known_dir):
    ui = 0
    ki = 0
    for unknown_img in unknown_img_lst:
        for known_img in known_img_lst:
            if recognise(unknown_img, known_img):
                return known_images[ki].replace(known_dir + '/', '').replace('.jpg', '')
            ki += 1
        ki = 0
        ui += 1
    return False


app = Flask(__name__)
UNKNOWN_FOLDER = 'unknown'
KNOWN_FOLDER = 'known'


@app.route('/registration', methods=['GET', 'POST'])
def parse_request():
    # app.config['UPLOAD_FOLDER'] = KNOWN_FOLDER
    # values = json.loads({''})
    # if request.method == 'POST':
    #     file = request.files['imageFile']
    #     values = request.get_json()
    # else:
    #     abort(500)
    # if file:
    #     if values == json.loads({''}):
    #         abort(500)
    #     user = values['name']
    #     number = values['phone']
    #
    #     cnx = mysql.connector.connect(user='root', password='root', host='127.0.0.1', database='cafe')
    #     cursor = cnx.cursor()
    #     add_customer = 'INSERT INTO customers (name, phone) VALUES (%s, %s)'
    #     data_customer = (user, number)
    #     cursor.execute(add_customer, data_customer)
    #     query = 'SELECT id FROM users WHERE name LIKE %s AND phone LIKE %s'
    #     data = (user, number)
    #     cursor.execute(query, data)
    #     for ids in cursor:
    #         userid = ids
    #     filename = str(userid) + ".jpg"
    #     file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
    #     return jsonify({'userId': userid})
    # else:
    #     abort(500)


@app.route('/auth', methods=['GET', 'POST'])
def parse_request1():
    # app.config['UPLOAD_FOLDER'] = UNKNOWN_FOLDER
    # if request.method == 'POST':
    #     file = request.files['imageFile']
    # else:
    #     abort(500)
    # if file:
    #     filename = "file.jpg"
    #     file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
    #     unknown = os.listdir(UNKNOWN_FOLDER)
    #     known = os.listdir(KNOWN_FOLDER)
    #     unknown_img_list, known_img_list = get_img_lsts(unknown, known, UNKNOWN_FOLDER, KNOWN_FOLDER)
    #     userid = recognise_user(unknown_img_list, known_img_list, known, KNOWN_FOLDER)
    #     if not userid:
    #         abort(500)
    #     os.remove('unknown/file.jpg')
    #     return jsonify({'userId': userid})


@app.route('/getuserinfo', methods=['GET', 'POST'])
def parse_request2():
    # app.config['UPLOAD_FOLDER'] = UNKNOWN_FOLDER
    # if request.method == 'POST':
    #     values = request.get_json()
    # else:
    #     abort(500)
    # userid = values['userId']
    # cnx = mysql.connector.connect(user='root', password='root', host='127.0.0.1', database='cafe')
    # cursor = cnx.cursor(dictionary=True)
    # query = 'SELECT (id, date, order_name) FROM orders  WHERE uid LIKE %s'
    # cursor.execute(query, userid)
    # orders = [{}]
    # for row in cursor:
    #     orders.append({'id': row['id'], 'date': row['date'], 'order': row['order_name']})
    # query = 'SELECT (phone, name) FROM customers WHERE uid LIKE %s'
    # cursor.execute(query, userid)
    # res = {}
    # for row in cursor:
    #     res = row
    # user = res['name']
    # phone_number = res['name']
    # return jsonify({'username': user, 'phone': phone_number, 'orders': orders})


@app.route('/order', methods=['GET', 'POST'])
def parse_request3():
    # app.config['UPLOAD_FOLDER'] = KNOWN_FOLDER
    # values = json.loads({''})
    # if request.method == 'POST':
    #     values = request.get_json()
    # else:
    #     abort(500)
    # if values == json.loads({''}):
    #     abort(500)
    # user = values['userId']
    # order = values['order']
    # date = time.time()
    # cnx = mysql.connector.connect(user='root', password='root', host='127.0.0.1', database='cafe')
    # cursor = cnx.cursor()
    # add_order = 'INSERT INTO orders (user_name, date, order) VALUES (%s, %s, %s)'
    # data_order = (user, date, order)
    # cursor.execute(add_order, data_order)
    # query = 'SELECT order_id FROM orders WHERE user_name LIKE %s AND date LIKE %s AND order LIKE %s'
    # data = (user, date, order)
    # cursor.execute(query, data)
    # for ids in cursor:
    #     orderid = ids
    # return jsonify({'orderId': orderid})


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

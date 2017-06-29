from flask import Flask, request, redirect, url_for, render_template
from werkzeug.utils import secure_filename
import os
import uuid
from PyPDF2 import PdfFileWriter, PdfFileReader
import json
from flask_socketio import *


UPLOAD_FOLDER = '/var/www/slidesapp/slidesapp/static/uploads'
ALLOWED_EXTENSIONS = set(['pdf'])


app = Flask('slidesapp')
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
socketio = SocketIO(app)

rooms = {}

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


@app.route('/')
def index():
	return render_template('layout.html')


@socketio.on('message')
def handle_message(message):
    print "test"

@socketio.on('connect')
def connect():
    pass
    
@socketio.on('sendrooms')
def send_rooms():
    emit('rooms', rooms, room=request.sid)

@socketio.on('join')
def on_join(data):
    join_room(data)
    emit('changePage', rooms[data]["currentPage"], room=request.sid)
    #send(username + ' has entered the room.', room=room)

@socketio.on('leave')
def on_leave(data):
    leave_room(data)


@socketio.on('changePage')
def change_page(data):
    rooms[data["room"]]["currentPage"] = data["currentPage"]
    emit('changePage', data["currentPage"], room=data["room"])

@socketio.on('createRoom')
def create_room(data):
    join_room(data['room'])
    rooms[data['room']] = {"dirName": data['dirName'], "numPages": data['numPages'], "currentPage": data['currentPage']}
    emit('rooms', rooms, broadcast=True)


@app.route('/upload', methods=['GET', 'POST'])
def upload():
    if request.method == 'POST':
        files = request.files['file']

        if files:
            filename = secure_filename(files.filename)
            mime_type = files.content_type

            if not allowed_file(files.filename):
                result = uploadfile(name=filename, type=mime_type, size=0, not_allowed_msg="File type not allowed")

            else:
                # save file to disk
                new_filename = str(uuid.uuid4())
                uploaded_file_path = os.path.join(app.config['UPLOAD_FOLDER'], new_filename)
                os.mkdir(uploaded_file_path)
                input = PdfFileReader(files)

                numPages = input.getNumPages()

                for i in range(numPages):
                    output = PdfFileWriter()
                    output.addPage(input.getPage(i))
                    outputStream = file(uploaded_file_path+"/"+str(i)+".pdf", "wb")
                    output.write(outputStream)
            
            return json.dumps({"dirName": new_filename, "pageCount": numPages})

if __name__ == "__main__":
    socketio.run(app, host='0.0.0.0', port=8080, debug=True)
    #app.run(host='0.0.0.0', port=8080, debug=True)

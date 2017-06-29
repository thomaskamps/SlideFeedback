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
lecturers = {}

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


@socketio.on('connect')
def connect():
    pass

@socketio.on('disconnect')
def disconnect():
    pass
    
@socketio.on('sendrooms')
def send_rooms():
    emit('rooms', rooms, room=request.sid)

@socketio.on('join')
def on_join(data):
    join_room(data)
    emit('changePage', rooms[data]["currentPage"], room=request.sid)

@socketio.on('leave')
def on_leave(data):
    leave_room(data)
    
@socketio.on('claimLecture')
def claim_lecture(data):
    if data in lecturers.values():
        temp_sid = {v: k for k, v in lecturers.items()}[data]
        del lecturers[temp_sid]
    lecturers[request.sid] = data
    print lecturers

@socketio.on('changePage')
def change_page(data):
    room = lecturers[request.sid]
    rooms[room]["currentPage"] = data
    emit('changePage', data, room=room)

@socketio.on('endLecture')
def end_lecture():
    room = lecturers[request.sid]
    emit('endLecture', room=room)
    close_room(room)
    del rooms[room]
    del lecturers[request.sid]
    emit('endLecture', room=request.sid)
    emit('rooms', rooms, broadcast=True)

@socketio.on('createRoom')
def create_room(data):
    join_room(data['room'])
    rooms[data['room']] = {"dirName": data['dirName'], "numPages": data['numPages'], "currentPage": data['currentPage'], "lecturer": data["lecturer"]}
    emit('rooms', rooms, broadcast=True)

@socketio.on('feedback')
def feedback(data):
    lecturer = {v: k for k, v in lecturers.items()}[data['room']]
    emit('feedback', data['feedback'], room=lecturer)
    
@socketio.on('test')
def testtest():
    for x in socketio.server.manager.get_participants('/', "Semantic Web Primer"):
        print x


@app.route('/')
def index():
    return render_template('layout.html')

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

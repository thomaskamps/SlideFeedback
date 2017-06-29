from flask import Flask, request, redirect, url_for, render_template
from werkzeug.utils import secure_filename
import os
import uuid
from PyPDF2 import PdfFileWriter, PdfFileReader
import json
from flask_socketio import *
import datetime


# settings
UPLOAD_FOLDER = '/var/www/slidesapp/slidesapp/static/uploads'
ALLOWED_EXTENSIONS = set(['pdf'])


# setup app
app = Flask('slidesapp')
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
socketio = SocketIO(app)


# init vars
rooms = {}
lecturers = {}


# filename check
def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


# on connect, send current rooms
@socketio.on('connect')
def connect():
    emit('rooms', rooms, room=request.sid)

# log disconnections
@socketio.on('disconnect')
def disconnect():
    print "disconnected"
    #if request.sid in lecturers:
    #    room = lecturers[request.sid]
    #    emit('endLecture', room=room)
    #    close_room(room)
    #    del rooms[room]
    #    del lecturers[request.sid]
    #    emit('rooms', rooms, broadcast=True)

# answer request for current rooms
@socketio.on('sendrooms')
def send_rooms():
    emit('rooms', rooms, room=request.sid)

# on join request, join room and send current page
@socketio.on('join')
def on_join(data):
    join_room(data)
    emit('changePage', rooms[data]["currentPage"], room=request.sid)

# leave room
@socketio.on('leave')
def on_leave(data):
    leave_room(data)

# on claim request from lecturer, appoint lecturer for slides
@socketio.on('claimLecture')
def claim_lecture(data):
    if data in lecturers.values():
    
        temp_sid = {v: k for k, v in lecturers.items()}[data]
        del lecturers[temp_sid]
        
    lecturers[request.sid] = data

# when lecturer emits changePage, get room and notify
@socketio.on('changePage')
def change_page(data):
    room = lecturers[request.sid]
    rooms[room]["currentPage"] = data
    emit('changePage', data, room=room)

# when room closes, delete all associated data and emit current rooms
@socketio.on('endLecture')
def end_lecture():
    room = lecturers[request.sid]
    emit('endLecture', room=room)
    close_room(room)
    del rooms[room]
    del lecturers[request.sid]
    emit('rooms', rooms, broadcast=True)

# when room is created, add the data and emit current rooms
@socketio.on('createRoom')
def create_room(data):
    join_room(data['dirName'])
    rooms[data['dirName']] = {"dirName": data["dirName"], "numPages": int(data['numPages']), "currentPage": data['currentPage'], "lecturer": data["lecturer"], "name": data["name"], "unique_id": str(uuid.uuid4()), "timestamp": '{:%Y-%m-%d %H:%M:%S}'.format(datetime.datetime.now())}
    emit('rooms', rooms, broadcast=True)

# on feedback from student, get lecturer, count current students connected and send data
@socketio.on('feedback')
def feedback(data):
    lecturer = {v: k for k, v in lecturers.items()}[data['room']]

    count = 0
    for x in socketio.server.manager.get_participants('/', data['room']):
        count += 1

    emit('feedback', {"feedback": data['feedback'], "studentCount": count -1}, room=lecturer)


# render main template
@app.route('/')
def index():
    return render_template('main.html')

# render startslide template
@app.route('/startslide')
def start_slide():
	return render_template('startslide.html')

# for uploading slides
@app.route('/upload', methods=['GET', 'POST'])
def upload():
    if request.method == 'POST':
        files = request.files['file']

        # if a file is added
        if files:
        
            # check filename 
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

                # split PDF into single pages
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

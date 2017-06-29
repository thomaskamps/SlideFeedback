var uid = null;

var clickLogin = function clickLogin(){
	console.log("Clicklogin");
	email = document.getElementById('username').value
	password = document.getElementById('password').value
	
	firebase.auth().signInWithEmailAndPassword(email, password).catch(function(error) {
	  var errorCode = error.code;
	  var errorMessage = error.message;
	  console.log(errorMessage);
	});
}

firebase.auth().onAuthStateChanged(function(user) {
  if (user) {
	$('#login').hide(300);
	$("#upload").show(300);
	/*$("#list").show(300);*/
    
    uid = user.uid;
    
  } else {
	/*$("#list").hide(300);*/
	$("#upload").hide(300);
    $('#login').show(300);
  }
});

var logout = function logout() {
	firebase.auth().signOut().then(function() {
	  console.log("loggedout");
	  uid = null;
	}).catch(function(error) {
	  console.log(error);
	});
}

var formSubmit = function formSubmit() {
	if(document.getElementById("file").files.length == 0 ){
    	alert("No file selected!");
    	return false;
	}
	if(!document.getElementById("file").files[0].name.endsWith(".pdf")) {
		alert("Not a .pdf-file!");
		return false;
	}
	if(document.getElementById("presentationname").value == "") {
		alert("Please enter a name for your slideshow!");
		return false;
	}
	
    var file_data = $('#file').prop('files')[0];
    var form_data = new FormData();
    form_data.append('file', file_data)
    $.ajax({
	    url: '/upload',
	    dataType: 'text',
	    cache: false,
	    contentType: false,
	    processData: false,
	    data: form_data,
	    type: 'post',
	    success: function(data){
	        console.log(data);
	        name = document.getElementById("presentationname").value;
	        var newData = JSON.parse(data);
	        database.ref('/slides').child(newData['dirName']).set({'pageCount': newData['pageCount'], 'name': name});
	        var newKey = database.ref('/users/'+uid+'/slides').push();
			newKey.set(newData['dirName'], function() {
				document.getElementById("presentationname").value = "";
				document.getElementById("file").value = "";
				alert("Succesfully uploaded your slideset!");
			});
	    }
     });
};
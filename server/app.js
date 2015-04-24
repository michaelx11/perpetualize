var express = require("express");
var multer = require('multer');

var app = express();
var done = false;

app.use(multer({ dest: 'uploads/',
 rename: function (fieldname, filename) {
    return filename+Date.now();
  },
  onFileUploadStart: function (file) {
    console.log(file.originalname + ' is starting ...')
  },
  onFileUploadComplete: function (file) {
    console.log(file.fieldname + ' uploaded to  ' + file.path)
    done = true;
  }
}));

app.get('/', function(req,res){
  res.sendfile("index.html");
});

app.post('/video', function(req,res){
  console.log('server hit with video!');
  console.log(req.params);
  console.log(req.body);

  if (done == true){
    console.log(req.files);
    res.end("File uploaded.");
  }
  res.end();

});

app.listen(8000, function(){
    console.log("Working on port 8888");
});

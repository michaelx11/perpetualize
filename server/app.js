var express = require("express");
var multer = require('multer');
var exec = require('child_process').exec, child;

var app = express();
var done = false;

app.set('port', 8000);

app.use(multer({ dest: 'uploads/',
 rename: function (fieldname, filename) {
    return filename+Date.now();
  },
  onFileUploadStart: function (file) {
    console.log(file.originalname + ' is starting ...')
  },
  onFileUploadComplete: function (file) {
    // Upload complete! Begin the processing
    console.log(file.fieldname + ' uploaded to ' + file.path)

    gifURL = file.path.split('.')[0].split('/')[1] + '.gif'
    processVideo(file.path, gifURL);
  }
}));

var processVideo = function(filename, outname) {
  child = exec('python process.py ' + filename + ' exports/'+outname,
    function (error, stdout, stderr) {
      if (error !== null) {
        console.log('exec error: ' + error);
      }
  });
}

app.get('/', function(req,res){
  res.sendfile("index.html");
});

app.post('/video', function(req,res){

  console.log('server hit with video!');
  console.log(req.files.uploadVideo.name)

  gifURL = req.files.uploadVideo.name.split('.')[0] + '.gif';
  res.json({url: req.files.uploadVideo.name.split('.')[0] + '.gif'});
});

app.listen(app.get('port'), function(){
  console.log("Working on port " + app.get('port'));
});

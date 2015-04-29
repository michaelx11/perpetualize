var express = require("express");
var multer = require('multer');
var exec = require('child_process').exec, child;
var fs = require('fs');
var exphbs  = require('express-handlebars');
var app = express();
var done = false;

app.set('port', 8000);
app.engine('handlebars', exphbs({defaultLayout: 'main'}));
app.set('view engine', 'handlebars');
app.use("/", express.static(__dirname + "/public"));
app.use("/uploads", express.static(__dirname + "/uploads"));

app.use(multer({ dest: 'uploads/',
 rename: function (fieldname, filename) {
    return 'upload';
  },
  changeDest: function(dest, req, res){
    newDir = base10_to_base64(Date.now());
    fs.mkdirSync('uploads/'+newDir);
    dest += newDir;
    return dest;
  },
  onFileUploadStart: function (file) {
    console.log(file.originalname + ' is starting ...')
  },
  onFileUploadComplete: function (file) {
    // Upload complete! Begin the processing
    console.log(file.fieldname + ' uploaded to ' + file.path)

    timestamp = file.path.split('/')[1];
    console.log(timestamp);
    processVideo(file.path, timestamp);
  }
}));

function base10_to_base64(num) {
    var order = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";
    var base = order.length;
    var str = "", r;
    while (num) {
        r = num % base
        num -= r;
        num /= base;
        str = order.charAt(r) + str;
    }
    return str;
}

var processVideo = function(filename, outname) {
  child = exec('python process.py ' + filename + ' ' + outname,
    function (error, stdout, stderr) {
      if (error !== null) {
        console.log('exec error: ' + error);
      }
  });
}

app.get('/', function(req,res){
  res.sendfile("index.html");
});

app.get('/s/:id', function(req,res){
  id = req.params.id
  console.log(id);
  if (fs.existsSync('uploads/' + id + '/')) {
    res.render("single", {id: id});
  } else {
    res.render("invalid");
  }
});

app.post('/video', function(req,res){
  filepath = req.files.uploadVideo.path
  timestamp = filepath.split('/')[1]
  res.json({
    original_file: filepath,
    gif_url: 'uploads/' + timestamp + '/_.gif',
    mp4_url: 'uploads/' + timestamp + '/_.mp4',
    share_url: 's/' + timestamp,
  });
});

app.listen(app.get('port'), function(){
  console.log("Working on port " + app.get('port'));
});

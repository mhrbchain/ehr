var express = require('express');
var session = require('express-session');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var morgan = require('morgan');
var app = express();
var port = process.env.PORT || 8080;

var passport = require('passport');
var flash = require('connect-flash');

require('./config/passport')(passport);

app.use(morgan('dev'));
app.use(cookieParser());
app.use(bodyParser.urlencoded({
 extended: true
}));

app.set('view engine', 'ejs');

app.use(session({
 secret: 'justasecret',
 resave:true,
 saveUninitialized: true
}));

app.use(passport.initialize());
app.use(passport.session());
app.use(flash());

app.use('/vendor', express.static(__dirname + '/node_modules'));
app.use(express.static(__dirname + '/views'));
app.use(express.static(__dirname + '/build/contracts'));
// app.use(express.static(__dirname + '/src'));


require('./app/routes.js')(app, passport);

app.listen(port);
console.log("Port: " + port);
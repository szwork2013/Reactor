var fs = require("fs");
fs.readdirSync(__dirname).map(function (item) { if(item.substr(item.length - 6, 6) == ('coffee')) require('./'+item); }    );


fs = require("fs");
fs.readdirSync(__dirname).map(function (item) { 
if(item.split('.')[1] == ('coffee')) require('./'+item)(module.parent.schema) }   
);

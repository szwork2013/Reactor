fs    = require("fs");
items = fs.readdirSync(__dirname).sort(function(a, b) { if(a > b) { return 1} else {return -1}})
items.map(
function (item) { 
if(item.split('.')[1] == ('coffee')) require('./'+item)(module.parent.schema); }   
);

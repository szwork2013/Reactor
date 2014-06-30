var util = require('../utils/util.coffee');


util.walk(__dirname, function (err, result) {
  result.map(function (item) {
    var segs = item.split('/');
    if (segs[segs.length - 1] == 'index.js') {
        return;
     } else {
    if(item.substr(item.length - 6, 6) == ('coffee')){
       require(item)
     }
   }
 });
});




;(function(e,t,n){function i(n,s){if(!t[n]){if(!e[n]){var o=typeof require=="function"&&require;if(!s&&o)return o(n,!0);if(r)return r(n,!0);throw new Error("Cannot find module '"+n+"'")}var u=t[n]={exports:{}};e[n][0].call(u.exports,function(t){var r=e[n][1][t];return i(r?r:t)},u,u.exports)}return t[n].exports}var r=typeof require=="function"&&require;for(var s=0;s<n.length;s++)i(n[s]);return i})({1:[function(require,module,exports){
window.id = require("../../models/Record/validators/id.coffee");

window.tel = require("../../models/Record/validators/tel.coffee");


},{"../../models/Record/validators/id.coffee":2,"../../models/Record/validators/tel.coffee":3}],2:[function(require,module,exports){
var aCity;

module.exports = function(v) {
  var birthday, date, i, iSum, pattern_date, pattern_id, right_birth, right_city, right_code, right_id, _i;
  pattern_id = /^\d{17}(\d|X)$/i;
  pattern_date = /^(19|20)[0-9]{2}-((0[1-9]|1[0-2])-((0[1-9]|1[0-9]|2[0-9]))|((0[13-9]|1[0-2])-30)|((0[13578]|1[02])-31))$/;
  right_id = false;
  if (pattern_id.test(v)) {
    right_city = aCity[parseInt(v.substr(0, 2))] ? true : false;
    birthday = v.substr(6, 4) + "-" + Number(v.substr(10, 2)) + "-" + Number(v.substr(12, 2));
    date = new Date(birthday.replace(/-/g, "/"));
    right_birth = birthday === (date.getFullYear() + "-" + (date.getMonth() + 1) + "-" + date.getDate()) ? true : false;
    iSum = 0;
    for (i = _i = 17; _i >= 0; i = --_i) {
      iSum += (Math.pow(2, i) % 11) * parseInt(v.charAt(17 - i), 11);
    }
    right_code = iSum % 11 === 1 ? true : false;
    right_id = right_city && right_birth && right_code ? true : false;
  }
  return !v || right_id || pattern_date.test(v);
};

aCity = {
  11: "北京",
  12: "天津",
  13: "河北",
  14: "山西",
  15: "内蒙古",
  21: "辽宁",
  22: "吉林",
  23: "黑龙江",
  31: "上海",
  32: "江苏",
  33: "浙江",
  34: "安徽",
  35: "福建",
  36: "江西",
  37: "山东",
  41: "河南",
  42: "湖北",
  43: "湖南",
  44: "广东",
  45: "广西",
  46: "海南",
  50: "重庆",
  51: "四川",
  52: "贵州",
  53: "云南",
  54: "西藏",
  61: "陕西",
  62: "甘肃",
  63: "青海",
  64: "宁夏",
  65: "新疆",
  71: "台湾",
  81: "香港",
  82: "澳门",
  91: "国外"
};


},{}],3:[function(require,module,exports){
module.exports = function(v) {
  var pattern_tel;
  pattern_tel = /^(0?1[3-8](\d){9}|(0(\d){2,3}-)?(\d){7,8}(-(\d){1,6})?)$/;
  return !v || pattern_tel.test(v);
};


},{}]},{},[1])
;
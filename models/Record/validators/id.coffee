moment = require 'moment'
module.exports = (v) ->
  return on if not v or (moment(v).isValid() and moment(v).format('YYYY-MM-DD') is v)
  pattern_id1 = /^\d{17}(\d|X)$/i
  pattern_id2 = /^\d{15}$/i
  pattern_date = /^(19|20)[0-9]{2}-((0[1-9]|1[0-2])-((0[1-9]|1[0-9]|2[0-9]))|((0[13-9]|1[0-2])-30)|((0[13578]|1[02])-31))$/
  right_id = off
  return off if not pattern_id1.test(v) and not pattern_id2.test(v)
  return off unless aCity[parseInt(v.substr(0,2))]
  if v.length is 15
    if ((parseInt(v.substr(6,2))+1900) % 4 is 0 or ((parseInt(v.substr(6,2))+1900) % 100 is 0 and (parseInt(v.substr(6,2))+1900) % 4 is 0 ))
      ereg = /^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}$/
    else
      ereg = /^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}$/
    return ereg.test(v) #测试出生日期的合法性
  else if v.length is 18
    # 验证地区是否合法
    birthday    = v.substr(6,4) + "-" + (v.substr(10,2)) + "-" + (v.substr(12,2))
    #我国在1986-1991年实行过6年的夏日制，这会导致moment解析这期间部分日期出错
    #例如1989-04-16解析为1989-04-15
    # date        = moment "#{birthday}T00:00:00+08:00"
    #上一行代码导致1951年1月1日出生的身份证号验证失败
    date        = moment "#{birthday}Z"
    # 验证生日是否合法
    right_birth = birthday is date.format 'YYYY-MM-DD'
    # console.log birthday, date.format 'YYYY-MM-DD'
    iSum = 0
    for i in [17..0]
      char = v.charAt(17 - i)
      char = '10' if char.toUpperCase() is 'X'
      iSum += (Math.pow(2, i) % 11) * parseInt(char, 10)
    # 验证效验码是否合法 
    right_code = if iSum % 11 is 1 then on else off
    # console.log right_birth, right_code
    right_id = if (right_birth and right_code) then on else off
    # console.log right_id, pattern_date.test(v)
    return right_id or pattern_date.test(v)

aCity=
  11:"北京"
  12:"天津"
  13:"河北"
  14:"山西"
  15:"内蒙古"
  21:"辽宁"
  22:"吉林"
  23:"黑龙江"
  31:"上海"
  32:"江苏"
  33:"浙江"
  34:"安徽"
  35:"福建"
  36:"江西"
  37:"山东"
  41:"河南"
  42:"湖北"
  43:"湖南"
  44:"广东"
  45:"广西"
  46:"海南"
  50:"重庆"
  51:"四川"
  52:"贵州"
  53:"云南"
  54:"西藏"
  61:"陕西"
  62:"甘肃"
  63:"青海"
  64:"宁夏"
  65:"新疆"
  71:"台湾"
  81:"香港"
  82:"澳门"
  91:"国外"

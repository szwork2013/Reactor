/*
  功能:YYYY-MM-DD 数字日期转化为汉字
  例:1984-3-7 -> 一九八四年三月七日
  调用:baodate2chinese("1984-3-7")
*/
var chinese = ['零','一','二','三','四','五','六','七','八','九'];
var len = ['十'];
var ydm =['年','月','日'];
function num2chinese(s)
{
    //将单个数字转成中文.
    s=""+s;
    slen = s.length;
    var result="";
    for(var i=0;i<slen;i++)
    {
        result+=chinese[s.charAt(i)];
    }
     return result;
}

function n2c(s)
{ 
    //对特殊情况进行处理.
    s=""+s;
    var result="";
    if(s.length==2)
    {
         if(s.charAt(0)=="1")
         {
            if(s.charAt(1)=="0")return len[0];
            return len[0]+chinese[s.charAt(1)];
          }
     if(s.charAt(1)=="0")return chinese[s.charAt(0)]+len[0];
        return chinese[s.charAt(0)]+len[0]+chinese[s.charAt(1)];
     }
     return num2chinese(s)
}

exports.date2chinese = function(s)
{
     //验证输入的日期格式.并提取相关数字.
     var datePat = /^(\d{2}|\d{4})(\/|-)(\d{1,2})(\2)(\d{1,2})$/; 
     var matchArray = s.match(datePat); 
     var ok="";
     if (matchArray == null) return false;
     for(var i=1;i<matchArray.length;i=i+2)
     {
         ok+=n2c(matchArray[i]-0)+ydm[(i-1)/2];
     }
 return ok;
}

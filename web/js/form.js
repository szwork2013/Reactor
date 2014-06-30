
/******提交表单js****/

/*
*   时间默认值
*/
function initDateInput() {
    var myDate = new Date();
    var year = (myDate.getYear() < 1900) ? (1900 + myDate.getYear()) : myDate.getYear();
    var month = myDate.getMonth() + 1;
    var day = myDate.getDate();

    $("#year").val(year);
    $("#month").val(month);
    $("#day").val(day);
}

/**
*   控制页面显示和锚记位置
*/
function groupPageStats(submitName) {
    initDateInput();

    $("#groupName").text(submitName);
    $(".wordGroup4").hide();
    $(".package").hide();
    $(".wordGroup5").show();
    var setFuc = goto("page4");
    setTimeout(setFuc, 0);
}

/*
*   查询该团体下所有的部门
*/
function getBatches(batchCode) {
    var curl = encodeURI(batchCode);
    var getBatchesUrl = "/batches/" + curl + "/divisions";

    $("#department").AutoComplete({
        'data': host + getBatchesUrl,
        'ajaxDataType': 'json',
        'onerror': function (error) {
        },
        'itemHeight': 20,
        'maxHeight': 210
    }).AutoComplete('show');
}

/*
*   匹配套餐
*/
function choosePlan(planArr, initParam) {
    //筛选年龄后的数组
    var clearSexArr = [];
    //套餐筛选后集合
    var truePlanArr = [];

    var sex = "";
    if (initParam) {
        sex = initParam;
    } else {
        sex = $.trim($(".sex_hover").text());
    }
    

    var age = $("#age").val();
    if (sex != "" && age != "" && age!="#") {
        var planSex = "";
        var planAge = "";
        var planName = "";
        if (planArr.length > 1) {
            //筛选性别
            for (var idx in planArr) {
                planSex = planArr[idx]["sex"];
                if (typeof (planSex) != "undefined") {
                    if (planSex == sex) {
                        clearSexArr.push(planArr[idx]);
                    } else {
                        clearSexArr.push("");
                    }
                } else {
                    clearSexArr.push(planArr[idx]);
                }
            }

            //筛选年龄
            for (var idx in clearSexArr) {
                if (clearSexArr[idx] != "") {
                    planAgeDown = clearSexArr[idx]["age_ut"];
                    planAgeUp = clearSexArr[idx]["age_lt"];
                    if (typeof (planAgeDown) != "undefined") {
                        if (age < planAgeDown) {
                            truePlanArr.push(clearSexArr[idx]);
                        }
                    } else if (typeof (planAgeUp) != "undefined") {
                        if (age >= planAgeUp) {
                            truePlanArr.push(clearSexArr[idx]);
                        }
                    } else {
                        truePlanArr.push(clearSexArr[idx]);
                    }
                }
            }
        }
        createPlan(truePlanArr);
    } else if (sex != "") {
        var planSex = "";
        var planAge = "";
        var planName = "";
        if (planArr.length > 1) {
            //筛选性别
            for (var idx in planArr) {
                planSex = planArr[idx]["sex"];
                if (typeof (planSex) != "undefined") {
                    if (planSex == sex) {
                        clearSexArr.push(planArr[idx]);
                    } else {
                        clearSexArr.push("");
                    }
                } else {
                    clearSexArr.push(planArr[idx]);
                }
            }
        }
        createPlan(clearSexArr);
    }
}

/*
*   创建套餐组并展示在页面
*/
function createPlan(truePlanArr) {
    //清空
    $("#showPlan").html("");
    //套餐html
    var plansText=""
    var pname = "";
    var pid = "";
    var price = "";
    for (var idx in truePlanArr) {
        if (truePlanArr[idx]) {
            pname = truePlanArr[idx]["name"];
            pid = truePlanArr[idx]["_id"];
            price = truePlanArr[idx]["price"];

            plansText += "<label id='" + pid + "_" + price + "'>";
            plansText += pname;
            plansText += "</label>";
        }
    }

    $("#showPlan").html(plansText);

    //绑定生成套餐事件
    $("#showPlan > label").live("click", function () {
        $("#showPlan > label").each(function () {
            if ($(this).hasClass("selectPlan")) {
                $(this).removeClass("selectPlan");
            }
        });
        $(this).addClass("selectPlan");
        var sub = $(this).attr("id");
        var subArr = sub.split('_');
        selectSmallId = subArr[0];
        selectSamllPrice = subArr[1];
        selectSmallName=$(this).text();
        $("#showResultName").text($(this).text());
        
    });

    //默认选中第一个
    $("#showPlan").find('label:first').trigger("click");
}


/*
*   绑定表单控件事件
*/
function bindFormEvent(planArr) {
    $(".sex").click(function () {
        $(this).addClass("sex_hover");
        var a = $(this).attr("id");
        var rm = $(this).attr("id") == "boy" ? "gril" : "boy";
        $("#"+rm).removeClass("sex_hover");
        return choosePlan(planArr);
    });

    $("#submitForm").click(function () {
        getFromImformation();
    });


    /*禁止输入非法年龄*/
    $("#age").keyup(function () {
        var ageText = $("#age").val();
        if (ageText!="#") {
            var ageText = ageText.replace(/[^\d]/g, '');
            if (parseInt(ageText) > 120) {
                ageText = (ageText + "").substr(0, 2);
            }
        }
        $("#age").val(ageText);
    });

    /*禁止输入非法日期*/
   /* $("#year").keyup(function () {
        var yearText = $(this).val().replace(/[^\d]/g, '');
        var myDate = new Date();
        var year = (myDate.getYear() < 1900) ? (1900 + myDate.getYear()) : myDate.getYear();

        if (yearText.length == 4) {
            if (parseInt(yearText) <= parseInt(year) || parseInt(yearText) > parseInt(year)+1) {
                yearText = year;
            }
        } else if (yearText.length>4) {
            yearText = year;
        }

        $(this).val(yearText);
    });
    $("#month").keyup(function () {
        var monthText = $(this).val().replace(/[^\d]/g, '');
        var myDate = new Date();
        var month = myDate.getMonth() + 1;

        if (parseInt(monthText) > 12) {
            monthText = month;
        } else if (monthText.length > 2) {
            monthText = month;
        }
        $(this).val(monthText);
    });

    $("#day").keyup(function () {
        var dayText = $(this).val().replace(/[^\d]/g, '');
        var myDate = new Date();
        var day = myDate.getDate();

        if (parseInt(dayText)>31) {
            dayText = day;
        } else if (dayText.length>2) {
            dayText = day;
        }
        $(this).val(dayText);
    });*/
    


    /**表单提交前验证事件**/
    $("#name").blur(function () {
        var istrue = checkName("name");
        if (istrue == true) {
            whatSay("name", false);
        }
        groupFormNull["name"] = istrue;
    });

    $("#age").blur(function () {
        var istrue = checkAge("age");
        if (istrue == true) {
            whatSay("age",false);
            choosePlan(planArr);
        }
        groupFormNull["age"] = istrue;
    });

    $("#mobile").blur(function () {
        var istrue = checkMobile("mobile");
        if (istrue == true) {
            whatSay("mobile", false);
        }
        groupFormNull["mobile"] = istrue;
    });

    $("#idPort").blur(function () {
        var istrue=false;
        var idCardNum = $.trim($("#idPort").val());
        if (idCardNum.length == 18 || idCardNum.length==15) {
            istrue = checkIdPort("idPort");
            if (istrue == true) {
                whatSay("idPort", false);
                idPort(idCardNum);
                choosePlan(planArr);
                //如果身份证补全年龄不会触发年龄验证事件
                $("#age").trigger("blur", "age");
            }
        } else if (idCardNum.length == 10) {
            istrue = checkBrith("idPort");
            if (istrue == true) {
                whatSay("idPort", false);
                getAgetoBirth("idPort");
                //如果身份证补全年龄不会触发年龄验证事件
                $("#age").trigger("blur", "age");
            }
        } else if (idCardNum=="#") {
            //允许用户输入#号，提交表单时转为null
            istrue = true
            whatSay("idPort", false);
        }else {
            whatSay("idPort", true);
        }
        
        groupFormNull["idPort"] = istrue;
        

    });
    /*
    $("#year").blur(function () {
        checkDate("year", 'y');
    });

    $("#month").blur(function () {
        checkDate("month", 'm');
    });

    $("#day").blur(function () {
        checkDate("day", 'd');
    }); */
    $("#datepicker").change(function () {
      if ($(this).val() != "") {
        whatSay("datepicker", false);
      } else {
        whatSay("datepicker", true);
      }
    });

    $("#department").blur(function () {
        var istrue = checkDepartment("department");
        if (istrue == true) {
            whatSay("department",false);
        }
        groupFormNull["department"] = istrue;
    });
    //如果是fesco需填写员工唯一编号
    if ($('#input-worker-id').css('display') == 'inline-block') {
      $("#input-worker-id").blur(function () {
        if ($(this).val() != "") {
          whatSay("input-worker-id", false);
        } else {
          whatSay("input-worker-id", true);
        }
      });
    }
}
/*
*   姓名验证
*/
function checkName(nid){
    var name = $("#"+nid).val();
    if(name==""){
        whatSay(nid,true);
        return false;
    }
    return true;
}

/*
*   日期验证

function checkDate(id, type) {
    var value = $("#" + id).val();
    if (value == "") {
        var myDate = new Date();
        switch(type){
            case 'y':
                var year = (myDate.getYear() < 1900) ? (1900 + myDate.getYear()) : myDate.getYear();
                $("#" + id).val(year);
                break;
            case 'm':
                var month = myDate.getMonth() + 1;
                $("#" + id).val(month);
                break;
            case 'd':
                var day = myDate.getDate();
                $("#" + id).val(day);
                break;
        }
    }
} */

/*
*   年龄验证
*/
function checkAge(aid) {
    var age = $("#"+aid).val();
    if(age==""){
        whatSay(aid,true);
        return false;
    }
    return true;
}

/*
*   生日验证
*   格式必须为YYYY-MM-DD
*/
function checkBrith(id) {
    var brithDay = $("#" + id).val();
    var dateCheckStr = /((^((1[8-9]\d{2})|([2-9]\d{3}))([-\/\._])(10|12|0?[13578])([-\/\._])(3[01]|[12][0-9]|0?[1-9])$)|(^((1[8-9]\d{2})|([2-9]\d{3}))([-\/\._])(11|0?[469])([-\/\._])(30|[12][0-9]|0?[1-9])$)|(^((1[8-9]\d{2})|([2-9]\d{3}))([-\/\._])(0?2)([-\/\._])(2[0-8]|1[0-9]|0?[1-9])$)|(^([2468][048]00)([-\/\._])(0?2)([-\/\._])(29)$)|(^([3579][26]00)([-\/\._])(0?2)([-\/\._])(29)$)|(^([1][89][0][48])([-\/\._])(0?2)([-\/\._])(29)$)|(^([2-9][0-9][0][48])([-\/\._])(0?2)([-\/\._])(29)$)|(^([1][89][2468][048])([-\/\._])(0?2)([-\/\._])(29)$)|(^([2-9][0-9][2468][048])([-\/\._])(0?2)([-\/\._])(29)$)|(^([1][89][13579][26])([-\/\._])(0?2)([-\/\._])(29)$)|(^([2-9][0-9][13579][26])([-\/\._])(0?2)([-\/\._])(29)$))/ig;
    var flag = dateCheckStr.test(brithDay);
    if (!flag) {
        whatSay(id, true);
    }
    return flag;
}


/*
*   通过生日取得年龄
*/
function getAgetoBirth(bir) {
    var strBirthday = $("#" + bir).val();

    var returnAge;
    var strBirthdayArr = strBirthday.split("-");
    var birthYear = strBirthdayArr[0];
    var birthMonth = strBirthdayArr[1];
    var birthDay = strBirthdayArr[2];

    d = new Date();
    var nowYear = d.getFullYear();
    var nowMonth = d.getMonth() + 1;
    var nowDay = d.getDate();

    if (nowYear == birthYear) {
        returnAge = 0;//同年 则为0岁
        $("#age").val(returnAge);
    }
    else {
        var ageDiff = nowYear - birthYear; //年之差
        if (ageDiff > 0) {
            if (nowMonth == birthMonth) {
                var dayDiff = nowDay - birthDay;//日之差
                if (dayDiff < 0) {
                    returnAge = ageDiff - 1;
                }
                else {
                    returnAge = ageDiff;
                }
            }
            else {
                var monthDiff = nowMonth - birthMonth;//月之差
                if (monthDiff < 0) {
                    returnAge = ageDiff - 1;
                }
                else {
                    returnAge = ageDiff;
                }
            }
            $("#age").val(returnAge);
        }
        else {
            //returnAge = -1;//返回-1 表示出生日期输入错误 晚于今天
            whatSay(id, true);
        }
    }
}

/*
*   身份证验证
*/
function checkIdPort(pid) {
    var sId = $("#" + pid).val();
    if (sId != "#") {
        var aCity = { 11: "北京", 12: "天津", 13: "河北", 14: "山西", 15: "内蒙古", 21: "辽宁", 22: "吉林", 23: "黑龙江 ", 31: "上海", 32: "江苏", 33: "浙江", 34: "安徽", 35: "福建", 36: "江西", 37: "山东", 41: "河南", 42: "湖北 ", 43: "湖南", 44: "广东", 45: "广西", 46: "海南", 50: "重庆", 51: "四川", 52: "贵州", 53: "云南", 54: "西藏 ", 61: "陕西", 62: "甘肃", 63: "青海", 64: "宁夏", 65: "新疆", 71: "台湾", 81: "香港", 82: "澳门", 91: "国外 " }
        var iSum = 0;
        var info = "";

        sId = sId.replace(/x$/i, "a");
        if (sId == "") {
            whatSay(pid, true);
            return false;
        }

        if (aCity[parseInt(sId.substr(0, 2))] == null) {
            whatSay(pid, true);
            return false;
        }
        sBirthday = sId.substr(6, 4) + "-" + Number(sId.substr(10, 2)) + "-" + Number(sId.substr(12, 2));
        var d = new Date(sBirthday.replace(/-/g, "/"))
        if (sBirthday != (d.getFullYear() + "-" + (d.getMonth() + 1) + "-" + d.getDate())) {
            whatSay(pid, true);
            return false;
        }
        for (var i = 17; i >= 0; i--) {
            iSum += (Math.pow(2, i) % 11) * parseInt(sId.charAt(17 - i), 11);
        }
        if (iSum % 11 != 1) {
            whatSay(pid, true);
            return false;
        }
        //return aCity[parseInt(sId.substr(0, 2))] + "," + sBirthday + "," + (sId.substr(16, 1) % 2 ? "男" : "女")
    }
    
    return true;
}

/*
*   手机号验证
*/
function checkMobile(mid) {
    var mobile = $("#" + mid).val();
    if (mobile != "#") {
        if (mobile == "") {
            whatSay(mid, true);
            return false;
        }

        if (!mobile.match(/^1[3|4|5|8][0-9]\d{4,8}$/)) {
            whatSay(mid, true);
            return false;
        }
    }

    return true;
}


/*
*   部门非空验证
*/
function checkDepartment(id) {
    var dt = $("#" + id).val();
    if (dt == "") {
        whatSay(id,true);
        return false;
    }
    return true;
}

/*
*   身份证匹配性别和年龄
*/
function idPort(value) {
    var length = value.length;
    var sex = "";
    var age = "";
    var myDate = new Date();
    var month = myDate.getMonth() + 1;
    var day = myDate.getDate();

    if (length == 18) {
        if (parseInt(value.substr(16, 1)) % 2 == 1) {
            sex = "boy";
        } else {
            sex = "gril";
        }

        age = myDate.getFullYear() - value.substring(6, 10) - 1;
        if (value.substring(10, 12) < month || value.substring(10, 12) == month && value.substring(12, 14) <= day) {
            age++;
        }
    } else if (length == 15) {
        if (parseInt(value.substr(14, 1)) % 2 == 1) {
            sex = "boy";
        } else {
            sex = "gril";
        }

        var brith = parseInt("19" + value.substr(6, 2));
        age = myDate.getFullYear() - brith - 1;
        if (value.substring(8, 10) < month || value.substring(8, 10) == month && value.substring(10, 12) <= day) {
            age++;
        }
    }

    //根据身份证给表单赋值
    if (sex == "boy") {
        $("#boy").addClass("sex_hover");
        $("#gril").removeClass("sex_hover");
    } else {
        $("#gril").addClass("sex_hover");
        $("#boy").removeClass("sex_hover");
    }

    $("#age").val(age);
}


/*
*   提取页面输入表单信息
*/
function getFromImformation() {
    //如果身份证补全年龄不会触发年龄验证事件
    $("#age").trigger("blur", "age");

    //记录表单是否有不符合要求填写
    var formFalseMark = true;
    //选中小套餐价格
    var selectSamllPrice = "";
    //预约时段A，B，C，D（目前没有）
    var utime = "A";
    //员工编号（目前没）
    var notes = [];
    //标记日期和fasco员工编号是否通过验证
    mark_pass = true
    

    for (var idx in groupFormNull) {
        if (groupFormNull[idx] == false) {
            whatSay(idx, true);
            formFalseMark = false;
        }
    }
    
    //如果是fesco需填写员工唯一编号
    var work_id = ''
    console.log($('#input-worker-id').css('display'))
    if ($('#input-worker-id').css('display') == 'inline-block') {
      var work_id = $('#input-worker-id').val();
      if (work_id == '') {
        whatSay('input-worker-id', true);
        mark_pass = false
      } else {
        whatSay('input-worker-id', false);
        notes.push('员工唯一号：' + work_id);
      }
    } 
    //日期
    var date = $.trim($("#datepicker").val());
    if (date == '') {
      whatSay('datepicker', true);
      mark_pass = false
    } else {
      whatSay('datepicker', false);
    }

    if (selectSmallName) {
      if (!formFalseMark || !mark_pass) {
            return;
        }

        var uname =  $.trim($("#name").val());
        var usex = $.trim($(".sex_hover").text());
        var uage = $.trim($("#age").val()) == "#" ? null : $.trim($("#age").val());
        var uidPort = $.trim($("#idPort").val()) == "#" ? null : $.trim($("#idPort").val());

        var umobile = $.trim($("#mobile").val()) == "#" ? null : $.trim($("#mobile").val());
        
        //var uyear = $.trim($("#year").val());
        //var umonth =  $.trim($("#month").val());
        //var uday = $.trim($("#day").val());        
        //var date = uyear+"-"+appendZero(umonth)+"-"+appendZero(uday);

        var gName = $("#groupName").text();
        var udepartment = $.trim($("#department").val());
        var splan = $("#selectPlan").text();

        //各种验证没问题提交表单
        var formObj = {
            "name":uname,
            "sex":usex,
            "age":uage,
            "id":uidPort,
            "check_date":date,
            "check_time": utime,
            "tel": umobile,
            "notes": notes,
            "batch": bigBatch,
            "division": udepartment,
            "source": gName
        }
        
        var paramObj = {
            "profile": formObj
        }

        submitFrom(paramObj);

    } 
}

function submitLoading(istrue) {
    if (istrue) {
        $("#formLoading").show();
    } else {
        $("#formLoading").hide();
    }
    
}

/*
*   提交表单信息
*/
function submitFrom(paramObj) {
    submitLoading(true);
    $.ajax({
        type: 'post',
        url: host + "/records",
        data: JSON.stringify(paramObj),
        contentType: "application/json; charset=utf-8",
        dataType: 'json',
        //async: false,
        xhrFields: { withCredentials: true },
        success: function (result) {
            //团体为2
            var paidVal = 2
            var barCode = result.barcode;
            //大套餐+小套餐名
            var oarderName= bigName+"("+selectSmallName+")"
            var orderParam = {
                _id: selectSmallId,
                name: oarderName,
                category: 'package',
                paid: paidVal,
                price: selectSamllPrice
            }
            submitOrder(orderParam,barCode);

        },
        error: function (e) {
            $("#groupFromResult").text("提交失败，请稍候重试");
            submitLoading(false);
            clearHtml();
        }
    });
}

/*
*   注册成功清空内容
*/
function clearHtml() {
    $(".register > form > dl > label > input").val("");
    initDateInput();
    $("#showPlan").html("");
    $("#showResultName").text("");

    function disFuc() {
        $("#groupFromResult").text("");
    }

    setTimeout(function() {
        $("#groupFromResult").text("");
    }, 3000);
    var sexInit = $(".sex_hover").val();
    choosePlan(planArr, sexInit);

    //重置验证表单对象
    for (var i in groupFormNull) {
        groupFormNull[i] = false;
    }
}

/*
*   提交订单
*/
function submitOrder(orderParam,barCode) {
    $.ajax({
        type: 'post',
        url: host + "/records/" + barCode + "/orders",
        data: orderParam,
        //contentType: "application/json; charset=utf-8",
        dataType: 'json',
        //async: false,
        xhrFields: { withCredentials: true },
        success: function (result) {
            submitLoading(false);
            $("#groupFromResult").text("预约成功");
            clearHtml();
        },
        error: function (e) {
            $("#groupFromResult").text("提交失败，请稍候重试");
            submitLoading(false);
            clearHtml();
        }
    });
}

/*
*   提示语
*   @word   提示语内容
*/
function whatSay(id,istrue){
    if (istrue) {
        $("#" + id).addClass("error");
    } else {
        $("#" + id).removeClass("error");
    }
    
}

/*
*   日期补零
*   @obj    日期值

function appendZero (obj) {
    obj=parseInt(obj);
    if (obj < 10) {
        return "0" + obj;
    }else{
        return obj;
    }
} */


/*
*   进入团体表单获得该团体的信息
*/
function goGroupForm(groupName) {
    var curl = encodeURI(groupName);
    var requestUrl = "/batches/" + curl + "/package"
    //针对FESCO特殊处理
    if (groupName === '北京外企人力资源服务有限公司') {
      $('#input-worker-id').show();
      $('#department').attr('placeholder', '公司名称（或代表处）（中文）');
      $('#idPort').attr('placeholder', '身份证号');
      $('#mobile').attr('placeholder', '手机号');
    }
    //初始化日历
    function nationalDays(date) {
      //节假日日期静态数组
      var natDays = ['20140101', '20140131', '20140201', '20140202', '20140203', '20140204', '20140205', '20140206', '20140405', '20140406', '20140407', '20140501', '20140502', '20140503', '20140531', '20140601', '20140602', '20140906', '20140907', '20140908', '20141001', '20141002', '20141003', '20141004', '20141005', '20141006', '20141007']
      var today = moment().format('YYYYMMDD')
      var format_date = moment(date).format('YYYYMMDD')
      var week = moment(date).format('d')
      //小于等于今天日期不能选
      if (format_date <= today) {
        return [false, 'unselect-date'];
      }
      //法定节假日不能选
      for (var i = 0; i < natDays.length; i++) {
        if (format_date === natDays[i]) {
          return [false, 'unselect-date'];
        }
      }
      //不是周三、周四、周日不能选
      if (week === '3' || week === '4' || week === '6') {
        //如果不等于上面描述条件此日期为可选日期
        return [true, ''];
      } else {
        return [false, 'unselect-date'];
      }
    }

    //渲染日历组件
    $("#datepicker").datepicker({
      beforeShowDay: nationalDays,
      dateFormat: "yy-mm-dd",
      monthNames: ['一月', '二月', '三月', '四月', '五月', '六月', '七月', '八月', '九月', '十月', '十一月', '十二月'],
      dayNamesMin: ['日', '一', '二', '三', '四', '五', '六'],
      prevText: '上月',
      nextText: '下月'
    });
    
    //提取补录公司信息
    $.ajax({
        type: 'get',
        url: host + requestUrl,
        //contentType: "application/json; charset=utf-8",
        dataType: 'json',
        //async: false,
        xhrFields: { withCredentials: true },
        success: function (result) {
            if (result == "" || result == []) {
                return;
            }
            //公司batch值
            bigBatch = result.batch;
            //小套餐数据数组
            planArr = result.configurations;
            //公司名称(大套餐名称)
            bigName = result.name;

            getBatches(bigBatch);
            groupPageStats(bigName);
            bindFormEvent(planArr);

            //默认加载男性相关体检
            choosePlan(planArr,"男");
        },
        error: function (e) {
        }
    });
}
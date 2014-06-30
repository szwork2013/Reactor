/*
*   体检报告查询，联系我们嵌入地图
*/

/*
*   绑定查看和下载pdf
*   @status 0查看，1是下载
*   @url pdf地址
*/
function serchAndDownloadClick(obj, status) {
    if ($.browser.msie && $.browser.version == 8.0) {
        $(".serch").attr("href", obj[markPdfNum].url);
    }else{
        window.open(obj[markPdfNum].url);
    }
    
}

/*
*   动态创建div
*/
function createDiv(param) {
    //体检报告pdf
    var createPdfDivHtml = "";
    //空报告
    var emptyPdfDivHtml = "";
    //记录pdf条数
    var countPdf = 0;
    //需要创建空白pdf条数
    var emptyCountPdf = 0;

    if (param == [] || param == null) {
        //库中还查不到此人报告
        createPdfDivHtml += "<dt>";
            createPdfDivHtml += "<div class='triangle'></div>";
            createPdfDivHtml += "<div class='info'>";
                createPdfDivHtml += "<p class='tishi'>总检医生正在针对您的报告进行分析</p>";
            createPdfDivHtml += "</div>";
        createPdfDivHtml += "</dt>";
        //把pdfDiv添加到html中
            $(".report").append(createPdfDivHtml);
    } else {
        //库中已查到此人报告
        for (var idx in param) {
            createPdfDivHtml = "";
            createPdfDivHtml += "<dt >";
                createPdfDivHtml += "<div class='displayDiv'>" + idx + "</div>";
                createPdfDivHtml += "<div class='triangle'></div>";
                createPdfDivHtml += "<div class='info'>";
                if (param[idx]["year"] == [] || param[idx]["year"] == null || param[idx]["url"] == false || param[idx]["url"] == undefined) {
                        //库中还查不到此人报告
                    createPdfDivHtml += "<p class='tishi'>自您体检后第10个工作日起查看报告</p>";
                } else {
                    createPdfDivHtml += "<p class='mark'>体检日期</p>";
                    createPdfDivHtml += "<p><span>" + param[idx].year + "</span>年</p>";
                    createPdfDivHtml += "<p><span>" + param[idx].month + "</span>月<span>" + param[idx].day + "</span>日</p>";
                    createPdfDivHtml += "<p class='top_15'>PDF</p>";
                }
                createPdfDivHtml += "</div>";
            createPdfDivHtml += "</dt>";
            countPdf = parseInt(idx) + 1;
            markPdfUrl.push(param.url);
            markPdfHtml.push(createPdfDivHtml);
            //把pdfDiv添加到html中
            $(".report").append(createPdfDivHtml);
        }
    }
    

    
    //判断显示几个空的pdfDiv
    if (countPdf <= 5) {
        emptyCountPdf = 5 - countPdf;
    } else {
        emptyCountPdf = 5-(countPdf % 5);
    }
    for (var i = 0; i < emptyCountPdf; i++) {
        if (i == emptyCountPdf - 1) {
            emptyPdfDivHtml += "<dd class='marginri_0'></dd>";
        } else {
            emptyPdfDivHtml += "<dd></dd>";
        }
        
    }
    $(".report").append(emptyPdfDivHtml);
}


/*
*   pdf鼠标浮动事件
*/
function pdfOnMouseOver(obj, clickObj) {
    var serchAndDownlodPdfDivHtml = "";
    //查看和下载pad报告
    if ($.browser.msie && $.browser.version == 8.0) {
        serchAndDownlodPdfDivHtml = "";
        serchAndDownlodPdfDivHtml = "<a class='serch' target='_blank'>"
        serchAndDownlodPdfDivHtml += "<p class='mark'>体检日期</p>";
        serchAndDownlodPdfDivHtml += "<p><span>" + clickObj[markPdfNum].year + "</span>年</p>";
        serchAndDownlodPdfDivHtml += "<p><span>" + clickObj[markPdfNum].month + "</span>月<span>" + clickObj[markPdfNum].day + "</span>日</p>";
        serchAndDownlodPdfDivHtml += "<div class='view'>";
        serchAndDownlodPdfDivHtml += "<img src='http://web-img.oss.aliyuncs.com/report-View.png' />";
        serchAndDownlodPdfDivHtml += "</a>"
    } else {
        serchAndDownlodPdfDivHtml = "";
        serchAndDownlodPdfDivHtml += "<p class='mark'>体检日期</p>";
        serchAndDownlodPdfDivHtml += "<p><span>" + clickObj[markPdfNum].year + "</span>年</p>";
        serchAndDownlodPdfDivHtml += "<p><span>" + clickObj[markPdfNum].month + "</span>月<span>" + clickObj[markPdfNum].day + "</span>日</p>";
        serchAndDownlodPdfDivHtml += "<div class='view'>";
        serchAndDownlodPdfDivHtml += "<img src='http://web-img.oss.aliyuncs.com/report-View.png' />";
    }
        $(obj).find(".info").html("");
        $(obj).find(".info").html(serchAndDownlodPdfDivHtml);
}

/*
*   pdf鼠标移出事件
*/
function pdfOnMouseOut(obj) {
    $(obj).html("");
    $(obj).html(markPdfHtml[markPdfNum]);
}

/*
*   绑定登录后pdf需要事件
*/
function binkLoginClick(obj) {
    var seePagewidth = $(window).width();
    //如果pc版添加报告的鼠标浮动事件
    if (seePagewidth > 999) {
        //鼠标浮动到pdf报告上
        $(".mark").parent(".info").parent("dt").mouseenter(function (event) {
            //记录选中pdf，用于淡出还原
            markPdfNum = parseInt($(this).find("div.displayDiv").text());
            pdfOnMouseOver(this, obj);
            event.stopPropagation();
        });

        $(".mark").parent(".info").parent("dt").mouseleave(function (event) {
            //记录选中pdf，用于淡出还原
            pdfOnMouseOut(this);
            event.stopPropagation();
        });
    } else {
        $(".mark").parent(".info").parent("dt").mouseenter(function (event) {
            markPdfNum = parseInt($(this).find("div.displayDiv").text());
            event.stopPropagation();
        });
    }
    
    $(".mark").parent(".info").parent("dt").click(function () {
        serchAndDownloadClick(obj, 0);
    });

}

function login(result) {
	//隐藏登录页面，展示体检报告页面
    $("#userLogin").css("display", "none");
    $(".icon").css("display", "none");
    $(".wordGroup6").css("display", "block");


    var jsonObj = [];
    var pdfName = "瀚思维康健检报告";
    if (result != null || result != []) {
        for (var i in result) {
			var time = "";
			var year = "";
			var month = "";
			var day = "";
			var timeArr = "";
			var name = "";
			var url = "";
            name = result[i].profile.name;
            time = result[i].profile.check_date;
			if (time != [] || time != null) {
                timeArr = time.split('-');
                year = timeArr[0];
                month = timeArr[1];
                day = timeArr[2];
            }
            if (result[i].pdf_created) {
                //pdfName=encodeURI(pdfName);
                url = encodeURI(host + "/reports/" + pdfName + "_" + year + month + day + "_" + name + ".pdf");
			}
            jsonObj.push(
                {
                    userName: name,
                    year: year,
                    month: month,
                    day: day,
                    url: url
                }
            );
        }
    }
    createDiv(jsonObj);
    if (result != null || result != []) {
        binkLoginClick(jsonObj);
    }

    $("#getName").text(name);
}


function disabledButton(flag) {
    if (flag) {
        $("#mobileLoginBtn").disabled = true;
        $("#loginLoading").show();
    } else {
        $("#mobileLoginBtn").disabled = false;
        $("#loginLoading").hide();
    }
    
}

function displayButton(flag) {
    if (flag) {
        $("#loginBtn").live("click", serchHealthReport);
        $("#loginLoading").hide();
    } else {
        $("#loginBtn").die("click", serchHealthReport);
        $("#loginLoading").show();
    }
}

function sendMessageButton(flag) {
    if (flag) {
        $("#loginBtn").live("click", serchHealthReport);
    } else {
        $("#loginBtn").die("click", serchHealthReport);
    }
}

/*
*   用户登录
*/
function serchHealthReport() {
    
    
    var userName = $("#userName").val();
    var passWord = $("#passWord").val();
    var param={
        name:userName,
        hash_id:passWord
    }

    if (userName != "" && passWord != "") {
        if (pcAndMobile == "mobile") {
            disabledButton(true);
        } else {
            displayButton(false);
        }
        
        //验证登陆
        $.ajax({
            type: 'post',
            url: host + "/guest_login",
            data: param,
            xhrFields: { withCredentials: true },
            success: function (result) {
                displayButton(true);
                //隐藏获取验证码
                $('#tab').css("display", "none");
                login(result);
            },
            error: function (e) {
                displayButton(true);
                var errorTip = e.responseText;
                if (pcAndMobile == "mobile") {
                    disabledButton(false);
                }
                $("#errorTip").text(errorTip);
                setTimeout(function () { $("#errorTip").text(""); }, 3000);
            }
        });
    } else {
        if (userName == "") {
            whatSay('userName',true);
        }
        if (passWord == "") {
            whatSay('passWord', true);
        }
    }

}


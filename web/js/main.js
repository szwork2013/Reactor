
/**
*   pc菜单的初始化
*/
function initMenu() {
    var setFuc = "";
    var resizeTimer = "";
    $("li").click(function () {
        $(this).blur();
    });
    $("li").mouseover(function () {
        $(this).stop().animate({ height: '150px' }, { queue: false, duration: 200 });
    });

    $("li").mouseout(function () {
        $(this).stop().animate({ height: '100px' }, { queue: false, duration: 200 });
    });

    $(".logo").click(function () {
        if (resizeTimer) {
            clearTimeout(resizeTimer);
        }
        setFuc = goto("page1");
        resizeTimer = setTimeout(setFuc, 400);
        return false;
    });

    $("#onlyOnePage").click(function () {
        if (resizeTimer) {
            clearTimeout(resizeTimer);
        }
        setFuc = goto("page4");
        resizeTimer = setTimeout(setFuc, 300);
        return false;
    });

    $("#groupPage").click(function () {
        if (resizeTimer) {
            clearTimeout(resizeTimer);
        }
        setFuc = goto("page8");
        resizeTimer = setTimeout(setFuc, 300);
        return false;
    });

    $("#healthMark").click(function () {
        if (resizeTimer) {
            clearTimeout(resizeTimer);
        }
        setFuc = goto("page6");
        resizeTimer = setTimeout(setFuc, 300);
        return false;
    });

    $("#findWe").click(function () {
        if (resizeTimer) {
            clearTimeout(resizeTimer);
        }
        setFuc = goto("page9");
        resizeTimer = setTimeout(setFuc, 300);
        return false;
    });
}

/*
*   手机菜单
*/
function bindMobileMenue() {
    var setFuc = "";
    var resizeTimer = "";

    $("body").click(function () {
        if ($(".mobileUL").hasClass("mobileUL_open")) {
            $(".mobileUL").removeClass("mobileUL_open");
        }
    });

    $(".menuDiv_mobile").click(function () {
        if ($(".mobileUL").hasClass("mobileUL_open")) {
            $(".mobileUL").removeClass("mobileUL_open");
            return false;
        } else {
            $(".mobileUL").addClass("mobileUL_open");
            return false;
        }
    });


    $(".logo_mobile").click(function () {
        if (resizeTimer) {
            clearTimeout(resizeTimer);
        }
        setFuc = goto("page1");
        resizeTimer = setTimeout(setFuc, 400);
    });

    $("#onlyOnePageMobile").click(function () {
        if (resizeTimer) {
            clearTimeout(resizeTimer);
        }
        setFuc = goto("page4");
        resizeTimer = setTimeout(setFuc, 300);
    });

    $("#groupPageMobile").click(function () {
        if (resizeTimer) {
            clearTimeout(resizeTimer);
        }
        setFuc = goto("page8");
        resizeTimer = setTimeout(setFuc, 300);
    });

    $("#healthMarkMobile").click(function () {
        if (resizeTimer) {
            clearTimeout(resizeTimer);
        }
        setFuc = goto("page6");
        resizeTimer = setTimeout(setFuc, 300);
    });

    $("#findWeMobile").click(function () {
        if (resizeTimer) {
            clearTimeout(resizeTimer);
        }
        setFuc = goto("page9");
        resizeTimer = setTimeout(setFuc, 300);
    });
}

/*
*   动态创建菜单（手机或pc）
*/
function changeMenu(seePagewidth) {
    var text = "";
    var smDiv = "";
    $("#menuTop").html(text);
    if (seePagewidth > 999 || $.browser.msie && $.browser.version == 8.0) {
        $("#menuTop").removeClass("header_mobile").addClass("header");
        text += "<div id=\"menuGroup\" class=\"menuDiv\">";
        text += "<ul class=\"mainUl\">";
        text += "<li id=\"onlyOnePage\"><p><a>体检预约</a></p></li>";
        text += "<li id=\"healthMark\"><p><a>查看报告</a></p></li>";
        text += "<li id=\"groupPage\"><p><a>企业定制</a></p></li>";
        text += "<li id=\"findWe\"><p><a>联系我们</a></p></li>";
        text += "</ul>";
        text += "</div>";
        text += "<div id=\"logo\" class=\"logo\">";
        text += "<img id=\"imgLogo\" src=\"http://web-img.oss.aliyuncs.com/logo.png\"/>";
        text += "</div>";
        $("#menuTop").html(text);
        initMenu();

    } else {
        $("#menuTop").removeClass("header").addClass("header_mobile");
        text += "<div  class=\"menuDiv_mobile\"> <div id=\"mobileMenu\" ></div> </div>";
        text += "<div id=\"logo\" class=\"logo_mobile\">";
        text += "<img id=\"imgLogo\" src=\"http://web-img.oss.aliyuncs.com/logo.png\"/> ";
        text += "</div>";
        text += "<div id=\"apDiv1\" class=\"mobileUL\">";
        text += "<p id=\"onlyOnePageMobile\"><a >体检预约</a></p>";
        text += "<p id=\"healthMarkMobile\"><a >查看报告</a></p>";
        text += "<p id=\"groupPageMobile\"><a >企业定制</a></p>";
        text += "<p id=\"findWeMobile\"><a >联系我们</a></p>";
        text += "</div>";

        $("#menuTop").html(text);
        bindMobileMenue();
    }

}


function computerInit() {
    index1ShowAndHidden(index_1_show);
}

/*
*   绑定跳转事件
*/
function bindForwordClick() {
    var setFuc = "";
    var resizeTimer="";
    
    $("#toIndex2").click(function () {
        setFuc = goto("page2");
        resizeTimer = setTimeout(setFuc, 400);
        return false;
    });
    $("#toIndex3").click(function () {
        setFuc = goto("page3");
        setTimeout(setFuc, 400);
        return false;
    });
    $("#toPage1").click(function () {
        setFuc = goto("page4");
        setTimeout(setFuc, 400);
        return false;
    });
}

/*
*   滚动条事件
*/
function goto(id) {
    return function callback() {
        $("#" + id).ScrollTo(300);
    }
}
/**
*   文字效果动画
*   @id 绑定div的id
*   @range  移动的距离
*   @time   移动速度（毫秒）
*/
function wordAnimation(id, range, time,status) {
    return function () {
        $("#" + id).stop().animate({ width: range }, { queue: false, duration: time });
    }
}


var showhide = false
/*
*  判断用户是个人还是团体登录
*/
function showOnlyOrFrom() {
    var hashValue = window.location.hash;
    hashValue = decodeURI(hashValue);
    if (hashValue && hashValue != "#group") {
        var urlIstrue = hashValue.indexOf(":");
        var urlArr = hashValue.split(":");
        if (urlIstrue == 3 && urlArr[0] == "#预约") {
          if ($.browser.msie && $.browser.version < 10.0) {
            showhide = true;
            return;
          } else {
            goGroupForm(urlArr[1]);
          }
        }
        createLoading('formLoading', '#2cd2de');
    } else {
        $(".wordGroup4").show();
        $(".package").show();
        $(".wordGroup5").hide();
    }
}

/*
*   手机和pc切换背景图
*/
function changeBgImg(seePagewidth) {
    if ($.browser.msie && $.browser.version == 8.0) {
        $("#backImage1").show();
        $("#backImage2").show();
        $("#backImage3").show();
    } else {
        if (seePagewidth > 999) {
            if ($("#backImage1").attr("src") == "" || $("#backImage2").attr("src") == "" || $("#backImage3").attr("src") == "") {
                downLoadPic();
            }
            $("#backImage1").show();
            $("#backImage2").show();
            $("#backImage3").show();
        } else {
            $("#backImage1").hide();
            $("#backImage2").hide();
            $("#backImage3").hide();
            $("#loadingDiv").hide();
        }
    }
}





/*
*   绑定login文本框检验
*/
function bindLoginCheck(uid,pid) {
    $("#" + uid).blur(function () {
        var value = $("#" + uid).val();
        if (value.match(/^[0-9]+$/)) {
            whatSay(uid, true);
        } else {
            whatSay(uid, false);
        }
    });
    $("#" + pid).blur(function () {
        var value = $("#" + pid).val();
        if (value!="") {
            whatSay(pid, false);
        }
    })
}

/*
*   图片加载失败的时候调用方法默认10s
*/
function erLoading() {
    $("#loadingDiv").hide();
}

/*
*   创建第版本浏览器不支持div
*/
function createMessageDiv(){
    var tipText = "";
    tipText += "<div class=\"mask\" id=\"mask\">";
    tipText += "<dl>";
    tipText += "<dt>为了让您体验更美观、流畅和完整功能的网页，</dt>";
    tipText += "<dt>我们建议您使用以下浏览器:</dt>";
    tipText += "<dd>";
    tipText += "<p><a href=\"http://windows.microsoft.com/zh-cn/internet-explorer/ie-8-worldwide-languages\">IE8.0或以上版本</a></p><p><a href=\"http://www.google.cn/intl/zh-CN/chrome/browser/index.html\">Chrome</a></p> <p><a href=\"http://firefox.com.cn/\">Firefox</a></p> <p><a href=\"http://se.360.cn/\">360安全浏览器</a></p></dd>";
    tipText += "</dd>";
    tipText += "<dt>如需继续浏览，将会降低您使用时的流畅性和舒适度。</dt>";
    tipText += "<dt>给您带来的不便敬请谅解！</dt>";
    tipText += "<dd>";
    tipText += "<p></p>";
    tipText += "</dd>";
    tipText += "</dl>";
    tipText += "</div>";
    $("#loadingDiv").after(tipText);
}

/*
*   手机菜单
*/
function messageDivHide(o) {
    var url = '#';
    var o = document.getElementById(o);
    o.style.display = "none";
    window.location = url;
}

/**
*   绑定登陆按钮click事件
*/
function bindLoginClick() {
    if (pcAndMobile == "pc") {
        //移除事件
        $("#loginBtn").die("click", serchHealthReport);
        $("#loginBtn").live("click", serchHealthReport);
    } else if (pcAndMobile == "mobile") {
        //移除事件
        $("#mobileLoginBtn").die("click",serchHealthReport);
        $("#mobileLoginBtn").live("click", serchHealthReport);
    }
}

/*
*   项目初始化下载图片
*/
function downLoadPic(){
    if ($.browser.msie && $.browser.version == 8.0 || $.browser.version == 9.0) {
        $("#backImage1").attr("src", "http://web-img.oss.aliyuncs.com/index_1.jpg?" + new Date().getTime());
        $("#backImage2").attr("src", "http://web-img.oss.aliyuncs.com/index_2.jpg?" + new Date().getTime());
        $("#backImage3").attr("src", "http://web-img.oss.aliyuncs.com/index_3.jpg?" + new Date().getTime());
    } else {
        $("#backImage1").attr("src", "http://web-img.oss.aliyuncs.com/index_1.jpg");
        $("#backImage2").attr("src", "http://web-img.oss.aliyuncs.com/index_2.jpg");
        $("#backImage3").attr("src", "http://web-img.oss.aliyuncs.com/index_3.jpg");
    }
}

//页面关闭事件
window.onbeforeunload = onbeforeunload_handler;

function onbeforeunload_handler() {
    
    if (closeStatus) {
        $.ajax({
            type: 'get',
            url: host + "/logout",
            xhrFields: { withCredentials: true },
            sucess: function () {
            },
            error: function (e) {

            }
        });
    } 
}


$(document).ready(function () {
    var seePageHeight = $(window).height();
    var seePagewidth = $(window).width();
    var resizeResult = {
        height: seePageHeight,
        width: seePagewidth
    }

    //下载图片
    downLoadPic();
    changeBgImg(seePagewidth);
    changeMenu(seePagewidth);
    tabMessage();
    //如果是ie8浏览器和ie9，做特殊操作
    if ($.browser.msie && $.browser.version == 8.0 || $.browser.version == 9.0) {
        $(".login > input").each(function () {
            placeHolder(this);
        });
    }
    /*else if ($.browser.msie && $.browser.version == 6.0 || $.browser.version == 7.0) {
        createMessageDiv();
    }*/

    $("#backImage1").load(function () {
        backImgReady["backImage1"] = true;
        hideIndexLoading("loadingDiv");
    });
    $("#backImage2").load(function () {
        backImgReady["backImage2"] = true;
        hideIndexLoading("loadingDiv");
    });
    $("#backImage3").load(function () {
        backImgReady["backImage3"] = true;
        hideIndexLoading("loadingDiv");
    });

    setTimeout("erLoading()", 10000);


    showOnlyOrFrom();
    if (showhide) {
      $("#mask").css('display', 'block');
      $("#ieIstrue").css('display', 'none');
      return;
    }

    //判断是否已登录
    if (typeof (serverUser) != "undefined" && serverUser != "") {
        login(serverUser);
        $('#tab').hide();
    }


    //取消首页1的内容隐藏，为实现动画效果
    $("#main1").show();
    $("#toIndex2").show();

    setTimeout("computerInit()", 300);

    initMenu();

    bindForwordClick();
    //根据浏览器大小调整背景图大小，pageBackGroudImg为model.js背景图片的集合
    resizeBackGroudImg(pageBackGroudImg, resizeResult);
    resizeDiv(pageDiv, resizeResult, defaultSeePageSize, resizeDivNum);

    bindLoginClick();

    bindLoginCheck('userName', 'passWord');
    //绑定登录页面回车登录事件
    document.onkeydown = keyDown;

    //退出登录
    $(".exit").click(function () {
        //隐藏登录页面，展示体检报告页面   
        $(".wordGroup6").css("display", "none");
        $("#userLogin").css("display", "block");
        $(".icon").css("display", "block");
        $('#userName').val('');
        $('#passWord').val('');
        $(".report").html("");
        //显示获取验证码
        $('#tab').css("display", "block");
        markPdfHtml = [];
        markPdfNum = 0;
        $.ajax({
            type: 'get',
            url: host+"/logout",
            xhrFields: { withCredentials: true },
            sucess: function () {
            },
            error: function (e) {

            }
        });
    });

    //创建地图
    createMap();

});

/**
* 切换获取验证码
*/
function tabMessage() {
    $("#tab li:last").addClass("aktif");

    // Tüm tab içeriklerini gizle
    $(".login").hide();

    // İlk tab içeriğini göster
    $(".login:last").show();

    // Tab'daki lilerden herhangi birine tıklandığında
    $("#tab li").click(function (e) {

        // indis değerini al
        var index = $(this).index();

        // tabdaki aktif classlarını sil
        $("#tab li").removeClass("aktif");

        // Tıklanan li'ye aktif classını ata
        $(this).addClass("aktif");

        // Tüm tab içeriklerini gizle
        $(".login").hide();

        // Indis değerine sahip tab içeriğini göster
        $(".login:eq(" + index + ")").show();

        return false

    });

    //pc发送短信按钮
    $("#notebth").click(function () {
        sendMessage();
    }); 
    //手机发送短信按钮
    $("#notebutton").click(function () {
        sendMessage();
    });
}

function sendMessage() {
    flag = checkMobile('r_mobile')
    if (!flag) {
        $('#errorTip').text('请输入正确的手机号码');
        setTimeout(closeTip, 3000);
    } else {
        //取消click事件，限制点击频率
        dieButton();
        var uMobile = $("#r_mobile").val();
        var param = { tel: uMobile };
        $.ajax({
            type: 'post',
            url: host + "/send_sms",
            data: param,
            xhrFields: { withCredentials: true },
            success: function (result) {
                res_arr = result.split('|')
                if (result == "无此号码") {
                    $('#errorTip').text('您输入的手机号有误，请联系客服010-62659812协助核实');
                    $('#r_mobile').addClass('error');
                    tipWord = '距您重获验证码还有';
                    countDonw(5, tipWord);
                } else if (res_arr[0] == '1') {
                    $('#r_mobile').removeClass('error');
                    $('#sucessTip').text('短信已发送，请查收');
                    tipWord = '距您重获验证码还有';
                    countDonw(30, tipWord);
                    setTimeout(closeTip, 5000);
                } else if (res_arr[0] == '3013') {
                    $('#errorTip').text('您的号码已被手机通信运营商添加到黑名单，请联系客服010-62659812协助解决');
                    $('#r_mobile').addClass('error');
                    tipWord = '距您重获验证码还有';
                    countDonw(5, tipWord);
                } else {
                    $('#errorTip').text('获取验证码失败，请联系客服010-62659812协助解决');
                    $('#r_mobile').addClass('error');
                    tipWord = '距您重获验证码还有';
                    countDonw(5, tipWord);
                }
            },
            error: function (e) {
                console.log(e);
                $('#errorTip').text('网络异常请稍后再试');
                setTimeout(closeTip, 5000);
                setTimeout(restBtn, 3000);
            }
        });
    }
}

//清除提示
function closeTip() {
    $('#errorTip').text('');
    $('#sucessTip').text('');
}
function dieButton() {
    $('#sendMsgBtnPic').removeClass('bth').addClass('bth_gray');
    $("#notebutton").css('background', '#8E8E8E');
    $("#notebth").unbind(); 
    $("#notebutton").unbind();
    
}

//恢复按钮选择
function restBtn() {
    $('#sendMsgBtnPic').removeClass('bth_gray').addClass('bth');
    $("#notebutton").css('background', '#5AC0EB');
    $("#cNumber").text('');
    $("#notebth").click(function () {
        sendMessage();
    });
    $("#notebutton").click(function () {
        sendMessage();
    });
}

//倒计时
function countDonw(num, tipWord) {
    this.countNumber = num;
    var setFuc = output(tipWord);
    var setForFuc = setInterval(setFuc, 1000);



    function output(tipWord) {
        return function callback() {
            if (this.countNumber === 0) {
                restBtn();
                $('#errorTip').text("");
                clearInterval(setForFuc);
            } else {
                $('#cNumber').text(tipWord + this.countNumber + "秒");
                this.countNumber = this.countNumber - 1;
            }
        }
    }
}



/*
*   取消loading
*/
function hideIndexLoading(id) {
	for (var idx in backImgReady) {
		if (backImgReady[idx] == false) {
            return;
        }
    }
	hideLoading(id);
}

/*
*   回车事件
*/
function keyDown(e) {
    var currKey = 0, e = e || event;
    currKey = e.keyCode || e.which || e.charCode;
    //判断是否已登录
    var islogin = $("#userLogin").css("display");
    
    if (islogin!="none") {
        //滚轮滚动距离
        var scrollrange = $(document).scrollTop();
        if (currKey == 13 && scrollrange > pageTop.page6 && scrollrange < pageTop.page8) {
            serchHealthReport();
        }
    }

    //刷新更改close状态，保证刷新后用户保持登录
    if (currKey == 116) {//屏蔽f5刷新 Maxthon下不行orz... 
        closeStatus = false;
    }
}
    
/**
 * @name placeHolder
 * @class 跨浏览器placeHolder,对于不支持原生placeHolder的浏览器，通过value或插入span元素两种方案模拟
 * @param {Object} obj 要应用placeHolder的表单元素对象
 * @param {Boolean} span 是否采用悬浮的span元素方式来模拟placeHolder，默认值false,默认使用value方式模拟
 */
function placeHolder(obj, span) {
    if (!obj.getAttribute('placeholder')) return;
    var imitateMode = span === true ? true : false;
    var supportPlaceholder = 'placeholder' in document.createElement('input');
    if (!supportPlaceholder) {
        var defaultValue = obj.getAttribute('placeholder');
        if (!imitateMode) {
            obj.onfocus = function () {
                (obj.value == defaultValue) && (obj.value = '');
                obj.style.color = '';
            }
            obj.onblur = function () {
                if (obj.value == defaultValue) {
                    obj.style.color = '';
                } else if (obj.value == '') {
                    obj.value = defaultValue;
                    obj.style.color = '#ACA899';
                }
            }
            obj.onblur();
        } else {
            var placeHolderCont = document.createTextNode(defaultValue);
            var oWrapper = document.createElement('span');
            oWrapper.style.cssText = 'position:absolute; color:#ACA899; display:inline-block; overflow:hidden;';
            oWrapper.className = 'wrap-placeholder';
            oWrapper.style.fontFamily = getStyle(obj, 'fontFamily');
            oWrapper.style.fontSize = getStyle(obj, 'fontSize');
            oWrapper.style.marginLeft = parseInt(getStyle(obj, 'marginLeft')) ? parseInt(getStyle(obj, 'marginLeft')) + 3 + 'px' : 3 + 'px';
            oWrapper.style.marginTop = parseInt(getStyle(obj, 'marginTop')) ? getStyle(obj, 'marginTop') : 1 + 'px';
            oWrapper.style.paddingLeft = getStyle(obj, 'paddingLeft');
            oWrapper.style.width = obj.offsetWidth - parseInt(getStyle(obj, 'marginLeft')) + 'px';
            oWrapper.style.height = obj.offsetHeight + 'px';
            oWrapper.style.lineHeight = obj.nodeName.toLowerCase() == 'textarea' ? '' : obj.offsetHeight + 'px';
            oWrapper.appendChild(placeHolderCont);
            obj.parentNode.insertBefore(oWrapper, obj);
            oWrapper.onclick = function () {
                obj.focus();
            }
            //绑定input或onpropertychange事件
            if (typeof (obj.oninput) == 'object') {
                obj.addEventListener("input", changeHandler, false);
            } else {
                obj.onpropertychange = changeHandler;
            }
            function changeHandler() {
                oWrapper.style.display = obj.value != '' ? 'none' : 'inline-block';
            }
            /**
             * @name getStyle
             * @class 获取样式
             * @param {Object} obj 要获取样式的对象
             * @param {String} styleName 要获取的样式名
             */
            function getStyle(obj, styleName) {
                var oStyle = null;
                if (obj.currentStyle)
                    oStyle = obj.currentStyle[styleName];
                else if (window.getComputedStyle)
                    oStyle = window.getComputedStyle(obj, null)[styleName];
                return oStyle;
            }
        }
    }
}






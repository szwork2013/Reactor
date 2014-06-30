/**
*   三个首页显示和隐藏方法
*   @obj    代表传来的需要显示隐藏的对象，有可能是pc端对象也有可能是移动端对象
*/
function index1ShowAndHidden(obj) {
    //用于setTimeOut传参的闭包对象
    var offBagFunction = "";

    offBagFunction = wordAnimation("title1", obj.title1_width, obj.title1_speed);
    setTimeout(offBagFunction, 0);
    offBagFunction = wordAnimation("title2", obj.title2_width, obj.title2_speed);
    setTimeout(offBagFunction, 100);
    offBagFunction = wordAnimation("title3", obj.title3_width, obj.title3_speed);
    setTimeout(offBagFunction, 200);

    $("#title1").css("padding", obj.padding);
    $("#title2").css("padding", obj.padding);
    $("#title3").css("padding", obj.padding);
}

function index2ShowAndHidden(obj) {
    //用于setTimeOut传参的闭包对象
    $("#main2").show();
    $("#toIndex3").show();

    $("#word_index2").removeClass(obj.word_index2_removeClass).addClass(obj.word_index2_addClass);
    $("#title21").removeClass(obj.title21_removeClass).addClass(obj.title21_addClass);
    $("#title22").removeClass(obj.title22_removeClass).addClass(obj.title22_addClass);
    $("#title23").removeClass(obj.title23_removeClass).addClass(obj.title23_addClass);
    $("#title24").removeClass(obj.title24_removeClass).addClass(obj.title24_addClass);
    $("#title25").removeClass(obj.title25_removeClass).addClass(obj.title25_addClass);
    $("#title26").removeClass(obj.title26_removeClass).addClass(obj.title26_addClass);
    $("#title27").removeClass(obj.title27_removeClass).addClass(obj.title27_addClass);
    $("#title28").removeClass(obj.title28_removeClass).addClass(obj.title28_addClass);
}



function index3ShowAndHidden(obj) {
    //用于setTimeOut传参的闭包对象
    $("#main3").show();
    $("#toPage1").show();
    $("#title31").removeClass(obj.title31_removeClass).addClass(obj.title31_addClass);
    $("#title32").removeClass(obj.title32_removeClass).addClass(obj.title32_addClass);
    $("#title33").removeClass(obj.title33_removeClass).addClass(obj.title33_addClass);
    $("#title34").removeClass(obj.title34_removeClass).addClass(obj.title34_addClass);
    $("#title35").removeClass(obj.title35_removeClass).addClass(obj.title35_addClass);
    $("#title36").removeClass(obj.title36_removeClass).addClass(obj.title36_addClass);
    $("#title37").removeClass(obj.title37_removeClass).addClass(obj.title37_addClass);
    $("#title38").removeClass(obj.title38_removeClass).addClass(obj.title38_addClass);
    $("#title39").removeClass(obj.title39_removeClass).addClass(obj.title39_addClass);

    //判断imgGroup是显示或隐藏
    if($(window).width()>999){
        imgRandomHidenAndShow(obj);
    }
}

/**
*   页面跳转标签现实或隐藏
*   @id     跳转标签id
*   @obj    显示隐藏的对象
*/
function jumpTagShowAndHidden(id, obj) {
    $("#" + id).removeClass(obj.jumpTagId_removeClass).addClass(obj.jumpTagId_addClass);
}

/**
*   乱序首页3展示图片id，以便做随机显示动画用
*   @classArr   每张图片class名称的集合
*/
function sortRandomArr(classArr) {
    function random(a,b){
        return Math.random()-0.5;
    }
    classArr.sort(random);
    return classArr;
}

function imgRandomHidenAndShow(obj) {
    var imgStatus = obj.img_div;
    //闭包临时对象
    var tempObj = "";
    //延迟播放秒数
    var sd = 200;

    function actionIn(num, id) {
        $("#imgGroup").fadeIn("slow");
    }

    function actionOut(id) {
        $("#" + id).fadeOut("slow");
    }

    function addBorderClass() {
        $("#imgGroup").addClass(obj.img_border_addClass);
        $("#imgLine").addClass(obj.img_border_addMiddleClass);
    }

    function cutBorderClass() {
        $("#imgGroup").removeClass(obj.img_border_removeClass);
        $("#imgLine").removeClass(obj.img_border_removeMiddleClass);
    }

    var seePagewidth = $(window).width();
    if (seePagewidth >= 1024) {
        if (imgStatus == true) {
            actionIn("", "imgGroup");
        } else {
            actionOut("imgGroup");
        }
    } else {
        $("#imgGroup").hide();
    }
}

function scrollPostion() {
    var pos = -1;
    var scrtop = document.documentElement.scrollTop || document.body.scrollTop;
    if (scrtop >= sign) {
        sign = scrtop;
        pos=1
    }

    if (scrtop < sign) {
        sign = scrtop;
        pos=0
    }
    return pos;
}



/*
*   控制滚动条滚动时标题的改变
*/
function scrollChangeTitle(delta) {
    //滚轮滚动距离
    var scrollrange = $(document).scrollTop();
    var temp="";
    var postion = 0;
    if (delta<0) {
        postion = 1;
    } else {
        postion = -1;
    }

    if (scrollrange < pageTop.page2) {
        if (postion == 1) {
            toPage("page2");
        } else {
            toPage("page1");
        }
    } else if (scrollrange > pageTop.page2 && scrollrange <= pageTop.page3) {
        if (postion == 1) {
            toPage("page3");
        } else {
            toPage("page1");
        }
    } else if (scrollrange > pageTop.page3 && scrollrange < pageTop.page4) {
        if (postion == 1) {
            toPage("page4");
        } else {
            toPage("page2");
        }
    } else if (scrollrange > pageTop.page4 && scrollrange < pageTop.page6) {
        if (postion == 1) {
            toPage("page6");
        } else {
            toPage("page3");
        }
    } else if (scrollrange > pageTop.page6 && scrollrange < pageTop.page8) {
        if (postion == 1) {
            toPage("page8");
        } else {
            toPage("page4");
        }
    } else if (scrollrange > pageTop.page8 && scrollrange < pageTop.page9) {
        if (postion == 1) {
            toPage("page9");
        } else {
            toPage("page6");
        }
    } else if (scrollrange > pageTop.page9 && scrollrange < pageTop.page10) {
        if (postion == 1) {
            toPage("page10");
        } else {
            toPage("page8");
        }
    } else if (scrollrange > pageTop.page10) {
        if (postion == 1) {
            toPage("page10");
        } else {
            toPage("page8");
        }
    }
}

/*
*   控制滚动条滚动时动画效果
*/
function scrollEvent() {
    //0是向上，1是向下
    var upAndDown = scrollPostion();
    var tempHeight=0;

    //滚轮滚动距离
    var scrollrange = $(document).scrollTop();
    
    if (scrollrange < pageTop.page2) {
        var imgHeight_1 = parseFloat(imgHeight.backImage1);

        if (scrollrange - pageTop.page1 > imgHeight_1 * 0.6) {
            jumpTagShowAndHidden(jumpTagId.page1, index_1_hidden);
        } else if (scrollrange - pageTop.page1 > imgHeight_1 * 0.2) {
            index1ShowAndHidden(index_1_hidden);
        } else {
            jumpTagShowAndHidden(jumpTagId.page1, index_1_show);
            index1ShowAndHidden(index_1_show);

            jumpTagShowAndHidden(jumpTagId.page2, index_2_hidden);
            index2ShowAndHidden(index_2_hidden);
        }
        //改变菜单样式
        $("#healthMark").removeClass("yellow");
        $("#onlyOnePage").removeClass("blue");
        $("#groupPage").removeClass("green");
        $("#findWe").removeClass("red");
        //$("#pageTitle").text("瀚思维康健康管理机构");
        document.title = "瀚思维康健康管理机构";
    } else if (scrollrange > pageTop.page2 && scrollrange <= pageTop.page3) {
        var imgHeight_2 = parseFloat(imgHeight.backImage2);

        if (scrollrange - pageTop.page2 > imgHeight_2 * 0.6) {
            jumpTagShowAndHidden(jumpTagId.page2, index_2_hidden);
        } else if (scrollrange - pageTop.page2 > imgHeight_2 * 0.2) {
            index2ShowAndHidden(index_2_hidden);
        } else {
            jumpTagShowAndHidden(jumpTagId.page2, index_2_show);
            index2ShowAndHidden(index_2_show);
            jumpTagShowAndHidden(jumpTagId.page3, index_3_hidden);
            index3ShowAndHidden(index_3_hidden);
        }
        //改变菜单样式
        $("#healthMark").removeClass("yellow");
        $("#onlyOnePage").removeClass("blue");
        $("#groupPage").removeClass("green");
        $("#findWe").removeClass("red");
        //$("#pageTitle").text("瀚思维康健康管理机构");
        document.title = "瀚思维康健康管理机构";
    } else if (scrollrange > pageTop.page3 && scrollrange < pageTop.page4) {
        var imgHeight_3 = parseFloat(imgHeight.backImage3);

        if (scrollrange - pageTop.page3 > imgHeight_3 * 0.6) {
            jumpTagShowAndHidden(jumpTagId.page3, index_3_hidden);
        } else if (scrollrange - pageTop.page3 > imgHeight_3 * 0.2) {
            index3ShowAndHidden(index_3_hidden);
        } else {
            index3ShowAndHidden(index_3_show);
            jumpTagShowAndHidden(jumpTagId.page3, index_3_show);
        }
        //改变菜单样式
        $("#healthMark").removeClass("yellow");
        $("#onlyOnePage").removeClass("blue");
        $("#groupPage").removeClass("green");
        $("#findWe").removeClass("red");
        //$("#pageTitle").text("瀚思维康健康管理机构");
        document.title = "瀚思维康健康管理机构";
    } else if (scrollrange > pageTop.page4 && scrollrange < pageTop.page6) {
        //改变菜单样式
        tempHeight= parseInt($("#bg6").css("height"));
        //向上滚动特殊处理
        if (upAndDown == 0) {
            if (scrollrange <= pageTop.page4 + tempHeight * 0.5) {
                $("#healthMark").removeClass("yellow");
                $("#onlyOnePage").addClass("blue");
            }
        } else {
            $("#onlyOnePage").addClass("blue");
            $("#healthMark").removeClass("yellow");
        }
        //改变菜单样式
        $("#groupPage").removeClass("green");
        $("#findWe").removeClass("red");
        //$("#pageTitle").text("体检预约");
        document.title = "体检预约";
    } else if (scrollrange > pageTop.page6 && scrollrange < pageTop.page8) {
        tempHeight = parseInt($("#bg8").css("height"));
        if (upAndDown == 0) {
            if (scrollrange <= pageTop.page6 + tempHeight * 0.5) {
                $("#groupPage").removeClass("green");
                $("#healthMark").addClass("yellow");
            } 
        } else {
            //改变菜单样式
            $("#groupPage").removeClass("green");
            $("#onlyOnePage").removeClass("blue");
            $("#healthMark").addClass("yellow");
        }
        //改变菜单样式
        $("#findWe").removeClass("red");
        //$("#pageTitle").text("查看报告");
        document.title = "查看报告";
    } else if (scrollrange > pageTop.page8 && scrollrange < pageTop.page9) {
        tempHeight = parseInt($("#bg9").css("height"));
        if (upAndDown == 0) {
            if (scrollrange <= pageTop.page8 + tempHeight * 0.5) {
                $("#findWe").removeClass("red");
                $("#groupPage").addClass("green");
            }
        } else {
            //改变菜单样式
            $("#findWe").removeClass("red");
            $("#healthMark").removeClass("yellow");
            $("#groupPage").addClass("green");
        }
        //改变菜单样式
        $("#onlyOnePage").removeClass("blue");
        //$("#pageTitle").text("企业定制");
        document.title = "企业定制";
    } else if (scrollrange > pageTop.page9) {
        $("#groupPage").removeClass("green");
        $("#findWe").addClass("red");
        //改变菜单样式
        $("#healthMark").removeClass("yellow");
        $("#onlyOnePage").removeClass("blue");
        // $("#pageTitle").text("联系我们");
        //$("title").text("联系我们");
        document.title = "联系我们";
    }
}

/*
*   手机版本去掉动画，直接显示出所有文字
*/
function showDivForMobile(seePagewidth) {
    if (seePagewidth<999) {
        $("#main1").show();
        $("#main2").show();
        $("#main3").show();

        $("#toPage1").show();
        $("#toIndex3").show();
        $("#toIndex2").show();
        $("#toPage1").removeClass("upOut1");
        $("#toIndex3").removeClass("upOut1");
        $("#toIndex2").removeClass("upOut1");
        
        index1ShowAndHidden(index_1_show);
        index2ShowAndHidden(index_2_show);
        index3ShowAndHidden(index_3_show);
        $("#imgGroup").hide();
    }
    
}

/*
*   监听滚轮滚动(只有屏幕尺寸大于999时候才做整屏翻滚)
*/
$(document).bind('mousewheel', function (event, delta, deltaX, deltaY) {
    var seePagewidth = $(window).width();
    if (seePagewidth > 999) {
        if (!scrollTimer) {
            scrollChangeTitle(delta);
        }
    }
});

/*
*   鼠标滚轮事件
*/
$(window).scroll(function () {
    var scrollrange = $(document).scrollTop();
    //屏幕可视高度
    var seePageHeight=$(window).height();
    var seePagewidth = $(window).width();

    if (seePagewidth > 999) {
        //背景图片高度
        for (var idx in pageBackGroudImg) {
            var topValue = pageBackGroudImg[idx];
            pageTop[idx] = parseInt($("#" + topValue).offset().top) - 20;
        }

        for (var idx in resizeImgClassName) {
            var id = resizeImgClassName[idx];
            imgHeight[id] = $("#" + id).css("height");
        }
        scrollEvent();
    } else {
        showDivForMobile(seePagewidth);  
    }
});

/*
*   释放滚动方法
*/
function closeScroll() {
    scrollTimer = false;
}

//var lastScrollTop = 0;
//var scrollMarkrange = 0;
/*
*   处理记录滚动到的页面
*/
function toPage(page) {
    for (var i in scrollMark) {
        if (i == page) {
            scrollMark[i] = true;
        } else {
            scrollMark[i] = false;
        }
    }

    if (!scrollTimer) {
       scrollToPage();
    }

}

/*
*   判断跳转页面并执行跳转操作
*/
function scrollToPage() {
    var flag = null;
    var gotoMark = "";
    var nextSt = "";
    var postion = -1;

    for (var i in scrollMark) {
        gotoMark = "";
        var flag = scrollMark[i];
        if (flag) {
            gotoMark = i;
            break;
        }
    }
   
    setFuc = goto(gotoMark);
    resizeTimer = setTimeout(setFuc, 0);
    setTimeout(closeScroll, 1000);
    scrollTimer = true;
    return false;
}
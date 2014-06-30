/**
*   手动调节大小背景图
*   因为手动调节的时候用的css来等比缩放，为不和其样式冲突，把宽改为100%
*/
function resizeBackGroudImg(idArr, resizeResult) {
    var resizImg = "";
    //如果不是手机端就执行
    if (resizeResult.width > 999) {
        //网页版整屏翻滚，隐藏滚动条
        $("html").css("overflow","hidden");
        //$("html").css("overflow", "scroll");
        pcAndMobile = "pc";
        resizImg = imgResize(imgSize);
        if (idArr && idArr != []) {
            for (var i in idArr) {
                if (idArr[i] == "bg9") {
                    var a = resizeResult.height;
                    var b = parseFloat($("#bg9").css("height"));
                    //var bg9hg = b + a - a;
                    var bg9hg = 0;
                    if (a >= b) {
                        bg9hg = b + (a - b);
                    } else {
                        bg9hg = b;
                    }

                    $("#" + idArr[i]).css("height", bg9hg + "px");
                } else {
                    if (resizImg.height > parseFloat(resizeResult.height)) {
                        if (parseFloat(resizeResult.height) < minWidthAndHeight.height) {
                            $("#" + idArr[i]).css("height", resizImg.height);
                        } else {
                            $("#" + idArr[i]).css("height", parseFloat(resizeResult.height));
                        }
                    } else {
                        $("#" + idArr[i]).css("height", resizImg.height + "px");
                    }
                }
                $("#" + resizeImgClassName[idArr[i]]).css("width", "100%");
            }
            //下一页图片切换
            $("#toIndex2 >img").attr("src", "http://web-img.oss.aliyuncs.com/arrows-1.png");
            $("#toIndex3 >img").attr("src", "http://web-img.oss.aliyuncs.com/arrows-2.png");
            $("#toPage1 >img").attr("src", "http://web-img.oss.aliyuncs.com/arrows-1.png");

            //判断是否隐藏显示首页3图
            if (resizeResult.width < 1024) {
                $("#imgGroup").hide();
            } else {
                hideIndexImg();
            }
            
        }
    } else {
        //手机版恢复滚动条
        $("html").css("overflow", "scroll");
        pcAndMobile = "mobile";
        if (idArr && idArr != []) {
            for (var i in idArr) {
                if (resizImg.height > parseFloat(resizeResult.height)) {
                    if (parseFloat(resizeResult.height) < minWidthAndHeight.height) {
                        $("#" + idArr[i]).css("height", resizImg.height);
                    } else {
                        $("#" + idArr[i]).css("height", parseFloat(resizeResult.height));
                    }
                } else {
                    $("#" + idArr[i]).css("height", resizImg.height + "px");
                }
                
                $("#" + resizeImgClassName[idArr[i]]).css("width", "100%");

                //下一页图片切换
                $("#toIndex2 >img").attr("src", "http://web-img.oss.aliyuncs.com/arrows-1.png");
                $("#toIndex3 >img").attr("src", "http://web-img.oss.aliyuncs.com/arrows-2.png");
                $("#toPage1 >img").attr("src", "http://web-img.oss.aliyuncs.com/arrows-1.png");
            }
        }
    }
}

/**
*   首页3图片div和文字div接近到一定程度隐藏图片div
*   如果因距离不够被隐藏返回false，展示图片div显示true,用于scroll判断显示隐藏冲突解决
*/
function hideIndexImg() {

    if ($("#imgGroup")) {
        var mw = parseFloat($("#main3").css("width"));
        var ww = parseFloat($("#word_index3").css("width"));
        var iw = parseFloat($("#imgGroup").css("width"));
        var v = mw - ww - iw;
        if (v < 50) {
            $("#imgGroup").hide();
        } else {
            $("#imgGroup").show();
        }
    }
}

/**
*   根据窗口和分辨率
*/
function resizeDiv(idArr, resizeResult, defaultSeePageSize, resizeDivNum) {
    if (idArr && idArr != []) {
        for (var i in idArr) {
            //处理id，因为方便div#main和背景图片缩放时高度一样，故main的id为divId+"_"+背景图片的id
            var tempArr = (idArr[i]).split('_');
            //外套层id
            var outDivId = tempArr[0];
            //背景图id
            var imgId = tempArr[1];
            //锚计点id
            var markId = tempArr[2];

            var bgImgHeight = parseFloat($("#" + imgId).css("height"));
            var bgImgWidth = parseFloat($("#" + imgId).css("width"));
            var bgImgTop = parseFloat($("#" + imgId).offset().top);
            //更改记录各页面top对象的值，用于scroll事件的计算
            pageTop[markId] = bgImgTop;

            bgImgHeight = bgImgHeight-9;
            bgImgWidth = bgImgWidth*0.9;
            //设置内容外套div最大宽度值
            if (bgImgWidth > minWidthAndHeight.width) {
                bgImgWidth = minWidthAndHeight.width;
            }

            $("#" + outDivId).css("height", bgImgHeight + "px");
            $("#" + outDivId).css("width", bgImgWidth + "px");
            $("#" + outDivId).css("top", bgImgTop + "px");

            //处理锚计点位置
            $("#" + markId).css("top", bgImgTop+"px");
        }
        //特殊处理page10，因为联系我们页面可能长于浏览器窗口，需要page10居底，让客户能看全最后一页
        var mark9=parseInt($("#page9").css("top"));
        var pageHeight9 = resizeResult.height;
        $("#page10").css("top", mark9 + pageHeight9 + "px");
        //$("#page9").css("top", mark9 + pageHeight9 + "px");
    }
}

/**
*   计算图片等比缩放
*   @width 如果有width值，缩放比例为height，如果没有就读取resizeImgClassName
*/
function imgResize(size) {
    
    //需要修改的图片集合
    var w = 0;
    var height = 0;
    for (var i in resizeImgClassName) {
        //外包围容器宽度
        w = $("#" + i).width()
        
        //图片原始像素
        var img_w = size.width;
        var img_h = size.height;
        if (img_w > w) {
            //高度等比缩放 
            height = (w * img_h) / img_w; 
            $("#" + resizeImgClassName[i]).css({ "width": w, "height": height });
        }
    }

    var resizImg = {
        height: height,
        width: w
    }

    return resizImg;
}

/**
*   窗口调整大小事件
*/
$(window).bind("resize", function () {
    //屏幕可视高度
    var seePageHeight = $(window).height();
    var seePagewidth = $(window).width();
    var resizeResult = {
        height: seePageHeight,
        width: seePagewidth
    }
    changeBgImg(seePagewidth);

    //手机版去掉动画直接显示文字
    showDivForMobile(seePagewidth);
    //动态创建菜单
    changeMenu(seePagewidth);

    if ($.browser.msie || $.browser.safari || $.browser.mozilla) {
        //ie10只执行一次
        resizeBackGroudImg(pageBackGroudImg, resizeResult);
        resizeDiv(pageDiv, resizeResult, defaultSeePageSize, resizeDivNum);
    } else {
        //避免resize的方法执行2次
        //背景图调整
        if (resizeBgImg % 2 == 0) {
            resizeBackGroudImg(pageBackGroudImg, resizeResult);
        }
        resizeBgImg++;

        //div调整
        if (resizeDivNum % 2 == 0) {
            resizeDiv(pageDiv, resizeResult, defaultSeePageSize, resizeDivNum);
        }
        resizeDivNum++;
    }
    //绑定手机或pc登录按钮
    bindLoginClick();
});








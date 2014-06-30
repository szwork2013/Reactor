/*
*   创建地图
*/
function createMap() {
    var map = new BMap.Map("mapOutDiv");
    var poi = new BMap.Point(116.334187, 39.990441);
    map.centerAndZoom(poi, 17);
    //启用滚动轮切换大小
    //map.enableScrollWheelZoom();
    map.addControl(new BMap.NavigationControl());
    map.addControl(new BMap.ScaleControl());
    map.addControl(new BMap.OverviewMapControl());
    //map.addControl(new BMap.MapTypeControl());
    var icon = new BMap.Icon("http://map-img.oss.aliyuncs.com/marker.png", new BMap.Size(31, 43), {
        anchor: new BMap.Size(10, 30)
    });

    var marker = new BMap.Marker(poi, {
        icon: icon
    });
    //var marker = new BMap.Marker(poi);
    map.addOverlay(marker);


    //标注click
    marker.addEventListener('click', function (e) {
        marker.openInfoWindow(infoWindow);
    });
    //整个地图的click
    map.addEventListener('click', function (e) {
        e.stopPropagation();
       /*if (e.overlay) {
            alert('你点击的是覆盖物：' + e.overlay.toString());
            // marker.openInfoWindow(infoWindow);
            return;
        } else {
            alert('你点击的是地图');
            return;
            //marker.openInfoWindow(infoWindow);
        }*/

    });

    var licontent = "<b>瀚思维康体检中心</b><br>";
    licontent += "<a><div class=\"bgimg\"></div></a>"
    licontent += "<span><strong>地址：</strong>北京市海淀区中关村南<span class=\"text\">三街6号中科资源大厦</span><span class=\"text2\">南楼5层</span></span><br>";
    licontent += "<span class=\"tel\"><strong>电话：</strong> <span class=\"kong\">010-82626102 010-62659812</span> </span><br>";
    licontent += "<p class=\"input\"><strong></strong><input class=\"outset\" type=\"text\" name=\"origin\" value=\"\"/><input class=\"outset-but\" type=\"button\" value=\"公交\" onclick=\"gotobaidu(1)\" /><input class=\"outset-but\" type=\"button\" value=\"驾车\"  onclick=\"gotobaidu(2)\"/><a class=\"gotob\" href=\"url=\"http://api.map.baidu.com/direction?destination=latlng:" + marker.getPosition().lat + "," + marker.getPosition().lng + "|name:中科资源大厦" + "?ion=北京" + "&output=html\" target=\"_blank\"></a></p>";
    var hiddeninput = "<input type=\"hidden\" value=\"" + '北京' + "\" name=\"region\" /><input type=\"hidden\" value=\"html\" name=\"output\" /><input type=\"hidden\" value=\"driving\" name=\"mode\" /><input type=\"hidden\" value=\"latlng:" + marker.getPosition().lat + "," + marker.getPosition().lng + "|name:中科资源大厦" + "\" name=\"destination\" />";
    var content1 = "<form id=\"gotobaiduform\" action=\"http://api.map.baidu.com/direction\" target=\"_blank\" method=\"get\">" + licontent + hiddeninput + "</form>";
    var opts1 = { width: 310,height:170 };

    var infoWindow = new BMap.InfoWindow(content1, opts1);
    marker.openInfoWindow(infoWindow);
}




/*
*   查询路线
*/
function gotobaidu(type) {
    if ($.trim($("input[name=origin]").val()) == "") {
        alert("请输入起点！");
        return;
    } else {
        if (type == 1) {
            $("input[name=mode]").val("transit");
            $("#gotobaiduform")[0].submit();
        } else if (type == 2) {
            $("input[name=mode]").val("driving");
            $("#gotobaiduform")[0].submit();
        }
    }
}

/**
*	ʵ����
*/

//���ؿ������ǰ׺��ַ�����ͬ���Ϊ���ַ���
var host = "http://wedocare.com";
//var host = "";

//�ж���ҳ3��ͼƬ�Ƿ��������¼�
var backImgReady = {
    backImage1: false,
    backImage2: false,
    backImage3: false
}

//ҳ�汳��ͼƬid����
var pageBackGroudImg = {
    page1: "bg1",
    page2: "bg2",
    page3: "bg3",
    page4: "bg4",
    page6: "bg6",
    page8: "bg8",
    page9: "bg9"
}

//ҳ��ֱ��ʼ����ڴ�С�ı䣬��Ҫ�ı���Ӧλ�õ�div��id����(��ʽ��ҳ�����Χdiv_����ͼƬ���Ϊdiv_ê�ǵ�div)����Ӵ�������Զ�resize����λ��
var pageDiv = ["main1_bg1_page1", "main2_bg2_page2", "main3_bg3_page3", "main4_bg4_page4", "main6_bg6_page6", "main8_bg8_page8", "main9_bg9_page9"];

//����resize�ķ���ִ��2�ζ���ı���
var resizeDivNum = 0;
var resizeBgImg = 0;

//Ҫ���ű���ͼ��id��key��ͼƬ����div��id��value��ͼƬid
var resizeImgClassName = {
    bg1: "backImage1",
    bg2: "backImage2",
    bg3: "backImage3"
}

//С�ײ���������
var planArr = [];

/*javascript��̬�ƶ���ʽ*/

//�趨Ĭ����������ӷ�Χ��͸�
var defaultSeePageSize = {
    height: $(window).height(),
    width: $(window).width()
}

//��̬�洢ÿ�ű���ͼƬtop�ľ���
var pageTop = {
    page1: 0,
    page2: 720,
    page3: 1510,
    page4: 2300,
    page6: 3020,
    page8: 3740,
    page9: 4460,
    page10:5694 
}

//����ͼ�߶�
var imgHeight = {
    backImage1: $(window).height(),
    backImage2: $(window).height(),
    backImage3: $(window).height()
}

//Ҫ���ŵı���ͼ��͸�
var imgSize = {
    width: 2880,
    height:1800
}

//�ֻ��������ſ�͸�
var mobileSize = {
    width: 1600,
    height: 720
}

//index1��ʾ�������ݵĶ�̬��ʽ
var index_1_show = {
    title1_width: "400px",
    title1_speed:200,
    title2_width: "215px",
    title2_speed:200,
    title3_width: "305px",
    title3_speed:200,
    padding: "5px 18px 4px 5px",
    jumpTagId_removeClass: "upOut1",
    jumpTagId_addClass: "top_fadein"
}

//index1�����������ݵĶ�̬��ʽ
var index_1_hidden = {
    title1_width: "0px",
    title1_speed: 200,
    title2_width: "0px",
    title2_speed: 200,
    title3_width: "0px",
    title3_speed: 200,
    padding: "5px 0px 4px 0px",
    jumpTagId_removeClass: "top_fadein",
    jumpTagId_addClass: "upOut1"
}

//index2��ʾ�������ݵĶ�̬��ʽ
var index_2_show = {
    word_index2_removeClass: "upOut1",
    word_index2_addClass:"",
    title21_removeClass: "upOut1",
    title21_addClass: "right_fadein1",
    title22_removeClass: "fallOut1",
    title22_addClass: "bottom_fadein",
    title23_removeClass: "fallOut1",
    title23_addClass: "bottom_fadein",
    title24_removeClass: "fallOut1",
    title24_addClass: "bottom_fadein",
    title25_removeClass: "fallOut1",
    title25_addClass: "bottom_fadein",
    title26_removeClass: "fallOut1",
    title26_addClass: "bottom_fadein",
    title27_removeClass: "fallOut1",
    title27_addClass: "bottom_fadein",
    title28_removeClass: "fallOut1",
    title28_addClass: "bottom_fadein",
    jumpTagId_removeClass: "upOut1",
    jumpTagId_addClass: "page_right_fadein_1"
}

//index2�����������ݵĶ�̬��ʽ
var index_2_hidden = {
    word_index2_removeClass:"",
    word_index2_addClass: "upOut1",
    title21_removeClass: "right_fadein1",
    title21_addClass: "upOut1",
    title22_removeClass: "bottom_fadein",
    title22_addClass: "fallOut1",
    title23_removeClass: "bottom_fadein",
    title23_addClass: "fallOut1",
    title24_removeClass: "bottom_fadein",
    title24_addClass: "fallOut1",
    title25_removeClass: "bottom_fadein",
    title25_addClass: "fallOut1",
    title26_removeClass: "bottom_fadein",
    title26_addClass: "fallOut1",
    title27_removeClass: "bottom_fadein",
    title27_addClass: "fallOut1",
    title28_removeClass: "bottom_fadein",
    title28_addClass: "fallOut1",
    jumpTagId_removeClass: "page_right_fadein_1",
    jumpTagId_addClass: "upOut1"
}

var index_3_show = {
    title31_removeClass: "upOut1",
    title31_addClass: "right_fadein1",
    title32_removeClass: "fallOut1",
    title32_addClass: "bottom_fadein2",
    title33_removeClass: "fallOut2",
    title33_addClass: "bottom_fadein3",
    title34_removeClass: "upOut2",
    title34_addClass: "right_fadein2",
    title35_removeClass: "fallOut3",
    title35_addClass: "bottom_fadein4",
    title36_removeClass: "fallOut4",
    title36_addClass: "bottom_fadein5",
    title37_removeClass: "upOut3",
    title37_addClass: "right_fadein3",
    title38_removeClass: "fallOut5",
    title38_addClass: "bottom_fadein6",
    title39_removeClass: "fallOut6",
    title39_addClass: "bottom_fadein7",
    jumpTagId_removeClass: "upOut1",
    jumpTagId_addClass: "page_right_fadein_1",
    img_div: true,
    img_border_addClass: "border_0",
    img_border_addMiddleClass: "border_1"
}

var index_3_hidden = {
    title31_removeClass: "right_fadein1",
    title31_addClass: "upOut1",
    title32_removeClass: "bottom_fadein2",
    title32_addClass: "fallOut1",
    title33_removeClass: "bottom_fadein3",
    title33_addClass: "fallOut2",
    title34_removeClass: "right_fadein2",
    title34_addClass: "upOut2",
    title35_removeClass: "bottom_fadein4",
    title35_addClass: "fallOut3",
    title36_removeClass: "bottom_fadein5",
    title36_addClass: "fallOut4",
    title37_removeClass: "right_fadein3",
    title37_addClass: "upOut3",
    title38_removeClass: "bottom_fadein6",
    title38_addClass: "fallOut5",
    title39_removeClass: "bottom_fadein7",
    title39_addClass: "fallOut6",
    jumpTagId_removeClass: "page_right_fadein_1",
    jumpTagId_addClass: "upOut1",
    img_div: false,
    img_border_removeOutClass: "border_0",
    img_border_removeMiddleClass: "border_1"
}

//ҳ����ת��ǩ��div����
var jumpTagId = {
    page1: "toIndex2",
    page2: "toIndex3",
    page3: "toPage1"
}

//ͼƬ��С��͸ߣ�������ݱ���д ԭͼ2880��1800��
var minWidthAndHeight = {
    width:1024,
    height:650
}

var randomImgNum = [1, 2, 3, 4, 5, 6];
var imgClassNameArr = ["img_01", "img_02", "img_03", "img_04", "img_05", "img_06"];

//���ڹ������ж����¹���
var sign = 0;

//��¼ÿ��pdf��url
var markPdfUrl = [];

//��¼ÿ����ʾpdf�ĵ���html���룬����onmouse�¼�
var markPdfHtml = [];

//��¼ѡ���ĸ�pdf
var markPdfNum = 0;

//ɸѡ����ײ�
var truePlan = [];

//���ײ�batch
var bigBatch = "";

//���ײ�����
var bigName = "";

//ѡ��С�ײ�id
var selectSmallId = "";

//ѡ��С�ײ�����
var selectSmallName = "";

//ѡ��С�ײͼ۸�
var selectSamllPrice = "";

//������ǿ���֤
var groupFormNull = {
    name: false,
    age: false,
    idPort: false,
    mobile: false,
    department:false
}

//�ֻ��˺�pc���ж϶����ֻ�Ϊmobile��pcΪpc
var pcAndMobile = "pc";

//�����ֹ�������״̬��������setTImeout��ʱ�ָ�״̬������������߹������ֵ���������
var scrollTimer = false;

//��¼����ҳ��
var scrollMark = {
    page1: false,
    page2: false,
    page3: false,
    page4: false,
    page6: false,
    page8: false,
    page9: false,
    page10: false
}

//����ˢ�º͹ر������
var closeStatus = true;
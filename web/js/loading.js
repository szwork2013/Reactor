function createLoading(id, color) {
    var cl = new CanvasLoader(id);
    cl.setColor(color); // default is '#000000'
    cl.setDiameter(26); // default is 40
    cl.setDensity(52); // default is 40
    cl.setRange(1.2); // default is 1.3
    cl.setFPS(28); // default is 24
    cl.show(); // Hidden by default

    // This bit is only for positioning - not necessary
    var loaderObj = document.getElementById("canvasLoader");
    loaderObj.style.position = "absolute";
    loaderObj.style["top"] = cl.getDiameter() * -0.5 + "px";
    loaderObj.style["left"] = cl.getDiameter() * -0.5 + "px";
}

function showLoading(id) {
    $("#" + id).show();
}

function hideLoading(id){
    $("#"+id).hide();
}



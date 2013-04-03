var map, iw, drag_area, actual, obj;
var dummy, z_index = 0;

function DummyOView() {
    console.log(this)
    this.setMap(map);
    this.draw = function () {}
}
DummyOView.prototype = new google.maps.OverlayView();

function fillMarker(a) {
    var b = document.createElement("div");
    b.style.backgroundImage = "url(" + a + ")";
    var c;
    if (obj.id == "m1") {
        c = "0px"
    } else if (obj.id == "m2") {
        c = "50px"
    } else if (obj.id == "m3") {
        c = "100px"
    }
    b.style.left = c;
    b.id = obj.id;
    b.className = "drag";
    b.onmousedown = b.ontouchstart = initDrag;
    drag_area.replaceChild(b, obj);
    obj = null
}
function highestOrder() {
    return z_index
}
function createDraggedMarker(c, f) {
    var d = google.maps;
    var h = {
        url: f,
        size: new d.Size(32, 32),
        anchor: new d.Point(15, 32)
    };
    var i = {
        url: "http://maps.gstatic.com/mapfiles/kml/paddle/A_maps.shadow.png",
        size: new d.Size(59, 32),
        anchor: new d.Point(15, 32)
    };
    var g = new d.Marker({
        position: c,
        map: map,
        clickable: true,
        draggable: true,
        raiseOnDrag: false,
        icon: h,
        shadow: i,
        zIndex: highestOrder()
    });
    d.event.addListener(g, "click", function () {
        actual = g;
        var a = actual.getPosition().lat();
        var b = actual.getPosition().lng();
        iw.setContent(a.toFixed(6) + ", " + b.toFixed(6));
        iw.open(map, this)
    });
    d.event.addListener(g, "dragstart", function () {
        if (actual == g) iw.close();
        z_index += 1;
        g.setZIndex(highestOrder())
    })
}
function initDrag(e) {
    var l = function (a) {
        var b = {};
        if (a && a.touches && a.touches.length) {
            b.x = a.touches[0].clientX;
            b.y = a.touches[0].clientY
        } else {
            if (!a) var a = window.event;
            b.x = a.clientX;
            b.y = a.clientY
        }
        return b
    };
    var m = function (r) {
        if (obj && obj.className == "drag") {
            var n = l(r),
                s = n.x - o.x,
                t = n.y - o.y;
            obj.style.left = (obj.x + s) + "px";
            obj.style.top = (obj.y + t) + "px";
            obj.onmouseup = obj.ontouchend = function () {
                var a = map.getDiv(),
                    b = a.offsetLeft,
                    c = a.offsetTop,
                    f = a.offsetWidth,
                    d = a.offsetHeight;
                var h = drag_area.offsetLeft,
                    i = drag_area.offsetTop,
                    g = obj.offsetWidth,
                    p = obj.offsetHeight;
                var j = obj.offsetLeft + h + g / 2;
                var k = obj.offsetTop + i + p / 2;
                if (j > b && j < (b + f) && k > c && k < (c + d)) {
                    var u = 1;
                    var v = google.maps;
                    var w = new v.Point(j - b - u, k - c + (p / 2));
                    var x = dummy.getProjection();
                    var y = x.fromContainerPixelToLatLng(w);
                    var q = obj.style.backgroundImage.slice(4, -1).replace(/"/g, "");
                    createDraggedMarker(y, q);
                    fillMarker(q)
                }
            }
        }
        return false
    };
    if (!e) var e = window.event;
    obj = e.target ? e.target : e.srcElement ? e.srcElement : e.touches ? e.touches[0].target : null;
    if (obj.className != "drag") {
        if (e.cancelable) e.preventDefault();
        obj = null;
        return
    } else {
        z_index += 1;
        obj.style.zIndex = z_index.toString();
        obj.x = obj.offsetLeft;
        obj.y = obj.offsetTop;
        var o = l(e);
        if (e.type === "touchstart") {
            obj.onmousedown = null;
            obj.ontouchmove = m;
            obj.ontouchend = function () {
                obj.ontouchmove = null;
                obj.ontouchend = null;
                obj.ontouchstart = initDrag
            }
        } else {
            document.onmousemove = m;
            document.onmouseup = function () {
                document.onmousemove = null;
                document.onmouseup = null;
                if (obj) obj = null
            }
        }
    }
    return false
}
function buildMap() {
    var a = google.maps;
    var b = {
        center: new a.LatLng(52.052491, 9.84375),
        zoom: 4,
        mapTypeId: a.MapTypeId.ROADMAP,
        streetViewControl: false,
        mapTypeControlOptions: {
            mapTypeIds: [a.MapTypeId.ROADMAP, a.MapTypeId.SATELLITE, a.MapTypeId.TERRAIN]
        },
        panControl: false,
        zoomControlOptions: {
            style: a.ZoomControlStyle.SMALL
        }
    };
    map = new a.Map(document.getElementById("map"), b);
    iw = new a.InfoWindow();
    a.event.addListener(map, "click", function () {
        if (iw) iw.close()
    });
    drag_area = document.getElementById("markers");
    var c = drag_area.getElementsByTagName("div");
    for (var f = 0; f < c.length; f++) {
        var d = c[f];
        d.onmousedown = d.ontouchstart = initDrag
    }
    //dummy = new DummyOView()
}
window.onload = buildMap;

var stv = {};

stv.init = function(){
  stvmap = new stv.Map(document.getElementById("map_canvas"), document.getElementById("pano"));
  stvmap.init();
  //var tag1 = new stv.Tag(stvmap.map, 35.69, 139.698699);

  for(var i=0; i<1; i++){
    var lat = 35.69      + (i / 10);
    var lng = 139.698699 + (i / 10);
    var tag = new stv.Tag(stvmap.stv, lat, lng);
  }
}

//---------------------------------------
stv.Tag = function(map, lat, lng){
  this.map_obj = map;
  this.lat = lat;
  this.lng = lng;
  this.setMap(map);
}
stv.Tag.prototype = new google.maps.OverlayView();
stv.Tag.prototype.onAdd = function(){
  if(!this.elem){
    this.elem = document.createElement( "div" );
    this.elem.innerHTML = "<div style='background-color:red;'>X</div>";
    this.elem.style.position = "absolute";
    this.getPanes().overlayLayer.appendChild(this.elem);
  }
}
stv.Tag.prototype.draw = function(){
  var projection = this.inspect_projection(700, 400);

  this.elem.style.left = projection.left + 'px';
  this.elem.style.top  = projection.top + 'px';
  //this.elem.style['fontSize'] = (pov.zoom * 10) + 'pt';
}
stv.Tag.prototype.inspect_projection = function(disp_x, disp_y){
  /*
  var pos = new google.maps.LatLng(this.lat, this.lng);
  var proj = this.getProjection();
  var point = proj.fromLatLngToDivPixel(pos);
  */

  var pov = stvmap.stv.getPov();
  var pos = stvmap.stv.getPosition();
  var camera = {
    head: pov.heading,
    pitch: pov.pitch,
    zoom: pov.zoom,
    lat:  pos.lat(),
    lng:  pos.lng()
  };
  console.log([camera.head, camera.pitch, camera.zoom, camera.lat, camera.lng]);

  //head  = 0 - 360..
  //pitch = -90 - 0 - 90
  //zoom  = 1, 2, 3, ...
  //lat   = North .... Sounth
  //lng   = West ..... East

  //rad = (degree / 360) * (Math.PI * 2);
  //deg = (rad / (Math.PI * 2)) * 360;

  var pow = function(x){ return x * x; }

  //Kakudo //////////////////////////////////////////
  var diff_lat = this.lat - camera.lat;
  var diff_lng = this.lng - camera.lng;

  var tan = diff_lat / diff_lng;
  var digree = (Math.atan(tan) / (2 * Math.PI)) * 360;

  //Kyori ///////////////////////////////////////////
  var kyori = Math.sqrt( pow(diff_lat) + pow(diff_lng) );

  //Camera //////////////////////////////////////////
  var diff_head  = digree - camera.head;
  var diff_pitch = -1 * (-20 - camera.pitch);

  var max_kyori = 0.0001;

  var max_gakaku_x = 45;
  var max_gakaku_y = 30;

  var gakaku_hi_x = (disp_x / 2) / max_gakaku_x;
  var gakaku_hi_y = (disp_y / 2) / max_gakaku_y;

  var left = gakaku_hi_x * diff_head;
  var top  = gakaku_hi_y * diff_pitch;

  return {left: left, top: top};
}

//---------------------------------------
stv.Map = function(map_elem, stv_elem){
  this.map_elem = map_elem;
  this.stv_elem = stv_elem;
}
stv.Map.prototype.init = function(){
  var fenway = new google.maps.LatLng(35.69, 139.698699);

  this.map = new google.maps.Map(this.map_elem, {
    center: fenway,
    zoom: 10,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    streetViewControl: true
  });

  this.stv = new google.maps.StreetViewPanorama(this.stv_elem, {
    position: fenway,
    pov: {
      heading: 0,
      pitch: 10,
      zoom: 1
    }
  });
  this.map.setStreetView(this.stv);
}


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
  var pos = new google.maps.LatLng(this.lat, this.lng);
  var proj = this.getProjection();
  var point = proj.fromLatLngToDivPixel(pos);

  var pov = stvmap.stv.getPov();
  console.log(pov);

  this.elem.style.left = pov.heading + 'px';
  this.elem.style.top  = pov.pitch + 'px';
  this.elem.style['fontSize'] = (pov.zoom * 10) + 'pt';
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

